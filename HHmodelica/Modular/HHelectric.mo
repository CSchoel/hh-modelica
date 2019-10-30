within HHmodelica.Modular;
model HHelectric
  Modelica.Electrical.Analog.Basic.Capacitor membrane(C = 1, v(fixed = true, start = -25))  annotation(
    Placement(visible = true, transformation(origin = {-74, 8}, extent = {{10, 10}, {-10, -10}}, rotation = 90)));
  Modelica.Electrical.Analog.Sources.ConstantVoltage V_Na(V = 50)  annotation(
    Placement(visible = true, transformation(origin = {-38, 8}, extent = {{10, 10}, {-10, -10}}, rotation = -90)));
  Modelica.Electrical.Analog.Sources.ConstantVoltage V_K(V = 77)  annotation(
    Placement(visible = true, transformation(origin = {-8, 8}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Electrical.Analog.Sources.ConstantVoltage V_l(V = 55.613)  annotation(
    Placement(visible = true, transformation(origin = {24, 8}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Electrical.Analog.Basic.Conductor G_Na(G = 120)  annotation(
    Placement(visible = true, transformation(origin = {-38, 46}, extent = {{10, 10}, {-10, -10}}, rotation = 90)));
  Modelica.Electrical.Analog.Basic.Conductor G_K(G = 36)  annotation(
    Placement(visible = true, transformation(origin = {-8, 46}, extent = {{10, 10}, {-10, -10}}, rotation = 90)));
  Modelica.Electrical.Analog.Basic.Conductor G_l(G = 0.3)  annotation(
    Placement(visible = true, transformation(origin = {24, 46}, extent = {{10, 10}, {-10, -10}}, rotation = 90)));
  Modelica.Electrical.Analog.Sources.ConstantCurrent externalCurrent(I = 40) annotation(
    Placement(visible = true, transformation(origin = {58, 8}, extent = {{-10, 10}, {10, -10}}, rotation = 90)));
equation
  connect(G_K.n, V_K.p) annotation(
    Line(points = {{-8, 36}, {-8, 36}, {-8, 18}, {-8, 18}}, color = {0, 0, 255}));
  connect(G_l.n, V_l.p) annotation(
    Line(points = {{24, 36}, {24, 36}, {24, 18}, {24, 18}}, color = {0, 0, 255}));
  connect(membrane.p, G_l.p) annotation(
    Line(points = {{-74, 18}, {-74, 18}, {-74, 72}, {24, 72}, {24, 56}, {24, 56}}, color = {0, 0, 255}));
  connect(membrane.p, G_K.p) annotation(
    Line(points = {{-74, 18}, {-74, 18}, {-74, 72}, {-8, 72}, {-8, 56}, {-8, 56}}, color = {0, 0, 255}));
  connect(membrane.p, G_Na.p) annotation(
    Line(points = {{-74, 18}, {-74, 18}, {-74, 72}, {-38, 72}, {-38, 56}, {-38, 56}}, color = {0, 0, 255}));
  connect(membrane.p, externalCurrent.n) annotation(
    Line(points = {{-74, 18}, {-74, 18}, {-74, 72}, {58, 72}, {58, 18}, {58, 18}}, color = {0, 0, 255}));
  connect(membrane.n, externalCurrent.p) annotation(
    Line(points = {{-74, -2}, {-74, -2}, {-74, -20}, {58, -20}, {58, -2}, {58, -2}}, color = {0, 0, 255}));
  connect(V_K.n, membrane.n) annotation(
    Line(points = {{-8, -2}, {-8, -2}, {-8, -20}, {-74, -20}, {-74, -2}, {-74, -2}}, color = {0, 0, 255}));
  connect(V_l.n, membrane.n) annotation(
    Line(points = {{24, -2}, {24, -2}, {24, -20}, {-74, -20}, {-74, -2}, {-74, -2}}, color = {0, 0, 255}));
  connect(membrane.n, V_Na.p) annotation(
    Line(points = {{-74, -2}, {-74, -2}, {-74, -20}, {-38, -20}, {-38, -2}, {-38, -2}}, color = {0, 0, 255}));
  connect(V_Na.n, G_Na.n) annotation(
    Line(points = {{-38, 18}, {-38, 18}, {-38, 36}, {-38, 36}}, color = {0, 0, 255}));

annotation(
    uses(Modelica(version = "3.2.3")));end HHelectric;
