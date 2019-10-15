within HHmodelica;
package Modular
  function scaledExpFit
    input Real x "input value";
    input Real sx "scaling factor for x axis";
    input Real sy "scaling factor for y axis";
    output Real y;
  algorithm
    y := sy * exp(sx * x);
  end scaledExpFit;
  // TODO: better explanation for what this function actually represents
  function goldmanFit
    input Real V "potential (as displacement from resting potential)";
    input Real V_off "offset for V";
    input Real sres "scaling factor for result";
    input Real sV "scaling factor for V in exp";
    output Real res "result";
  protected
    Real V_adj "adjusted V with offset and scaling factor";
  algorithm
    V_adj := sV * (V + V_off);
    res := sres * V_adj / (exp(V_adj) - 1);
  end goldmanFit;
  // TODO: better explanation for what this function actually represents
  function inactivationFit
    input Real V "potential (as displacement from resting potential)";
    input Real V_off "offset for V";
    input Real sV "scaling factor for V";
    output Real res "result";
  protected
    Real V_adj "adjusted V with offset and scaling factor";
  algorithm
    V_adj := sV * (V + V_off);
    res := 1 / (exp(V_adj) + 1);
  end inactivationFit;
  model Gate
    replaceable function falpha = goldmanFit(V_off=0, sres=1, sV=1) "rate of transfer from closed to open position";
    replaceable function fbeta = scaledExpFit(sx=1, sy=1) "rate of transfer from open to closed position";
    Real n(start=falpha(0)/(falpha(0) + fbeta(0)), fixed=true) "ratio of molecules in 'open' position";
    input Real V;
  equation
    der(n) = falpha(V) * (1 - n) - fbeta(V) * n;
  end Gate;
  partial model IonChannel
    output Real I "current";
    Real G "conductance";
    input Real V "actual potential (as displacement from resting potential)";
    parameter Real V_eq "equilibrium potential (as displacement from resting potential)";
    parameter Real G_max "maximum conductance";
  equation
    I = G * (V - V_eq);
  end IonChannel;
  model PotassiumChannel
    extends IonChannel(G_max=120, V_eq=-115);
    Gate gate_act(
      redeclare function falpha= goldmanFit(V_off=10, sres=0.1, sV=0.1),
      redeclare function fbeta= scaledExpFit(sx=1/80, sy=0.125)
    ) "actiaction gate";
  equation
    G = G_max * gate_act.n ^ 4;
    connect(V, gate_act.V);
  end PotassiumChannel;
  model SodiumChannel
    extends IonChannel(G_max=36, V_eq=12);
    Gate gate_act(
      redeclare function falpha= goldmanFit(V_off=25, sres=0.1, sV=1),
      redeclare function fbeta= scaledExpFit(sx=1/18, sy=4)
    ) "activation gate";
    Gate gate_inact(
      redeclare function falpha= scaledExpFit(sx=1/20, sy=0.07),
      redeclare function fbeta= inactivationFit(V_off=30, sV=0.1)
    ) "inactivation gate";
  equation
    G = G_max * gate_act.n ^ 3 * gate_inact.n;
    connect(V, gate_act.V);
    connect(V, gate_inact.V);
  end SodiumChannel;
  model LeakChannel
    extends IonChannel(G_max=0.3, V_eq=-10.613);
  equation
    G = G_max;
  end LeakChannel;
  model Cell
    PotassiumChannel c_pot;
    SodiumChannel c_sod;
    LeakChannel c_leak;
    Real V(start=-90, fixed=true);
    Real I_total;
    Real I = 40; // TODO: explain
    parameter Real C = 1;
  equation
    I_total = c_pot.I + c_sod.I + c_leak.I - I;
    der(V) = -I_total / C;
    connect(V, c_pot.V);
    connect(V, c_sod.V);
    connect(V, c_leak.V);
  end Cell;
end Modular;
