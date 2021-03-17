import MathOptInterface
using Test

const MOI = MathOptInterface
const MOIU = MOI.Utilities
const LP = MOI.FileFormats.LP
const LP_TEST_FILE = "test.lp"

@test sprint(show, LP.Model()) == "A .LP-file model"

@testset "write_to_file" begin
    @testset "comprehensive write" begin
        model = LP.Model()
        MOIU.loadfromstring!(
            model,
            """
variables: a, x, y, z
minobjective: x
c1: x >= -1.0
c2: x <= 2.0
c3: y == 3.0
c4: z in Interval(4.0, 5.0)
c5: 1.1x + 0.0 <= 5.1
c6: 1.3x + -1.4 >= -0.1
c7: 1.5a + 1.6 == 0.2
c8: 1.7a + 1.8 in Interval(0.3, 0.4)
c9: x in ZeroOne()
c10: y in Integer()
""",
        )
        MOI.write_to_file(model, LP_TEST_FILE)
        @test read(LP_TEST_FILE, String) ==
              "minimize\n" *
              "obj: x\n" *
              "subject to\n" *
              "c5: 1.1 x <= 5.1\n" *
              "c6: -1.4 + 1.3 x >= -0.1\n" *
              "c7: 1.6 + 1.5 a = 0.2\n" *
              "c8: 0.3 <= 1.8 + 1.7 a <= 0.4\n" *
              "Bounds\n" *
              "x <= 2\n" *
              "x >= -1\n" *
              "y = 3\n" *
              "4 <= z <= 5\n" *
              "a free\n" *
              "General\n" *
              "y\n" *
              "Binary\n" *
              "x\n" *
              "End\n"

        @test !MOI.is_empty(model)
        MOI.empty!(model)
        @test MOI.is_empty(model)
    end
    @testset "Name sanitization" begin
        @testset "Start name sanitisation" begin
            for starting_letter in [".", "0", "E", "e"]
                model = LP.Model()
                MOI.Utilities.loadfromstring!(
                    model,
                    """
variables: x
minobjective: x
c1: 1.0 * x >= -1.0
""",
                )
                x = MOI.get(model, MOI.VariableIndex, "x")
                MOI.set(model, MOI.VariableName(), x, starting_letter * "x")
                c = MOI.get(model, MOI.ConstraintIndex, "c1")
                MOI.set(model, MOI.ConstraintName(), c, starting_letter * "c1")
                MOI.write_to_file(model, LP_TEST_FILE)
                @test read(LP_TEST_FILE, String) ==
                      "minimize\n" *
                      "obj: _$(starting_letter)x\n" *
                      "subject to\n" *
                      "_$(starting_letter)c1: 1 _$(starting_letter)x >= -1\n" *
                      "Bounds\n" *
                      "_$(starting_letter)x free\n" *
                      "End\n"
            end
        end
        @testset "Illegal character sanitisation" begin
            for illegal_letter in ["[", "]", "*", "^"]
                model = LP.Model()
                MOI.Utilities.loadfromstring!(
                    model,
                    """
variables: x
minobjective: x
c1: 1.0 * x >= -1.0
""",
                )
                x = MOI.get(model, MOI.VariableIndex, "x")
                MOI.set(model, MOI.VariableName(), x, "x$(illegal_letter)y")
                c = MOI.get(model, MOI.ConstraintIndex, "c1")
                MOI.set(model, MOI.ConstraintName(), c, "c$(illegal_letter)d")
                MOI.write_to_file(model, LP_TEST_FILE)
                @test read(LP_TEST_FILE, String) ==
                      "minimize\n" *
                      "obj: x_y\n" *
                      "subject to\n" *
                      "c_d: 1 x_y >= -1\n" *
                      "Bounds\n" *
                      "x_y free\n" *
                      "End\n"
            end
        end
        @testset "Duplicate names after sanitization" begin
            model = LP.Model()
            MOI.Utilities.loadfromstring!(
                model,
                """
variables: a, b, c, d
minobjective: a + b + c + d
c1: a + b + c + d >= -1.0
""",
            )
            variables = MOI.get(model, MOI.ListOfVariableIndices())
            MOI.set.(
                model,
                MOI.VariableName(),
                variables,
                ["a[", "a]", "a*", "a^"],
            )
            MOI.write_to_file(model, LP_TEST_FILE)
            @test read(LP_TEST_FILE, String) ==
                  "minimize\n" *
                  "obj: 1 a_ + 1 a__1 + 1 a__2 + 1 a__3\n" *
                  "subject to\n" *
                  "c1: 1 a_ + 1 a__1 + 1 a__2 + 1 a__3 >= -1\n" *
                  "Bounds\n" *
                  "a_ free\n" *
                  "a__1 free\n" *
                  "a__2 free\n" *
                  "a__3 free\n" *
                  "End\n"
        end
        @testset "Length sanitisation" begin
            model = LP.Model(maximum_length = 3)
            x = MOI.add_variable(model)
            MOI.set(model, MOI.VariableName(), x, "abcdefg")
            MOI.set(model, MOI.ObjectiveSense(), MOI.MIN_SENSE)
            MOI.set(
                model,
                MOI.ObjectiveFunction{MOI.SingleVariable}(),
                MOI.SingleVariable(x),
            )
            MOI.write_to_file(model, LP_TEST_FILE)
            @test read(LP_TEST_FILE, String) ==
                  "minimize\n" *
                  "obj: abc\n" *
                  "subject to\n" *
                  "Bounds\n" *
                  "abc free\n" *
                  "End\n"
        end
        @testset "Too long duplicate names after sanitization" begin
            model = LP.Model(maximum_length = 3)
            MOI.Utilities.loadfromstring!(
                model,
                """
variables: abcd, abce
minobjective: abcd + abce
c1: abcd + abce >= -1.0
""",
            )
            MOI.write_to_file(model, LP_TEST_FILE)
            @test read(LP_TEST_FILE, String) ==
                  "minimize\n" *
                  "obj: 1 abc + 1 abc_1\n" *
                  "subject to\n" *
                  "c1: 1 abc + 1 abc_1 >= -1\n" *
                  "Bounds\n" *
                  "abc free\n" *
                  "abc_1 free\n" *
                  "End\n"
        end
    end
    @testset "other features" begin
        model = LP.Model()
        MOIU.loadfromstring!(
            model,
            """
variables: x
maxobjective: 2.0 * x + -1.0
""",
        )
        MOI.write_to_file(model, LP_TEST_FILE)
        @test read(LP_TEST_FILE, String) ==
              "maximize\n" *
              "obj: -1 + 2 x\n" *
              "subject to\n" *
              "Bounds\n" *
              "x free\n" *
              "End\n"
    end
    @testset "free variables" begin
        model = LP.Model()
        MOIU.loadfromstring!(
            model,
            """
variables: x, y, z
maxobjective: x
c1: x in ZeroOne()
c2: y in Integer()
""",
        )
        MOI.write_to_file(model, LP_TEST_FILE)
        @test read(LP_TEST_FILE, String) ==
              "maximize\n" *
              "obj: x\n" *
              "subject to\n" *
              "Bounds\n" *
              "y free\n" *
              "z free\n" *
              "General\n" *
              "y\n" *
              "Binary\n" *
              "x\n" *
              "End\n"
    end
    @testset "Quadratic Objective" begin
        model = LP.Model()
        @test_throws(
            MOI.UnsupportedAttribute,
            MOIU.loadfromstring!(
                model,
                """
    variables: x
    minobjective: 1.0*x*x
    """,
            )
        )
    end
end

@testset "read_from_file" begin
    model = LP.Model()
    exception = ErrorException("read! is not implemented for LP files.")
    @test_throws exception MOI.read_from_file(model, LP_TEST_FILE)
end

# Clean up
sleep(1.0)  # Allow time for unlink to happen.
rm(LP_TEST_FILE, force = true)
