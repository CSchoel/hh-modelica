within HHmodelica.Modular;
package TwoPin
  model TwoPinComponent
    ElectricalPin p;
    ElectricalPin n;
    Real V(unit="mV");
  equation
    0 = p.I + n.I;
    V = p.V - n.V;
  end TwoPinComponent;

  partial model IonChannel2P "ionic current through the membrane"
    extends TwoPinComponent;
    Real G(unit="mmho/cm2") "ion conductance";
    parameter Real V_eq(unit="mV") "equilibrium potential (as displacement from resting potential)";
    parameter Real G_max(unit="mmho/cm2") "maximum conductance";
  equation
    p.I = G * (V - V_eq);
  end IonChannel2P;

  partial model GatedIonChannel2P "ion channel that has voltage-dependent gates"
    extends IonChannel2P;
    TemperatureInput T "membrane temperature to determine reaction coefficient";
  end GatedIonChannel2P;

  model PotassiumChannel2P "channel selective for K+ ions"
    extends GatedIonChannel2P(G_max=36, V_eq=12);
    Gate gate_act(
      redeclare function falpha= goldmanFit(V_off=10, sdn=100, sV=0.1),
      redeclare function fbeta= scaledExpFit(sx=1/80, sy=125),
      V=V, T=T
    ) "actiaction gate (A = open, B = closed)";
  equation
    G = G_max * gate_act.n ^ 4;
  end PotassiumChannel2P;

  model SodiumChannel2P "channel selective for Na+ ions"
    extends GatedIonChannel2P(G_max=120, V_eq=-115);
    Gate gate_act(
      redeclare function falpha= goldmanFit(V_off=25, sdn=1000, sV=0.1),
      redeclare function fbeta= scaledExpFit(sx=1/18, sy=4000),
      V=V, T=T
    ) "activation gate (A = open, B = closed)";
    Gate gate_inact(
      redeclare function falpha= scaledExpFit(sx=1/20, sy=70),
      redeclare function fbeta= decliningLogisticFit(x0=-30, k=0.1, L=1000),
      V=V, T=T
    ) "inactivation gate (A = closed, b = open)";
  equation
    G = G_max * gate_act.n ^ 3 * gate_inact.n;
  end SodiumChannel2P;

  model LeakChannel2P "constant leakage current of ions through membrane"
    extends IonChannel2P(G_max=0.3, V_eq=-10.613);
  equation
    G = G_max;
  end LeakChannel2P;

  model LipidBilayer2P "lipid bilayer separating external and internal potential (i.e. acting as a capacitor)"
    extends TwoPinComponent;
    TemperatureOutput T = T_m;
    parameter Real T_m(unit="degC") = 6.3 "membrane temperature";
    parameter Real C(unit="uF/cm2") = 1 "membrane capacitance";
  initial equation
    V = -90 "short initial stimulation";
  equation
    der(V) = 1000 * p.I / C; // multiply with 1000 to get mV/s instead of V/s
  end LipidBilayer2P;

  model ConstantCurrent2P
    extends TwoPinComponent;
    parameter Real I;
    ElectricalPin p;
  equation
    p.I = I;
  end ConstantCurrent2P;

  model Ground
    ElectricalPin p;
  equation
    p.V = 0;
  end Ground;

  model Membrane2P
    ElectricalPin outside;
    ElectricalPin inside;
    PotassiumChannel2P c_pot;
    SodiumChannel2P c_sod;
    LeakChannel2P c_leak;
    LipidBilayer2P l;
  equation
    connect(c_pot.p, l.p);
    connect(c_pot.n, l.n);
    connect(c_sod.p, l.p);
    connect(c_sod.n, l.n);
    connect(c_leak.p, l.p);
    connect(c_leak.n, l.n);
    connect(outside, l.p);
    connect(inside, l.n);
    connect(c_pot.T, l.T);
    connect(c_sod.T, l.T);
  end Membrane2P;

  model HH2P
    Membrane2P m;
    // I = 40 => recurring depolarizations
    // I = 0 => V returns to 0
    ConstantCurrent2P ext(I=40) "external current applied to membrane";
    Ground g;
  equation
    connect(m.outside, ext.p);
    connect(m.inside, ext.n);
    connect(m.inside, g.p);
  annotation(
    experiment(StartTime = 0, StopTime = 0.03, Tolerance = 1e-6, Interval = 1e-05),
    __OpenModelica_simulationFlags(outputFormat = "csv", s = "dassl")
  );
  end HH2P;
end TwoPin;
