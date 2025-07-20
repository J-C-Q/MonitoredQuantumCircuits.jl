using MonitoredQuantumCircuits
import JLD2
import ProgressMeter
function simulate(path::String; depth=100, L=12, averaging=10, resolution=100, boundary=Open)

    # points = point_distribution(resolution; ratio_in_high_density_region=0.7, high_density_center=0.39, high_density_width=0.1)
    points = point_distribution(resolution; ratio_in_high_density_region=0.7, high_density_center=0.43, high_density_width=0.15)


    geometry = ChainGeometry(boundary, L)
    progressMeter = ProgressMeter.Progress(length(points) * averaging; dt=1.0)
    Threads.@threads for p in points
        circuit = compile(MeasurementOnlyFibonacciDrive(geometry, p; depth))

        sim = QuantumClifford.TableauSimulator(nQubits(geometry); mixed=false, basis=:X)
        entropies = zeros(L + 1)
        for _ in 1:averaging
            result = execute(circuit, sim)
            for i in 0:L
                entropies[i+1] += QuantumClifford.entanglement_entropy(result.stab, 1:i)
            end
            ProgressMeter.next!(progressMeter)
        end
        entropies ./= averaging
        JLD2.save(
            "$path/$(L)_$(depth)/ENT_L=$(L)_averaging=$(averaging)_p=$(p)_depth=$(depth).jld2",
            "entropies", entropies, "p", p)
    end
end


function point_distribution(n; ratio_in_high_density_region=0.5, high_density_center=0.3, high_density_width=0.1)
    d = ratio_in_high_density_region / 2high_density_width
    a = high_density_center
    b = high_density_width
    equal_points = range(0, 1, n)
    f1(x) = (a - b) / (-b * d + a) * x
    f2(x) = 1 / d * (x - a) + a

    f3(x) = (1 - a - b) / (1 - d * b - a) * (x - b * d - a) + a + b

    cross12 = (-a / d + a) / ((a - b) / (-b * d + a) - 1 / d)
    cross23 = ((1 - a - b) / (1 - b * d - a) * (b * d + a) - b - a / d) / ((1 - a - b) / (1 - d * b - a) - 1 / d)
    f(x) = x < cross12 ? f1(x) : x < cross23 ? f2(x) : f3(x)
    return [f(x) for x in equal_points]
end
