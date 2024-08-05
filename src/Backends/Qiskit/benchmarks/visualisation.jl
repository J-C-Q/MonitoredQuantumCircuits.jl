using CairoMakie
using BenchmarkTools
using JLD2
function visualizeBenchmark()
    title = L"$$QiskitAer cuStateVec random circuit simulation"
    CairoMakie.activate!(type="svg")

    fig = Figure(fontsize=12, size=72 .* (5, 4), title=title)
    # Label(fig[1, 1:2, Top()], L"$$\textbf{QiskitAer cuStateVec random circuit simulation}", font=:bold, justification=:left, valign=:bottom, padding=(0, 35, 5, 0))

    ax = Axis(fig[1, 1],
        title=L"$$\textbf{Random monitored circuit simulation}",
        subtitle=L"$$Qiskit Aer with cuStateVec",
        subtitlesize=10,
        xlabel=L"$$measurement probability",
        ylabel=L"$$speedup $\left(\frac{\mathrm{Ramses\,time}}{\mathrm{GH200\,time}}\right)$",
        titlealign=:left,
        xticksmirrored=true,
        yticksmirrored=true,
        xtickalign=1,
        ytickalign=1,
        spinewidth=1.5,
        xtickwidth=1.5,
        ytickwidth=1.5,
        yticksize=6,
        xticksize=6,
        xgridvisible=false,
        ygridvisible=false,
        # yscale=log,
        limits=(0, 1, 0.9, 3.5),
        yticks=[1, 2, 3],
        xminorticksvisible=true,
        yminorticksvisible=true,
        xminortickalign=1,
        yminortickalign=1,
        xminorticksize=4,
        yminorticksize=4,
        xminortickwidth=1.5,
        yminortickwidth=1.5,
        xminorticks=IntervalsBetween(5),
        yminorticks=IntervalsBetween(10),
        xtickformat=values -> [L"$$%$(round(Int,value*100))%" for value in values],
        ytickformat=values -> [L"$$%$(round(Int,value))" for value in values]
    )

    colors = [:blue, :red, :green, :yellow, :purple, :orange, :brown, :pink, :gray, :black]
    markers = [:circle, :rect, :star5, :diamond, :hexagon, :cross, :xcross, :utriangle, :dtriangle, :star4]

    num_qubits = [5, 10, 15, 20]
    depths = [5, 10]
    measure_probs = 0.0:0.1:1.0
    devices_names = ["GH200", "Ramses"]#, "Thp"]
    depth = 10
    # for (i, device) in enumerate(devices_names)
    #     for qubits in num_qubits
    #         file = jldopen("src/Qiskit/benchmarks/Benchmark" * device * ".jld2", "r")
    #         benchmarks = [read(file, "$depth/$m/$qubits/benchmark") for m in measure_probs]
    #         close(file)
    #         scatterlines!(ax, measure_probs, [median(b.times) / 1e9 for b in benchmarks], color=(colors[i], qubits / 10), markersize=10, marker=:circle, strokewidth=1.2, label=device)
    #     end
    # end


    for qubits in reverse(num_qubits)
        file1 = jldopen("src/Qiskit/benchmarks/Benchmark" * devices_names[1] * ".jld2", "r")

        benchmarks1 = [read(file1, "$depth/$m/$qubits/benchmark") for m in measure_probs]
        close(file1)
        file2 = jldopen("src/Qiskit/benchmarks/Benchmark" * devices_names[2] * ".jld2", "r")
        benchmarks2 = [read(file2, "$depth/$m/$qubits/benchmark") for m in measure_probs]
        close(file2)
        means1 = [median(b.times) / 1e9 for b in benchmarks1]
        means2 = [median(b.times) / 1e9 for b in benchmarks2]
        speedup = means2 ./ means1

        # errorbars!(ax, measure_probs, speedup, lowerrors, higherrors,
        # whiskerwidth = 10)

        if qubits == maximum(num_qubits)
            scatterlines!(ax, measure_probs, speedup, markercolor=(:orange), markersize=7, color=:black, marker=:circle, strokewidth=1.2, label=L"$$%$qubits", linestyle=Linestyle([0, qubits / 9, 2 * qubits / 9]), transparency=false)
        else
            scatterlines!(ax, measure_probs, speedup, markercolor=(:white), markersize=7, color=:black, marker=:circle, strokewidth=1.2, label=L"$$%$qubits", linestyle=Linestyle([0, qubits / 9, 2 * qubits / 9]), transparency=false)
        end

    end
    # axislegend(ax, position=:rb, fontsize=10, horizontal=true)
    leg = Legend(fig[1, 2], ax, L"$$\textbf{Qubits}", framevisible=false, padding=(0, 0, 0, 0))


    # TotalNs = []
    # elements = []
    # for (i, device_name) in enumerate(devices_names)
    #     file = jldopen(name * "_" * device_name * ".jld2", "r")
    #     elem = [PolyElement(color=colors[i], strokecolor=:black, strokewidth=0.7)]
    #     push!(elements, elem)
    #     # file = jldopen(name*_devices_names[1], "r")
    #     Ns = read(file, "Ns")
    #     benchmarks = [read(file, "$N/benchmark") for N in Ns]
    #     close(file)
    #     violin!(
    #         ax,
    #         vcat(
    #             [fill(log2(N), length(benchmark.times)) for (N, benchmark) in zip(Ns, benchmarks)]...
    #         ),
    #         vcat([log10.(benchmark.times ./ 1e9) for benchmark in benchmarks]...),
    #         color=(colors[i], 0.9),
    #         scale=:width,
    #         width=2,
    #         side=:left,
    #         strokewidth=0.7,
    #         strokecolor=:black,
    #         label=device_name,)


    #     translate!(scatter!(ax, log2.(Ns), [median(log10.(benchmarks[i].times ./ 1e9)) for i in 1:length(Ns)], color=colors[i], markersize=10, marker=markers[i], strokewidth=1.2, label=device_name), 0, 0, 100)
    #     append!(TotalNs, Ns)
    # end
    # translate!(vlines!(ax, [log2(N) for N in unique(TotalNs)], color=:black, linewidth=1.5), 0, 0, -100)
    # axislegend(ax, position=:rt, fontsize=10)
    # Legend(fig[2, 1], elements, [L"$$%$devices_name" for devices_name in devices_names], tellwidth=false, orientation=:horizontal)
    save("Benchmark.pdf", fig, pt_per_unit=1)
    fig


end

visualizeBenchmark()
