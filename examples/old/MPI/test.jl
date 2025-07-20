ENV["JULIA_CONDAPKG_UNSAFE_PARALLEL"] = "true"
using MonitoredQuantumCircuits
using MPI

g = HoneycombGeometry(Periodic, 12, 12)
c = MeasurementOnlyKitaev(g, 1 / 3, 1 / 3, 1 / 3; depth=10000)
comp = compile(c)

sim = QuantumClifford.TableauSimulator(nQubits(g))

executeParallel(comp, sim; samples=100)
