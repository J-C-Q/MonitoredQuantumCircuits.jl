function apply!(
    register::QC.Register,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.Measure_X,
    p::SubArray)

    _, res = QC.projectXrand!(register, p[1])
    push!(register.bits, res / 2)
end
