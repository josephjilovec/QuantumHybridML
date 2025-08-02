QuantumHybridML
A hybrid quantum-classical machine learning framework combining Yao.jl, CuYao.jl, and Flux.jl for quantum neural networks with CUDA acceleration.
Overview
QuantumHybridML is a cutting-edge framework that integrates classical neural networks (via Flux.jl) with quantum circuits (via Yao.jl) and CUDA-accelerated quantum operations (via CuYao.jl). Developed by Joseph Jilovec, it implements a HybridQuantumNN model, a VQCOptimizer for variational quantum-classical optimization, and a quantum feature map demo for kernel-based classification. The framework is designed for researchers exploring quantum machine learning, particularly in hybrid architectures, variational algorithms, and quantum kernel methods, with unique features inspired by metaphysical concepts like fractal dimensional expansion and Nexus Integrity.
Features

HybridQuantumNN: Combines classical neural networks with quantum circuit layers for end-to-end learning.
Variational Quantum-Classical Optimization: Implements VQCOptimizer with multi-layer variational circuits, fractal-inspired state encoding, and entanglement analysis.
Quantum Feature Map: Demonstrates a fractal-inspired quantum feature map with kernel-based classification, comparing quantum and classical SVMs.
CUDA Acceleration: Leverages CuYao.jl for GPU-accelerated quantum operations, with CPU fallbacks for accessibility.
Entanglement Analysis: Computes von Neumann entropy to quantify quantum circuit expressivity, ideal for studying quantum advantage.
Visualization: Includes training progress, decision boundaries, and quantum state fidelity plots using Plots.jl.
Metaphysical Inspiration: Incorporates fractal encoding and a Nexus_Integrity-based kernel, inspired by a unified consciousness framework.
Extensibility: Modular design for experimenting with quantum circuit architectures and machine learning tasks.

Installation

Install Julia (version 1.10 or later recommended).
Clone this repository:git clone https://github.com/josephjilovec/QuantumHybridML.git
cd QuantumHybridML


Activate the project environment and install dependencies:julia --project=.
] activate .
] add Yao CuYao Flux LinearAlgebra Optimisers Statistics Plots LIBSVM MLDatasets


Run the demo scripts:julia examples/demo.jl
julia examples/quantum_feature_map_demo.jl



Usage
The core code resides in src/hybrid_quantum_nn.jl and src/quantum_variational_optimizer.jl. Demo scripts are provided in examples/:

demo.jl: Runs the hybrid model and variational optimizer, showcasing training and entanglement analysis.
quantum_feature_map_demo.jl: Demonstrates quantum feature mapping with kernel-based classification on a synthetic dataset, including visualizations of decision boundaries and state fidelities.

Example usage:
using Pkg
Pkg.activate(".")
include("src/hybrid_quantum_nn.jl")
include("src/quantum_variational_optimizer.jl")
include("examples/quantum_feature_map_demo.jl")

# Run quantum feature map demo
run_quantum_feature_map_demo()

Repository Structure

src/:
hybrid_quantum_nn.jl: Hybrid quantum-classical neural network implementation.
quantum_variational_optimizer.jl: Variational quantum circuit with fractal encoding and entanglement analysis.


examples/:
demo.jl: Basic demo for hybrid model and variational optimizer.
quantum_feature_map_demo.jl: Quantum feature map with kernel-based classification and visualizations.


tests/: Unit tests for validating functionality.
Project.toml: Dependency management for Julia.

Contributing
Contributions are welcome! Please open an issue or submit a pull request. See our Contributing Guidelines for details.
Citation
If you use QuantumHybridML in your research, please cite:
@misc{QuantumHybridML2025,
  title={QuantumHybridML: A Hybrid Quantum-Classical Machine Learning Framework},
  author={Joseph Jilovec},
  year={2025},
  url={https://github.com/josephjilovec/QuantumHybridML}
}

License
This project is licensed under the Apache 2.0 License - see the LICENSE file for details.
Contact
For questions, open an issue or reach out on X: @josephjilovec
