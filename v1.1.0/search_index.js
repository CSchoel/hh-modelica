var documenterSearchIndex = {"docs":
[{"location":"#HH-Modelica","page":"HH-Modelica","title":"HH-Modelica","text":"","category":"section"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"This project contains a modular implementation of the Hodgkin-Huxley equations that has two aims:","category":"page"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"Increase the understandability of the Hodgkin-Huxley model for novices by keeping the amount of variables and equations per component very low and bridging the gap between biological meaning and electrical analogy.\nServe as a unifying basis for extensions by experts and therefore facilitate the creation of more complex Hogdkin-Huxley-type models.","category":"page"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"note: Note\nThis documentation is work in progress. Currently, the extension of Documenter.jl in my package MoST.jl is still experimental. As the package evolves further, this documentation will increase in readabilty.","category":"page"},{"location":"#Full-modular-model","page":"HH-Modelica","title":"Full modular model","text":"","category":"section"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"%outdir=../out\nHHmodelica.CompleteModels.HHmodular","category":"page"},{"location":"#Monolithic-reference-model","page":"HH-Modelica","title":"Monolithic reference model","text":"","category":"section"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"%outdir=../out\nHHmodelica.CompleteModels.HHmono","category":"page"},{"location":"#Model-structure","page":"HH-Modelica","title":"Model structure","text":"","category":"section"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"The structure of the modular implementation follows both the physiology of the squid giant axon and the electrical analogy that Hodgkin and Huxley used to derive the equations.","category":"page"},{"location":"#Interfaces","page":"HH-Modelica","title":"Interfaces","text":"","category":"section"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"The lipid bilayer, the ion channels, and the current clamp used for the experiment protocol each are electrical components with a basic interface.","category":"page"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"%outdir=../out\n%noequations\nHHmodelica.Components.ElectricalPin\nHHmodelica.Components.PositivePin\nHHmodelica.Components.NegativePin","category":"page"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"The voltage-dependent gating molecules of the sodium and potassium channels have an additional interface since they are temperature dependent.","category":"page"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"%outdir=../out\n%noequations\nHHmodelica.Components.TemperatureInput\nHHmodelica.Components.TemperatureOutput","category":"page"},{"location":"#Base-components","page":"HH-Modelica","title":"Base components","text":"","category":"section"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"The simplest component of the model is the lipid bilayer, which just acts as a capacitor.","category":"page"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"%outdir=../out\n%noequations\nHHmodelica.Components.LipidBilayer","category":"page"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"The central components that regulate the shape of the action potential curve are the voltage-dependent ion channels. These channels all follow the same basic structure","category":"page"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"%outdir=../out\n%noequations\nHHmodelica.Components.IonChannel\nHHmodelica.Components.GatedIonChannel","category":"page"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"The specific ion channels that are built upon those base classes are the fast sodium channel, the (rapid delayed rectifier) potassium channel, and a leak channel.","category":"page"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"%outdir=../out\n%noequations\nHHmodelica.Components.SodiumChannel\nHHmodelica.Components.PotassiumChannel\nHHmodelica.Components.LeakChannel","category":"page"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"The behavior of the sodium and potassium channels is defined by gating molecules that have an open and a closed conformation. All gates in the model follow the same structure.","category":"page"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"%outdir=../out\n%noequations\nHHmodelica.Components.Gate","category":"page"},{"location":"#Fitting-functions","page":"HH-Modelica","title":"Fitting functions","text":"","category":"section"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"Different fitting functions are used to determine the behavior of fclose and fopen in the","category":"page"},{"location":"","page":"HH-Modelica","title":"HH-Modelica","text":"%outdir=../out\n%noequations\nHHmodelica.Components.expFit\nHHmodelica.Components.logisticFit\nHHmodelica.Components.goldmanFit","category":"page"}]
}
