using MonitoredQuantumCircuits
using Test
using Aqua

# @testset "MonitoredQuantumCircuits.jl" begin
#     # @testset "Code quality (Aqua.jl)" begin
#     #     Aqua.test_all(MonitoredQuantumCircuits)
#     # end

#     # Write your tests here.
#     @testset "functionality" begin
#         # token = "24519c61427d7a80665a014a79f7adbba12955cee6b72e48e3c09cb445e06aee1f43248cb2fd0ac4bada1e4d5ff6567eb61419eb95e569255ca37e57adcc6d73"

#         # circuit = GeneralQuantumCircuit([PauliX(), Hadamard(), ControlledX(), ProjectiveMeasurement()], [[1], [1, 2], [2]], [2, 3, 4], LinearRegister(2))
#         # println(to_Qobj(circuit))
#         # println(IBMQdevices(token))
#         # IBMQrun(to_Qobj(circuit), "ibm_osaka", token)
#         # println(IBMQjobs(token))

#         # circuit = QiskitQuantumCircuit(2, 2)


#         # circuit.qc.p(0.1253, 0)
#         # circuit.qc.measure([0, 1], [0, 1])

#         # # QiskitPrint(circuit)


#         # # println(string(circuit.qc.draw())[10:end])



#         # IBMQ_osaka = IBMQChip("osaka", "24519c61427d7a80665a014a79f7adbba12955cee6b72e48e3c09cb445e06aee1f43248cb2fd0ac4bada1e4d5ff6567eb61419eb95e569255ca37e57adcc6d73")
#         # qiskitTranspile(circuit, IBMQ_osaka)

#         # println(randomCircuit(IBMQ_osaka, 10))
#         # println(nishimori(IBMQ_osaka))
#         # QiskitPrint(circuit)

#         # IBMQRun(circuit, IBMQ_osaka)
#         # runOpenQASM("""OPENQASM 2.0;
#         # include "qelib1.inc";

#         # qreg q[2];
#         # creg c[1];
#         # x q[0];
#         # measure q[0] -> c[0];""")


#         # itensorTest()
#         token = "24519c61427d7a80665a014a79f7adbba12955cee6b72e48e3c09cb445e06aee1f43248cb2fd0ac4bada1e4d5ff6567eb61419eb95e569255ca37e57adcc6d73"
#         GLMakiePrint(nishimori_on_Eagler3_1D(token), IBMQChip("brisbane", token))

#     end

# end

token = "24519c61427d7a80665a014a79f7adbba12955cee6b72e48e3c09cb445e06aee1f43248cb2fd0ac4bada1e4d5ff6567eb61419eb95e569255ca37e57adcc6d73"
GLMakiePrint(nishimori_on_Eagler3_1D(token), IBMQChip("brisbane", token))
