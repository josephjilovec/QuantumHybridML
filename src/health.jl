"""
Health check and monitoring utilities for QuantumHybridML.

This module provides health check functions for production monitoring.
"""
module HealthModule

using ..Utils

"""
    HealthStatus

Health status of the QuantumHybridML system.
"""
struct HealthStatus
    status::String  # "healthy", "degraded", "unhealthy"
    cuda_available::Bool
    memory_usage_mb::Float64
    timestamp::Float64
    details::Dict{String, Any}
end

"""
    check_health() -> HealthStatus

Perform a comprehensive health check of the system.
"""
function check_health()::HealthStatus
    status = "healthy"
    details = Dict{String, Any}()
    
    # Check CUDA availability
    cuda_available = check_cuda_available()
    details["cuda_available"] = cuda_available
    
    # Check memory usage (approximate)
    memory_usage_mb = 0.0
    try
        # Try to get memory info if available
        if isdefined(Base, :Sys) && hasmethod(Base.Sys.total_memory, ())
            mem_info = Base.Sys.total_memory() / (1024^2)  # MB
            details["total_memory_mb"] = mem_info
            memory_usage_mb = mem_info
        else
            details["memory_check"] = "not_available"
        end
    catch
        memory_usage_mb = 0.0
        details["memory_check"] = "failed"
    end
    
    # Check if basic quantum operations work
    try
        reg = zero_state(2)
        test_circuit = chain(2, put(2, 1, H), cnot(2, 1, 2))
        reg = reg |> test_circuit
        details["quantum_ops"] = "working"
    catch e
        status = "degraded"
        details["quantum_ops"] = "error: $e"
    end
    
    # Check Julia version
    details["julia_version"] = string(VERSION)
    
    # Get current time
    current_time = time()
    
    return HealthStatus(
        status,
        cuda_available,
        memory_usage_mb,
        current_time,
        details
    )
end

"""
    is_healthy() -> Bool

Quick health check returning true if system is healthy.
"""
function is_healthy()::Bool
    health = check_health()
    return health.status == "healthy"
end

export HealthStatus, check_health, is_healthy

end # module

