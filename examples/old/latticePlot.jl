using CairoMakie

function plotLattice(lattice::HoneycombGeometry{Periodic})
    fig = Figure()
    ax = Axis(fig[1, 1])

    gridPositions = [(i + j - 1, j + 0.2 * iseven(i) - 0.2 * isodd(i)) for j in 1:lattice.sizeY for i in 1:lattice.sizeX]


    # zcon = Point2f[]
    # for (i,j) in kitaevZ(lattice)
    #     if abs(gridPositions[i][2] -  gridPositions[j][2]) > 1
    #         indboth = [i,j]
    #         both = [gridPositions[i][2],gridPositions[j][2]]
    #         max = argmax(both)
    #         min = argmin(both)
    #         push!(zcon,  gridPositions[indboth[max]])
    #         push!(zcon,  (gridPositions[indboth[min]][1]+lattice.sizeX/2,gridPositions[indboth[min]][2]+lattice.sizeY))
    #         push!(zcon,  gridPositions[indboth[min]])
    #         push!(zcon,  (gridPositions[indboth[max]][1]-lattice.sizeX/2,gridPositions[indboth[max]][2]-lattice.sizeY))
    #     else
    #     push!(zcon,  gridPositions[i])
    #     push!(zcon, gridPositions[j])
    #     end
    # end
    # linesegments!(ax,zcon)

    # xcon = Point2f[]
    # for (i,j) in kitaevX(lattice)
    #     push!(xcon,  gridPositions[i])
    #     push!(xcon, gridPositions[j])
    # end
    # linesegments!(ax,xcon, color=:red)


    # ycon = Point2f[]
    # for (i,j) in kitaevY(lattice)
    #     if abs(gridPositions[i][1] -  gridPositions[j][1]) > 1
    #         indboth = [i,j]
    #         both = [gridPositions[i][1],gridPositions[j][1]]
    #         max = argmax(both)
    #         min = argmin(both)
    #         push!(ycon,  gridPositions[indboth[max]])
    #         push!(ycon,  (gridPositions[indboth[min]][1]+lattice.sizeX,gridPositions[indboth[min]][2]))
    #         push!(ycon,  gridPositions[indboth[min]])
    #         push!(ycon,  (gridPositions[indboth[max]][1]-lattice.sizeX,gridPositions[indboth[max]][2]))
    #     else
    #         push!(ycon,  gridPositions[i])
    #         push!(ycon, gridPositions[j])
    #     end
    # end
    # linesegments!(ax,ycon, color=:green)



    kekX = Point2f[]
    for site in 1:nQubits(lattice)
        push!(kekX, Point2f(gridPositions[site]))
        neighbor = kekuleX_neighbor(lattice, site)
        push!(kekX, Point2f(gridPositions[neighbor]))
    end
    linesegments!(ax, kekX, color=:red)

    kekY = Point2f[]
    for site in 1:nQubits(lattice)
        push!(kekY, Point2f(gridPositions[site]))
        neighbor = kekuleY_neighbor(lattice, site)
        push!(kekY, Point2f(gridPositions[neighbor]))
    end
    linesegments!(ax, kekY, color=:green)

    kekZ = Point2f[]
    for site in 1:nQubits(lattice)
        push!(kekZ, Point2f(gridPositions[site]))
        neighbor = kekuleZ_neighbor(lattice, site)
        push!(kekZ, Point2f(gridPositions[neighbor]))
    end
    linesegments!(ax, kekZ, color=:blue)








    scatter!(ax, Point2f.(gridPositions))
    scatter!(ax, Point2f.([(gp[1] + lattice.sizeX, gp[2]) for gp in gridPositions]), color=:gray)
    scatter!(ax, Point2f.([(gp[1] - lattice.sizeX, gp[2]) for gp in gridPositions]), color=:gray)
    scatter!(ax, Point2f.([(gp[1] + lattice.sizeX / 2, gp[2] + lattice.sizeY) for gp in gridPositions]), color=:gray)
    scatter!(ax, Point2f.([(gp[1] - lattice.sizeX / 2, gp[2] - lattice.sizeY) for gp in gridPositions]), color=:gray)
    scatter!(ax, Point2f.([(gp[1] - 3lattice.sizeX / 2, gp[2] - lattice.sizeY) for gp in gridPositions]), color=:gray)
    scatter!(ax, Point2f.([(gp[1] - lattice.sizeX / 2, gp[2] + lattice.sizeY) for gp in gridPositions]), color=:gray)
    scatter!(ax, Point2f.([(gp[1] + 3lattice.sizeX / 2, gp[2] + lattice.sizeY) for gp in gridPositions]), color=:gray)
    scatter!(ax, Point2f.([(gp[1] + lattice.sizeX / 2, gp[2] - lattice.sizeY) for gp in gridPositions]), color=:gray)

    L = lattice.sizeY
    N = 2L^2
    xsubs = x_subsystems(lattice, N, L)
    scatter!(ax, Point2f.([gridPositions[xsubs[1][i]] for i in 1:N÷4]), color=:red)
    scatter!(ax, Point2f.([gridPositions[xsubs[2][i]] for i in 1:N÷4]), color=:green)
    scatter!(ax, Point2f.([gridPositions[xsubs[3][i]] for i in 1:N÷4]), color=:blue)
    # scatter!(ax, Point2f.(vcat([gridPositions[i:24:end] for i in 1:Int(24/4)]...)), color=:red)
    # scatter!(ax, Point2f.(vcat([gridPositions[i+Int(24/4):24:end] for i in 1:Int(24/4)]...)), color=:blue)
    # scatter!(ax, Point2f.(vcat([gridPositions[i+2Int(24/4):24:end] for i in 1:Int(24/4)]...)), color=:green)

    text!(ax, gridPositions; text=string.(collect(1:length(gridPositions))), fontsize=4, align=(:center, :center))



    limits!(ax, -0.25lattice.sizeX, 1.75lattice.sizeX, -0.5lattice.sizeY, 1.5lattice.sizeY)
    save("lattice.png", fig)

end

function x_subsystems(lattice, N, L)
    quater = N ÷ 4
    chainlength = 2L
    first = Vector{Int64}(undef, quater)
    second = Vector{Int64}(undef, quater)
    third = Vector{Int64}(undef, quater)
    fourth = Vector{Int64}(undef, quater)
    for (i, arr) in enumerate([first, second, third, fourth])
        start = (i - 1) * L ÷ 2 + 1
        for j in 1:L÷4
            curr = start + (j - 1) * 2
            for k in 1:2L
                arr[k+(j-1)*2L] = curr
                if iseven(curr)
                    curr = kitaevY_neighbor(lattice, curr)
                else
                    curr = kitaevZ_neighbor(lattice, curr)
                end
            end
        end
    end
    return (first, second, third, fourth)
end
