Base.@kwdef struct Location
    id::Int
    x::Float64
    y::Float64
end

distance(l₁::Location, l₂::Location) = sqrt((l₁.x - l₂.x)^2 + (l₁.y - l₂.y)^2)

Base.@kwdef struct CableType
    id::Int
    rating::Float64
    probability_of_failure::Float64
    fixed_cost::Float64
    variable_cost::Float64
end

Base.@kwdef struct SubStationType
    id::Int
    rating::Float64
    probability_of_failure::Float64
    cost::Float64
end

Base.@kwdef struct WindScenario
    id::Int
    power_generation::Float64
    probability::Float64
end

"""
    Instance

Instance data structure.
"""
Base.@kwdef struct Instance
    fixed_cost_cable::Float64
    variable_cost_cable::Float64
    curtailing_cost::Float64
    curtailing_penalty::Float64
    maximum_curtailing::Float64
    maximum_power::Float64
    land::Location
    substation_locations::Vector{Location}
    substation_types::Vector{SubStationType}
    wind_turbines::Vector{Location}
    land_substation_cable_types::Vector{CableType}
    substation_substation_cable_types::Vector{CableType}
    wind_scenarios::Vector{WindScenario}
end

nb_turbines(instance::Instance) = length(instance.wind_turbines)
nb_scenarios(instance::Instance) = length(instance.wind_scenarios)
nb_station_locations(instance::Instance) = length(instance.substation_locations)

function distance_to_land(instance::Instance, substation_id)
    return distance(instance.land, instance.substation_locations[substation_id])
end

function distance_inter_station(instance::Instance, v₁, v₂)
    return distance(instance.substation_locations[v₁], instance.substation_locations[v₂])
end

function substation_cost(instance, substation_type)
    return instance.substation_types[substation_type].cost
end

function land_cable_cost(instance::Instance, substation_id, cable_id)
    l = distance_to_land(instance, substation_id)
    (; fixed_cost, variable_cost) = instance.land_substation_cable_types[cable_id]
    return linear_cost(fixed_cost, variable_cost, l)
end

function inter_station_cable_cost(
    instance::Instance, substation1_id, substation2_id, cable_type
)
    l = distance_inter_station(instance, substation1_id, substation2_id)
    (; fixed_cost, variable_cost) = instance.substation_substation_cable_types[cable_type]
    return linear_cost(fixed_cost, variable_cost, l)
end

function turbine_cable_cost(instance::Instance, substation_id, turbine_id)
    (; fixed_cost_cable, variable_cost_cable, substation_locations, wind_turbines) =
        instance
    l = distance(substation_locations[substation_id], wind_turbines[turbine_id])
    return linear_cost(fixed_cost_cable, variable_cost_cable, l)
end

function full_cost(instance::Instance, curtailing)
    return instance.curtailing_cost * curtailing +
           instance.curtailing_penalty * max(curtailing - instance.maximum_curtailing, 0.0)
end

function power_generation(instance::Instance, scenario)
    return instance.wind_scenarios[scenario].power_generation
end

function substation_rating(instance::Instance, substation_type)
    return instance.substation_types[substation_type].rating
end

function land_cable_rating(instance::Instance, cable_type)
    return instance.land_substation_cable_types[cable_type].rating
end

function inter_substation_cable_rating(instance::Instance, cable_type)
    return instance.substation_substation_cable_types[cable_type].rating
end
