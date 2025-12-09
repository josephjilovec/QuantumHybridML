# QuantumHybridML - Quick Start Guide

Get up and running with QuantumHybridML in 5 minutes!

## Installation

```bash
# Clone the repository
git clone https://github.com/josephjilovec/QuantumHybridML.git
cd QuantumHybridML

# Activate and install
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

## Verify Installation

```bash
julia scripts/verify_installation.jl
```

## Basic Usage

```julia
using QuantumHybridML
using Flux

# Create a model
model = HybridQuantumNN(16, 4, 10)  # input_dim, nqubits, output_dim

# Use it
x = rand(Float32, 16, 100)
output = model(x)
```

## Run Examples

```bash
# Basic demo
julia examples/demo.jl

# Quantum feature map demo
julia examples/quantum_feature_map_demo.jl
```

## Health Check

```julia
using QuantumHybridML

# Check system health
health = check_health()
println("Status: $(health.status)")
println("CUDA: $(health.cuda_available)")
```

## Next Steps

- Read [docs/API.md](docs/API.md) for full API reference
- Check [docs/SETUP.md](docs/SETUP.md) for detailed setup
- See [DEPLOYMENT.md](DEPLOYMENT.md) for production deployment
- Review [examples/](examples/) for more examples

## Troubleshooting

**CUDA not available?** No problem! The framework automatically falls back to CPU.

**Import errors?** Run `Pkg.instantiate()` to install dependencies.

**Need help?** Check [docs/SETUP.md](docs/SETUP.md) or open an issue.

