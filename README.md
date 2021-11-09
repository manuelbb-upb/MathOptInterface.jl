# VecMathOptInterface
### MathOptInterface with Multiple Objectives

The main idea of this fork is to explore the possibility of treating objective functions 
similar to constraints.
It is motivated by [this issue](https://github.com/jump-dev/JuMP.jl/issues/2099) regarding multi-objective
optimization in `MathOptInterface` (and possibly `JuMP`).
As you can read in that conversation, there are basically two ways to go:
* [Perform a 1 line change](https://github.com/jump-dev/JuMP.jl/issues/2099#issuecomment-562414044) to enable 
  `AbstractVectorFunction`s as objectives.
* Or, do what I am trying here, which involves some major changes to the inner architecture (outlined below). 
Unfamiliar then with the inner workings of MOI, I opted for treating multiple objectives separately.
This is certainly overkill for multi-objective linear or quadratic optimization (I realize now) but could come in handy with nonlinear objectives (and when JuMP is adapted).

#### What is new?

* Objectives are meant to be added via `add_objective`. 
* To provide some backwards compatibility with the old `set` routine, old types are kept for now and new types 
  are prefixed with `Goal` instead of `Objective`.
* Just like constraints, objectives now have an index type `GoalIndex{F,S}` where `F<:AbstractFunction` and `S<:OptimSense`.
* There is an abstract super type `OptimSense` with subtypes `MinSense, MaxSense, FeasibiltiySense`. 
  These are meant to replace `OptimizationSense` and are to objectives what sets are to constraints.
* There are many new attributes, both `AbstractModelAttribute`s and `AbstractGoalAttribute`s.

#### What is next?
I am currently trying to understand how bridging works. 
Bridges for individual objectives should open up many interesting possibilities, but for now I would be content with flipping signs and transforming a minimization problem into a maximization problem.

## Links and Information for the Original Package

| **Documentation** | **Build Status** | **Social** |
|:-----------------:|:----------------:|:----------:|
| [![][docs-stable-img]][docs-stable-url] [![][docs-dev-img]][docs-dev-url] | [![Build Status][build-img]][build-url] [![Codecov branch][codecov-img]][codecov-url] | [![Gitter][gitter-img]][gitter-url] [<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Discourse_logo.png/799px-Discourse_logo.png" width="64">][discourse-url] |

An abstraction layer for mathematical optimization solvers. Replaces [MathProgBase](https://github.com/JuliaOpt/MathProgBase.jl).

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-stable-url]: http://jump.dev/MathOptInterface.jl/stable
[docs-dev-url]: http://jump.dev/MathOptInterface.jl/dev

[build-img]: https://github.com/JuMP-dev/MathOptInterface.jl/workflows/CI/badge.svg?branch=master
[build-url]: https://github.com/JuMP-dev/MathOptInterface.jl/actions?query=workflow%3ACI
[codecov-img]: http://codecov.io/github/JuMP-dev/MathOptInterface.jl/coverage.svg?branch=master
[codecov-url]: http://codecov.io/github/JuMP-dev/MathOptInterface.jl?branch=master

[gitter-url]: https://gitter.im/JuliaOpt/JuMP-dev?utm_source=share-link&utm_medium=link&utm_campaign=share-link
[gitter-img]: https://badges.gitter.im/JuliaOpt/JuMP-dev.svg
[discourse-url]: https://discourse.julialang.org/c/domain/opt

## Citing MathOptInterface

If you find MathOptInterface useful in your work, we kindly request that you cite the
following [paper](https://pubsonline.informs.org/doi/10.1287/ijoc.2021.1067):
```bibtex
@article{legat2021mathoptinterface,
    title={{MathOptInterface}: a data structure for mathematical optimization problems},
    author={Legat, Beno{\^\i}t and Dowson, Oscar and Garcia, Joaquim Dias and Lubin, Miles},
    journal={INFORMS Journal on Computing},
    year={2021},
    doi={10.1287/ijoc.2021.1067},
    publisher={INFORMS}
}
```
A preprint of this paper is [freely available](https://arxiv.org/abs/2002.03447). 
