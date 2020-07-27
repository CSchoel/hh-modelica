within HHmodelica.CompleteModels;
model HHmodular "'flat' version of the modular model (no membrane container)"
  HHmodelica.Components.PotassiumChannel c_pot annotation(
    Placement(visible = true, transformation(origin = {-33, 3}, extent = {{-17, -17}, {17, 17}}, rotation = 0)));
  HHmodelica.Components.SodiumChannel c_sod annotation(
    Placement(visible = true, transformation(origin = {1,3}, extent = {{-17, -17}, {17, 17}}, rotation = 0)));
  HHmodelica.Components.LeakChannel c_leak annotation(
    Placement(visible = true, transformation(origin = {35, 3}, extent = {{-17, -17}, {17, 17}}, rotation = 0)));
  HHmodelica.Components.LipidBilayer l2 annotation(
    Placement(visible = true, transformation(origin = {-67, 3}, extent = {{-17, -17}, {17, 17}}, rotation = 0)));
  HHmodelica.Components.CurrentClamp clamp annotation(
    Placement(visible = true, transformation(origin = {69, 3}, extent = {{-17, -17}, {17, 17}}, rotation = 0)));
equation
  connect(l2.p, c_pot.p) annotation(
    Line(points = {{-66, 20}, {-66, 40}, {-33, 40}, {-33, 20}}, color = {0, 0, 255}));
  connect(c_pot.p, c_sod.p) annotation(
    Line(points = {{-33, 20}, {-32, 20}, {-32, 40}, {0, 40}, {0, 20}, {2, 20}}, color = {0, 0, 255}));
  connect(c_sod.p, c_leak.p) annotation(
    Line(points = {{2, 20}, {2, 20}, {2, 40}, {34, 40}, {34, 20}, {36, 20}}, color = {0, 0, 255}));
  connect(c_leak.p, clamp.p) annotation(
    Line(points = {{36, 20}, {36, 20}, {36, 40}, {68, 40}, {68, 20}, {70, 20}}, color = {0, 0, 255}));
  connect(clamp.n, c_leak.n) annotation(
    Line(points = {{70, -14}, {68, -14}, {68, -40}, {36, -40}, {36, -14}, {36, -14}}, color = {0, 0, 255}));
  connect(c_leak.n, c_sod.n) annotation(
    Line(points = {{36, -14}, {34, -14}, {34, -40}, {2, -40}, {2, -14}, {2, -14}}, color = {0, 0, 255}));
  connect(c_sod.n, c_pot.n) annotation(
    Line(points = {{2, -14}, {0, -14}, {0, -40}, {-32, -40}, {-32, -14}, {-33, -14}}, color = {0, 0, 255}));
  connect(c_pot.n, l2.n) annotation(
    Line(points = {{-33, -14}, {-33, -40}, {-66, -40}, {-66, -14}}, color = {0, 0, 255}));
  connect(l2.temp, c_pot.temp) annotation(
    Line(points = {{-58, 12}, {-58, 16}, {-42, 16}, {-42, 13}}, color = {255, 0, 0}));
  connect(c_pot.temp, c_sod.temp) annotation(
    Line(points = {{-42, 13}, {-40, 13}, {-40, 16}, {-8, 16}, {-8, 12}}, color = {255, 0, 0}));
annotation(
  experiment(StartTime = 0, StopTime = 0.03, Tolerance = 1e-6, Interval = 1e-05),
  __OpenModelica_simulationFlags(s = "dassl"),
  __MoST_experiment(variableFilter="clamp\\.(v|i)|c_pot\\.(g|gate_act\\.n)|c_sod\\.(g|gate_act\\.n|gate_inact\\.n)")
);
end HHmodular;
