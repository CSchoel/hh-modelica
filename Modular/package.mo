within HHmodelica;
package Modular
  // TODO: starting values
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
    Real n "ratio of molecules in 'open' position";
    input Real alpha "rate of transfer from closed to open position";
    input Real beta "rate of transfer from open to closed position";
  equation
    der(n) = alpha * (1 - n) - beta * n;
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
    Gate gate_act "actiaction gate";
  equation
    gate_act.alpha = goldmanFit(V, 10, 0.1, 0.1);
    gate_act.beta = scaledExpFit(V, 1/80, 0.125);
    G = G_max * gate_act.n ^ 4;
  end PotassiumChannel;
  model SodiumChannel
    extends IonChannel(G_max=36, V_eq=12);
    Gate gate_act "activation gate";
    Gate gate_inact "inactivation gate";
  equation
    gate_act.alpha = goldmanFit(V, 25, 0.1, 1);
    gate_act.beta = scaledExpFit(V, 1/18, 4);
    gate_inact.alpha = scaledExpFit(V, 1/20, 0.07);
    gate_inact.beta = inactivationFit(V, 30, 0.1);
    G = G_max * gate_act.n ^ 3 * gate_inact.n;
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
    Real V;
    Real I_total;
    Real I = 40; // TODO: explain
    parameter Real C = 1;
  equation
    I_total = c_pot.I + c_sod.I + c_leak.I - I;
    der(V) = -I_total / C;
  end Cell;
end Modular;
