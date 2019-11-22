within HHmodelica.CompleteModels;
model HHmodular
  import HHmodelica.Components.Membrane;
  import HHmodelica.Components.CurrentClamp;
  Membrane m;
  // I = 40 => recurring depolarizations
  // I = 0 => V returns to 0
  CurrentClamp c(I=40);
equation
  connect(m.outside, c.ext);
  connect(m.inside, c.int);
annotation(
  experiment(StartTime = 0, StopTime = 0.03, Tolerance = 1e-6, Interval = 1e-05),
  __OpenModelica_simulationFlags(outputFormat = "csv", s = "dassl")
);
end HHmodular;
