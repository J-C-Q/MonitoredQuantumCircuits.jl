# function depth(::MonitoredQuantumCircuits.Measure, ::Type{QuantumCircuit})
#     return 1
# end


function apply!(qc::Circuit, ::MQC.Measure_Z, clbit::Integer, p::Integer)
    qc.measure(p - 1, clbit - 1)
end
# function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.Measure, step::Integer, clbit::Integer, p::Integer)
#     apply!(qc, MonitoredQuantumCircuits.Measure(), Val(step), clbit, p)
# end
# function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.Measure, ::Val{1}, clbit::Integer, p::Integer)
#     qc.measure(p - 1, clbit - 1)
# end
