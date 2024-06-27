using MonitoredQuantumCircuits
using Test
using Aqua

@testset "MonitoredQuantumCircuits.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(MonitoredQuantumCircuits)
    end
    @testset "Operations" begin
        @test ZZ() == ZZ()
        @test nQubits(ZZ()) == 2
        @test isClifford(ZZ()) == true
        @test qiskitRepresentation(ZZ()) === nothing

        @test XX() == XX()
        @test nQubits(XX()) == 2
        @test isClifford(XX()) == true
        @test qiskitRepresentation(XX()) === nothing

        @test YY() == YY()
        @test nQubits(YY()) == 2
        @test isClifford(YY()) == true
        @test qiskitRepresentation(YY()) === nothing
    end
    @testset "Lattice" begin
        @test getBonds(ChainLattice(3)) = [(1, 2), (2, 3)]
        @test getBonds(SquareLattice(2, 2)) = [(1, 2), (1, 3), (2, 4), (3, 4)]
    end
end
