function apply!(
    register::QC.Register,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.Measure_Z,
    p::SubArray)

    _, res = QC.projectZrand!(register, p[1])
    push!(register.bits, res / 2)
end
