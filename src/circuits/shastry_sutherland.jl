#old
function MeasurementOnlyShastrySutherland(geometry::ShastrySutherlandGeometry{Periodic}, px::Float64, py::Float64, pz::Float64; depth::Real=100, purify::Bool=false)
    circuit = Circuit(geometry)
    if purify
        for position in eachcol(bonds(geometry; type=:HORIZONTAL))
            apply!(circuit, XX(), position...)
        end
        for position in eachcol(bonds(geometry; type=:VERTICAL))
            apply!(circuit, ZZ(), position...)
        end
        x_loop = loops(geometry; type=:HORIZONTAL)[:, 1]
        apply!(circuit, NPauli(X(), length(x_loop)), x_loop...)
    end

    randomPartityMeasurement = RandomOperation()
    push!(randomPartityMeasurement, XX(), bonds(geometry; type=:HORIZONTAL); probability=px)
    push!(randomPartityMeasurement, YY(), bonds(geometry; type=:DIAGONAL); probability=py)
    push!(randomPartityMeasurement, ZZ(), bonds(geometry; type=:VERTICAL); probability=pz)
    for _ in 1:round(Int64, depth * nQubits(geometry))
        apply!(circuit, randomPartityMeasurement)
    end

    return circuit
end
