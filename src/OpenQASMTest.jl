using Yao, YaoBlocksQASM, YaoBlocksQobj
cphase(i, j) = control(i, j => shift(2π / (2^(i - j + 1))));
hcphases(n, i) = chain(n, i == j ? put(i => H) : cphase(j, i) for j in i:n);
qft(n) = chain(hcphases(n, i) for i in 1:n)

qc = chain(3, [put(1 => X), put(2 => Y), put(3 => Z),
    put(2 => T), swap(1, 2), put(3 => Ry(0.7)),
    control(2, 1 => Y), control(3, 2 => Z)])
ast = convert_to_qasm(qft(3))

string(ast)
q = convert_to_qobj([qft(3)], id="test_id")
