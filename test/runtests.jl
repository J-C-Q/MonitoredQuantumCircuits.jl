using MonitoredQuantumCircuits
using Test
using Aqua

@testset "MonitoredQuantumCircuits.jl" begin
    # @testset "Code quality (Aqua.jl)" begin
    #     Aqua.test_all(MonitoredQuantumCircuits)
    # end
    @testset "Operations" begin
        # @test ZZ() == ZZ()
        # @test MonitoredQuantumCircuits.nQubits(ZZ()) == 3
        # @test MonitoredQuantumCircuits.isClifford(ZZ()) == true
        # # @test qiskitRepresentation(ZZ()) === nothing

        # @test XX() == XX()
        # @test MonitoredQuantumCircuits.nQubits(XX()) == 3
        # @test MonitoredQuantumCircuits.isClifford(XX()) == true
        # # @test qiskitRepresentation(XX()) === nothing

        # @test YY() == YY()
        # @test MonitoredQuantumCircuits.nQubits(YY()) == 3
        # @test MonitoredQuantumCircuits.isClifford(YY()) == true
        # # @test qiskitRepresentation(YY()) === nothing
    end
    @testset "Lattice" begin
        # @test MonitoredQuantumCircuits.getBonds(ChainLattice(3)) == [(1, 2), (2, 3)]
        # @test MonitoredQuantumCircuits.getBonds(SquareLattice(2, 2)) == [(1, 3), (1, 2), (2, 4), (3, 4)]
    end

    @testset "QuantumClifford" begin
        g = HoneycombGeometry(Periodic, 2, 2)
        c = MeasurementOnlyKitaev(g, 1 / 3, 1 / 3, 1 / 3; depth=10)
        comp = compile(c)
        sim = QuantumClifford.TableauSimulator(nQubits(g))
        result = execute(comp, sim)
        println(result)
    end
end
