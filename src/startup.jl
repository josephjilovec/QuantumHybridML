"""
Startup checks and initialization for QuantumHybridML.

This module performs system checks and initialization on package load.
"""
module StartupModule

using ..Utils
using ..HealthModule

"""
    perform_startup_checks() -> Bool

Perform startup checks to ensure the system is ready.
Returns true if all checks pass, false otherwise.
"""
function perform_startup_checks()::Bool
    try
        # Check CUDA availability (non-blocking)
        cuda_available = check_cuda_available()
        if cuda_available
            @info "CUDA acceleration available"
        else
            @info "CUDA not available, using CPU"
        end
        
        # Check basic quantum operations
        try
            reg = zero_state(2)
            test_circuit = chain(2, put(2, 1, H), cnot(2, 1, 2))
            reg = reg |> test_circuit
            @debug "Basic quantum operations working"
        catch e
            @error "Basic quantum operations failed: $e"
            return false
        end
        
        # Perform health check
        health = check_health()
        if health.status != "healthy"
            @warn "System health check returned: $(health.status)"
        end
        
        return true
    catch e
        @error "Startup checks failed: $e"
        return false
    end
end

# Perform checks on module load (optional, can be disabled)
const PERFORM_STARTUP_CHECKS = get(ENV, "QML_SKIP_STARTUP_CHECKS", "false") != "true"

if PERFORM_STARTUP_CHECKS
    perform_startup_checks()
end

export perform_startup_checks

end # module

