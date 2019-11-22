within HHmodelica.Components;
package OnePin
  partial model IonChannel "ionic current through the membrane"
    ElectricalPin p "connection to the membrane";
    Real G(unit="mmho/cm2") "ion conductance";
    parameter Real V_eq(unit="mV") "equilibrium potential (as displacement from resting potential)";
    parameter Real G_max(unit="mmho/cm2") "maximum conductance";
  equation
    p.I = G * (p.V - V_eq);
  end IonChannel;

  partial model GatedIonChannel
    extends IonChannel;
    TemperatureInput T "membrane temperature to determine reaction coefficient";
  end GatedIonChannel;

  model PotassiumChannel "channel selective for K+ ions"
    extends GatedIonChannel(G_max=36, V_eq=12);
    Gate gate_act(
      redeclare function falpha= goldmanFit(V_off=10, sdn=100, sV=0.1),
      redeclare function fbeta= scaledExpFit(sx=1/80, sy=125),
      V= p.V, T= T
    ) "actiaction gate (A = open, B = closed)";
  equation
    G = G_max * gate_act.n ^ 4;
  end PotassiumChannel;

  model SodiumChannel "channel selective for Na+ ions"
    extends GatedIonChannel(G_max=120, V_eq=-115);
    Gate gate_act(
      redeclare function falpha= goldmanFit(V_off=25, sdn=1000, sV=0.1),
      redeclare function fbeta= scaledExpFit(sx=1/18, sy=4000),
      V= p.V, T= T
    ) "activation gate (A = open, B = closed)";
    Gate gate_inact(
      redeclare function falpha= scaledExpFit(sx=1/20, sy=70),
      redeclare function fbeta= decliningLogisticFit(x0=-30, k=0.1, L=1000),
      V= p.V, T= T
    ) "inactivation gate (A = closed, b = open)";
  equation
    G = G_max * gate_act.n ^ 3 * gate_inact.n;
  end SodiumChannel;

  model LeakChannel "constant leakage current of ions through membrane"
    extends IonChannel(G_max=0.3, V_eq=-10.613);
  equation
    G = G_max;
  end LeakChannel;

  model LipidBilayer "lipid bilayer separating external and internal potential (i.e. acting as a capacitor)"
    ElectricalPin p;
    TemperatureOutput T = T_m "constant membrane temperature";
    parameter Real T_m(unit="degC") = 6.3 "membrane temperature";
    parameter Real C(unit="uF/cm2") = 1 "membrane capacitance";
    parameter Real V_init(unit="mV") = -90 "short initial stimulation";
  initial equation
    p.V = V_init;
  equation
    der(p.V) = 1000 * p.I / C; // multiply with 1000 to get mV/s instead of V/s
  end LipidBilayer;

  model ConstantCurrent
    parameter Real I;
    ElectricalPin p;
  equation
    p.I = I;
  end ConstantCurrent;

  model Membrane
    ElectricalPin p;
    PotassiumChannel c_pot;
    SodiumChannel c_sod;
    LeakChannel c_leak;
    LipidBilayer l;
  equation
    connect(p, l.p);
    connect(c_pot.p, l.p);
    connect(c_sod.p, l.p);
    connect(c_leak.p, l.p);
    connect(l.T, c_pot.T);
    connect(l.T, c_sod.T);
  end Membrane;

end OnePin;
