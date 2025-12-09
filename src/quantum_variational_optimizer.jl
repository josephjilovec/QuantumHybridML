"""
Variational Quantum-Classical Optimizer implementation.

This module provides tools for variational quantum circuits with fractal-inspired encoding
and entanglement analysis for hybrid quantum-classical optimization.
"""
module VariationalOptimizerModule

using Yao
using CuYao
using Flux
using LinearAlgebra
using Statistics
using Optimisers
using Plots
using ..Utils

"""
    VariationalQuantumCircuit{N} <: PrimitiveBlock{N}

A variational quantum circuit with multiple layers of rotation and entangling gates.

# Fields
- `nqubits::Int`: Number of qubits
- `nlayers::Int`: Number of variational layers
- `params::Vector{Float64}`: Parameters for rotation gates (2 * nqubits * nlayers)

# Example
```julia
vqc = VariationalQuantumCircuit(4, 3, rand(24))  # 4 qubits, 3 layers, 24 params
```
"""
struct VariationalQuantumCircuit{N} <: PrimitiveBlock{N}
    nqubits::Int
    nlayers::Int
    params::Vector{Float64}
    
    function VariationalQuantumCircuit{N}(nqubits::Int, nlayers::Int, params::Vector{Float64}) where N
        Utils.validate_qubit_count(nqubits)
        if nlayers < 1
            throw(ArgumentError("Number of layers must be at least 1, got $nlayers"))
        end
        expected_params = 2 * nqubits * nlayers
        if length(params) != expected_params
            throw(ArgumentError(
                "Expected $expected_params parameters for $nqubits qubits and $nlayers layers, " *
                "got $(length(params))"
            ))
        end
        new{N}(nqubits, nlayers, params)
    end
end

# Convenience constructor
VariationalQuantumCircuit(nqubits::Int, nlayers::Int, params::Vector{Float64}) = 
    VariationalQuantumCircuit{nqubits}(nqubits, nlayers, params)

Yao.nparameters(vqc::VariationalQuantumCircuit) = length(vqc.params)
Yao.nqubits(vqc::VariationalQuantumCircuit) = vqc.nqubits

function Yao.mat(::Type{T}, vqc::VariationalQuantumCircuit{N}) where {T, N}
    circuit = chain(N)
    idx = 1
    for _ in 1:vqc.nlayers
        # Rotation layer
        for i in 1:N
            θ = vqc.params[idx]
            push!(circuit, put(N, i, rot(RX, θ)))
            idx += 1
            ϕ = vqc.params[idx]
            push!(circuit, put(N, i, rot(RY, ϕ)))
            idx += 1
        end
        # Entangling layer
        for i in 1:(N-1)
            push!(circuit, cnot(N, i, i+1))
        end
    end
    return mat(T, circuit)
end

"""
    fractal_state_encoding(data::Vector{Float64}, nqubits::Int) -> AbstractRegister

Encode classical data into a quantum state using a fractal-inspired encoding scheme.

# Arguments
- `data::Vector{Float64}`: Input classical data vector
- `nqubits::Int`: Number of qubits for encoding

# Returns
- `AbstractRegister`: Quantum register with encoded state

# Example
```julia
data = rand(10)
reg = fractal_state_encoding(data, 4)
```
"""
function fractal_state_encoding(data::Vector{Float64}, nqubits::Int)::AbstractRegister
    Utils.validate_qubit_count(nqubits)
    if isempty(data)
        throw(ArgumentError("Input data cannot be empty"))
    end
    
    # Normalize input data to [0, 1]
    data_min = minimum(data)
    data_max = maximum(data)
    if data_max - data_min < 1e-10
        # All values are the same, use uniform encoding
        data_normalized = fill(0.5, length(data))
    else
        data_normalized = (data .- data_min) ./ (data_max - data_min)
    end
    
    # Create fractal-like pattern using recursive angle scaling
    angles = zeros(Float64, nqubits)
    for i in 1:nqubits
        level = floor(Int, log2(i + 1))
        data_window = data_normalized[1:min(length(data_normalized), 2^level)]
        angles[i] = sum(data_window) / length(data_window)
    end
    
    # Prepare quantum state with CUDA fallback
    reg = zero_state(nqubits)
    reg = Utils.safe_cuda_apply(reg) do r
        for (i, θ) in enumerate(angles)
            r = r |> put(nqubits, i, RX(θ * π))
        end
        return r
    end
    
    return reg
