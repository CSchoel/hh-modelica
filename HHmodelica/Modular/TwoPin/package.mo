within HHmodelica.Modular;
package TwoPin
  model TwoPinComponent
    MembranePin p;
    MembranePin n;
    Real V(unit="mV");
    Real T(unit="degC");
  equation
    p.T = n.T;
    p.dT = n.dT;
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
    p.dT = 0;
  end IonChannel2P;

  model PotassiumChannel2P "channel selective for K+ ions"
    extends IonChannel2P(G_max=36, V_eq=12);
    Gate gate_act(
      redeclare function falpha= goldmanFit(V_off=10, sdn=100, sV=0.1),
      redeclare function fbeta= scaledExpFit(sx=1/80, sy=125),
      V= p.V, T= p.T
    ) "actiaction gate (A = open, B = closed)";
  equation
    G = G_max * gate_act.n ^ 4;
  end PotassiumChannel2P;

  model SodiumChannel2P "channel selective for Na+ ions"
    extends IonChannel2P(G_max=120, V_eq=-115);
    Gate gate_act(
      redeclare function falpha= goldmanFit(V_off=25, sdn=1000, sV=0.1),
      redeclare function fbeta= scaledExpFit(sx=1/18, sy=4000),
      V= p.V, T= p.T
    ) "activation gate (A = open, B = closed)";
    Gate gate_inact(
      redeclare function falpha= scaledExpFit(sx=1/20, sy=70),
      redeclare function fbeta= decliningLogisticFit(x0=-30, k=0.1, L=1000),
      V= p.V, T= p.T
    ) "inactivation gate (A = closed, b = open)";
  equation
    G = G_max * gate_act.n ^ 3 * gate_inact.n;
  end SodiumChannel2P;

  model LeakChannel2P "constant leakage current of ions through membrane"
    extends IonChannel2P(G_max=0.3, V_eq=-10.613);
  equation
    G = G_max;
  end LeakChannel2P;

  model Membrane "membrane model relating individual currents to total voltage"
    extends TwoPinComponent;
    parameter Real T(unit="degC") = 6.3 "membrane temperature";
    parameter Real C(unit="uF/cm2") = 1 "membrane capacitance";
  initial equation
    V = -90 "short initial stimulation";
    p.T = T "constant temperature (unless any component sets dT != 0)";
  equation
    der(V) = 1000 * p.I / C; // multiply with 1000 to get mV/s instead of V/s
    der(p.T) = p.dT;
  end Membrane;

  model ConstantMembraneCurrent
    extends TwoPinComponent;
    parameter Real I;
    MembranePin p;
  equation
    p.I = I;
    p.dT = 0;
  end ConstantMembraneCurrent;

  // TODO: we need a ground somewhere

  model Cell
    PotassiumChannel2P c_pot;
    SodiumChannel2P c_sod;
    LeakChannel2P c_leak;
    Membrane m;
    // I = 40 => recurring depolarizations
    // I = 0 => V returns to 0
    ConstantMembraneCurrent ext(I=40) "external current applied to membrane";
  equation
    connect(c_pot.p, m.p);
    connect(c_sod.p, m.p);
    connect(c_leak.p, m.p);
    connect(ext.p, m.p);
    connect(c_pot.n, m.n);
    connect(c_sod.n, m.n);
    connect(c_leak.n, m.n);
    connect(ext.n, m.n);
  end Cell;
end TwoPin;
