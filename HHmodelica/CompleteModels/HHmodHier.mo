within HHmodelica.CompleteModels;
model HHmodHier
  import HHmodelica.Components.Membrane;
  import HHmodelica.Components.CurrentClamp;
  Membrane m;
  // i = 40 => recurring depolarizations
  // i = 0 => v returns to 0
  CurrentClamp c(i=40);
equation
  connect(m.outside, c.ext);
  connect(m.inside, c.int);
annotation(
  experiment(StartTime = 0, StopTime = 0.03, Tolerance = 1e-6, Interval = 1e-05),
  __OpenModelica_simulationFlags(s = "dassl"),
  __ChrisS_testing(testedVariableFilter="c\\.(v|i)|m\\.c_pot\\.(g|gate_act\\.n)|m\\.c_sod\\.(G|gate_act\\.n|gate_inact\\.n)")
);
end HHmodHier;
