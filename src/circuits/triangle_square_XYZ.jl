function MeasurementOnlyTriangleSquareXYZ(geometry::TriangleSquareGeometry{Periodic}, px::Float64, py::Float64, pz::Float64; depth::Integer=100)
    circuit = Circuit(geometry)

    randomPartityMeasurement = RandomOperation()
    push!(randomPartityMeasurement, XX(), bonds(geometry; type=:HORIZONTAL); probability=px)
    push!(randomPartityMeasurement, YY(), bonds(geometry; type=:DIAGONAL); probability=py)
    push!(randomPartityMeasurement, ZZ(), bonds(geometry; type=:VERTICAL); probability=pz)
    for i in 1:depth*nQubits(geometry)
        apply!(circuit, randomPartityMeasurement)
    end

    return circuit
end
