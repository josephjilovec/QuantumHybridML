"""
QuantumHybridML - A hybrid quantum-classical machine learning framework.

This module provides tools for combining classical neural networks with quantum circuits
for end-to-end learning, variational quantum optimization, and quantum kernel methods.
"""
module QuantumHybridML

using Yao
using CuYao
using Flux
using LinearAlgebra
using Statistics
using Optimisers
using Logging

# Include submodules
include("config.jl")
include("utils.jl")
include("logging.jl")
include("performance.jl")
include("health.jl")
include("startup.jl")
include("hybrid_quantum_nn.jl")
include("quantum_variational_optimizer.jl")
include("quantum_feature_map.jl")

# Import from submodules
using .ConfigModule
using .Utils
using .LoggingModule
using .PerformanceModule
using .HealthModule
using .StartupModule
using .HybridQuantumNNModule
using .VariationalOptimizerModule
using .QuantumFeatureMapModule

# Re-export commonly used types and functions
export HybridQuantumNN, QuantumLayer
export VQCOptimizer, VariationalQuantumCircuit
export fractal_state_encoding, compute_entanglement_entropy
export create_vqc_optimizer, train_vqc_optimizer!
export fractal_feature_map, quantum_kernel, compute_kernel_matrix
export check_cuda_available, safe_cuda_apply
export validate_qubit_count, validate_input_dimension
export HealthStatus, check_health, is_healthy
export clear_cache, normalize_state!, batch_normalize_states!

end # module

