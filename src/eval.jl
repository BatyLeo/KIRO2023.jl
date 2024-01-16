"""
    is_feasible(solution::Solution, instance::Instance; verbose=true)

Check if `solution` is feasible for `instance`.
Prints some warnings when solution is infeasible and `verbose` is `true`.
"""
function is_feasible(solution::Solution, instance::Instance; verbose=true)
    (; substations, inter_station_cables, turbine_links) = solution

    # Check that the inter station cables matrix is symmetric
    if !LinearAlgebra.issymmetric(inter_station_cables)
        verbose && @warn "The inter station cables matrix is not symmetric"
        return false
    end

    # Check that all turbines are in the solution
    if nb_turbines(instance) != length(turbine_links)
        verbose && @warn "Not all turbines are in the solution."
        return false
    end

    # x[i] == 1 if substation i is built
    x = falses(nb_station_locations(instance))
    for v in substations
        x[v.id] = true
    end

    # Check cables between stations
    for v₁ in 1:nb_station_locations(instance)
        for v₂ in 1:nb_station_locations(instance)
            if inter_station_cables[v₁, v₂] > 0
                if !x[v₁] || !x[v₂]
                    verbose && @warn(
                        "Cable between substation $v₁ and $v₂, at least one is not built.",
                    )
                    return false
                end
            end
        end
    end

    # Check that at most one inter station cable connected to each station
    for v₁ in 1:nb_station_locations(instance)
        if @views sum(inter_station_cables[v₁, :] .> 0) > 1
            verbose && @warn("More than one inter station cable connected to station $v₁.")
            return false
        end
    end

    # Check that each turbine is connected to an existing substation
    for (i, v) in enumerate(turbine_links)
        if !x[v]
            verbose && @warn "Turbine $i connected to unbuilt substation."
            return false
        end
    end
    return true
end

"""
construction cost
"""
function construction_cost(solution::Solution, instance::Instance)
    (; turbine_links, inter_station_cables, substations) = solution

    total = 0.0
    # substation construction
    for substation in substations
        v = id(substation)
        s = substation_type(substation)
        q = land_cable_type(substation)

        # add cost of substation and cost of land cable
        total += substation_cost(instance, s) + land_cable_cost(instance, v, q)
    end

    # Inter station cables
    for v₁ in 1:nb_station_locations(instance)
        for v₂ in (v₁+1):nb_station_locations(instance)
            if inter_station_cables[v₁, v₂] > 0
                q = inter_station_cables[v₁, v₂]
                total += inter_station_cable_cost(instance, v₁, v₂, q)
            end
        end
    end

    # Add turbine-station cable costs
    for (t, v) in enumerate(turbine_links)
        total += turbine_cable_cost(instance, v, t)
    end

    return total
end

function compute_probability_of_failure(substation::SubStation, instance::Instance)
    # probability of failure of cable + probability of failure of station
    return instance.substation_types[substation.substation_type].probability_of_failure +
           instance.land_substation_cable_types[substation.land_cable_type].probability_of_failure
end

"""
Return a probability of failure for each substation in solution
"""
function compute_probabilities_of_failure(solution::Solution, instance::Instance)
    return [
        compute_probability_of_failure(substation, instance) for
        substation in solution.substations
    ]
end

"""
operational cost
"""
function operational_cost(solution::Solution, instance::Instance, scenario, p_fail)
    (; substations, inter_station_cables, turbine_links) = solution

    total = 0.0

    # number of turbines connected to each substation
    nb_connected_turbines = zeros(nb_station_locations(instance))
    for v in turbine_links
        nb_connected_turbines[v] += 1
    end

    no_failure_cost = 0.0
    for (pf, substation) in zip(p_fail, substations)
        v = id(substation)
        s = substation_type(substation)
        q = land_cable_type(substation)

        T = nb_connected_turbines[v]

        Pw = power_generation(instance, scenario)
        @assert Pw <= instance.maximum_power

        # No failure cost
        # =total power - minus capacity/rating between substation and land cable
        rs = substation_rating(instance, s)
        rq = land_cable_rating(instance, q)
        no_failure_cost += max(Pw * T - min(rs, rq), 0.0)

        # Under failure cost
        under_failure_cost = Pw * T  # full cost if no link to another substation
        if sum(@view inter_station_cables[v, :]) > 0 # linked_to_another(substation)
            v_other = argmax(@view inter_station_cables[v, :]) # linked_substation(substation)

            other_substation = solution.substations[findfirst(
                x -> x.id == v_other, solution.substations
            )]

            rs_other = substation_rating(instance, substation_type(other_substation))
            rq_other = land_cable_rating(instance, land_cable_type(other_substation))
            rq_link = inter_substation_cable_rating(
                instance, inter_station_cables[v, v_other]
            )

            under_failure_cost -= rq_link
            # @show under_failure_cost rq_link Pw * T v v_other
            under_failure_cost = max(under_failure_cost, 0.0)

            T_other = nb_connected_turbines[v_other]
            under_failure_cost += max(
                Pw * T_other + min(rq_link, Pw * T) - min(rs_other, rq_other), 0.0
            )
        end
        total += pf * full_cost(instance, under_failure_cost)
    end
    total += (1 - sum(p_fail)) * full_cost(instance, no_failure_cost)
    return total
end

function operational_cost(solution::Solution, instance::Instance)
    p_fail = compute_probabilities_of_failure(solution, instance)
    return sum(
        ω.probability * operational_cost(solution, instance, i, p_fail) for
        (i, ω) in enumerate(instance.wind_scenarios)
    )
end

"""
    cost(solution::Solution, instance::Instance)

Compute the objective value of `solution` for given `instance`.
"""
function cost(solution::Solution, instance::Instance)
    return construction_cost(solution, instance) + operational_cost(solution, instance)
end
