# HH-Modelica

[![Run tests](https://github.com/CSchoel/hh-modelica/actions/workflows/test.yml/badge.svg)](https://github.com/CSchoel/hh-modelica/actions/workflows/test.yml)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3947849.svg)](https://doi.org/10.5281/zenodo.3947849)
[![BioModels](https://img.shields.io/badge/BioModels-MODEL2103050003-377)](https://www.ebi.ac.uk/biomodels/MODEL2103050003)

This repository contains a modular implementation of the [Hodgkin-Huxley equations](https://en.wikipedia.org/wiki/Hodgkin%E2%80%93Huxley_model) that has two aims:

1. Increase the understandability of the Hodgkin-Huxley model for novices by keeping the amount of variables and equations per component very low and bridging the gap between biological meaning and electrical analogy.
2. Serve as a unifying basis for extensions by experts and therefore facilitate the creation of more complex Hogdkin-Huxley-type models.

## Documentation

A HTML [documentation of the model](https://cschoel.github.io/hh-modelica/dev/) can be found on GitHub pages.

## Quick guide

To simulate the models in this repository you can use the following steps:

* Download and install [OpenModelica](https://www.openmodelica.org/).
* Clone this repository with Git or download a [ZIP file of the current master branch](https://github.com/CSchoel/hh-modelica/archive/master.zip) and extract it with an archive manager of your choice.
* Start the OpenModelica Connection Editor (OMEdit) and open the folder `HHmodelica` with "File" → "Load Library".
* Open the model you want to simulate, e.g. `HHModelica.CompleteModels.HHmodular` (select from "Libraries Browser" on the left hand side with a double click).
* Simulate the model with "Simulation" → "Simulate".
* In the "Variables Browser" on the right hand side select the variable `clamp.v`.

## Project structure

* `HHmodelica/CompleteModels` contains complete Hodgkin-Huxley models that are ready for simulation
  * `HHelectric.mo` is a model that consists of electric components from the Modelica standard library.
      It should be mainly used as a reference for how the diagram view of a completely electrical implementation would look.
      Direct simulation will not yield any usable results as the voltage-dependent change of conductance in ion channels is not included.
  * `HHmodular.mo` is the main modular implementation.
      It directly contains all ion channels, the lipid bilayer and the current clamp on one hierarchical layer.
  * `HHmodHier.mo` is the same as `HHmodFlat.mo`, but with an additional hierarchical layer that combines lipid bilayer and ion channels to a  "membrane" model which is then connected to the current clamp.
  * `HHmodular1p.mo` is analog to `HHmodular.mo`, but features a reduced interface that abandons the analogy of an electric circuit by only using a single pin to connect the components.
      This development branch is discontinued, because I do not think the reduction in the number of equations justifies to break the circuit analogy and therefore make the diagram view less intuitive.
  * `HHmono.mo` is a "classical" monolithic implementation of the Hogdkin-Huxley equations.
* `HHmodelica/Components/package.mo` contains components used for the modular models with regular two-pin components.
* `HHmodelica/Components/OnePin/package.mo` contains components used for the one-pin model `HHmodular1p.mo`.
* `HHmodelica/Components/Icons` contains empty models with graphical annotations that are used to give a graphical representation to modular model components.
* `img` contains SVG images that were used to create the graphical annotations for the component icons (with a currently unpublished Inkscape plugin).
* `regRefData` is a submodule that links to the repository [HH-modelica-ref](https://github.com/CSchoel/hh-modelica-ref) which contains reference data for the regression tests (see below).
* `scripts` contains scripts for testing and plotting (see below).

## Testing

The file `scripts/unittests.jl` contains a Julia script that uses [OMJulia](https://github.com/OpenModelica/OMJulia.jl) to interface with the OpenModelica compiler.
To install all necessary dependencies you have do the following:

1. Download and install [Julia](https://julialang.org/).
2. Run the following commands in a terminal from the repository folder:
  * `julia -e 'ENV["PYTHON"]=""; using Pkg; Pkg.add(PackageSpec(url="https://github.com/THM-MoTE/ModelicaScriptingTools.jl.git"))'`
  * `julia scripts/unittests.jl`

### Test output

The test suite produces simulation outputs in the folder `out` (will be created).
These outputs are used by the plotting script (see below).

### Regression tests

The test suite also contains regression tests that are used to check whether a change in the code has introduced any unforeseen change in the simulation output.
For this I store the latest verified simulation results in a [separate repository](https://github.com/CSchoel/hh-modelica-ref).
This is done to ensure that the large (currently ~2MB) data files do not inflate the size of the git history of this project.
The reference files are downloaded automatically when you call `git submodule update --init`.

## Plots

The plot from the publication (see below) can be reproduced by calling `python plot_compare.py` in the `scripts` directory.
The plotting script depends on the data generated by the unit tests (see above) and will generate plots in the folder `plots` (will be created).

## Publication

This project has been published in Frontiers in Physiology - Computational Physiology and Medicine:

C. Schölzel, V. Blesius, G. Ernst, and A. Dominik, “An understandable, extensible, and reusable implementation of the Hodgkin-Huxley equations using Modelica,” Front. Physiol., vol. 11, p. 583203, 2020, doi: <a href="https://doi.org/10.3389/fphys.2020.583203">10.3389/fphys.2020.583203</a>.
