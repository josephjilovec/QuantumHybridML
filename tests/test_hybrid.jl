using Test
using Pkg
Pkg.activate(".")
using Yao, CuYao, Flux, LinearAlgebra
include("../src/hybrid_quantum_nn.jl")

@testset "HybridQuantumNN Tests" begin
    # Test model initialization
    @test model.classical_layer isa Chain
    @test model.quantum_layer isa QuantumLayer
    @test Yao.nqubits(model.quantum_layer) == 4

    # Test forward pass
    input = rand(Float32, 16, 10)
    output = model(input)
    @test size(output) == (16, 10)

    # Test quantum layer parameters
    @test length(model.quantum_layer.params) == 8
end
