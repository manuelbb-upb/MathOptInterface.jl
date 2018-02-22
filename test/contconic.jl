@testset "Mock optimizer automatic constraint primal" begin
    optimizer = MOIU.MockOptimizer(Model{Float64}())
    config = MOIT.TestConfig()
    optimizer.evalobjective = true

    @testset "Conic linear tests" begin
        optimizer.optimize! = (optimizer::MOIU.MockOptimizer) -> MOIU.mock_optimize!(optimizer, [1.0, 0.0, 2.0],
                              (MOI.VectorOfVariables,             MOI.Nonnegatives) => [[0, 2, 0]],
                              (MOI.VectorAffineFunction{Float64}, MOI.Zeros)        => [[-3, -1]])
        MOIT.lin1vtest(optimizer, config)
        optimizer.optimize! = (optimizer::MOIU.MockOptimizer) -> MOIU.mock_optimize!(optimizer, [1.0, 0.0, 2.0],
                              (MOI.VectorAffineFunction{Float64}, MOI.Nonnegatives) => [[0, 2, 0]],
                              (MOI.VectorAffineFunction{Float64}, MOI.Zeros)        => [[-3, -1]])
        MOIT.lin1ftest(optimizer, config)
        optimizer.optimize! = (optimizer::MOIU.MockOptimizer) -> MOIU.mock_optimize!(optimizer, [-4, -3, 16, 0],
                              (MOI.VectorOfVariables,             MOI.Nonnegatives) => [[0]],
                              (MOI.VectorOfVariables,             MOI.Nonpositives) => [[0]],
                              (MOI.VectorOfVariables,             MOI.Zeros)        => [[7]],
                              (MOI.VectorAffineFunction{Float64}, MOI.Zeros)        => [[7, 2, -4]])
        MOIT.lin2vtest(optimizer, config)
        optimizer.optimize! = (optimizer::MOIU.MockOptimizer) -> MOIU.mock_optimize!(optimizer, [-4, -3, 16, 0],
                              (MOI.VectorAffineFunction{Float64}, MOI.Nonnegatives) => [[0]],
                              (MOI.VectorAffineFunction{Float64}, MOI.Nonpositives) => [[0]],
                              (MOI.VectorAffineFunction{Float64}, MOI.Zeros)        => [[7, 2, -4], [7]])
        MOIT.lin2ftest(optimizer, config)
        optimizer.optimize! = (optimizer::MOIU.MockOptimizer) -> MOIU.mock_optimize!(optimizer)
        MOIT.lin3test(optimizer, config)
        optimizer.optimize! = (optimizer::MOIU.MockOptimizer) -> MOIU.mock_optimize!(optimizer)
        MOIT.lin4test(optimizer, config)
    end
    @testset "Conic SOC tests" begin
        optimizer.optimize! = (optimizer::MOIU.MockOptimizer) -> MOIU.mock_optimize!(optimizer, [1.0, 1/√2, 1/√2],
                              (MOI.VectorOfVariables,             MOI.SecondOrderCone) => [[√2, -1, -1]],
                              (MOI.VectorAffineFunction{Float64}, MOI.Zeros)           => [[-√2]])
        MOIT.soc1vtest(optimizer, config)
        optimizer.optimize! = (optimizer::MOIU.MockOptimizer) -> MOIU.mock_optimize!(optimizer, [1.0, 1/√2, 1/√2],
                              (MOI.VectorAffineFunction{Float64}, MOI.SecondOrderCone) => [[√2, -1, -1]],
                              (MOI.VectorAffineFunction{Float64}, MOI.Zeros)           => [[-√2]])
        MOIT.soc1ftest(optimizer, config)
        optimizer.optimize! = (optimizer::MOIU.MockOptimizer) -> MOIU.mock_optimize!(optimizer, [-1/√2, 1/√2, 1.],
                              (MOI.VectorAffineFunction{Float64}, MOI.SecondOrderCone) => [[√2, 1, -1]],
                              (MOI.VectorAffineFunction{Float64}, MOI.Zeros)           => [[√2]],
                              (MOI.VectorAffineFunction{Float64}, MOI.Nonnegatives)    => [[1.0]])
        MOIT.soc2ntest(optimizer, config)
        optimizer.optimize! = (optimizer::MOIU.MockOptimizer) -> MOIU.mock_optimize!(optimizer, [-1/√2, 1/√2, 1.],
                              (MOI.VectorAffineFunction{Float64}, MOI.SecondOrderCone) => [[√2, 1, -1]],
                              (MOI.VectorAffineFunction{Float64}, MOI.Zeros)           => [[√2]],
                              (MOI.VectorAffineFunction{Float64}, MOI.Nonpositives)    => [[-1.0]])
        MOIT.soc2ptest(optimizer, config)
        optimizer.optimize! = (optimizer::MOIU.MockOptimizer) -> MOIU.mock_optimize!(optimizer)
        MOIT.soc3test(optimizer, config)
        optimizer.optimize! = (optimizer::MOIU.MockOptimizer) -> MOIU.mock_optimize!(optimizer, [1.0, 2/√5, 1/√5, 2/√5, 1/√5],
                              (MOI.VectorAffineFunction{Float64}, MOI.Zeros)           => [[-√5, -2.0, -1.0]],
                              (MOI.VectorOfVariables,             MOI.SecondOrderCone) => [[√5, -2.0, -1.0]])
        MOIT.soc4test(optimizer, config)
    end
    @testset "Conic RSOC tests" begin
        optimizer.optimize! = (optimizer::MOIU.MockOptimizer) -> MOIU.mock_optimize!(optimizer, [1/√2, 1/√2, 0.5, 1.0],
                              (MOI.SingleVariable,                MOI.EqualTo{Float64})       => [-√2, -1/√2],
                              (MOI.VectorOfVariables,             MOI.RotatedSecondOrderCone) => [[√2, 1/√2, -1.0, -1.0]])
        MOIT.rotatedsoc1vtest(optimizer, config)
        optimizer.optimize! = (optimizer::MOIU.MockOptimizer) -> MOIU.mock_optimize!(optimizer, [1/√2, 1/√2],
                              (MOI.VectorAffineFunction{Float64}, MOI.RotatedSecondOrderCone) => [[√2, 1/√2, -1.0, -1.0]])
        MOIT.rotatedsoc1ftest(optimizer, config)
        optimizer.optimize! = (optimizer::MOIU.MockOptimizer) -> MOIU.mock_optimize!(optimizer,
                              (MOI.SingleVariable,                MOI.LessThan{Float64})      => [-1],
                              (MOI.SingleVariable,                MOI.EqualTo{Float64})       => [-1],
                              (MOI.SingleVariable,                MOI.GreaterThan{Float64})   => [1],
                              (MOI.VectorOfVariables            , MOI.RotatedSecondOrderCone) => [[1, 1, -1]])
        MOIT.rotatedsoc2test(optimizer, config)
        n = 2
        ub = 3.0
        optimizer.optimize! = (optimizer::MOIU.MockOptimizer) -> MOIU.mock_optimize!(optimizer, [1.0; zeros(n-1); ub; √ub; ones(2)],
                              (MOI.SingleVariable,                MOI.EqualTo{Float64})       => [-√ub/4, -√ub/4],
                              (MOI.VectorOfVariables,             MOI.Nonnegatives)           => [zeros(n)],
                              (MOI.SingleVariable,                MOI.GreaterThan{Float64})   => [0.0],
                              (MOI.SingleVariable,                MOI.LessThan{Float64})      => [-1/(2*√ub)],
                              (MOI.VectorAffineFunction{Float64}, MOI.RotatedSecondOrderCone) => [[√ub/(2*√2); √ub/(2*√2); -√ub/2; zeros(n-1)], [√ub/√2, 1/√(2*ub), -1.0]])
        MOIT.rotatedsoc3test(optimizer, config)
    end
end
