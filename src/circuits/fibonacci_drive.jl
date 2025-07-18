function measurementOnlyFibonacciDrive!(
    backend::Backend, geometry::ChainGeometry,
    p::Float64; depth=610, keep_result=false)

    qubits_ = qubits(geometry)
    bonds_ = bonds(geometry)
    for n in 1:depth
        if fibonacci_word(n)
            for position in eachcol(qubits_)
                if rand() < p
                    apply!(backend, Measure_X(), position...;keep_result)
                end
            end
        else
            for position in eachcol(bonds_)
                if rand() >= p
                    apply!(backend, ZZ(), position...; keep_result)
                end
            end
        end
    end
    return backend
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
