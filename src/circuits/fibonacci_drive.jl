function MeasurementOnlyFibonacciDrive(geometry::ChainGeometry, p::Float64; depth=10)
    circuit = Circuit(geometry)

    ZZ_distributed = DistributedOperation(ZZ(), bonds(geometry), 1-p)
    X_distributed = DistributedOperation(Measure_X(), qubits(geometry), p)

    depth = word_length(depth)
    for n in 1:depth
        if fibonacci_word(n)
            apply!(circuit, X_distributed)
        else
            apply!(circuit, ZZ_distributed)
        end
    end

    return circuit
end

function fibonacci_word(n)
    golden_ratio = (1+sqrt(5))/2

    return Bool(floor((n+1)/golden_ratio) - floor(n/golden_ratio))
end

# Sum over fibonacci series for i <= n
function word_length(n)
    last = 1
    fib = 1
    for i in 3:n
        newfib = fib + last
        last = fib
        fib = newfib
    end
    return fib
end
