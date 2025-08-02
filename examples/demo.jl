using Pkg
Pkg.activate(".")
using Yao, CuYao, Flux, LinearAlgebra, Optimisers, Statistics, Plots
include("../src/hybrid_quantum_nn.jl")
include("../src/quantum_variational_optimizer.jl")

# Generate dummy data
x_train = rand(Float32, 16, 100)
y_train = rand(Float32, 16, 100) # Replace with actual labels

# Run the hybrid model
println("Running HybridQuantumNN...")
output_hybrid = model(x_train)
println("Hybrid model output (first 2 samples): ", output_hybrid[:, 1:2])

# Run the variational optimizer
println("\nRunning VQCOptimizer...")
vqc_opt = create_vqc_optimizer(4, 3)
losses, entropies = train_vqc_optimizer!(vqc_opt, x_train, y_train, 10) # Shortened for demo
println("Final loss: ", losses[end], ", Final entropy: ", entropies[end])

# Display training plot
display("image/png", read("training_progress.png"))
