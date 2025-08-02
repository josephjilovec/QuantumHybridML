QuantumHybridML
A hybrid quantum-classical machine learning framework combining Yao.jl, CuYao.jl, and Flux.jl for quantum neural networks with CUDA acceleration.
Overview
QuantumHybridML integrates classical neural networks (via Flux.jl) with quantum circuits (via Yao.jl) and CUDA-accelerated quantum operations (via CuYao.jl). The framework implements a HybridQuantumNN model that processes data through classical layers, applies a quantum circuit layer, and post-processes quantum outputs for downstream tasks. It is designed for researchers exploring quantum machine learning, particularly in hybrid quantum-classical architectures.
Features

Quantum Layer: Custom QuantumLayer struct using Yao.jl for quantum circuit simulation.
CUDA Acceleration: Leverages CuYao.jl for GPU-accelerated quantum operations.
Classical Integration: Uses Flux.jl for seamless integration with classical neural networks.
Extensibility: Modular design for experimenting with quantum circuit architectures.

Installation

Install Julia (version 1.10 or later recommended).
Clone this repository:git clone https://github.com/your-username/QuantumHybridML.git
cd QuantumHybridML


Activate the project environment and install dependencies:julia --project=.
] activate .
] add Yao CuYao Flux LinearAlgebra Optimisers


Run the demo script:julia examples/demo.jl



Usage
The main code is in src/hybrid_quantum_nn.jl. A demo script is provided in examples/demo.jl to showcase model initialization and training. Example:
using Pkg
Pkg.activate(".")
include("src/hybrid_quantum_nn.jl")

Repository Structure

src/: Core implementation of the hybrid quantum-classical model.
examples/: Demo scripts for running the model.
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
For questions, open an issue or reach out on X: @jilovecjoseph
