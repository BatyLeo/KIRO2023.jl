```@meta
CurrentModule = KIRO2023
```

# KIRO2023

Documentation for [KIRO2023](https://github.com/BatyLeo/KIRO2023.jl).

## Parsing functions

This package exports the three following parsing functions:
- [`read_instance`](@ref): read an instance file from its path and returns a corresponding `Instance` object.
- [`read_solution`](@ref): write a `Solution` object to a solution format json file.
- [`write_solution`](@ref): read a solution file into a `Solution` object.

## Data structures

- [`Instance`](@ref)
    - Methods `nb_tasks`, `nb_operators`, `nb_jobs`, `nb_machines` can be used to query instance parameters.
- [`Solution`](@ref)

Note: you may want to implement your own custom data structures that contain additional information that may be used by your algorithms.

## Evaluation utilities
- [`is_feasible`](@ref): function that tests if a solution is feasible for a given instance
- [`cost`](@ref): function that computes the cost of a solution for given instance

---

# API

```@index
```

```@autodocs
Modules = [KIRO2023]
```
