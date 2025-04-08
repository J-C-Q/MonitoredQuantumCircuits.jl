ENV["JULIA_CONDAPKG_UNSAFE_PARALLEL"] = "true"
using MonitoredQuantumCircuits
using MPI
println(MonitoredQuantumCircuits.get_mpi_ref())
# g = HoneycombGeometry(Periodic, 4, 4)
# c = MeasurementOnlyKitaev(g, 1/3, 1/3, 1/3; depth=100)
# comp = compile(c)

# sim = QuantumClifford.TableauSimulator(nQubits(g))

# MonitoredQuantumCircuits.executeMPI(comp, sim; samples=10)
