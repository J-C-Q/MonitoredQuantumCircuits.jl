include("./util/fastYY.jl")
function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.YY,
    p1::Integer,
    p2::Integer;
    keep_result=true,
    kwargs...)

    if keep_result
        _, res = projectYYrand!(backend.state, p1, p2)
        res = Bool(res / 2)
        push!(backend.measurements, res)
    else
        projectYY!(backend.state, p1, p2; keep_result)
        res = false
    end
    return res
end
