using DelimitedFiles, Printf


function loaddata(Ly, tApi; decoded::Bool=false, meas_err::Float64=0.0, numsamples::Int64=10000, sitefolder::String="./data/", decodefolder::String="./decoding/")
    ## Load data
    Lx = 2 * Ly - 1
    sitestring = zeros(Int, 2Ly * Lx - 2, numsamples)
    gaugestring = zeros(Int, 2Ly * Lx - 2, numsamples)
    if meas_err == 0.0
        sitestring = readdlm(sitefolder * (@sprintf "sitemeasurement_tA%.4fpi_L%d_fault%.3f.txt" tApi Ly meas_err), Int)
        if decoded
            gaugestring = readdlm(decodefolder * (@sprintf "gauge_sitestring_brickwall_tA%.4fpi_L%d.txt" tApi Ly), Int)
        end
    else
        sitestring = readdlm(sitefolder * (@sprintf "sitemeasurement_tA%.4fpi_L%d_fault%.3f.txt" tApi Ly meas_err), Int)
        if decoded
            gaugestring = readdlm(decodefolder * (@sprintf "gauge_sitestring_brickwall_tA%.4fpi_L%d_fault%.3f.txt" tApi Ly meas_err), Int)
        end
    end

    sitestring_undecoded = sitestring
    if decoded
        sitestring_decoded = xor.(sitestring, gaugestring)
    end
    sitestring_undecoded = (-1) .^ sitestring_undecoded
    if decoded
        sitestring_decoded = (-1) .^ sitestring_decoded
    end

    if decoded
        return sitestring_decoded
    else
        return sitestring_undecoded
    end
end
