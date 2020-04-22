within HHmodelica.CompleteModels;
model HHmodular1p
  import HHmodelica.Components.OnePin.Membrane;
  import HHmodelica.Components.OnePin.ConstantCurrent;
  Membrane m;
  // I = 40 => recurring depolarizations
  // I = 0 => V returns to 0
  ConstantCurrent ext(I=40) "external current applied to membrane";
equation
  connect(m.p, ext.p);
annotation(
  experiment(StartTime = 0, StopTime = 0.03, Tolerance = 1e-6, Interval = 1e-05),
  __OpenModelica_simulationFlags(s = "dassl"),
  __ChrisS_testing(testedVariableFilter="m\\.l\\.p(v|i)|m\\.c_pot\\.(g|gate_act\\.n)|m\\.c_sod\\.(G|gate_act\\.n|gate_inact\\.n)")
);
end HHmodular1p;
