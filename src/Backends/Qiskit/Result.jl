abstract type Result end

struct QiskitResult <: Result
    python_interface::Py
    function QiskitResult(python_interface::Py)
        _checkinit_qiskit()
        new(python_interface)
    end
end
