# HH-Modelica

This project contains a modular implementation of the [Hodgkin-Huxley equations](https://en.wikipedia.org/wiki/Hodgkin%E2%80%93Huxley_model) that has two aims:

1. Increase the understandability of the Hodgkin-Huxley model for novices by keeping the amount of variables and equations per component very low and bridging the gap between biological meaning and electrical analogy.
2. Serve as a unifying basis for extensions by experts and therefore facilitate the creation of more complex Hogdkin-Huxley-type models.

!!! note

    This documentation is work in progress.
    Currently, the extension of Documenter.jl in my package [MoST.jl](https://github.com/THM-MoTE/ModelicaScriptingTools.jl) is still experimental.
    As the package evolves further, this documentation will increase in readabilty.

## Full modular model

```@modelica
%outdir=../out
HHmodelica.CompleteModels.HHmodular
```

## Monolithic reference model

```@modelica
%outdir=../out
HHmodelica.CompleteModels.HHmono
```

## Model structure

The structure of the modular implementation follows both the physiology of the squid giant axon and the electrical analogy that Hodgkin and Huxley used to derive the equations.

### Interfaces

The lipid bilayer, the ion channels, and the current clamp used for the experiment protocol each are electrical components with a basic interface.

```@modelica
%outdir=../out
%noequations
HHmodelica.Components.ElectricalPin
HHmodelica.Components.PositivePin
HHmodelica.Components.NegativePin
```

The voltage-dependent gating molecules of the sodium and potassium channels have an additional interface since they are temperature dependent.

```@modelica
%outdir=../out
%noequations
HHmodelica.Components.TemperatureInput
HHmodelica.Components.TemperatureOutput
```

### Base components

The simplest component of the model is the lipid bilayer, which just acts as a capacitor.

```@modelica
%outdir=../out
%noequations
HHmodelica.Components.LipidBilayer
```

The central components that regulate the shape of the action potential curve are the voltage-dependent ion channels.
These channels all follow the same basic structure

```@modelica
%outdir=../out
%noequations
HHmodelica.Components.IonChannel
HHmodelica.Components.GatedIonChannel
```

The specific ion channels that are built upon those base classes are the fast sodium channel, the (rapid delayed rectifier) potassium channel, and a leak channel.

```@modelica
%outdir=../out
%noequations
HHmodelica.Components.SodiumChannel
HHmodelica.Components.PotassiumChannel
HHmodelica.Components.LeakChannel
```

The behavior of the sodium and potassium channels is defined by gating molecules that have an open and a closed conformation.
All gates in the model follow the same structure.

```@modelica
%outdir=../out
%noequations
HHmodelica.Components.Gate
```

### Fitting functions

Different fitting functions are used to determine the behavior of `fclose` and `fopen` in the

```@modelica
%outdir=../out
%noequations
HHmodelica.Components.expFit
HHmodelica.Components.logisticFit
HHmodelica.Components.goldmanFit
```
