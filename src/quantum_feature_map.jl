"""
Quantum Feature Map implementation for kernel methods.

This module provides quantum feature maps and kernel functions for quantum-enhanced
machine learning, particularly for quantum support vector machines.
"""
module QuantumFeatureMapModule

using Yao
using CuYao
using LinearAlgebra
using Statistics
using ..Utils
using ..VariationalOptimizerModule: compute_entanglement_entropy

"""
    fractal_feature_map(data::Vector{Float64}, nqubits::Int, nlayers::Int) -> AbstractRegister

Create a fractal-inspired quantum feature map with multiple layers.

# Arguments
- `data::Vector{Float64}`: Input classical data vector
- `nqubits::Int`: Number of qubits
- `nlayers::Int`: Number of encoding layers

# Returns
- `AbstractRegister`: Quantum register with encoded state

# Example
```julia
data = rand(10)
reg = fractal_feature_map(data, 4, 3)
```
"""
function fractal_feature_map(data::Vector{Float64}, nqubits::Int, nlayers::Int)::AbstractRegister
    Utils.validate_qubit_count(nqubits)
    if nlayers < 1
        throw(ArgumentError("Number of layers must be at least 1, got $nlayers"))
    end
    if isempty(data)
        throw(ArgumentError("Input data cannot be empty"))
    end
    
    # Normalize input data to [0, π]
    data_min = minimum(data)
    data_max = maximum(data)
    if data_max - data_min < 1e-10
        data_normalized = fill(0.5, length(data))
    else
        data_normalized = (data .- data_min) ./ (data_max - data_min)
    end
    
    # Initialize quantum register
    reg = zero_state(nqubits)
    reg = Utils.safe_cuda_apply(reg) do r
        # Apply fractal-inspired encoding with multiple layers
        for layer in 1:nlayers
            for i in 1:nqubits
                # Scale angles based on fractal level
                level = floor(Int, log2(i + 1))
                data_idx = min(length(data_normalized), i)
                θ = data_normalized[data_idx] / (2^level) * π
                r = r |> put(nqubits, i, RX(θ))
                r = r |> put(nqubits, i, RY(θ * π / 2))
            end
            # Entangling layer
            for i in 1:(nqubits-1)
                r = r |> cnot(nqubits, i, i+1)
            end
        end
        return r
    end
    
    return reg
end

"""
    quantum_kernel(x1::Vector{Float64}, x2::Vector{Float64}, nqubits::Int, nlayers::Int) -> Float64

Compute quantum kernel between two data points using quantum feature maps.

# Arguments
- `x1::Vector{Float64}`: First data point
- `x2::Vector{Float64}`: Second data point
- `nqubits::Int`: Number of qubits
- `nlayers::Int`: Number of encoding layers

# Returns
- `Float64`: Kernel value (state overlap)

# Example
```julia
x1 = rand(10)
x2 = rand(10)
kernel_val = quantum_kernel(x1, x2, 4, 3)
```
"""
function quantum_kernel(x1::Vector{Float64}, x2::Vector{Float64}, nqubits::Int, nlayers::Int)::Float64
    try
        # Compute quantum states
        state1 = fractal_feature_map(x1, nqubits, nlayers)
        state2 = fractal_feature_map(x2, nqubits, nlayers)
        
        # Compute state overlap (kernel) - FIX: use proper state vector access
        # Get state vectors
        state_vec1 = Array(state1.state)
        state_vec2 = Array(state2.state)
        
        # Compute overlap: |<ψ1|ψ2>|²
        overlap = abs2(dot(state_vec1, state_vec2))
        
        # Nexus_Integrity penalty: penalize low coherence
        entropy = compute_entanglement_entropy(state1)
        coherence_penalty = 0.05 * abs(entropy - 1.0)  # Target entropy ~1.0
        
        return overlap * exp(-coherence_penalty)
    catch e
        @warn "Error computing quantum kernel: $e"
        return 0.0
    end
end

"""
    compute_kernel_matrix(X::Matrix{Float64}, nqubits::Int, nlayers::Int) -> Matrix{Float64}

Generate kernel matrix for all pairs of data points.

# Arguments
- `X::Matrix{Float64}`: Data matrix (features × samples)
- `nqubits::Int`: Number of qubits
- `nlayers::Int`: Number of encoding layers

# Returns
- `Matrix{Float64}`: Kernel matrix (samples × samples)

# Example
```julia
X = rand(10, 100)
K = compute_kernel_matrix(X, 4, 3)
```
"""
function compute_kernel_matrix(X::Matrix{Float64}, nqubits::Int, nlayers::Int)::Matrix{Float64}
    n_samples = size(X, 2)
    K = zeros(Float64, n_samples, n_samples)
    
    # Compute kernel for all pairs (symmetric, so we can optimize)
    for i in 1:n_samples
        K[i, i] = 1.0  # Self-similarity
        for j in (i+1):n_samples
            k_val = quantum_kernel(X[:, i], X[:, j], nqubits, nlayers)
            K[i, j] = k_val
            K[j, i] = k_val  # Symmetric
        end
    end
    
    return K
end

# Export public functions
export fractal_feature_map, quantum_kernel, compute_kernel_matrix

end # module

