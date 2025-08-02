QuantumHybridML
A hybrid quantum-classical machine learning framework combining Yao.jl, CuYao.jl, and Flux.jl for quantum neural networks with CUDA acceleration.
Overview
QuantumHybridML integrates classical neural networks (via Flux.jl) with quantum circuits (via Yao.jl) and CUDA-accelerated quantum operations (via CuYao.jl). The framework implements a HybridQuantumNN model and a new VQCOptimizer for variational quantum-classical optimization, featuring fractal-inspired state encoding and entanglement analysis. It is designed for researchers exploring quantum machine learning, particularly in hybrid architectures and variational quantum algorithms.
Features

HybridQuantumNN: Combines classical neural networks with quantum circuit layers for end-to-end learning.
Variational Quantum-Classical Optimization: Implements VQCOptimizer with multi-layer variational circuits, fractal encoding, and custom loss functions inspired by metaphysical concepts like "Nexus_Integrity."
CUDA Acceleration: Leverages CuYao.jl for GPU-accelerated quantum operations.
Entanglement Analysis: Computes von Neumann entropy to study quantum circuit expressivity.
Visualization: Includes training progress and quantum state visualizations using Plots.jl.
Extensibility: Modular design for experimenting with quantum circuit architectures.

Installation

Install Julia (version 1.10 or later recommended).
Clone this repository:git clone https://github.com/jilovecjoseph/QuantumHybridML.git
cd QuantumHybridML


Activate the project environment and install dependencies:julia --project=.
] activate .
] add Yao CuYao Flux LinearAlgebra Optimisers Statistics Plots


Run the demo script:julia examples/demo.jl



Usage
The core code is in src/hybrid_quantum_nn.jl and src/quantum_variational_optimizer.jl. A demo script is provided in examples/demo.jl to showcase model initialization and training. Example:
using Pkg
Pkg.activate(".")
include("src/hybrid_quantum_nn.jl")
include("src/quantum_variational_optimizer.jl")

# Run variational optimizer
vqc_opt = create_vqc_optimizer(4, 3)
x_train = rand(Float32, 16, 100)
y_train = rand(Float32, 16, 100)
losses, entropies = train_vqc_optimizer!(vqc_opt, x_train, y_train)

Repository Structure

src/: Core implementation of the hybrid model and variational optimizer.
hybrid_quantum_nn.jl: Hybrid quantum-classical neural network.
quantum_variational_optimizer.jl: Variational quantum circuit with fractal encoding and entanglement analysis.


examples/: Demo scripts for running the models.
tests/: Unit tests for validating functionality.
Project.toml: Dependency management for Julia.

Contributing
Contributions are welcome! Please open an issue or submit a pull request. See our Contributing Guidelines for details.
Citation
If you use QuantumHybridML in your research, please cite:
@misc{QuantumHybridML2025,
  title={QuantumHybridML: A Hybrid Quantum-Classical Machine Learning Framework},
  author={Your Name},
  year={2025},
  url={https://github.com/your-username/QuantumHybridML}
}

License
This project is licensed under the Apache 2.0 License - see the LICENSE file for details.
Contact
For questions, open an issue or reach out on X: @your-username
