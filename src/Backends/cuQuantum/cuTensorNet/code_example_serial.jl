using CUDA
using cuTensorNet


struct GPUTimer
    stream::CUDA.CuStream
    start::CUDA.CuEvent
    stop::CUDA.CuEvent
    function GPUTimer(stream::CUDA.CuStream = CUDA.stream())
        return GPUTimer(stream, CuEvent(), CuEvent())
    end
end
start!(t::GPUTimer) = CUDA.record(t.start, t.stream)
function seconds!(t::GPUTimer)
    CUDA.record(t.stop, t.stream)
    CUDA.synchronize(t.stop)
    return Float64(CUDA.elapsed(t.start, t.stop))
end


