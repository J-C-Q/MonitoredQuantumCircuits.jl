abstract type Result end

struct QiskitResult <: Result
    python_interface::PythonCall.Py
    function QiskitResult(python_interface::PythonCall.Py)
        _checkinit_qiskit()
        new(python_interface)
    end
end
