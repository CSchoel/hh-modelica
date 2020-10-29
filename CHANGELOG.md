# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Added

[nothing]

### Changed

[nothing]

### Fixed

[nothing]

## [1.1.0]

### Added

* variable `v_m` in `HHmodular` and `HHmono` that captures absolute membrane potential as difference between inside and outside potential for plotting
* HTML documentation using [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl) with [MoST.jl](https://github.com/THM-MoTE/ModelicaScriptingTools.jl)

### Changed

* uses [MoST](https://github.com/THM-MoTE/ModelicaScriptingTools.jl) for test script
* plot now displays `v_m` instead of `v` with opposite sign

### Fixed

* unit inconsistency in `HHmono`: currents must be `nA`, not `uA`

## [1.0.1]
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3947849.svg)](https://doi.org/10.5281/zenodo.3947849)


### Added

- this changelog
- plot output in EPS format

### Changed

- adjusts variable names in plotting script
- more verbose description of y-axis in plot
- rasterized plots are generated with 300 DPI

### Fixed

[nothing]

### References

- this version was submitted to Frontiers in Physiology - Computational Physiology and Medicine

## [1.0.0]

### Added

- more documentation
- Julia script for unit testing
- plotting script
- submodule with reference data
- variable `i` in base component to remove need to distinguish between `p.i` and `n.i`
- Travis CI script

### Changed

- clarified parts of documentation
- cleanup of code
  - all variables start with lowercase letters
  - inside/outside or ext/int variables renamed to positive/negative
- renames `scaledExpFit` to `expFit`
- renames `decliningLogisticFit` to `logisticFit`

### Fixed

[nothing]

### References

- this version was submitted to IEEE Transactions on Biomedical Engineering (rejected)

## [0.9.0]

### Added

- full code of modular and monolithic version

### Changed

[nothing]

### Fixed

[nothing]