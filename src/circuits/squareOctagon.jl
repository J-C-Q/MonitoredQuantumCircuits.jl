#old
function MeasurementOnlySquareOctagon(geometry::SquareOctagonGeometry{Periodic}, px::Float64, py::Float64, pz::Float64; depth::Integer=100)
    circuit = Circuit(geometry)

    randomPartityMeasurement = RandomOperation()
    push!(randomPartityMeasurement, XX(), MonitoredQuantumCircuits.bondsX(geometry); probability=px)
    push!(randomPartityMeasurement, YY(), MonitoredQuantumCircuits.bondsY(geometry); probability=py)
    push!(randomPartityMeasurement, ZZ(), MonitoredQuantumCircuits.bondsZ(geometry); probability=pz)
    for i in 1:depth*nQubits(geometry)
        apply!(circuit, randomPartityMeasurement)
    end

    return circuit
end
