"""
Performance optimization utilities for QuantumHybridML.

This module provides caching and optimization utilities for improved performance.
"""
module PerformanceModule

using LinearAlgebra

# Cache for frequently used computations
const _circuit_cache = Dict{String, Any}()

"""
    clear_cache()

Clear all performance caches.
"""
function clear_cache()
    empty!(_circuit_cache)
end

"""
    get_cached_or_compute(key::String, compute_fn)

Get a value from cache or compute and cache it.
"""
function get_cached_or_compute(key::String, compute_fn)
    if haskey(_circuit_cache, key)
        return _circuit_cache[key]
    else
        value = compute_fn()
        _circuit_cache[key] = value
        return value
    end
end

"""
    normalize_state!(state::Vector{ComplexF64}) -> Vector{ComplexF64}

Normalize a quantum state vector in-place for efficiency.
"""
function normalize_state!(state::Vector{ComplexF64})::Vector{ComplexF64}
    norm = sqrt(sum(abs2, state))
    if norm < 1e-10
        # Fallback to uniform state
        fill!(state, ComplexF64(1.0 / sqrt(length(state))))
    else
        state ./= norm
    end
    return state
end

"""
    batch_normalize_states!(states::Matrix{ComplexF64})

Normalize multiple quantum states in batch.
"""
function batch_normalize_states!(states::Matrix{ComplexF64})
    for i in 1:size(states, 2)
        normalize_state!(view(states, :, i))
    end
    return states
end

export clear_cache, get_cached_or_compute, normalize_state!, batch_normalize_states!

end # module

