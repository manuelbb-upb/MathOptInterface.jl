# Most functions here are copied and adapted from `constraints.jl`
"""
    supports_objective( model::ModelLike, 
		::Type{F})::Bool where {F<MOI.AbstractFunction}

Return a `Bool` indicating whether `model` generally supports adding an objective 
of type `F`.
That is, `copy_to(model, src)` does not throw [`UnsupportedGoal`](@ref) when
`src` contains objectives of type `F`.
"""
function supports_objective(
		::ModelLike,
		::Type{F},
		::Type{S}
	) where{F<:AbstractFunction, S<:OptimSense}
	if !(is_multi_model(model))
		return supports_single_objective(model,F,S)
	end
    return false
end

# this is a helper function to be used if `!(is_multi_model(model))`
# to check whether model supports F-S objectives via the "old" interface
function supports_single_objective( 
	model :: ModelLike,
	::Type{F},
	::Type{S} ) where{F<:AbstractFunction, S<:OptimSense}
	return(
		supports(model, ObjectiveFunction{F}()) && 
		supports(model, ObjectiveSense(), _optimization_sense(S))
	)
end

"""
    struct UnsupportedGoal{F<:MOI.AbstractFunction}
        message::String # Human-friendly explanation why the attribute cannot be set
    end

An error indicating that objectives of type `F` are not supported by
the model, i.e. that [`supports_constraint`](@ref) returns `false`.
"""
struct UnsupportedGoal{F<:AbstractFunction,S<:OptimSense} <: UnsupportedError
    message::String # Human-friendly explanation why the attribute cannot be set
end
UnsupportedGoal{F,S}() where {F,S} = UnsupportedGoal{F,S}("")

function element_name(::UnsupportedGoal{F,S}) where {F,S}
    return "`$F-$S` objective"
end

"""
    struct AddGoalNotAllowed{F<:AbstractFunction} <: NotAllowedError
        message::String # Human-friendly explanation why the attribute cannot be set
    end
An error indicating that objectives of type `F` are supported (see
[`supports_objective`](@ref)) but cannot be added.
"""
struct AddGoalNotAllowed{F<:AbstractFunction, S<:OptimSense} <:
       NotAllowedError
    message::String # Human-friendly explanation why the attribute cannot be set
end
AddGoalNotAllowed{F,S}() where {F,S} = AddConstraintNotAllowed{F,S}("")

function operation_name(::AddGoalNotAllowed{F,S}) where {F,S}
    return "Adding `$F-$S` objectives."
end

"""
    add_objective(model::ModelLike, func::F, sense::S)::GoalIndex{F,S} where {F,S}

Add the objective ``f: ℝⁿ → ℝᵏ`` to `model`, where ``f`` is defined by `func` and
`sense` is the optimization sense.

* An [`UnsupportedGoal`](@ref) error is thrown if `model` does not support
  `F`-objectives.
* a [`AddGoalNotAllowed`](@ref) error is thrown if it supports `F`-objectives  
  but it cannot add the objectives(s) in its current state.
"""

function add_objective(
		model::ModelLike,
		func::F,
		sense::S
	) where {F<:AbstractFunction,S<:OptimSense}

	if !(is_multi_model(model)) 
		if supports_single_objective(model, F, S)
			set(model, ObjectiveFunction(), func )
			set(model, ObjectiveSense(), sense)
		end
		return GoalIndex{F,S}(-1)
	end		

	return throw_add_objective_error_fallback(model, func, sense)    
end

# if the model generally supports the objective type, 
# then throw `error_if_supported` to indicate that currently
# it is not possible to add it.
# else throw `UnsupportedObjective(F)`.
function throw_add_objective_error_fallback(
	model::ModelLike,
	func::F,
	sense::S;
	error_if_supported = AddObjectiveNotAllowed{F,S}(),
) where {F<:AbstractFunction, S<:OptimSense}
    if supports_objective(model, F, S)
        throw(error_if_supported)
    else
        throw(UnsupportedObjective{F,S}())
    end
end

"""
    add_objectives(model::ModelLike, funcs::Vector{F}, senses::Vector{S})::Vector{GoalIndex{F,S}} where {F,S}

Add the set of objectives specified by each function-sense pair in `funcs` and `sets`. 
`F` and `S` should be concrete types.
This call is equivalent to `add_constraint.(model, funcs, sets)` but may be more efficient.
"""
function add_objectives end

# default fallback
function add_objectives(model::ModelLike, funcs, senses)
    return add_objective.(model, funcs, sets)
end
 
# default fallback
function transform(model::ModelLike, o::GoalIndex, new_sense)
    f = get(model, GoalFunction(), o)
    delete(model, o)
    return add_objective(model, f, new_sense)
end
