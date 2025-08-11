backend = Qiskit.GPUTensorNetworkSimulator(nqubits; ancillas=nancillas)

backend = Qiskit.IBMBackend(nqubits; ancillas=nancillas)
geometry = IBMQ_Falcon()
function process(backend::Backend, geometry::IBMQ_Falcon,
    jobId::String, tApi; postselect=false)

    nAncillas = nControlQubits(geometry)
    magnetization = Int64[]
    post = (s) -> begin
		measurements = Qiskit.get_measurements(backend, s)
		if !postselect || all(i->i==0, (@view measurements[1:nAncillas]))
			m = sum(i->2*i-1, (@view measurements[(nAncillas+1):end]))
			push!(magnetization, m)
		end
	end
    Qiskit.postprocess!(backend, jobId, post)
    return magnetization
end

function run(;shots = 10^5, tApi = 1/4)
	g = IBMQ_Falcon()
	backend = Qiskit.IBMBackend(nQubits(g); ancillas = nControlQubits(g))
	execute!(()->monitoredGHZ!(backend, g; tApi), backend; shots = shots)
	return backend
end


function simulate(; shots = 10^6, postselect = false, tApi = 1/4)
	g = IBMQ_Falcon()
	nAncillas = nBonds(g)
	backend = Qiskit.GPUTensorNetworkSimulator(nQubits(g); ancillas = nAncillas)
	magnetization = Int64[]
	post = (s) -> begin
		measurements = Qiskit.get_measurements(backend, s)
		if !postselect || all(i->i==0, (@view measurements[1:nAncillas]))
			m = sum(i->2*i-1, (@view measurements[(nAncillas+1):end]))
			push!(magnetization, m)
		end
	end
	execute!(
		()->monitoredGHZ!(backend, g; tApi), backend, post; shots = shots)
	return magnetization
end


function monitoredGHZ!(
	backend::Backend, geometry::IBMQ_Falcon;
	tApi::Float64 = 1/4)

	for position in qubits(geometry)
		apply!(backend, H(), position)
	end
	for (i, position) in enumerate(bonds(geometry))
		apply!(backend, MZZ(π * tApi), position; ancilla = nQubits(geometry)+i)
	end
	for position in qubits(geometry)
		apply!(backend, MZ(), position)
	end
	return backend
end
function measurementOnlyKekule!(
	backend::Backend, geometry::HoneycombGeometry{Periodic},
	px::Float64, py::Float64, pz::Float64;
	depth::Integer = 100, keep_result = false, phases = false)

	initialState!(backend, geometry; keep_result, phases)
	for i in 1:(depth*nQubits(geometry))
		p = rand()
		if p < pr
			bond = random_kekuleRed_bond(geometry)
		elseif p < pr + pg
			bond = random_kekuleGreen_bond(geometry)
		else
			bond = random_kekuleBlue_bond(geometry)
		end
		if isKitaevX(geometry, bond)
			apply!(backend, MXX(), bond; keep_result, phases)
		elseif isKitaevY(geometry, bond)
			apply!(backend, MYY(), bond; keep_result, phases)
		else
			apply!(backend, MZZ(), bond; keep_result, phases)
		end
	end
	return backend
end
function simulate(L; resolution = 207, shots = 2048, depth = 512)
	g = HoneycombGeometry(Periodic, L, L)
	backend = QuantumClifford.TableauSimulator(nQubits(g); mixed = true)
	ps = generateProbabilities(resolution)
	partitionsX = subsystems(g, 4; cutType = :X)
	partitionsY = subsystems(g, 4; cutType = :Y)
	partitionsZ = subsystems(g, 4; cutType = :Z)
	tmi = zeros(Float64, length(ps))
	for (i, (px, py, pz)) in enumerate(ps)
		post = (s) -> begin
			x = QuantumClifford.tmi(backend.state, partitionsX)
			y = QuantumClifford.tmi(backend.state, partitionsY)
			z = QuantumClifford.tmi(backend.state, partitionsZ)
			tmi[i] += x + y + z
		end
		execute!(
			()->measurementOnlyKitaev!(backend, g, px, py, pz; depth),
			backend, post; shots = shots)
	end
	return tmi ./= 3shots
end

function generateProbabilities(resolution)
	n = resolution
	points = Vector{NTuple{3, Float64}}(undef, n*(n + 1) ÷ 2)
	m = 1
	for (k, i) in enumerate(range(0, 1, n))
		for j in range(i, 1, n - k + 1)
			px = i
			py = j - i
			pz = 1 - j
			points[m] = (px, py, pz)
			m += 1
		end
	end
	return points
end

