struct StimResult <: MonitoredQuantumCircuits.Result
    measurementOutcomes::Matrix{Bool}
    measuredQubits::Vector{Int}
    nativeResult::PythonCall.Py

    function StimResult(nativeResult::PythonCall.Core.Py, circuit::MonitoredQuantumCircuits.Circuit)
        _checkinit_stim()
        nMeasurements = MonitoredQuantumCircuits.nMeasurements(circuit)
        measurementOutcomes = zeros(Bool, length(nativeResult), nMeasurements)
        for (i, shot) in enumerate(nativeResult)
            measurementOutcomes[i, :] .= PythonCall.pyconvert(Vector{Bool}, shot)
        end
        measuredQubits = zeros(Int, nMeasurements)
        new(measurementOutcomes, measuredQubits, nativeResult)
    end
end

function Base.show(io::IO, ::MIME"text/plain", obj::StimResult)
    print(io, obj.measurementOutcomes)
end