end

"""
    compute_entanglement_entropy(reg::AbstractRegister) -> Float64

Compute the von Neumann entropy of a quantum register to quantify entanglement.

# Arguments
- `reg::AbstractRegister`: Quantum register

# Returns
- `Float64`: Entanglement entropy (von Neumann entropy)

# Example
```julia
reg = zero_state(4) |> put(4, 1, H) |> cnot(4, 1, 2)
entropy = compute_entanglement_entropy(reg)
```
"""
function compute_entanglement_entropy(reg::AbstractRegister)::Float64
    try
        ρ = density_matrix(reg)
        evals = eigvals(ρ)
        # Filter out near-zero eigenvalues to avoid log(0)
        evals = real.(evals[evals .> 1e-10])
        if isempty(evals)
            return 0.0
        end
        # Normalize eigenvalues
        evals = evals ./ sum(evals)
        entropy = -sum(evals .* log.(evals .+ 1e-10))
        return entropy
    catch e
        @warn "Error computing entanglement entropy: $e"
        return 0.0
    end
end

"""
    nexus_integrity_loss(model_output::Matrix{Float32}, target::Matrix{Float32}, quantum_reg::AbstractRegister) -> Float64

Custom loss function inspired by Nexus_Integrity that combines classification loss with quantum coherence penalty.

# Arguments
- `model_output::Matrix{Float32}`: Model predictions
- `target::Matrix{Float32}`: Target values
- `quantum_reg::AbstractRegister`: Quantum register for coherence computation

# Returns
- `Float64`: Combined loss value

# Example
```julia
output = rand(Float32, 10, 5)
target = rand(Float32, 10, 5)
reg = zero_state(4)
loss = nexus_integrity_loss(output, target, reg)
```
"""
function nexus_integrity_loss(
    model_output::Matrix{Float32},
    target::Matrix{Float32},
    quantum_reg::AbstractRegister
)::Float64
    if size(model_output) != size(target)
        throw(DimensionMismatch(
            "Model output size $(size(model_output)) does not match target size $(size(target))"
        ))
    end
    
    # Classification loss (mean squared error)
    mse_loss = mean((model_output .- target).^2)
    
    # Quantum coherence penalty (inspired by Nexus_Integrity)
    coherence = compute_entanglement_entropy(quantum_reg)
    coherence_penalty = 0.1 * abs(coherence - 1.0)  # Target entropy ~1.0
    
    return mse_loss + coherence_penalty
end

"""
    VQCOptimizer

Variational Quantum-Classical Optimizer combining classical preprocessing with variational quantum circuits.

# Fields
- `classical_preprocessor::Chain`: Classical neural network for preprocessing
- `quantum_circuit::VariationalQuantumCircuit`: Variational quantum circuit
- `classical_postprocessor::Chain`: Classical neural network for postprocessing
- `nqubits::Int`: Number of qubits

# Example
```julia
preprocessor = Chain(Dense(16, 32, relu), Dense(32, 16))
vqc = VariationalQuantumCircuit(4, 3, rand(24))
postprocessor = Chain(Dense(16, 32, relu), Dense(32, 10))
optimizer = VQCOptimizer(preprocessor, vqc, postprocessor, 4)
```
"""
struct VQCOptimizer
    classical_preprocessor::Chain
    quantum_circuit::VariationalQuantumCircuit
    classical_postprocessor::Chain
    nqubits::Int
    
    function VQCOptimizer(
        classical_preprocessor::Chain,
        quantum_circuit::VariationalQuantumCircuit,
        classical_postprocessor::Chain,
        nqubits::Int
    )
        Utils.validate_qubit_count(nqubits)
        if quantum_circuit.nqubits != nqubits
            throw(ArgumentError(
                "Quantum circuit nqubits $(quantum_circuit.nqubits) does not match optimizer nqubits $nqubits"
            ))
        end
        new(classical_preprocessor, quantum_circuit, classical_postprocessor, nqubits)
    end
