"""
Hybrid Quantum-Classical Neural Network implementation.

This module provides a HybridQuantumNN model that combines classical neural networks
with quantum circuit layers for end-to-end learning.
"""
module HybridQuantumNNModule

using Yao
using CuYao
using Flux
using LinearAlgebra
using ..Utils

"""
    QuantumLayer{N} <: PrimitiveBlock{N}

A quantum circuit layer that can be integrated into a hybrid quantum-classical neural network.

# Fields
- `nqubits::Int`: Number of qubits in the quantum layer
- `params::Vector{Float64}`: Parameters for the quantum gates (2 * nqubits parameters)

# Example
```julia
layer = QuantumLayer(4, rand(8))  # 4 qubits, 8 parameters
```
"""
struct QuantumLayer{N} <: PrimitiveBlock{N}
    nqubits::Int
    params::Vector{Float64}
    
    function QuantumLayer{N}(nqubits::Int, params::Vector{Float64}) where N
        Utils.validate_qubit_count(nqubits)
        expected_params = 2 * nqubits
        if length(params) != expected_params
            throw(ArgumentError(
                "Expected $expected_params parameters for $nqubits qubits, got $(length(params))"
            ))
        end
        new{N}(nqubits, params)
    end
end

# Convenience constructor
QuantumLayer(nqubits::Int, params::Vector{Float64}) = QuantumLayer{nqubits}(nqubits, params)

Yao.nparameters(l::QuantumLayer) = length(l.params)
Yao.nqubits(l::QuantumLayer) = l.nqubits

function Yao.mat(::Type{T}, l::QuantumLayer{N}) where {T, N}
    circuit = chain(N)
    for i in 1:l.nqubits
        # Apply rotation gates: RX and RY rotations
        # Each qubit gets two rotation parameters
        θ = l.params[i]
        ϕ = l.params[i + l.nqubits]
        push!(circuit, put(N, i, rot(RX, θ)))
        push!(circuit, put(N, i, rot(RY, ϕ)))
    end
    # Add entangling layer
    for i in 1:(N-1)
        push!(circuit, cnot(N, i, i+1))
    end
    return mat(T, circuit)
end

"""
    q_to_q_cuda_layer(input_state::Array{ComplexF64}, params::Vector{Float64}) -> Array{ComplexF64}

Apply quantum operations to an input state using CUDA acceleration when available.

# Arguments
- `input_state::Array{ComplexF64}`: Input quantum state vector (length must be 2^n for n qubits)
- `params::Vector{Float64}`: Parameters for quantum gates

# Returns
- `Array{ComplexF64}`: Output quantum state after applying quantum operations

# Example
```julia
state = rand(ComplexF64, 16)  # 4 qubits
params = rand(8)
output = q_to_q_cuda_layer(state, params)
```
"""
function q_to_q_cuda_layer(input_state::Array{ComplexF64}, params::Vector{Float64})::Array{ComplexF64}
    n = length(input_state)
    nqubits = Int(log2(n))
    if 2^nqubits != n
        throw(ArgumentError("Input state length must be a power of 2, got $n"))
    end
    
    Utils.validate_qubit_count(nqubits)
    if length(params) != 2 * nqubits
        throw(ArgumentError("Expected $(2*nqubits) parameters, got $(length(params))"))
    end
    
    # Normalize input state to ensure it's a valid quantum state
    state_norm = sqrt(sum(abs2, input_state))
    if state_norm < 1e-10
        # Fallback to uniform superposition
        normalized_state = fill(ComplexF64(1.0 / sqrt(n)), n)
    else
        normalized_state = input_state / state_norm
    end
    
    # Create quantum register from input state
    reg = ArrayReg(copy(normalized_state))  # Copy to avoid mutation
    
    # Apply quantum operations with CUDA fallback
    reg = Utils.safe_cuda_apply(reg) do r
        # Build circuit
        circuit = chain(nqubits)
        for i in 1:nqubits
            θ = params[i]
            ϕ = params[i + nqubits]
            push!(circuit, put(nqubits, i, rot(RX, θ)))
            push!(circuit, put(nqubits, i, rot(RY, ϕ)))
        end
        # Add entangling layer
        for i in 1:(nqubits-1)
            push!(circuit, cnot(nqubits, i, i+1))
        end
        # Apply circuit
        return r |> circuit
    end
    
    # Return the state vector
    return Array(reg.state)
