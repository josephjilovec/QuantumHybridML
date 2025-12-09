"""
Logging infrastructure for QuantumHybridML.

This module provides structured logging capabilities for the framework.
"""
module LoggingModule

using Logging

# Log levels
const LOG_LEVEL_DEBUG = 0
const LOG_LEVEL_INFO = 1
const LOG_LEVEL_WARN = 2
const LOG_LEVEL_ERROR = 3

# Global log level (can be configured)
_log_level = LOG_LEVEL_INFO

"""
    set_log_level(level::Int)

Set the global log level.
- 0: DEBUG
- 1: INFO (default)
- 2: WARN
- 3: ERROR
"""
function set_log_level(level::Int)
    global _log_level
    if level < 0 || level > 3
        throw(ArgumentError("Log level must be between 0 and 3, got $level"))
    end
    _log_level = level
end

"""
    get_log_level() -> Int

Get the current log level.
"""
get_log_level() = _log_level

"""
    @qml_log level message

Log a message at the specified level.
"""
macro qml_log(level, message)
    quote
        if $level >= _log_level
            if $level == LOG_LEVEL_DEBUG
                @debug $message
            elseif $level == LOG_LEVEL_INFO
                @info $message
            elseif $level == LOG_LEVEL_WARN
                @warn $message
            elseif $level == LOG_LEVEL_ERROR
                @error $message
            end
        end
    end
end

"""
    log_quantum_operation(operation::String, nqubits::Int, duration::Float64)

Log a quantum operation with timing information.
"""
function log_quantum_operation(operation::String, nqubits::Int, duration::Float64)
    @qml_log LOG_LEVEL_DEBUG "Quantum operation: $operation (nqubits=$nqubits, duration=$(round(duration, digits=4))s)"
end

"""
    log_training_progress(epoch::Int, loss::Float64, entropy::Float64)

Log training progress information.
"""
function log_training_progress(epoch::Int, loss::Float64, entropy::Float64)
    @qml_log LOG_LEVEL_INFO "Epoch $epoch: Loss=$loss, Entropy=$entropy"
end

# Export public functions
export set_log_level, get_log_level, log_quantum_operation, log_training_progress

end # module