end

"""
    (vqc_opt::VQCOptimizer)(x::Matrix{Float32}, y::Matrix{Float32}) -> Tuple{Matrix{Float32}, Float64}

Forward pass for VQCOptimizer that returns predictions and loss.

# Arguments
- `x::Matrix{Float32}`: Input features (features × batch_size)
- `y::Matrix{Float32}`: Target values (output_dim × batch_size)

# Returns
- `Tuple{Matrix{Float32}, Float64}`: (predictions, loss)

# Example
```julia
x = rand(Float32, 16, 10)
y = rand(Float32, 10, 10)
predictions, loss = optimizer(x, y)
```
"""
function (vqc_opt::VQCOptimizer)(x::Matrix{Float32}, y::Matrix{Float32})
    try
        # Classical preprocessing
        x_classical = vqc_opt.classical_preprocessor(x)
        
        # Validate dimensions
        nqubits = vqc_opt.nqubits
        expected_dim = 2^nqubits
        if size(x_classical, 1) != expected_dim
            throw(DimensionMismatch(
                "Preprocessor output dimension $(size(x_classical, 1)) does not match " *
                "quantum layer requirement $expected_dim"
            ))
        end
        
        # Quantum encoding and processing
        batch_size = size(x_classical, 2)
        quantum_states = zeros(ComplexF64, 2^nqubits, batch_size)
        reg_final = nothing
        
        for i in 1:batch_size
            reg = fractal_state_encoding(x_classical[:, i], nqubits)
            # Apply quantum circuit - FIX: assign result
            circuit = chain(nqubits)
            idx = 1
            for layer in 1:vqc_opt.quantum_circuit.nlayers
                for q in 1:nqubits
                    θ = vqc_opt.quantum_circuit.params[idx]
                    push!(circuit, put(nqubits, q, rot(RX, θ)))
                    idx += 1
                    ϕ = vqc_opt.quantum_circuit.params[idx]
                    push!(circuit, put(nqubits, q, rot(RY, ϕ)))
                    idx += 1
                end
                for q in 1:(nqubits-1)
                    push!(circuit, cnot(nqubits, q, q+1))
                end
            end
            reg = reg |> circuit
            quantum_states[:, i] = Array(reg.state)
            if i == 1
                reg_final = reg  # Store for loss computation
            end
        end
        
        # Post-process quantum output
        real_output = real(quantum_states)
        final_output = vqc_opt.classical_postprocessor(real_output)
        
        # Compute loss with Nexus_Integrity
        if reg_final === nothing
            reg_final = zero_state(nqubits)
        end
        loss = nexus_integrity_loss(final_output, y, reg_final)
        return final_output, loss
    catch e
        error("Error in VQCOptimizer forward pass: $e")
    end
end

Flux.@functor VQCOptimizer

