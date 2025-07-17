# function apply!(
#     register::QC.Register,
#     ::TableauSimulator,
#     ::MonitoredQuantumCircuits.Measure_Z,
#     p::SubArray)

#     _, res = QC.projectZrand!(register, p[1])
#     push!(register.bits, res / 2)
# end

function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.Measure_Z,
    p::Integer;
    keep_result=true)

    if keep_result
        _, res = QC.projectZrand!(backend.state, p)
        res = Bool(res/2)
        push!(backend.measurements, res)
    else
        QC.projectZ!(backend.state, p; keep_result)
        res = false
    end
    return res
end
