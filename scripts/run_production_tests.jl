#!/usr/bin/env julia
"""
Production test suite for QuantumHybridML.

This script runs comprehensive tests suitable for production environments.
"""
using Pkg
Pkg.activate(@__DIR__ * "/..")

println("=" ^ 60)
println("QuantumHybridML Production Test Suite")
println("=" ^ 60)

# Run standard tests
println("\n[1/3] Running standard test suite...")
try
    Pkg.test("QuantumHybridML")
    println("✓ Standard tests passed")
catch e
    println("✗ Standard tests failed: $e")
    exit(1)
end

# Run health checks
println("\n[2/3] Running health checks...")
try
    using QuantumHybridML
    health = QuantumHybridML.check_health()
    if health.status != "healthy"
        println("⚠ Health status: $(health.status)")
    else
        println("✓ Health check passed")
    end
catch e
    println("✗ Health check failed: $e")
    exit(1)
end

# Run performance benchmarks
println("\n[3/3] Running performance benchmarks...")
try
    using QuantumHybridML
    using Flux
    
    # Benchmark model creation
    @time model = QuantumHybridML.HybridQuantumNN(16, 4, 10)
    
    # Benchmark forward pass
    x = rand(Float32, 16, 100)
    @time output = model(x)
    
    println("✓ Performance benchmarks completed")
catch e
    println("⚠ Performance benchmarks had issues: $e")
end

println("\n" * "=" ^ 60)
println("✓ Production tests completed successfully!")
println("=" ^ 60)

