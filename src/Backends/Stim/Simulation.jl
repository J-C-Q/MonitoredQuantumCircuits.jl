
struct CompileSimulator <: MonitoredQuantumCircuits.Simulator
    function CompileSimulator()
        _checkinit_stim()
        return new()
    end
end

function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, ::CompileSimulator; shots=1024, verbose::Bool=true)
    verbose && print("Transpiling circuit to Stim...")
    qc = MonitoredQuantumCircuits.translate(StimCircuit, circuit)
    verbose && println("✓")

    verbose && print("Initializing compile sampler...")
    sampler = CompileSampler(qc)
    verbose && println("✓")

    verbose && print("Simulating circuit...")
    # stimResult = PythonCall.pyconvert(Vector{Vector{Bool}}, sample(sampler; shots))
    result = sample(sampler; shots)
    # result = MonitoredQuantumCircuits.SampleResult(hcat(stimResult...), zeros(Int64, length(stimResult)))

    verbose && println("✓")
    stimResult = StimResult(result, circuit)
    return stimResult
end

struct TableauSimulator <: MonitoredQuantumCircuits.Simulator
    function TableauSimulator()
        _checkinit_stim()
        return new(stim.TableauSimulator())
    end
end

function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, ::TableauSimulator; shots=1024, verbose::Bool=true)
    verbose && print("Transpiling circuit to Stim...")
    qc = MonitoredQuantumCircuits.translate(StimCircuit, circuit)
    verbose && println("✓")

    # verbose && print("Initializing tableau sampler...")
    # sampler = TableauSampler(qc)
    # verbose && println("✓")
    simulator = TableauSampler()

    verbose && print("Simulating circuit...")
    simulator.do_circuit(qc.python_interface)

    verbose && println("✓")
    return qc.to_inverse_tableau()
end
