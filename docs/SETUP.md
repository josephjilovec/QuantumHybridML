# QuantumHybridML Setup Guide

## Prerequisites

- **Julia**: Version 1.10 or later
- **CUDA** (optional): For GPU acceleration (CUDA 12.2+ recommended)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/josephjilovec/QuantumHybridML.git
cd QuantumHybridML
```

### 2. Activate the Project

```bash
julia --project=.
```

### 3. Install Dependencies

In the Julia REPL:

```julia
using Pkg
Pkg.instantiate()
```

This will install all required dependencies:
- Yao.jl - Quantum circuit framework
- CuYao.jl - CUDA-accelerated quantum operations
- Flux.jl - Neural network framework
- Optimisers.jl - Optimization algorithms
- Plots.jl - Visualization
- LIBSVM.jl - Support vector machines
- MLDatasets.jl - Machine learning datasets

### 4. Verify Installation

Run the test suite:

```julia
using Pkg
Pkg.test("QuantumHybridML")
```

Or run tests manually:

```julia
include("tests/runtests.jl")
```

## CUDA Setup (Optional)

For GPU acceleration:

1. Install CUDA toolkit (version 12.2 or later)
2. Install CUDA.jl:

```julia
using Pkg
Pkg.add("CUDA")
```

3. Verify CUDA availability:

```julia
using QuantumHybridML
check_cuda_available()
```

## Quick Start

### Basic Usage

```julia
using QuantumHybridML
using Flux

# Create a hybrid model
model = HybridQuantumNN(16, 4, 10)  # 16 input, 4 qubits, 10 output

# Generate dummy data
x = rand(Float32, 16, 100)

# Forward pass
output = model(x)
```

### Variational Quantum Optimizer

```julia
# Create optimizer
optimizer = create_vqc_optimizer(4, 3, input_dim=16, output_dim=10)

# Prepare data
x = rand(Float32, 16, 100)
y = rand(Float32, 10, 100)

# Train
losses, entropies = train_vqc_optimizer!(optimizer, x, y, 50)
```

### Quantum Feature Maps

```julia
# Compute quantum kernel
x1 = rand(10)
x2 = rand(10)
kernel_val = quantum_kernel(x1, x2, 4, 3)

# Compute kernel matrix
X = rand(10, 100)
K = compute_kernel_matrix(X, 4, 3)
```

## Running Examples

### Basic Demo

```bash
julia examples/demo.jl
```

### Quantum Feature Map Demo

```bash
julia examples/quantum_feature_map_demo.jl
```

## Troubleshooting

### CUDA Issues

If CUDA is not available:
- The framework automatically falls back to CPU
- No action required
- Check CUDA installation if GPU acceleration is desired

### Dependency Issues

If package installation fails:
1. Update Julia: `julia --version` (should be 1.10+)
2. Update package registry: `Pkg.update()`
3. Try installing dependencies individually

### Memory Issues

For large models:
- Reduce batch size
- Use fewer qubits
- Consider CPU-only mode if CUDA memory is limited

## Development Setup

For development:

1. Clone the repository
2. Activate the project: `julia --project=.`
3. Install dependencies: `Pkg.instantiate()`
4. Run tests: `Pkg.test()`

## Getting Help

- Check the [API Documentation](API.md)
- Review [Architecture Documentation](ARCHITECTURE.md)
- Open an issue on GitHub
- Contact: @josephjilovec on X

