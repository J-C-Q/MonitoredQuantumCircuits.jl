using JET
using MonitoredQuantumCircuits
using Test
using Aqua


@testset "MonitoredQuantumCircuits.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(MonitoredQuantumCircuits)
    end
    @testset "Code quality (JET.jl)" begin
        JET.test_package(MonitoredQuantumCircuits, target_defined_modules = true)
    end
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

end
