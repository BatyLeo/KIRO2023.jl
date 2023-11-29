"""
    read_instance(path::String)

Read instance from json file `path`.
"""
function read_instance(path::String)
    # ! ids need to be are ordered, if not this will fail
    @assert endswith(path, ".json")

    data = JSON.parsefile(path)

    parameters_data = data["general_parameters"]
    curtailing_cost = parameters_data["curtailing_cost"]
    curtailing_penalty = parameters_data["curtailing_penalty"]
    fixed_cost_cable = parameters_data["fixed_cost_cable"]
    maximum_curtailing = parameters_data["maximum_curtailing"]
    maximum_power = parameters_data["maximum_power"]
    variable_cost_cable = parameters_data["variable_cost_cable"]
    land_data = parameters_data["main_land_station"]
    land = Location(0, land_data["x"], land_data["y"])

    land_substation_cable_types_data = data["land_substation_cable_types"]
    land_substation_cable_types = [
        CableType(;
            id=cable["id"],
            fixed_cost=cable["fixed_cost"],
            probability_of_failure=cable["probability_of_failure"],
            rating=cable["rating"],
            variable_cost=cable["variable_cost"],
        ) for cable in land_substation_cable_types_data
    ]

    substation_locations_data = data["substation_locations"]
    substation_locations = [
        Location(station["id"], station["x"], station["y"]) for
        station in substation_locations_data
    ]

    substation_substation_cable_types_data = data["substation_substation_cable_types"]
    substation_substation_cable_types = [
        CableType(;
            id=cable["id"],
            fixed_cost=cable["fixed_cost"],
            probability_of_failure=-1,
            rating=cable["rating"],
            variable_cost=cable["variable_cost"],
        ) for cable in substation_substation_cable_types_data
    ]

    substation_types_data = data["substation_types"]
    substation_types = [
        SubStationType(;
            id=station["id"],
            cost=station["cost"],
            probability_of_failure=station["probability_of_failure"],
            rating=station["rating"],
        ) for station in substation_types_data
    ]

    wind_scenarios_data = data["wind_scenarios"]
    wind_scenarios = [
        WindScenario(;
            id=scenario["id"],
            power_generation=scenario["power_generation"],
            probability=scenario["probability"],
        ) for scenario in wind_scenarios_data
    ]

    wind_turbines_data = data["wind_turbines"]
    wind_turbines = [
        Location(turbine["id"], turbine["x"], turbine["y"]) for
        turbine in wind_turbines_data
    ]

    return Instance(;
        curtailing_cost,
        curtailing_penalty,
        fixed_cost_cable,
        maximum_curtailing,
        maximum_power,
        variable_cost_cable,
        land,
        substation_locations,
        substation_types,
        wind_turbines,
        land_substation_cable_types,
        substation_substation_cable_types,
        wind_scenarios,
    )
end

"""
    read_solution(path::String)

Read solution from json file `path`.
"""
function read_solution(path::String, instance=nothing)
    @assert endswith(path, ".json")

    data = JSON.parsefile(path)

    substations_data = data["substations"]
    cable_data = data["substation_substation_cables"]
    turbines_data = data["turbines"]

    substations = [
        SubStation(;
            id=s["id"],
            substation_type=s["substation_type"],
            land_cable_type=s["land_cable_type"],
        ) for s in substations_data
    ]
    n = if isnothing(instance)
        maximum(x -> x.id, substations)
    else
        nb_station_locations(instance)
    end
    inter_station_cables = zeros(Int, n, n)
    for c in cable_data
        i = c["substation_id"]
        j = c["other_substation_id"]
        q = c["cable_type"]
        inter_station_cables[i, j] = q
        inter_station_cables[j, i] = q
    end
    turbine_links = zeros(length(turbines_data))
    for t in turbines_data
        turbine_links[t["id"]] = t["substation_id"]
    end
    return Solution(; turbine_links, inter_station_cables, substations)
end

"""
    write_solution(solution::Solution, path::String)

Write `solution` to file `path` with json format.
"""
function write_solution(solution::Solution, path::String)
    @assert endswith(path, ".json")

    (; turbine_links, inter_station_cables, substations) = solution
    data = Dict()
    data["turbines"] = []
    data["substations"] = []
    data["substation_substation_cables"] = []
    for (id, t) in enumerate(turbine_links)
        push!(data["turbines"], Dict("id" => id, "substation_id" => t))
    end
    for s in substations
        push!(
            data["substations"],
            Dict(
                "id" => s.id,
                "land_cable_type" => s.land_cable_type,
                "substation_type" => s.substation_type,
            ),
        )
    end
    n = size(inter_station_cables, 1)
    for i in 1:n
        for j in (i + 1):n
            if inter_station_cables[i, j] > 0
                push!(
                    data["substation_substation_cables"],
                    Dict(
                        "substation_id" => i,
                        "other_substation_id" => j,
                        "cable_type" => inter_station_cables[i, j],
                    ),
                )
            end
        end
    end
    open(path, "w") do f
        JSON.print(f, data)
    end
end
