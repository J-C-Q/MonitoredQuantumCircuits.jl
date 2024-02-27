# using Yao
# using IBMQClient
# cphase(i, j) = control(i, j => shift(2π / (2^(i - j + 1))));
# hcphases(n, i) = chain(n, i == j ? put(i => H) : cphase(j, i) for j in i:n);
# qft(n) = chain(hcphases(n, i) for i in 1:n)
# rand_state(3) |> qft(3) |> measure

using IBMQClient
using IBMQClient.Schema
account = AccountInfo("24519c61427d7a80665a014a79f7adbba12955cee6b72e48e3c09cb445e06aee1f43248cb2fd0ac4bada1e4d5ff6567eb61419eb95e569255ca37e57adcc6d73")


qobj = Qobj(;
    qobj_id="bell_Qobj_07272018",
    type="QASM",
    schema_version=v"1",
    header=Dict("description" => "Bell states"),
    config=ExpConfig(shots=1000, memory_slots=2),
    experiments=[
        Experiment(;
            header=Dict("description" => "|11>+|00> Bell"),
            instructions=[
                Gate(name="u2", qubits=[0], params=[0.0, π]),
                Gate(name="cx", qubits=[0, 1]),
                Measure(qubits=[0, 1], memory=[0, 1]),
            ]
        ),
        Experiment(;
            header=Dict("description" => "|01>+|10> Bell"),
            instructions=[
                Gate(name="u2", qubits=[0], params=[0.0, π]),
                Gate(name="cx", qubits=[0, 1]),
                Gate(name="u3", qubits=[0], params=[π, 0.0, π]),
                Measure(qubits=[0, 1], memory=[0, 1]),
            ]
        )
    ]
)

qobj2 = IBMQClient.Schema.Qobj("test_id", "QASM", v"1.0.0", IBMQClient.Schema.Experiment[IBMQClient.Schema.Experiment(nothing, nothing, IBMQClient.Schema.Instruction[IBMQClient.Schema.Gate("u2", [0], [0.0, 3.141592653589793], nothing, nothing), IBMQClient.Schema.Gate("cu1", [1, 0], [1.5707963267948966], nothing, nothing), IBMQClient.Schema.Gate("cu1", [2, 0], [0.7853981633974483], nothing, nothing), IBMQClient.Schema.Gate("u2", [1], [0.0, 3.141592653589793], nothing, nothing), IBMQClient.Schema.Gate("cu1", [2, 1], [1.5707963267948966], nothing, nothing), IBMQClient.Schema.Gate("u2", [2], [0.0, 3.141592653589793], nothing, nothing)])], nothing, IBMQClient.Schema.ExpConfig(1024, 1, nothing, nothing, nothing))

devices = [device.backend_name for device in IBMQClient.devices(account)]

job_info = IBMQClient.submit(account, RemoteJob(dev=devices[end-2]), qobj2)

job_info = IBMQClient.status(account, job_info)

result_info = IBMQClient.results(account, job_info)

result_info.results[1]

IBMQClient.status(account, job_info).job_id
