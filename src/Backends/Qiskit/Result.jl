# abstract type Result end

# struct QiskitResult <: Result
#     python_interface::PythonCall.Py
#     function QiskitResult(python_interface::PythonCall.Py)
#         _checkinit_qiskit()
#         new(python_interface)
#     end
# end

struct QiskitResult <: MQC.Result
    measurementOutcomes::Matrix{Bool}
    measuredQubits::Vector{Int}
    nativeResult::PythonCall.Py

    function QiskitResult(nativeResult::PythonCall.Core.Py, circuit::MQC.Circuit)
        _checkinit_qiskit()
        nMeasurements = MQC.nMeasurements(circuit)
        bitstrings = PythonCall.pyconvert(Vector{String}, nativeResult.data.c.get_bitstrings())
        measurementOutcomes = hcat(map(s -> [c == '1' for c in s], bitstrings)...)


        measuredQubits = zeros(Int, nMeasurements)
        new(measurementOutcomes, measuredQubits, nativeResult)
    end
end

function Base.show(io::IO, ::MIME"text/plain", obj::QiskitResult)
    print(io, obj.measurementOutcomes)
end


# function QiskitResult(Backend::Type{AerSimulator}, python_interface::PythonCall.Py)
#     return MonitoredQuantumCircuits.Result{Backend,PythonCall.Py}(zeros(Bool, 3, 3), zeros(Int, 3), python_interface)
# end
