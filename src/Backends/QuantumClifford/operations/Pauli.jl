function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    P::MonitoredQuantumCircuits.MnPauli{N},
    p::Vararg{Int,N};
    keep_result=true,
    ancilla=aux(backend),  # Default to the number of qubits + ancillas + 1
    kwargs...) where N

    options = ((true, false), (true, true), (false, true))
    operator = backend.operator
    QC.zero!(operator)

    for (i, parameter) in enumerate(P.memory)
        operator[p[i]] = options[parameter]
    end
    if keep_result
        _, res = QC.projectrand!(backend.state, operator)
        res = Bool(res/2)
        push!(backend.measurements, res)
        push!(backend.measured_qubits, ancilla)
    else
        QC.project!(backend.state, operator)
        res = false
    end
    return res
end

function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    P::MonitoredQuantumCircuits.MnPauli{N},
    p::SubArray;
    keep_result=true,
    ancilla=aux(backend),  # Default to the number of qubits + ancillas + 1
    kwargs...) where N

    options = ((true, false), (true, true), (false, true))
    operator = backend.operator
    QC.zero!(operator)

    for (i, parameter) in enumerate(P.memory)
        operator[p[i]] = options[parameter]
    end
    if keep_result
        _, res = QC.projectrand!(backend.state, operator)
        res = Bool(res/2)
        push!(backend.measurements, res)
        push!(backend.measured_qubits, ancilla)
    else
        QC.project!(backend.state, operator)
        res = false
    end
    return res
end


# function MonitoredQuantumCircuits.apply!(
#     backend::TableauSimulator,
#     P::MonitoredQuantumCircuits.MnPauli{N},
#     p::Vector{Int};
#     keep_result=true,
#     ancilla=aux(backend),  # Default to the number of qubits + ancillas + 1
#     kwargs...) where N

#     options = ((true, false), (true, true), (false, true))
#     operator = backend.operator
#     QC.zero!(operator)

#     for (i, parameter) in enumerate(P.memory)
#         operator[p[i]] = options[parameter]
#     end
#     if keep_result
#         _, res = QC.projectrand!(backend.state, operator)
#         res = Bool(res/2)
#         push!(backend.measurements, res)
#         push!(backend.measured_qubits, ancilla)
#     else
#         QC.project!(backend.state, operator)
#         res = false
#     end
#     return res
# end
