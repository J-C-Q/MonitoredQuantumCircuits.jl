

struct Qubit
    qiskit_qubit::Py
    function Qubit(qubit::Py)
        if pyisinstance(qubit, qiskit.circuit.quantumregister.Qubit)
            return new(qubit)
        else
            throw(ArgumentError("The input must be a qiskit.circuit.quantumregister.Qubit"))
        end
    end
end
Base.show(io::IO, ::MIME"text/plain", obj::Qubit) = print(io, obj.qiskit_qubit)

function _qiskitqubit_to_Qubit(S::Type, x::Py)
    PythonCall.Convert.pyconvert_return(Qubit(x))
end

function _qiskitqubit_list_to_Qubit_vector(S::Type, x::Py)
    PythonCall.Convert.pyconvert_return([Qubit(q) for q in x])
end