"""
    train_vqc_optimizer!(vqc_opt::VQCOptimizer, x::Matrix{Float32}, y::Matrix{Float32}, epochs::Int=100) -> Tuple{Vector{Float64}, Vector{Float64}}

Train a VQCOptimizer model.

# Arguments
- `vqc_opt::VQCOptimizer`: The optimizer to train
- `x::Matrix{Float32}`: Training features (features × batch_size)
- `y::Matrix{Float32}`: Training targets (output_dim × batch_size)
- `epochs::Int`: Number of training epochs (default: 100)

# Returns
- `Tuple{Vector{Float64}, Vector{Float64}}`: (losses, entropies) over training

# Example
```julia
optimizer = create_vqc_optimizer(4, 3)
x = rand(Float32, 16, 100)
y = rand(Float32, 10, 100)
losses, entropies = train_vqc_optimizer!(optimizer, x, y, 50)
```
"""
function train_vqc_optimizer!(
    vqc_opt::VQCOptimizer,
    x::Matrix{Float32},
    y::Matrix{Float32},
    epochs::Int=100
)::Tuple{Vector{Float64}, Vector{Float64}}
    if epochs < 1
        throw(ArgumentError("Number of epochs must be at least 1, got $epochs"))
    end
    
    opt = Optimisers.ADAM(0.01)
    losses = Float64[]
    entropies = Float64[]
    
    for epoch in 1:epochs
        try
            loss, grads = Flux.withgradient(vqc_opt) do m
                _, l = m(x, y)
                l
            end
            Optimisers.update!(opt, vqc_opt, grads[1])
            
            # Compute entanglement entropy for monitoring
            reg = fractal_state_encoding(x[:, 1], vqc_opt.nqubits)
            # Build and apply circuit
            circuit = chain(vqc_opt.nqubits)
            idx = 1
            for layer in 1:vqc_opt.quantum_circuit.nlayers
                for q in 1:vqc_opt.nqubits
                    θ = vqc_opt.quantum_circuit.params[idx]
                    push!(circuit, put(vqc_opt.nqubits, q, rot(RX, θ)))
                    idx += 1
                    ϕ = vqc_opt.quantum_circuit.params[idx]
                    push!(circuit, put(vqc_opt.nqubits, q, rot(RY, ϕ)))
                    idx += 1
                end
                for q in 1:(vqc_opt.nqubits-1)
                    push!(circuit, cnot(vqc_opt.nqubits, q, q+1))
                end
            end
            reg = reg |> circuit
            entropy = compute_entanglement_entropy(reg)
            
            push!(losses, loss)
            push!(entropies, entropy)
            if epoch % 10 == 0 || epoch == 1
                println("Epoch $epoch, Loss: $loss, Entanglement Entropy: $entropy")
            end
        catch e
            @warn "Error in training epoch $epoch: $e"
            push!(losses, Inf)
            push!(entropies, 0.0)
        end
    end
    
    # Visualize training progress
    try
        p = plot(1:epochs, losses, label="Loss", xlabel="Epoch", ylabel="Value", title="Training Progress")
        plot!(p, 1:epochs, entropies, label="Entanglement Entropy")
        savefig(p, "training_progress.png")
    catch e
        @warn "Could not save training plot: $e"
    end
    
    return losses, entropies
end

"""
    create_vqc_optimizer(nqubits::Int, nlayers::Int; input_dim::Int=16, output_dim::Int=16, hidden_dim::Int=32) -> VQCOptimizer

Create a VQCOptimizer with default architecture.

# Arguments
- `nqubits::Int`: Number of qubits
- `nlayers::Int`: Number of variational layers
- `input_dim::Int`: Input dimension (default: 16)
- `output_dim::Int`: Output dimension (default: 16)
- `hidden_dim::Int`: Hidden layer dimension (default: 32)

# Returns
- `VQCOptimizer`: Configured optimizer

# Example
```julia
optimizer = create_vqc_optimizer(4, 3, input_dim=16, output_dim=10)
```
"""
function create_vqc_optimizer(
    nqubits::Int,
    nlayers::Int;
    input_dim::Int=16,
    output_dim::Int=16,
    hidden_dim::Int=32
)::VQCOptimizer
    Utils.validate_qubit_count(nqubits)
    if nlayers < 1
        throw(ArgumentError("Number of layers must be at least 1, got $nlayers"))
    end
    
    quantum_dim = 2^nqubits
    classical_preprocessor = Chain(
        Dense(input_dim, hidden_dim, relu),
        Dense(hidden_dim, quantum_dim)
    )
    nparams = 2 * nqubits * nlayers
    quantum_circuit = VariationalQuantumCircuit(nqubits, nlayers, rand(nparams))
    classical_postprocessor = Chain(
        Dense(quantum_dim, hidden_dim, relu),
        Dense(hidden_dim, output_dim)
    )
    return VQCOptimizer(classical_preprocessor, quantum_circuit, classical_postprocessor, nqubits)
end

# Export public types and functions
export VariationalQuantumCircuit, VQCOptimizer
export fractal_state_encoding, compute_entanglement_entropy
export nexus_integrity_loss, create_vqc_optimizer, train_vqc_optimizer!

end # module
