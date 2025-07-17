using MonitoredQuantumCircuits
import JLD2
import ProgressMeter
function simulate(; path="", L=12, averaging=10, tApi=1/4)
    geometry = HoneycombGeometry(Open, L, L)
    circuit = compile(NishimorisCatClifford(geometry))
    
end
