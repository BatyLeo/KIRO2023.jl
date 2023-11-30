Base.@kwdef struct SubStation
    id::Int
    substation_type::Int
    land_cable_type::Int
end

id(substation::SubStation) = substation.id
substation_type(substation::SubStation) = substation.substation_type
land_cable_type(substation::SubStation) = substation.land_cable_type

"""
    Solution

Solution data structure.
"""
Base.@kwdef struct Solution
    turbine_links::Vector{Int}
    inter_station_cables::Matrix{Int} # [i, j] = 0 if no cable, else cable_id
    substations::Vector{SubStation}
end
