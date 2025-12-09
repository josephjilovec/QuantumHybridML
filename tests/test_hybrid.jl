"""
Comprehensive tests for HybridQuantumNN module.
"""
using Test
using Pkg
Pkg.activate(@__DIR__ * "/..")

using QuantumHybridML
using Flux
using LinearAlgebra

@testset "HybridQuantumNN Tests" begin
    @testset "QuantumLayer" begin
        # Test creation
        layer = QuantumLayer(4, rand(8))
        @test layer.nqubits == 4
        @test length(layer.params) == 8
        @test Yao.nqubits(layer) == 4
        @test Yao.nparameters(layer) == 8
        
        # Test invalid parameters
        @test_throws ArgumentError QuantumLayer(4, rand(10))  # Wrong number of params
        @test_throws ArgumentError QuantumLayer(0, rand(2))    # Invalid qubit count
        @test_throws ArgumentError QuantumLayer(25, rand(50)) # Too many qubits
    end
    
    @testset "HybridQuantumNN Creation" begin
        # Test convenience constructor
        model = HybridQuantumNN(16, 4, 10)
        @test model.classical_preprocessor isa Chain
        @test model.quantum_layer isa QuantumLayer
        @test model.classical_postprocessor isa Chain
        @test model.quantum_layer.nqubits == 4
        
        # Test custom constructor
        preprocessor = Chain(Dense(16, 32, relu), Dense(32, 16))
        quantum_layer = QuantumLayer(4, rand(8))
        postprocessor = Chain(Dense(16, 32, relu), Dense(32, 10))
        model2 = HybridQuantumNN(preprocessor, quantum_layer, postprocessor)
        @test model2.classical_preprocessor == preprocessor
        @test model2.quantum_layer == quantum_layer
        @test model2.classical_postprocessor == postprocessor
    end
    
    @testset "HybridQuantumNN Forward Pass" begin
        model = HybridQuantumNN(16, 4, 10)
        input = rand(Float32, 16, 10)
        
        # Test forward pass
        output = model(input)
        @test size(output) == (10, 10)  # output_dim × batch_size
        
        # Test with different batch sizes
        input2 = rand(Float32, 16, 1)
        output2 = model(input2)
        @test size(output2) == (10, 1)
        
        # Test dimension mismatch
        bad_input = rand(Float32, 20, 10)
        @test_throws DimensionMismatch model(bad_input)
    end
    
    @testset "CUDA Fallback" begin
        # Test CUDA availability check
        cuda_available = check_cuda_available()
        @test cuda_available isa Bool
        
        # Test safe CUDA apply
        reg = zero_state(4)
        result = safe_cuda_apply(reg) do r
            r |> put(4, 1, H)
        end
        @test result isa AbstractRegister
    end
end

@testset "VariationalOptimizerModule Tests" begin
    @testset "VariationalQuantumCircuit" begin
        # Test creation
        vqc = VariationalQuantumCircuit(4, 3, rand(24))
        @test vqc.nqubits == 4
        @test vqc.nlayers == 3
        @test length(vqc.params) == 24
        @test Yao.nqubits(vqc) == 4
        @test Yao.nparameters(vqc) == 24
        
        # Test invalid parameters
        @test_throws ArgumentError VariationalQuantumCircuit(4, 3, rand(20))
        @test_throws ArgumentError VariationalQuantumCircuit(4, 0, rand(8))
    end
    
    @testset "Fractal State Encoding" begin
        data = rand(10)
        reg = fractal_state_encoding(data, 4)
        @test reg isa AbstractRegister
        @test Yao.nqubits(reg) == 4
        
        # Test with different data sizes
        data2 = rand(2)
        reg2 = fractal_state_encoding(data2, 4)
        @test Yao.nqubits(reg2) == 4
        
        # Test invalid input
        @test_throws ArgumentError fractal_state_encoding(Float64[], 4)
    end
    
    @testset "Entanglement Entropy" begin
        reg = zero_state(4) |> put(4, 1, H) |> cnot(4, 1, 2)
        entropy = compute_entanglement_entropy(reg)
        @test entropy isa Float64
        @test entropy >= 0.0
        @test entropy <= 1.0
    end
    
    @testset "VQCOptimizer" begin
        # Test creation
        optimizer = create_vqc_optimizer(4, 3, input_dim=16, output_dim=10)
        @test optimizer.nqubits == 4
        @test optimizer.classical_preprocessor isa Chain
        @test optimizer.quantum_circuit isa VariationalQuantumCircuit
        @test optimizer.classical_postprocessor isa Chain
        
        # Test forward pass
        x = rand(Float32, 16, 10)
        y = rand(Float32, 10, 10)
        output, loss = optimizer(x, y)
        @test size(output) == size(y)
        @test loss isa Float64
        @test loss >= 0.0
        
        # Test training (short)
        losses, entropies = train_vqc_optimizer!(optimizer, x, y, 2)
        @test length(losses) == 2
        @test length(entropies) == 2
        @test all(losses .>= 0.0)
        @test all(entropies .>= 0.0)
    end
end

@testset "QuantumFeatureMapModule Tests" begin
    @testset "Fractal Feature Map" begin
        data = rand(10)
        reg = fractal_feature_map(data, 4, 3)
        @test reg isa AbstractRegister
        @test Yao.nqubits(reg) == 4
    end
    
    @testset "Quantum Kernel" begin
        x1 = rand(10)
        x2 = rand(10)
        kernel_val = quantum_kernel(x1, x2, 4, 3)
        @test kernel_val isa Float64
        @test kernel_val >= 0.0
        @test kernel_val <= 1.0
        
        # Test symmetry
        kernel_val2 = quantum_kernel(x2, x1, 4, 3)
        @test abs(kernel_val - kernel_val2) < 1e-6
    end
    
    @testset "Kernel Matrix" begin
        X = rand(10, 5)
        K = compute_kernel_matrix(X, 4, 3)
        @test size(K) == (5, 5)
        @test all(K .>= 0.0)
        @test all(K .<= 1.0)
        
        # Test symmetry
        @test K ≈ K'
        
        # Test diagonal (self-similarity)
        @test all(diag(K) .≈ 1.0)
    end
end

@testset "Utils Tests" begin
    @testset "Validation Functions" begin
        # Test qubit count validation
        @test validate_qubit_count(4) === nothing
        @test_throws ArgumentError validate_qubit_count(0)
        @test_throws ArgumentError validate_qubit_count(25)
        
        # Test input dimension validation
        input = rand(16, 10)
        @test validate_input_dimension(input, 16) === nothing
        @test_throws DimensionMismatch validate_input_dimension(input, 20)
    end
end

@testset "Integration Tests" begin
    @testset "End-to-End Pipeline" begin
        # Create model
        model = HybridQuantumNN(16, 4, 10)
        
        # Generate data
        x_train = rand(Float32, 16, 100)
        y_train = rand(Float32, 10, 100)
        
        # Forward pass
        output = model(x_train)
        @test size(output) == (10, 100)
        
        # Test with optimizer
        optimizer = create_vqc_optimizer(4, 3, input_dim=16, output_dim=10)
        output2, loss = optimizer(x_train, y_train)
        @test size(output2) == size(y_train)
        @test loss >= 0.0
    end
end
