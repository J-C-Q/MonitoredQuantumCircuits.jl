using MonitoredQuantumCircuits
using Test
using Aqua

@testset "MonitoredQuantumCircuits.jl" begin
    # @testset "Code quality (Aqua.jl)" begin
    #     Aqua.test_all(MonitoredQuantumCircuits)
    # end

    # Write your tests here.
    @testset "functionality" begin
        token = "24519c61427d7a80665a014a79f7adbba12955cee6b72e48e3c09cb445e06aee1f43248cb2fd0ac4bada1e4d5ff6567eb61419eb95e569255ca37e57adcc6d73"

        circuit = GeneralQuantumCircuit([PauliX(), Hadamard(), ControlledX(), ProjectiveMeasurement()], [[1], [1, 2], [2]], [2, 3, 4], LinearRegister(2))
        println(to_Qobj(circuit))
        # println(IBMQdevices(token)[end])
        # IBMQrun(to_Qobj(circuit), "ibm_osaka", token)
        # println(IBMQjobs(token))
    end

end