function initialState!(
	backend::Backend, geometry::HoneycombGeometry{Periodic};
	keep_result = false, phases = false)

	for position in kitaevZ_bonds(geometry)
		apply!(backend, MZZ(), position; keep_result, phases)
	end
	plaquette_pauli = MnPauli(Y, X, Z, Y, X, Z)
	for position in plaquettes(geometry)
		apply!(backend, plaquette_pauli, position; keep_result, phases)
	end
	xy_loop = loopsXY(geometry)[1]
	xz_loop = loopsXZ(geometry)[1]
	xy_looplength = XYlooplength(geometry)
	xz_looplength = XZlooplength(geometry)
	apply!(backend, MnPauli(Z(), xy_looplength), xy_loop; keep_result, phases)
	apply!(backend, MnPauli(Y(), xz_looplength), xz_loop; keep_result, phases)
	return backend
end
function measurementOnlyKitaev!(
	backend::Backend, geometry::HoneycombGeometry{Periodic},
	px::Float64, py::Float64, pz::Float64;
	depth::Integer = 100, keep_result = false, phases = false)

	initialState!(backend, geometry; keep_result, phases)
	for i in 1:(depth*nQubits(geometry))
		p = rand()
		if p < px
			bond = random_kitaevX_bond(geometry)
			apply!(backend, MXX(), bond; keep_result, phases)
		elseif p < px + py
			bond = random_kitaevY_bond(geometry)
			apply!(backend, MYY(), bond; keep_result, phases)
		else
			bond = random_kitaevZ_bond(geometry)
			apply!(backend, MZZ(), bond; keep_result, phases)
		end
	end
	return backend
end
function measurementOnlyKitaev_initialState!(
	backend::Backend, geometry::HoneycombGeometry{Periodic};
	keep_result = false, phases = false)

	for position in kitaevZ_bonds(geometry)
		apply!(backend, MZZ(), position; keep_result, phases)
	end
	plaquette_pauli = MnPauli(Y, X, Z, Y, X, Z)
	for position in plaquettes(geometry)
		apply!(backend, plaquette_pauli, position; keep_result, phases)
	end
	xy_loop = loopsXY(geometry)[1]
	xz_loop = loopsXZ(geometry)[1]
	xy_looplength = XYlooplength(geometry)
	xz_looplength = XZlooplength(geometry)
	apply!(backend, MnPauli(Z(), xy_looplength), xy_loop; keep_result, phases)
	apply!(backend, MnPauli(Y(), xz_looplength), xz_loop; keep_result, phases)
	return backend
end


post = (s) -> begin
	subsystem = 1:div(L, 2)
	state = backend.state
	entropy = QuantumClifford.entanglement_entropy(state, subsystem)
	entanglement[i] += entropy
end

function simulate(L, ps; shots = 2^16, depth = 1597)
	g = ChainGeometry(Periodic, L)
	nqubits = nQubits(g)
	backend = QuantumClifford.TableauSimulator(nqubits; mixed = false, basis = :X)
	entanglement = zeros(Float64, length(ps))
	for (i, p) in enumerate(ps)
		post = (s) -> begin
			subsystem = 1:div(L, 2)
			state = backend.state
			entropy = QuantumClifford.entanglement_entropy(state, subsystem)
			entanglement[i] += entropy
		end
		execute!(
			()->monitoredTransverseFieldIsingFibonacci!(backend, g, p; depth),
			backend, post; shots = shots)
	end
	return entanglement ./= shots
end
function simulate(L, ps; shots = 2^16, depth = 2584)
	g = ChainGeometry(Periodic, L)
	nqubits = nQubits(g)
	backend = QuantumClifford.TableauSimulator(nqubits; mixed = false, basis = :X)
	entanglement = zeros(Float64, length(ps))
	for (i, p) in enumerate(ps)
		post = (s) -> begin
			subsystem = 1:div(L, 2)
			state = backend.state
			entropy = QuantumClifford.entanglement_entropy(state, subsystem)
			entanglement[i] += entropy
		end
		execute!(
			()->monitoredTransverseFieldIsing!(backend, g, p; depth),
			backend, post; shots = shots)
	end
	return entanglement ./= shots
end

function monitoredTransverseFieldIsingFibonacci!(
	backend::Backend, geometry::ChainGeometry,
	p::Float64; depth = 610, keep_result = false, phases = false)

	for i in 1:depth
		if !fibonacci_word(i)
			for position in bonds(geometry)
				if rand() >= p
					apply!(backend, MZZ(), position; keep_result, phases)
				end
			end
		else
			for position in qubits(geometry)
				if rand() < p
					apply!(backend, MX(), position; keep_result, phases)
				end
			end
		end
	end
	return backend
end
function monitoredTransverseFieldIsing!(
	backend::Backend, geometry::ChainGeometry{Periodic},
	p::Float64; depth = 100, keep_result = false, phases = false)

	for i in 1:depth
		if i%2 == 1
			for position in bonds(geometry)
				if rand() >= p
					apply!(backend, MZZ(), position; keep_result, phases)
				end
			end
		else
			for position in qubits(geometry)
				if rand() < p
					apply!(backend, MX(), position; keep_result, phases)
				end
			end
		end
	end
	return backend
end
backend = QuantumClifford.TableauSimulator(nqubits; mixed = false, basis = :X)
backend = QuantumClifford.TableauSimulator(nqubits; mixed = true)
