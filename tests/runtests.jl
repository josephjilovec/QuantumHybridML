"""
Test runner for QuantumHybridML.

Run all tests in the test suite.
"""
using Pkg
Pkg.activate(@__DIR__ * "/..")

# Run all test files
include("test_hybrid.jl")

println("\n" * "="^60)
println("All tests completed!")
println("="^60)

