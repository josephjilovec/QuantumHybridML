"""
Utility functions for QuantumHybridML.

This module provides helper functions for error handling, logging, and CUDA management.
"""
module Utils

using Yao
using CuYao
using Logging

"""
    check_cuda_available() -> Bool

Check if CUDA is available for quantum operations.
Returns true if CUDA is available, false otherwise.
"""
function check_cuda_available()::Bool
    try
        # Try to create a CUDA register
        reg = zero_state(1) |> cu
        return true
    catch
        return false
    end
end

"""
    safe_cuda_apply(f, reg)

Safely apply a function to a quantum register, falling back to CPU if CUDA fails.
"""
function safe_cuda_apply(f, reg)
    try
        if check_cuda_available()
            reg_cuda = reg |> cu
            return f(reg_cuda) |> cpu
        else
            return f(reg)
        end
    catch e
        @warn "CUDA operation failed, falling back to CPU: $e"
        return f(reg)
    end
end

"""
    validate_qubit_count(nqubits::Int) -> Nothing

Validate that the number of qubits is within reasonable bounds.
Throws ArgumentError if invalid.
"""
function validate_qubit_count(nqubits::Int)
    if nqubits < 1
        throw(ArgumentError("Number of qubits must be at least 1, got $nqubits"))
    end
    # Allow up to 20 qubits (configurable limit)
    const MAX_QUBITS = 20
    if nqubits > MAX_QUBITS
        throw(ArgumentError("Number of qubits exceeds practical limit of $MAX_QUBITS, got $nqubits"))
    end
end

"""
    validate_input_dimension(input::AbstractArray, expected::Int) -> Nothing

Validate that input dimensions match expected values.
"""
function validate_input_dimension(input::AbstractArray, expected::Int)
    if size(input, 1) != expected
        throw(DimensionMismatch(
            "Input dimension mismatch: expected $expected, got $(size(input, 1))"
        ))
    end
end

# Export public functions
export check_cuda_available, safe_cuda_apply, validate_qubit_count, validate_input_dimension

end # module Utils

