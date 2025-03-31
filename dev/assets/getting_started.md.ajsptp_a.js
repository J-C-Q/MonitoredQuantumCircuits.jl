import{_ as i,c as s,o as a,a7 as t}from"./chunks/framework.BlNHQ1cX.js";const g=JSON.parse('{"title":"Getting Started","description":"","frontmatter":{},"headers":[],"relativePath":"getting_started.md","filePath":"getting_started.md","lastUpdated":null}'),e={name:"getting_started.md"},n=t('<h1 id="Getting-Started" tabindex="-1">Getting Started <a class="header-anchor" href="#Getting-Started" aria-label="Permalink to &quot;Getting Started {#Getting-Started}&quot;">​</a></h1><p>The framework consists out of three main parts. First is the qubit geometry, which represents the underlying qubits structure. Second is the circuit, which holds information about the operations applied to the qubits in a given geometry. The last part is the execution of the circuit, which can happen on various backends. As always, load MonitoredQuantumCircuits.jl (after <a href="/MonitoredQuantumCircuits.jl/dev/">installing</a> it) using the <code>using</code> keyword for the following code snippets to work</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> MonitoredQuantumCircuits</span></span></code></pre></div><h2 id="Choose-a-Geometry" tabindex="-1">Choose a Geometry <a class="header-anchor" href="#Choose-a-Geometry" aria-label="Permalink to &quot;Choose a Geometry {#Choose-a-Geometry}&quot;">​</a></h2><p>A <code>Geometry</code> is a representation of qubits and connections between them (i.e., a graph). In general, it is only possible to apply operations to multiple qubits if they are connected in the geometry. For more information see <a href="/MonitoredQuantumCircuits.jl/dev/library/lattices">Geometries</a>. To construct a geometry object, call a constructor, e.g.,</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">geometry </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> HoneycombGeometry</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(Periodic, </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">12</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">12</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><h2 id="Compose-a-Circuit" tabindex="-1">Compose a Circuit <a class="header-anchor" href="#Compose-a-Circuit" aria-label="Permalink to &quot;Compose a Circuit {#Compose-a-Circuit}&quot;">​</a></h2><p>A circuit stores the <a href="/MonitoredQuantumCircuits.jl/dev/library/operations">Operations</a> being applied to the qubits in a lattice. For more information see <a href="/MonitoredQuantumCircuits.jl/dev/library/circuits">Circuits</a>. To construct a circuit object, call a constructor, e.g.,</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">circuit </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> MeasurementOnlyKitaev</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(geometry, px, py, pz; depth</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">100</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Or start an iterative construction by initializing an empty circuit</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">circuit </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> Circuit</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(geometry)</span></span></code></pre></div><p>Now you could continue with the CLI and call <code>apply!</code> for different operations, or launch a <a href="/MonitoredQuantumCircuits.jl/dev/modules/gui">GUI</a> (WIP) using</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">GUI</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">CircuitComposer!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(circuit)</span></span></code></pre></div><p>Once you are done creating the circuit, compile it for faster iteration</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">compiled_circuit </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> compile</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(circuit)</span></span></code></pre></div><h2 id="execute" tabindex="-1">Execute <a class="header-anchor" href="#execute" aria-label="Permalink to &quot;Execute&quot;">​</a></h2><p>To execute a quantum circuit, you first have to think about which <a href="/MonitoredQuantumCircuits.jl/dev/library/backends">Backend</a> to use. For example a Clifford simulation using QuantumClifford.jl</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">simulator </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> QuantumClifford</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">TableauSimulator</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">nQubits</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(geometry))</span></span></code></pre></div><p>or a state vector simulation using cuQuantum via Qiskit-Aer</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">simulator </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Qiskit</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">GPUStateVectorSimulator</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">()</span></span></code></pre></div><p>Then, you can execute the circuit using</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">execute!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(circuit</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">CompiledCircuit</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, backend</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Backend</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div>',22),l=[n];function h(p,o,r,c,d,k){return a(),s("div",null,l)}const y=i(e,[["render",h]]);export{g as __pageData,y as default};
