using MonitoredQuantumCircuits
import JLD2
import ProgressMeter
function simulate(; path="", L=12, averaging=10)
    geometry = HoneycombGeometry(Open, L, L)
    circuit = compile(NishimorisCat(geometry))
end
