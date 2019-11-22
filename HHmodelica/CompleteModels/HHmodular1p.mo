within HHmodelica.CompleteModels;
model HHmodular1p
  Membrane m;
  // I = 40 => recurring depolarizations
  // I = 0 => V returns to 0
  ConstantCurrent ext(I=40) "external current applied to membrane";
equation
  connect(m.p, ext.p);
annotation(
  experiment(StartTime = 0, StopTime = 0.03, Tolerance = 1e-6, Interval = 1e-05),
  __OpenModelica_simulationFlags(outputFormat = "csv", s = "dassl")
);
end HHmodular1p;
