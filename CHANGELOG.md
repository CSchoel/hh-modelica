# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Added

nothing

### Changed

nothing

### Fixed

nothing

## [1.2.0]

### Added

- support for OpenModelica 1.15, 1.16, and 1.17
- releases now contain a FMU export of `HHmodular`
- `Project.toml` and `Manifest.toml` so that dependencies can be installed automatically using `Pkg.instantiate()`
- `requirements.txt` to install python dependencies for plotting
- note that indicates that `HHmono` is a 1:1 translation of the JSim implementation
- this changelog now contains links to compare versions
- `package.mo` now contains version number

### Changed

- uses MoST.jl version 1.1
- switched from Travis CI to GitHub Actions
- `clamp_0no_1yes` in `HHmono` is now a `Boolean`

### Fixed

- the main package now properly states that it requires the MSL version 3.2.3

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

[Unreleased]: https://github.com/CSchoel/hh-modelica/compare/v1.2.0..HEAD
[1.2.0]: https://github.com/CSchoel/hh-modelica/compare/v1.1.0..v1.2.0
[1.1.0]: https://github.com/CSchoel/hh-modelica/compare/1.0.1..v1.1.0
[1.0.1]: https://github.com/CSchoel/hh-modelica/compare/1.0.0..1.0.1
[1.0.0]: https://github.com/CSchoel/hh-modelica/compare/0.9.0..1.0.0
[0.9.0]: https://github.com/CSchoel/hh-modelica/releases/tag/0.9.0
