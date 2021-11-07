# this is copied and adapted from `constraints.jl`
"""
    supports_objective( model::ModelLike, 
		::Type{F})::Bool where {F<MOI.AbstractFunction}

Return a `Bool` indicating whether `model` generally supports adding an objective 
of type `F`.
That is, `copy_to(model, src)` does not throw [`UnsupportedObjective`](@ref) when
`src` contains objectives of type `F`.
"""
function supports_objective(
    ::ModelLike,
    ::Type{<:AbstractFunction},
	::Type{<:OptimSense}
)
    return false
end

# This function first checks, if `model`
# implements the old (single objective) interface 
# and `supports` both `func` and `sense`.
function supports_objective_fallback(
	model :: ModelLike,
	func :: F, 
	sense :: S) where{F<:AbstractFunction,S<:OptimSense}
	if supports( model, ObjectiveFunction(), func ) && 
		supports( model, ObjectiveSense, optimization_sense(sense) )
		return true
	end
	return supports_objective( model, F, S)
end

"""
    struct UnsupportedObjective{F<:MOI.AbstractFunction}
        message::String # Human-friendly explanation why the attribute cannot be set
    end

An error indicating that objectives of type `F` are not supported by
the model, i.e. that [`supports_constraint`](@ref) returns `false`.
"""
struct UnsupportedObjective{F<:AbstractFunction,S<:OptimSense} <: UnsupportedError
    message::String # Human-friendly explanation why the attribute cannot be set
end
UnsupportedObjective{F,S}() where {F,S} = UnsupportedObjective{F,S}("")

function element_name(::UnsupportedObjective{F,S}) where {F,S}
    return "`$F-$S` objective"
end

"""
    struct AddObjectiveNotAllowed{F<:AbstractFunction} <: NotAllowedError
        message::String # Human-friendly explanation why the attribute cannot be set
    end
An error indicating that objectives of type `F` are supported (see
[`supports_objective`](@ref)) but cannot be added.
"""
struct AddObjectiveNotAllowed{F<:AbstractFunction, S<:OptimSense} <:
       NotAllowedError
    message::String # Human-friendly explanation why the attribute cannot be set
end
AddObjectiveNotAllowed{F,S}() where {F,S} = AddConstraintNotAllowed{F,S}("")

function operation_name(::AddObjectiveNotAllowed{F,S}) where {F,S}
    return "Adding `$F-$S` objectives."
end

"""
    add_objective(model::ModelLike, func::F, sense::S)::ObjectiveIndex{F,S} where {F,S}

Add the objective ``f: ℝⁿ → ℝᵏ`` to `model`, where ``f`` is defined by `func` and
`sense` is the optimization sense.

* An [`UnsupportedObjective`](@ref) error is thrown if `model` does not support
  `F`-objectives.
* a [`AddObjectiveNotAllowed`](@ref) error is thrown if it supports `F`-objectives  
  but it cannot add the objectives(s) in its current state.
"""

function add_objective(
    model::ModelLike,
    func::AbstractFunction
	sense::OptimSense
)

	try 
		num_objfs = get( model, MaxOutputs() )	# if this fails, then the model implements the old interface
	catch ArgumentError
		if supports_objective_fallback(model, func, sense)
			set(model, ObjectiveFunction(), func )
			set(model, ObjectiveSense(), sense)
		end
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
    add_objectives(model::ModelLike, funcs::Vector{F}, senses::Vector{S})::Vector{ObjectiveIndex{F,S}} where {F,S}

Add the set of objectives specified by each function-sense pair in `funcs` and `sets`. 
`F` and `S` should be concrete types.
This call is equivalent to `add_constraint.(model, funcs, sets)` but may be more efficient.
"""
function add_objectives end

# default fallback
function add_objectives(model::ModelLike, funcs, senses)
    return add_objective.(model, funcs, sets)
end
