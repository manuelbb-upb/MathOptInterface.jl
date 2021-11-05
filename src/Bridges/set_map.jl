"""
    map_set(::Type{BT}, set) where {BT}

Return the image of `set` through the linear map `A` defined in
[`Variable.SetMapBridge`](@ref) and [`Constraint.SetMapBridge`](@ref). This is
used for bridging the constraint and setting
the [`VecMathOptInterface.ConstraintSet`](@ref).
"""
function map_set end

"""
    inverse_map_set(::Type{BT}, set) where {BT}

Return the preimage of `set` through the linear map `A` defined in
[`Variable.SetMapBridge`](@ref) and [`Constraint.SetMapBridge`](@ref). This is
used for getting the [`VecMathOptInterface.ConstraintSet`](@ref).
"""
function inverse_map_set end

"""
    map_function(::Type{BT}, func) where {BT}

Return the image of `func` through the linear map `A` defined in
[`Variable.SetMapBridge`](@ref) and [`Constraint.SetMapBridge`](@ref). This is
used for getting the [`VecMathOptInterface.ConstraintPrimal`](@ref) of variable
bridges. For constraint bridges, this is used for bridging the constraint,
setting the [`VecMathOptInterface.ConstraintFunction`](@ref) and
[`VecMathOptInterface.ConstraintPrimalStart`](@ref) and
modifying the function with [`VecMathOptInterface.modify`](@ref).

    map_function(::Type{BT}, func, i::IndexInVector) where {BT}

Return the scalar function at the `i`th index of the vector function that
would be returned by `map_function(BT, func)` except that it may compute the
`i`th element. This is used by [`bridged_function`](@ref) and for getting
the [`VecMathOptInterface.VariablePrimal`](@ref) and
[`VecMathOptInterface.VariablePrimalStart`](@ref) of variable bridges.
"""
function map_function end

function map_function(::Type{BT}, func, i::IndexInVector) where {BT}
    return MOIU.eachscalar(map_function(BT, func))[i.value]
end

"""
    inverse_map_function(::Type{BT}, func) where {BT}

Return the image of `func` through the inverse of the linear map `A` defined in
[`Variable.SetMapBridge`](@ref) and [`Constraint.SetMapBridge`](@ref). This is
used by [`Variable.unbridged_map`](@ref) and for setting the
[`VecMathOptInterface.VariablePrimalStart`](@ref) of variable bridges
and for getting the [`VecMathOptInterface.ConstraintFunction`](@ref),
the [`VecMathOptInterface.ConstraintPrimal`](@ref) and the
[`VecMathOptInterface.ConstraintPrimalStart`](@ref) of constraint bridges.
"""
function inverse_map_function end

"""
    adjoint_map_function(::Type{BT}, func) where {BT}

Return the image of `func` through the adjoint of the linear map `A` defined in
[`Variable.SetMapBridge`](@ref) and [`Constraint.SetMapBridge`](@ref). This is
used for getting the [`VecMathOptInterface.ConstraintDual`](@ref) and
[`VecMathOptInterface.ConstraintDualStart`](@ref) of constraint bridges.
"""
function adjoint_map_function end

"""
    inverse_adjoint_map_function(::Type{BT}, func) where {BT}

Return the image of `func` through the inverse of the adjoint of the linear map
`A` defined in [`Variable.SetMapBridge`](@ref) and
[`Constraint.SetMapBridge`](@ref). This is used for getting the
[`VecMathOptInterface.ConstraintDual`](@ref) of variable bridges and setting the
[`VecMathOptInterface.ConstraintDualStart`](@ref) of constraint bridges.
"""
function inverse_adjoint_map_function end
