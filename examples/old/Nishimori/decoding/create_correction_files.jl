using DelimitedFiles, Printf


#Ref2gauge

function ref2gauge(bondstring::Vector{Int}, refstring::Vector{Int}, Ly::Int; Lx::Int=2Ly - 1)

    numbonds_row = 2Ly - 1
    numbonds_col = Ly
    numbonds_layer = numbonds_row + numbonds_col
    numbonds_latt_obc = 3Ly * Lx - Lx - Ly

    # get snake label:
    temp = [1:numbonds_row-1; 0; numbonds_row:numbonds_latt_obc-numbonds_row-1; 0; numbonds_latt_obc-numbonds_row:numbonds_latt_obc-2+Ly]
    temp = reshape(temp, numbonds_layer, Lx)
    temp2 = zeros(Int, numbonds_row + 1, Lx)
    for x in 1:2:Lx
        temp2[1:numbonds_row, x] .= temp[numbonds_row:-1:1, x]
        temp2[end, x] = temp[numbonds_row+1, x]
    end
    for x in 2:2:Lx
        temp2[1:numbonds_row, x] .= temp[1:numbonds_row, x]
        temp2[end, x] = temp[end, x]
    end
    snakeind = temp2[2:end-2]

    # from transition string to gauge string
    transstring = (bondstring.+refstring.+1)[snakeind]
    gaugestring = [0; 0; mod.(cumsum(transstring), 2); 0]

    # from snake to normal ordering
    gaugestring = reshape(gaugestring, 2Ly, Lx)
    gaugestring[:, 1:2:end] .= gaugestring[end:-1:1, 1:2:end]

    gaugestring = gaugestring[:]

    gaugestring = gaugestring[[1:2Ly-1; 2Ly+1:end-2Ly; end-2Ly+2:end]]

    return gaugestring[:]
end


function generate_correction_files(Ly, tApi; meas_err=0.0, bondfolder::String="./data/", testfolder="./decoding/")

    ## generate gauge transformation
    if meas_err == 0.0
        bondstring = readdlm(bondfolder * (@sprintf "samples_bondstring_brickwall_tA%.4fpi_L%d.txt" tApi Ly), Int)
        refstring = readdlm(testfolder * (@sprintf "reference_bondstring_brickwall_tA%.4fpi_L%d.txt" tApi Ly), Int)
    else
        bondstring = readdlm(bondfolder * (@sprintf "samples_bondstring_brickwall_tA%.4fpi_L%d_fault%.3f.txt" tApi Ly meas_err), Int)
        refstring = readdlm(testfolder * (@sprintf "reference_bondstring_brickwall_tA%.4fpi_L%d_fault%.3f.txt" tApi Ly meas_err), Int)
    end
    numsamples = size(bondstring, 2)
    Lx = 2Ly - 1
    gaugestring = zeros(Int, 2Ly * Lx - 2, numsamples)
    for ss in 1:numsamples
        gaugestring[:, ss] = ref2gauge(bondstring[:, ss], refstring[:, ss], Ly)
    end
    if meas_err == 0.0
        filestring = @sprintf "gauge_sitestring_brickwall_tA%.4fpi_L%d.txt" tApi Ly
        open(testfolder * filestring, "w") do io
            writedlm(io, gaugestring, ' ')
        end
    else
        filestring = @sprintf "gauge_sitestring_brickwall_tA%.4fpi_L%d_fault%.3f.txt" tApi Ly meas_err
        open(testfolder * filestring, "w") do io
            writedlm(io, gaugestring, ' ')
        end
    end
end
