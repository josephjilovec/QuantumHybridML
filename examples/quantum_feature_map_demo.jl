using Pkg
Pkg.activate(".")
using Yao, CuYao, Flux, LinearAlgebra, Statistics, Plots, LIBSVM, MLDatasets
using Random: seed!

# Set random seed for reproducibility
seed!(42)

# Fractal-inspired quantum feature map
function fractal_feature_map(data::Vector{Float64}, nqubits::Int, nlayers::Int)
    # Normalize input data to [0, π]
    data = (data .- minimum(data)) ./ (maximum(data) - minimum(data) .+ 1e-10) .* π
    
    # Initialize quantum register
    reg = zero_state(nqubits) |> cu
    
    # Apply fractal-inspired encoding
    idx = 1
    for layer in 1:nlayers
        for i in 1:nqubits
            # Scale angles based on fractal level
            level = floor(Int, log2(i + 1))
            θ = data[min(length(data), i)] / (2^level)
            reg |> put(i=>RX(θ))
            reg |> put(i=>RY(θ * π / 2))
            idx += 1
        end
        # Entangling layer
        for i in 1:nqubits-1
            reg |> CNOT(i, i+1)
        end
    end
    return reg
end

# Quantum kernel with Nexus_Integrity penalty
function quantum_kernel(x1::Vector{Float64}, x2::Vector{Float64}, nqubits::Int, nlayers::Int)
    # Compute quantum states
    state1 = fractal_feature_map(x1, nqubits, nlayers)
    state2 = fractal_feature_map(x2, nqubits, nlayers)
    
    # Compute state overlap (kernel)
    overlap = abs2(state1' * state2)
    
    # Nexus_Integrity penalty: penalize low coherence
    ρ1 = density_matrix(state1)
    evals = eigvals(ρ1)
    evals = real.(evals[evals .> 1e-10])
    entropy = -sum(evals .* log.(evals))
    coherence_penalty = 0.05 * abs(entropy - 1.0) # Target entropy ~1.0
    
    return overlap * exp(-coherence_penalty)
end

# Generate kernel matrix
function compute_kernel_matrix(X::Matrix{Float64}, nqubits::Int, nlayers::Int)
    n_samples = size(X, 2)
    K = zeros(Float64, n_samples, n_samples)
    for i in 1:n_samples
        for j in 1:n_samples
            K[i, j] = quantum_kernel(X[:, i], X[:, j], nqubits, nlayers)
        end
    end
    return K
end

# Generate synthetic dataset (e.g., moons)
function generate_moons_dataset(n_samples::Int=100)
    # Simple moons dataset
    X = zeros(Float64, 2, n_samples)
    y = zeros(Int, n_samples)
    for i in 1:n_samples
        θ = rand() * 2π
        r = rand() < 0.5 ? 1.0 : 0.5
        X[1, i] = r * cos(θ) + (rand() < 0.5 ? 0.0 : 0.5)
        X[2, i] = r * sin(θ)
        y[i] = rand() < 0.5 ? 1 : -1
    end
    return X, y
end

# Train quantum kernel SVM
function train_quantum_svm(X::Matrix{Float64}, y::Vector{Int}, nqubits::Int, nlayers::Int)
    K = compute_kernel_matrix(X, nqubits, nlayers)
    model = svmtrain(K, y, kernel=LIBSVM.Kernel.Precomputed, cost=1.0)
    return model
end

# Train classical RBF SVM for comparison
function train_classical_svm(X::Matrix{Float64}, y::Vector{Int})
    model = svmtrain(X, y, kernel=LIBSVM.Kernel.RadialBasis, gamma=1.0, cost=1.0)
    return model
end

# Visualize decision boundaries
function plot_decision_boundary(X::Matrix{Float64}, y::Vector{Int}, model, kernel_type::String, nqubits::Int, nlayers::Int)
    x_min, x_max = minimum(X[1, :]) - 0.5, maximum(X[1, :]) + 0.5
    y_min, y_max = minimum(X[2, :]) - 0.5, maximum(X[2, :]) + 0.5
    xx = range(x_min, x_max, length=50)
    yy = range(y_min, y_max, length=50)
    
    Z = zeros(Float64, length(yy), length(xx))
    for i in 1:length(xx)
        for j in 1:length(yy)
            x_test = [xx[i]; yy[j]]
            if kernel_type == "quantum"
                K_test = [quantum_kernel(x_test, X[:, k], nqubits, nlayers) for k in 1:size(X, 2)]
                Z[j, i] = svmpredict(model, reshape(K_test, :, 1))[1][1]
            else
                Z[j, i] = svmpredict(model, reshape(x_test, :, 1))[1][1]
            end
        end
    end
    
    p = contourf(xx, yy, Z', c=:coolwarm, alpha=0.5, title="$kernel_type Kernel Decision Boundary")
    scatter!(X[1, y.==1], X[2, y.==1], label="Class 1", c=:blue)
    scatter!(X[1, y.==-1], X[2, y.==-1], label="Class -1", c=:red)
    xlabel!("Feature 1")
    ylabel!("Feature 2")
    savefig(p, "decision_boundary_$(kernel_type).png")
    return p
end

# Main demo function
function run_quantum_feature_map_demo()
    # Parameters
    nqubits = 4
    nlayers = 3
    n_samples = 100
    
    # Generate dataset
    X, y = generate_moons_dataset(n_samples)
    
    # Train quantum kernel SVM
    println("Training Quantum Kernel SVM...")
    quantum_model = train_quantum_svm(X, y, nqubits, nlayers)
    
    # Train classical RBF SVM
    println("Training Classical RBF SVM...")
    classical_model = train_classical_svm(X, y)
    
    # Evaluate models
    K_quantum = compute_kernel_matrix(X, nqubits, nlayers)
    y_pred_quantum = svmpredict(quantum_model, K_quantum)[1]
    y_pred_classical = svmpredict(classical_model, X)[1]
    
    accuracy_quantum = mean(y_pred_quantum .== y)
    accuracy_classical = mean(y_pred_classical .== y)
    println("Quantum Kernel Accuracy: $accuracy_quantum")
    println("Classical RBF Accuracy: $accuracy_classical")
    
    # Visualize decision boundaries
    p_quantum = plot_decision_boundary(X, y, quantum_model, "quantum", nqubits, nlayers)
    p_classical = plot_decision_boundary(X, y, classical_model, "classical", nqubits, nlayers)
    
    # Plot combined results
    combined_plot = plot(p_quantum, p_classical, layout=(1, 2), size=(800, 400))
    savefig(combined_plot, "combined_decision_boundaries.png")
    display("image/png", read("combined_decision_boundaries.png"))
    
    # Compute and plot quantum state fidelities
    fidelities = Float64[]
    for i in 1:n_samples
        state = fractal_feature_map(X[:, i], nqubits, nlayers)
        fidelity = abs2(state' * zero_state(nqubits))
        push!(fidelities, fidelity)
    end
    p_fidelity = histogram(fidelities, bins=20, label="Fidelity", title="Quantum State Fidelity Distribution", xlabel="Fidelity", ylabel="Count")
    savefig(p_fidelity, "fidelity_distribution.png")
    display("image/png", read("fidelity_distribution.png"))
end

# Run the demo
run_quantum_feature_map_demo()
