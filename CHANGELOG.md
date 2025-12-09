# Changelog

All notable changes to QuantumHybridML will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-01-27

### Added
- Comprehensive module structure with proper separation of concerns
- Error handling and validation throughout the codebase
- Logging infrastructure for debugging and monitoring
- Comprehensive test suite with integration tests
- CI/CD workflows for automated testing
- `.gitignore` file for proper version control
- Type annotations and docstrings for all public APIs
- CUDA fallback mechanism for graceful degradation
- Quantum feature map module for kernel methods
- Utility functions for input validation and CUDA management

### Changed
- Refactored code structure into proper Julia modules
- Fixed critical bugs in quantum layer implementations
- Fixed quantum state overlap calculations
- Fixed quantum circuit application (proper assignment)
- Removed global code from source files
- Improved forward pass implementations
- Enhanced error messages with context

### Fixed
- Fixed `rot` function usage in quantum layers
- Fixed quantum register state modifications (proper assignment)
- Fixed quantum kernel calculations (proper state vector access)
- Fixed dimension mismatches in forward passes
- Fixed test suite to work with new module structure

### Security
- Added input validation to prevent invalid operations
- Added bounds checking for qubit counts
- Improved error handling to prevent information leakage

## [0.1.0] - 2025-01-XX

### Added
- Initial release
- HybridQuantumNN model
- VariationalQuantumCircuit implementation
- Fractal-inspired state encoding
- Entanglement entropy computation
- Quantum feature maps
- Basic examples and demos

