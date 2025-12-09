"""
Demo script for HybridQuantumNN and VQCOptimizer.

This script demonstrates basic usage of the hybrid quantum-classical models.
"""
using Pkg
Pkg.activate(@__DIR__ * "/..")

using QuantumHybridML
using Flux
using Optimisers

println("=" ^ 60)
println("QuantumHybridML Demo")
println("=" ^ 60)

# Health check
println("\n[1/3] System health check...")
health = check_health()
println("Status: $(health.status)")
println("CUDA available: $(health.cuda_available)")

# Generate dummy data
println("\n[2/3] Running HybridQuantumNN...")
x_train = rand(Float32, 16, 100)
y_train = rand(Float32, 10, 100)

# Run the hybrid model
model = HybridQuantumNN(16, 4, 10)  # input_dim=16, nqubits=4, output_dim=10
output_hybrid = model(x_train)
println("✓ Hybrid model output shape: ", size(output_hybrid))
println("  Sample output (first 2): ", output_hybrid[:, 1:2])

# Run the variational optimizer
println("\n[3/3] Running VQCOptimizer...")
vqc_opt = create_vqc_optimizer(4, 3, input_dim=16, output_dim=10)
losses, entropies = train_vqc_optimizer!(vqc_opt, x_train, y_train, 10)  # Shortened for demo
println("✓ Training completed")
println("  Final loss: $(round(losses[end], digits=6))")
println("  Final entropy: $(round(entropies[end], digits=6))")

# Display training plot if available
if isfile("training_progress.png")
    println("\n✓ Training plot saved to training_progress.png")
end

println("\n" * "=" ^ 60)
println("Demo completed successfully!")
println("=" ^ 60)