end

"""
    HybridQuantumNN

A hybrid quantum-classical neural network that combines classical layers with quantum circuits.

# Fields
- `classical_preprocessor::Chain`: Classical neural network layers before quantum processing
- `quantum_layer::QuantumLayer`: Quantum circuit layer
- `classical_postprocessor::Chain`: Classical neural network layers after quantum processing

# Example
```julia
preprocessor = Chain(Dense(16, 32, relu), Dense(32, 16))
quantum_layer = QuantumLayer(4, rand(8))
postprocessor = Chain(Dense(16, 32, relu), Dense(32, 10))
model = HybridQuantumNN(preprocessor, quantum_layer, postprocessor)
```
"""
struct HybridQuantumNN
    classical_preprocessor::Chain
    quantum_layer::QuantumLayer
    classical_postprocessor::Chain
    
    function HybridQuantumNN(
        classical_preprocessor::Chain,
        quantum_layer::QuantumLayer,
        classical_postprocessor::Chain
    )
        new(classical_preprocessor, quantum_layer, classical_postprocessor)
    end
end

# Convenience constructor with default layers
function HybridQuantumNN(
    input_dim::Int,
    nqubits::Int,
    output_dim::Int;
    hidden_dim::Int=32
)
    preprocessor = Chain(
        Dense(input_dim, hidden_dim, relu),
        Dense(hidden_dim, 2^nqubits)
    )
    quantum_layer = QuantumLayer(nqubits, rand(2 * nqubits))
    postprocessor = Chain(
        Dense(2^nqubits, hidden_dim, relu),
        Dense(hidden_dim, output_dim)
    )
    return HybridQuantumNN(preprocessor, quantum_layer, postprocessor)
end

"""
    (m::HybridQuantumNN)(x) -> Array{Float32}

Forward pass of the hybrid quantum-classical neural network.

# Arguments
- `x::AbstractArray`: Input data (features × batch_size)

# Returns
- `Array{Float32}`: Output predictions

# Example
```julia
model = HybridQuantumNN(16, 4, 10)
input = rand(Float32, 16, 10)
output = model(input)
```
"""
function (m::HybridQuantumNN)(x::AbstractArray)
    try
        # Classical preprocessing
        x_classical = m.classical_preprocessor(x)
        
        # Validate dimensions
        nqubits = m.quantum_layer.nqubits
        expected_dim = 2^nqubits
        if size(x_classical, 1) != expected_dim
            throw(DimensionMismatch(
                "Preprocessor output dimension $(size(x_classical, 1)) does not match " *
                "quantum layer requirement $expected_dim"
            ))
        end
        
        # Quantum processing - optimized batch processing
        batch_size = size(x_classical, 2)
        quantum_output = zeros(ComplexF64, size(x_classical))
        
        # Pre-build circuit for efficiency (if parameters don't change)
        # For now, process each sample (can be optimized further with batched operations)
        @inbounds for i in 1:batch_size
            # Convert to complex state and normalize
            state = ComplexF64.(x_classical[:, i])
            # Normalize to ensure valid quantum state
            norm = sqrt(sum(abs2, state))
            if norm > 1e-10
                state = state / norm
            else
                # Fallback to uniform state if input is zero
                state = fill(ComplexF64(1.0 / sqrt(length(state))), length(state))
            end
            quantum_output[:, i] = q_to_q_cuda_layer(state, m.quantum_layer.params)
        end
        
        # Convert to real and post-process
        real_output = real(quantum_output)
        return m.classical_postprocessor(real_output)
    catch e
        error("Error in HybridQuantumNN forward pass: $e")
    end
end

Flux.@functor HybridQuantumNN

# Export public types and functions
export HybridQuantumNN, QuantumLayer

end # module
