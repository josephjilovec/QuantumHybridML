# QuantumHybridML API Documentation

## Core Modules

### QuantumHybridML

Main module that exports all public APIs.

```julia
using QuantumHybridML
```

## Hybrid Quantum-Classical Neural Networks

### Types

#### `HybridQuantumNN`

A hybrid quantum-classical neural network model.

```julia
struct HybridQuantumNN
    classical_preprocessor::Chain
    quantum_layer::QuantumLayer
    classical_postprocessor::Chain
end
```

**Constructors:**

```julia
# Convenience constructor
HybridQuantumNN(input_dim::Int, nqubits::Int, output_dim::Int; hidden_dim::Int=32)

# Custom constructor
HybridQuantumNN(preprocessor::Chain, quantum_layer::QuantumLayer, postprocessor::Chain)
```

**Example:**
```julia
model = HybridQuantumNN(16, 4, 10)  # 16 input dim, 4 qubits, 10 output dim
```

#### `QuantumLayer{N}`

A quantum circuit layer for integration into neural networks.

```julia
struct QuantumLayer{N} <: PrimitiveBlock{N}
    nqubits::Int
    params::Vector{Float64}
end
```

**Constructors:**

```julia
QuantumLayer(nqubits::Int, params::Vector{Float64})
```

**Methods:**

- `Yao.nqubits(layer::QuantumLayer)` - Get number of qubits
- `Yao.nparameters(layer::QuantumLayer)` - Get number of parameters

## Variational Quantum Optimization

### Types

#### `VQCOptimizer`

Variational quantum-classical optimizer.

```julia
struct VQCOptimizer
    classical_preprocessor::Chain
    quantum_circuit::VariationalQuantumCircuit
    classical_postprocessor::Chain
    nqubits::Int
end
```

**Constructors:**

```julia
create_vqc_optimizer(nqubits::Int, nlayers::Int; 
                     input_dim::Int=16, 
                     output_dim::Int=16, 
                     hidden_dim::Int=32)
```

**Methods:**

```julia
# Forward pass
(vqc_opt::VQCOptimizer)(x::Matrix{Float32}, y::Matrix{Float32}) -> Tuple{Matrix{Float32}, Float64}

# Training
train_vqc_optimizer!(vqc_opt::VQCOptimizer, 
                     x::Matrix{Float32}, 
                     y::Matrix{Float32}, 
                     epochs::Int=100) -> Tuple{Vector{Float64}, Vector{Float64}}
```

#### `VariationalQuantumCircuit{N}`

Variational quantum circuit with multiple layers.

```julia
struct VariationalQuantumCircuit{N} <: PrimitiveBlock{N}
    nqubits::Int
    nlayers::Int
    params::Vector{Float64}
end
```

### Functions

#### `fractal_state_encoding`

Encode classical data into a quantum state using fractal-inspired encoding.

```julia
fractal_state_encoding(data::Vector{Float64}, nqubits::Int) -> AbstractRegister
```

#### `compute_entanglement_entropy`

Compute von Neumann entropy to quantify entanglement.

```julia
compute_entanglement_entropy(reg::AbstractRegister) -> Float64
```

## Quantum Feature Maps

### Functions

#### `fractal_feature_map`

Create a fractal-inspired quantum feature map.

```julia
fractal_feature_map(data::Vector{Float64}, nqubits::Int, nlayers::Int) -> AbstractRegister
```

#### `quantum_kernel`

Compute quantum kernel between two data points.

```julia
quantum_kernel(x1::Vector{Float64}, x2::Vector{Float64}, nqubits::Int, nlayers::Int) -> Float64
```

#### `compute_kernel_matrix`

Generate kernel matrix for all pairs of data points.

```julia
compute_kernel_matrix(X::Matrix{Float64}, nqubits::Int, nlayers::Int) -> Matrix{Float64}
```

## Utilities

### CUDA Management

#### `check_cuda_available`

Check if CUDA is available.

```julia
check_cuda_available() -> Bool
```

#### `safe_cuda_apply`

Safely apply a function with CUDA fallback.

```julia
safe_cuda_apply(f, reg) -> AbstractRegister
```

### Validation

#### `validate_qubit_count`

Validate qubit count is within bounds.

```julia
validate_qubit_count(nqubits::Int) -> Nothing
```

#### `validate_input_dimension`

Validate input dimensions match expected values.

```julia
validate_input_dimension(input::AbstractArray, expected::Int) -> Nothing
```

## Error Handling

All functions include comprehensive error handling:

- `ArgumentError` - Invalid arguments (e.g., wrong dimensions, invalid qubit counts)
- `DimensionMismatch` - Dimension mismatches in operations
- `Error` - General errors with context information

## Examples

See the `examples/` directory for complete usage examples:

- `examples/demo.jl` - Basic hybrid model usage
- `examples/quantum_feature_map_demo.jl` - Quantum kernel methods

