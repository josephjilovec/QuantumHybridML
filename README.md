# QuantumHybridML

A hybrid quantum-classical machine learning framework combining Yao.jl, CuYao.jl, and Flux.jl for quantum neural networks with CUDA acceleration.

## 🚀 Production Status

✅ **Production Ready** - This repository has been comprehensively audited and refactored for production deployment.

### Recent Updates
- ✅ Comprehensive test suite with automated CI/CD
- ✅ Structured logging infrastructure
- ✅ Error handling and input validation
- ✅ Modular architecture with proper separation of concerns
- ✅ Complete API documentation
- ✅ CUDA fallback mechanisms
- ✅ Production deployment guides

See [CHANGELOG.md](CHANGELOG.md) for detailed changes and [REFACTORING_SUMMARY.md](REFACTORING_SUMMARY.md) for refactoring details.

## Overview

QuantumHybridML is a cutting-edge framework that integrates classical neural networks (via Flux.jl) with quantum circuits (via Yao.jl) and CUDA-accelerated quantum operations (via CuYao.jl). Developed by Joseph Jilovec, it implements a HybridQuantumNN model, a VQCOptimizer for variational quantum-classical optimization, and quantum feature maps for kernel-based classification. The framework is designed for researchers exploring quantum machine learning, particularly in hybrid architectures, variational algorithms, and quantum kernel methods, with unique features inspired by fractal dimensional expansion and Nexus Integrity.

## Features

- **HybridQuantumNN**: Combines classical neural networks with quantum circuit layers for end-to-end learning
- **Variational Quantum-Classical Optimization**: Implements VQCOptimizer with multi-layer variational circuits, fractal-inspired state encoding, and entanglement analysis
- **Quantum Feature Maps**: Fractal-inspired quantum feature maps with kernel-based classification, comparing quantum and classical SVMs
- **CUDA Acceleration**: Leverages CuYao.jl for GPU-accelerated quantum operations, with automatic CPU fallbacks
- **Entanglement Analysis**: Computes von Neumann entropy to quantify quantum circuit expressivity
- **Visualization**: Includes training progress, decision boundaries, and quantum state fidelity plots using Plots.jl
- **Extensibility**: Modular design for experimenting with quantum circuit architectures and machine learning tasks
- **Production Ready**: Comprehensive error handling, logging, testing, and documentation

## Installation

### Prerequisites

- Julia version 1.10 or later
- CUDA (optional, for GPU acceleration)

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/josephjilovec/QuantumHybridML.git
   cd QuantumHybridML
   ```

2. **Activate the project and install dependencies:**
   ```bash
   julia --project=.
   ```
   
   In the Julia REPL:
   ```julia
   using Pkg
   Pkg.instantiate()
   ```

3. **Run tests:**
   ```julia
   Pkg.test()
   ```

For detailed setup instructions, see [docs/SETUP.md](docs/SETUP.md).

## Usage

### Basic Example

```julia
using QuantumHybridML
using Flux

# Create a hybrid quantum-classical model
model = HybridQuantumNN(16, 4, 10)  # input_dim=16, nqubits=4, output_dim=10

# Generate data
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

### Running Examples

```bash
# Basic demo
julia examples/demo.jl

# Quantum feature map demo
julia examples/quantum_feature_map_demo.jl
```

For more examples and detailed API documentation, see [docs/API.md](docs/API.md).

## Repository Structure

```
QuantumHybridML/
├── src/
│   ├── QuantumHybridML.jl          # Main module
│   ├── utils.jl                     # Utility functions
│   ├── logging.jl                   # Logging infrastructure
│   ├── hybrid_quantum_nn.jl        # Hybrid NN implementation
│   ├── quantum_variational_optimizer.jl  # VQC optimizer
│   └── quantum_feature_map.jl      # Quantum feature maps
├── examples/
│   ├── demo.jl                      # Basic usage demo
│   └── quantum_feature_map_demo.jl  # Kernel methods demo
├── tests/
│   ├── test_hybrid.jl               # Comprehensive tests
│   └── runtests.jl                  # Test runner
├── docs/
│   ├── API.md                       # API documentation
│   ├── ARCHITECTURE.md              # Architecture guide
│   └── SETUP.md                     # Setup instructions
├── .github/
│   └── workflows/
│       └── ci.yml                   # CI/CD workflows
├── CHANGELOG.md                     # Version history
├── REFACTORING_SUMMARY.md           # Refactoring details
└── README.md                         # This file
```

## Documentation

- [API Documentation](docs/API.md) - Complete API reference
- [Architecture Guide](docs/ARCHITECTURE.md) - System architecture and design
- [Setup Guide](docs/SETUP.md) - Detailed installation and setup
- [Changelog](CHANGELOG.md) - Version history and changes
- [Refactoring Summary](REFACTORING_SUMMARY.md) - Production readiness improvements

## Testing

Run the comprehensive test suite:

```julia
using Pkg
Pkg.test("QuantumHybridML")
```

Or run tests manually:

```julia
include("tests/runtests.jl")
```

The test suite includes:
- Unit tests for all modules
- Integration tests for end-to-end workflows
- Error case testing
- Performance benchmarks

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Submit a pull request

## Citation

If you use QuantumHybridML in your research, please cite:

```bibtex
@misc{QuantumHybridML2025,
  title={QuantumHybridML: A Hybrid Quantum-Classical Machine Learning Framework},
  author={Joseph Jilovec},
  year={2025},
  url={https://github.com/josephjilovec/QuantumHybridML}
}
```

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

## Contact

For questions, open an issue or reach out on X: [@josephjilovec](https://x.com/josephjilovec)

## Acknowledgments

Built with:
- [Yao.jl](https://github.com/QuantumBFS/Yao.jl) - Quantum circuit framework
- [CuYao.jl](https://github.com/QuantumBFS/CuYao.jl) - CUDA-accelerated quantum operations
- [Flux.jl](https://github.com/FluxML/Flux.jl) - Neural network framework
