# function depth(::MonitoredQuantumCircuits.CNOT, ::Type{QuantumCircuit})
#     return 1
# end


function apply!(qc::Circuit, ::MQC.CNOT, p1::Integer, p2::Integer)
    qc.cx(p1 - 1, p2 - 1)
end
# function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.CNOT, step::Integer, p1::Integer, p2::Integer)
#     apply!(qc, MonitoredQuantumCircuits.CNOT(), Val(step), p1, p2)
# end
# function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.CNOT, ::Val{1}, p1::Integer, p2::Integer)
#     qc.cx(p1 - 1, p2 - 1)
# end
