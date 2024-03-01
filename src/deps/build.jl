function ensure_qiskit_installed()
    if !("qiskit" in Conda.list())
        Conda.add("qiskit")
    end
end

function main()
    pyversion = PyCall.python
    println("Using Python at: $pyversion")

    Conda.add(["qiskit", "qiskit-ibm-runtime", "qiskit-ibm-provider"])

end

main()
