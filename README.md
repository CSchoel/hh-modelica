# HH-Modelica

This repository contains a modular implementation of the Hodgkin-Huxley equations that has two aims:

1. Increase the understandability of the Hodgkin-Huxley model for novices by keeping the amount of variables and equations per component very low and bridging the gap between biological meaning and electrical analogy.
2. Serve as a unifying basis for extensions by experts and therefore facilitate the creation of more complex Hogdkin-Huxley-type models.

## Project structure

* `HHmodelica/CompleteModels` contains complete Hodgkin-Huxley models that are ready for simulation
  * `HHelectric.mo` is a model that consists of electric components from the Modelica standard library.
      It should be mainly used as a reference for how the diagram view of a completely electrical implementation would look.
      Direct simulation will not yield any usable results as the voltage-dependent change of conductance in ion channels is not included.
  * `HHmodFlat.mo` is the main modular implementation.
      It directly contains all ion channels, the lipid bilayer and the current clamp on one hierarchical layer.
  * `HHmodular.mo` is the same as `HHmodFlat.mo`, but with an additional hierarchical layer that combines lipid bilayer and ion channels to a  "membrane" model which is then connected to the current clamp.
  * `HHmodular1p.mo` is analog to `HHmodular.mo`, but features a reduced interface that abandons the analogy of an electric circuit by only using a single pin to connect the components.
      This development branch is discontinued, because I do not think the reduction in the number of equations justifies to break the circuit analogy and therefore make the diagram view less intuitive.
  * `HHmono.mo` is a "classical" monolithic implementation of the Hogdkin-Huxley equations.
* `HHmodelica/Components/package.mo` contains components used for the modular models with regular two-pin components.
* `HHmodelica/Components/OnePin/package.mo` contains components used for the one-pin model `HHmodular1p.mo`.
* `HHmodelica/Components/Icons` contains empty models with graphical annotations that are used to give a graphical representation to modular model components.
* `img` contains SVG images that were used to create the graphical annotations for the component icons (with a currently unpublished Inkscape plugin).

This README is still work in progress (as is the documentation and publication of this code in a scientific journal).
