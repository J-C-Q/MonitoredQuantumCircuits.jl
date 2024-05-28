struct Qubit
    qiskit_qubit::Py
    function Qubit(qubit::Qubit)
        return new(qubit.qiskit_qubit)
    end
end
