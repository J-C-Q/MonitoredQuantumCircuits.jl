using Distributed;
using SharedArrays;
addprocs(6);
# List of all worker IDs
worker_ids = workers()
using MonitoredQuantumCircuits
# Load the package on each worker one by one
for wid in worker_ids
    @eval @everywhere if myid() == $wid
        using MonitoredQuantumCircuits
    end
    sleep(1)
end

using ProgressMeter
using JLD2




function generateData(; grain=0.1, shots=10000)
    lattice = HeavyHexagonLattice(6, 4)
    backend = Stim.CompileSimulator()
    points = NTuple{3,Float64}[]

    for i in 0:grain:1
        for j in i:grain:1
            px = i
            py = j - i
            pz = 1 - j
            push!(points, (px, py, pz))
        end
    end

    tmis = SharedVector{Float64}(length(points))
    @showprogress @distributed for i in 1:length(points)
        px, py, pz = points[i]
        circuit = KitaevCircuit(lattice, px, py, pz, 24^2)

        result = execute(circuit, backend; shots, verbose=false)

        bits = result[end-MonitoredQuantumCircuits.nQubits(lattice)+1:end]

        tripartiteInformation = Analysis.TMI(bits, [1, 2, 7, 8, 13, 14, 19, 20], [3, 4, 9, 10, 15, 16, 21, 22], [5, 6, 11, 12, 17, 18, 23, 24])

        tmis[i] = tripartiteInformation
    end

    # wait(collect(Dagger.@spawn))
    JLD2.@save "tmis.jld2" tmis points
end




generateData(; grain=0.05, shots=100000)
