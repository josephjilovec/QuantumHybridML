#!/usr/bin/env julia
"""
Verification script for QuantumHybridML installation.

This script verifies that all components are working correctly.
"""
using Pkg
Pkg.activate(@__DIR__ * "/..")

println("=" ^ 60)
println("QuantumHybridML Installation Verification")
println("=" ^ 60)

# Check dependencies
println("\n[1/5] Checking dependencies...")
try
    using QuantumHybridML
    println("✓ QuantumHybridML loaded successfully")
catch e
    println("✗ Failed to load QuantumHybridML: $e")
    exit(1)
end

# Check CUDA
println("\n[2/5] Checking CUDA availability...")
try
    cuda_available = QuantumHybridML.check_cuda_available()
    if cuda_available
        println("✓ CUDA acceleration available")
    else
        println("⚠ CUDA not available (CPU mode will be used)")
    end
catch e
    println("⚠ CUDA check failed: $e")
end

# Check health
println("\n[3/5] Performing health check...")
try
    health = QuantumHybridML.check_health()
    println("✓ Health status: $(health.status)")
    println("  - CUDA: $(health.cuda_available)")
    println("  - Julia version: $(health.details["julia_version"])")
catch e
    println("✗ Health check failed: $e")
    exit(1)
end

# Test basic operations
println("\n[4/5] Testing basic operations...")
try
    using Flux
    model = QuantumHybridML.HybridQuantumNN(16, 4, 10)
    x = rand(Float32, 16, 10)
    output = model(x)
    @assert size(output) == (10, 10)
    println("✓ HybridQuantumNN forward pass working")
catch e
    println("✗ Basic operations failed: $e")
    exit(1)
end

# Test VQC optimizer
println("\n[5/5] Testing VQC optimizer...")
try
    optimizer = QuantumHybridML.create_vqc_optimizer(4, 3, input_dim=16, output_dim=10)
    x = rand(Float32, 16, 10)
    y = rand(Float32, 10, 10)
    output, loss = optimizer(x, y)
    @assert size(output) == size(y)
    @assert loss >= 0.0
    println("✓ VQCOptimizer working")
catch e
    println("✗ VQC optimizer test failed: $e")
    exit(1)
end

println("\n" * "=" ^ 60)
println("✓ All checks passed! Installation is correct.")
println("=" ^ 60)

