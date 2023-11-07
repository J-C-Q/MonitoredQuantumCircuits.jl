using MonitoredQuantumCircuits
using Test
using Aqua

@testset "MonitoredQuantumCircuits.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(MonitoredQuantumCircuits)
    end
    # Write your tests here.
end
