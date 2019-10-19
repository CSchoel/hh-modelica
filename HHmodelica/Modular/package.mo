within HHmodelica;
package Modular
  function scaledExpFit "exponential function with scaling parameters for x and y axis"
    input Real x "input value";
    input Real sx "scaling factor for x axis";
    input Real sy "scaling factor for y axis";
    output Real y "result";
  algorithm
    y := sy * exp(sx * x);
  end scaledExpFit;
  function goldmanFit "fitting function related to Goldmans formula for the movement of a charged particle in a constant electrical field"
    input Real V "membrane potential (as displacement from resting potential)";
    input Real V_off "offset for V";
    input Real sdn "scaling factor for dn";
    input Real sV "scaling factor for V";
    output Real dn "rate of change of the gating variable at given V";
  protected
    Real V_adj "adjusted V with offset and scaling factor";
  algorithm
    V_adj := sV * (V + V_off);
    if V_adj == 0 then
      dn := sV; // using L'Hôpital to find limit for V_adj->0
    else
      dn := sdn * V_adj / (exp(V_adj) - 1);
    end if;
    annotation(
      Documentation(info="
        <html>
          <p>Hodgkin and Huxley state that this formula was (in part) used
          because it &quot;bears a close resemblance to the equation derived
          by Goldman (1943) for the movements of a charged particle in a constant
          field&quot;.</p>
          <p>We suppose that this statement refers to equation 11 of Goldman
          (1943) when n_i' is zero.</p>
        </html>
      ")
    );
  end goldmanFit;
  function decliningLogisticFit "logistic function with flipped x-axis"
    input Real x "input value";
    input Real x0 "x-value of sigmoid midpoint";
    input Real k "growth rate/steepness";
    output Real y "result";
  protected
    Real x_adj "adjusted x with offset and scaling factor";
  algorithm
    x_adj := k * (x - x0);
    y := 1 / (exp(x_adj) + 1);
  end decliningLogisticFit;
  model Gate
    replaceable function falpha = goldmanFit(V_off=0, sdn=1, sV=1) "rate of transfer from closed to open position";
    replaceable function fbeta = scaledExpFit(sx=1, sy=1) "rate of transfer from open to closed position";
    Real n(start=falpha(0)/(falpha(0) + fbeta(0)), fixed=true) "ratio of molecules in 'open' position";
    input Real V "membrane potential (as displacement from resting potential)";
  equation
    der(n) = falpha(V) * (1 - n) - fbeta(V) * n;
  end Gate;
  partial model IonChannel
    output Real I "current";
    Real G "conductance";
    input Real V "membrane potential (as displacement from resting potential)";
    parameter Real V_eq "equilibrium potential (as displacement from resting potential)";
    parameter Real G_max "maximum conductance";
  equation
    I = G * (V - V_eq);
  end IonChannel;
  model PotassiumChannel
    extends IonChannel(G_max=120, V_eq=-115);
    Gate gate_act(
      redeclare function falpha= goldmanFit(V_off=10, sdn=0.1, sV=0.1),
      redeclare function fbeta= scaledExpFit(sx=1/80, sy=0.125)
    ) "actiaction gate";
  equation
    G = G_max * gate_act.n ^ 4;
    connect(V, gate_act.V);
  end PotassiumChannel;
  model SodiumChannel
    extends IonChannel(G_max=36, V_eq=12);
    Gate gate_act(
      redeclare function falpha= goldmanFit(V_off=25, sdn=0.1, sV=1),
      redeclare function fbeta= scaledExpFit(sx=1/18, sy=4)
    ) "activation gate";
    Gate gate_inact(
      redeclare function falpha= scaledExpFit(sx=1/20, sy=0.07),
      redeclare function fbeta= decliningLogisticFit(x0=-30, k=0.1)
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
