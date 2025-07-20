function monitoredTransverseFieldIsingFibonacci!(
    backend::Backend, geometry::ChainGeometry,
    p::Float64; depth=610, keep_result=false,phases=false)

    for n in 1:depth
        if fibonacci_word(n)
            for position in qubits(geometry)
                if rand() < p
                    apply!(backend, MX(), position;keep_result,phases)
                end
            end
        else
            for position in bonds(geometry)
                if rand() >= p
                    apply!(backend, MZZ(), position; keep_result,phases)
                end
            end
        end
    end
    return backend
end

function fibonacci_word(n)
    golden_ratio = (1+sqrt(5))/2

    return Bool(div((n+1),golden_ratio) - div(n,golden_ratio))
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
