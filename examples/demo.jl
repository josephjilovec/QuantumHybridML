using Pkg
Pkg.activate(".")
using Yao, CuYao, Flux, LinearAlgebra, Optimisers
include("../src/hybrid_quantum_nn.jl")

# Generate dummy data
dummy_input = rand(Float32, 16, 10)

# Run the model
output = model(dummy_input)

# Print sample output
println("Sample output: ", output[:, 1:2])

# Run a single training epoch
loss, grads = Flux.withgradient(model) do m
    output = m(dummy_input)
    sum(abs2, output)
end
println("Sample loss: ", loss)
