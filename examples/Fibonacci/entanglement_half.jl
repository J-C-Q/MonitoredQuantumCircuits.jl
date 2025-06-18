using MonitoredQuantumCircuits
import Statistics
import UUIDs
import JLD2
import ProgressMeter
function simulate(path::String; depth=15, L=128, averaging=10000, resolution=24)

    # define the p values to sample
    rg = (1+sqrt(5))/2
    left = 1/(1+rg)
    right = (1+rg)^2/2rg - sqrt(((1+rg)^2/2rg)^2 - (1+rg)/rg)
    points = range(left, right+0.01, resolution)

    # construct the geometry
    geometry = ChainGeometry(Open, L)

    # create the progress meter
    progressMeter = ProgressMeter.Progress(length(points) * averaging; dt=1.0)

    # simulate the circuit for each probability point
    Threads.@threads for p in points

        # construct circuit and simulator
        circuit = compile(MeasurementOnlyFibonacciDrive(geometry, p; depth))
        sim = QuantumClifford.TableauSimulator(nQubits(geometry); mixed=false, basis=:X)

        entropies = zeros(averaging)
        for i in 1:averaging
            result = execute(circuit, sim)
            entropies[i] = QuantumClifford.entanglement_entropy(result.stab, 1:L÷2)
            ProgressMeter.next!(progressMeter)
        end
        average = sum(entropies) / averaging
        error = Statistics.std(entropies) / sqrt(averaging)
        JLD2.save(
            "$path/L$(L)_D$(depth)/ENTh_avg$(averaging)_p$(p)_$(UUIDs.uuid4().value).jld2",
            "probability", p,
            "entanglement", average,
            "error", error,
            "depth", depth,
            "system_size", L,
            "samples", averaging)
    end
end
