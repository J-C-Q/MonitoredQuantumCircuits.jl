function apply!(
    register::QC.Register,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.Measure_Y,
    p::SubArray)

    _, res = QC.projectYrand!(register, p[1])
    push!(register.bits, res / 2)
end
