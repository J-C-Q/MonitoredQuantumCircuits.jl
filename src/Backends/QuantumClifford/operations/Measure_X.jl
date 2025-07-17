# function apply!(
#     register::QC.Register,
#     ::TableauSimulator,
#     ::MonitoredQuantumCircuits.Measure_X,
#     p::SubArray)

#     _, res = QC.projectXrand!(register, p[1])
#     push!(register.bits, res / 2)
# end

function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.Measure_X,
    p::Integer;
    keep_result=true)

    if keep_result
        _, res = QC.projectXrand!(backend.state, p)
        res = Bool(res/2)
        push!(backend.measurements, res)
    else
        QC.projectX!(backend.state, p; keep_result)
        res = false
    end
    return res
end
