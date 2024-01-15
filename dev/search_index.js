var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = KIRO2023","category":"page"},{"location":"#KIRO2023","page":"Home","title":"KIRO2023","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for KIRO2023.","category":"page"},{"location":"#Parsing-functions","page":"Home","title":"Parsing functions","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package exports the three following parsing functions:","category":"page"},{"location":"","page":"Home","title":"Home","text":"read_instance: read an instance file from its path and returns a corresponding Instance object.\nread_solution: write a Solution object to a solution format json file.\nwrite_solution: read a solution file into a Solution object.","category":"page"},{"location":"#Data-structures","page":"Home","title":"Data structures","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Instance\nSolution","category":"page"},{"location":"","page":"Home","title":"Home","text":"Note: you may want to implement your own custom data structures that contain additional information that may be used by your algorithms.","category":"page"},{"location":"#Evaluation-utilities","page":"Home","title":"Evaluation utilities","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"is_feasible: function that tests if a solution is feasible for a given instance\ncost, operational_cost, construction_cost: functions that computes the cost of a solution for given instance","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"#API","page":"Home","title":"API","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [KIRO2023]","category":"page"},{"location":"#KIRO2023.Instance","page":"Home","title":"KIRO2023.Instance","text":"Instance\n\nInstance data structure.\n\n\n\n\n\n","category":"type"},{"location":"#KIRO2023.Solution","page":"Home","title":"KIRO2023.Solution","text":"Solution\n\nSolution data structure.\n\n\n\n\n\n","category":"type"},{"location":"#KIRO2023.compute_probabilities_of_failure-Tuple{Solution, Instance}","page":"Home","title":"KIRO2023.compute_probabilities_of_failure","text":"Return a probability of failure for each substation in solution\n\n\n\n\n\n","category":"method"},{"location":"#KIRO2023.construction_cost-Tuple{Solution, Instance}","page":"Home","title":"KIRO2023.construction_cost","text":"construction cost\n\n\n\n\n\n","category":"method"},{"location":"#KIRO2023.cost-Tuple{Solution, Instance}","page":"Home","title":"KIRO2023.cost","text":"cost(solution::Solution, instance::Instance)\n\nCompute the objective value of solution for given instance.\n\n\n\n\n\n","category":"method"},{"location":"#KIRO2023.is_feasible-Tuple{Solution, Instance}","page":"Home","title":"KIRO2023.is_feasible","text":"is_feasible(solution::Solution, instance::Instance; verbose=true)\n\nCheck if solution is feasible for instance. Prints some warnings when solution is infeasible and verbose is true.\n\n\n\n\n\n","category":"method"},{"location":"#KIRO2023.operational_cost-Tuple{Solution, Instance, Any, Any}","page":"Home","title":"KIRO2023.operational_cost","text":"operational cost\n\n\n\n\n\n","category":"method"},{"location":"#KIRO2023.read_instance-Tuple{String}","page":"Home","title":"KIRO2023.read_instance","text":"read_instance(path::String)\n\nRead instance from json file path.\n\n\n\n\n\n","category":"method"},{"location":"#KIRO2023.read_solution","page":"Home","title":"KIRO2023.read_solution","text":"read_solution(path::String, instance=nothing)\n\nRead solution from json file path.\n\nwarning: Warning\nWe recommend giving the associated Instance as the (optional) second input in order for the parser to infer correctly the number of station locations in the instance.\n\n\n\n\n\n","category":"function"},{"location":"#KIRO2023.write_solution-Tuple{Solution, String}","page":"Home","title":"KIRO2023.write_solution","text":"write_solution(solution::Solution, path::String)\n\nWrite solution to file path with json format.\n\n\n\n\n\n","category":"method"}]
}
