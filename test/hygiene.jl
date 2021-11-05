module Hygiene

using Test

import VecMathOptInterface
const MOI = VecMathOptInterface

# Dict is used in the @model macro but setting Dict in the outer scope
# should not affect it
Dict = nothing

VecMathOptInterface.Utilities.@model(
    LPModel,                      # Name of model
    (),                                                         # untyped scalar sets
    (MOI.EqualTo, MOI.GreaterThan, MOI.LessThan, MOI.Interval), #   typed scalar sets
    (MOI.Zeros, MOI.Nonnegatives, MOI.Nonpositives),            # untyped vector sets
    (),                                                         #   typed vector sets
    (),                                                         # untyped scalar functions
    (MOI.ScalarAffineFunction,),                                #   typed scalar functions
    (MOI.VectorOfVariables,),                                   # untyped vector functions
    (MOI.VectorAffineFunction,)
)                                #   typed vector functions

model = LPModel{Float64}()

@test model isa VecMathOptInterface.ModelLike
@test model isa VecMathOptInterface.Utilities.AbstractModel{Float64}

end
