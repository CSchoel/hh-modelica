within HHmodelica;
package Components
  connector TemperatureInput = input Real(unit="degC") "membrane temperature";
  connector TemperatureOutput = output Real(unit="degC") "membrane temperature";

  connector ElectricalPin "electrical connector for membrane currents"
    flow Real I(unit="uA/cm2") "ionic current through membrane";
    Real V(unit="mV") "membrane potential (as displacement from resting potential)";
  end ElectricalPin;

  model TwoPinComponent
    ElectricalPin p;
    ElectricalPin n;
    Real V(unit="mV");
  equation
    0 = p.I + n.I;
    V = p.V - n.V;
  end TwoPinComponent;

  function scaledExpFit "exponential function with scaling parameters for x and y axis"
    input Real x "input value";
    input Real sx "scaling factor for x axis (fitting parameter)";
    input Real sy "scaling factor for y axis (fitting parameter)";
    output Real y "result";
  algorithm
    y := sy * exp(sx * x);
  end scaledExpFit;

  function goldmanFit "fitting function related to Goldmans formula for the movement of a charged particle in a constant electrical field"
    input Real V "membrane potential (as displacement from resting potential)";
    input Real V_off "offset for V (fitting parameter)";
    input Real sdn "scaling factor for dn (fitting parameter)";
    input Real sV "scaling factor for V (fitting parameter)";
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
    input Real x0 "x-value of sigmoid midpoint (fitting parameter)";
    input Real k "growth rate/steepness (fitting parameter)";
    input Real L "maximum value";
    output Real y "result";
  protected
    Real x_adj "adjusted x with offset and scaling factor";
  algorithm
    x_adj := k * (x - x0);
    y := L / (exp(x_adj) + 1);
  end decliningLogisticFit;

  model Gate "gating molecule with two conformations/positions A and B"
    replaceable function falpha = goldmanFit(V_off=0, sdn=1, sV=1) "rate of transfer from conformation B to A";
    replaceable function fbeta = scaledExpFit(sx=1, sy=1) "rate of transfer from conformation A to B";
    Real n(start=falpha(0)/(falpha(0) + fbeta(0)), fixed=true) "ratio of molecules in conformation A";
    input Real V(unit="mV") "membrane potential (as displacement from resting potential)";
    TemperatureInput T;
  protected
    Real phi = 3^((T-6.3)/10);
  equation
    der(n) = phi * (falpha(V) * (1 - n) - fbeta(V) * n);
  end Gate;

  partial model IonChannel "ionic current through the membrane"
    extends TwoPinComponent;
    Real G(unit="mmho/cm2") "ion conductance";
    parameter Real V_eq(unit="mV") "equilibrium potential (as displacement from resting potential)";
    parameter Real G_max(unit="mmho/cm2") "maximum conductance";
  equation
    p.I = G * (V - V_eq);
  end IonChannel;

  partial model GatedIonChannel "ion channel that has voltage-dependent gates"
    extends IonChannel;
    TemperatureInput T "membrane temperature to determine reaction coefficient";
  end GatedIonChannel;

  model PotassiumChannel "channel selective for K+ ions"
    extends GatedIonChannel(G_max=36, V_eq=12);
    Gate gate_act(
      redeclare function falpha= goldmanFit(V_off=10, sdn=100, sV=0.1),
      redeclare function fbeta= scaledExpFit(sx=1/80, sy=125),
      V=V, T=T
    ) "actiaction gate (A = open, B = closed)";
  equation
    G = G_max * gate_act.n ^ 4;
  end PotassiumChannel;

  model SodiumChannel "channel selective for Na+ ions"
    extends GatedIonChannel(G_max=120, V_eq=-115);
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
  end SodiumChannel;

  model LeakChannel "constant leakage current of ions through membrane"
    extends IonChannel(G_max=0.3, V_eq=-10.613);
  equation
    G = G_max;
  end LeakChannel;

  model LipidBilayer "lipid bilayer separating external and internal potential (i.e. acting as a capacitor)"
    extends TwoPinComponent;
    TemperatureOutput T = T_m;
    parameter Real T_m(unit="degC") = 6.3 "membrane temperature";
    parameter Real C(unit="uF/cm2") = 1 "membrane capacitance";
  initial equation
    V = -90 "short initial stimulation";
  equation
    der(V) = 1000 * p.I / C; // multiply with 1000 to get mV/s instead of V/s
  end LipidBilayer;

  model ConstantCurrent
    extends TwoPinComponent;
    parameter Real I;
    ElectricalPin p;
  equation
    p.I = I;
  end ConstantCurrent;

  model Ground
    ElectricalPin p;
  equation
    p.V = 0;
  end Ground;

  model Membrane
    ElectricalPin outside;
    ElectricalPin inside;
    PotassiumChannel c_pot;
    SodiumChannel c_sod;
    LeakChannel c_leak;
    LipidBilayer l;
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
  end Membrane;

  model CurrentClamp
    ElectricalPin ext "extracellular electrode";
    ElectricalPin int "intracellular electrode(s)";
    parameter Real I = 40 "current applied to membrane";
    ConstantCurrent cur(I=I) "external current applied to membrane";
    Ground g;
  equation
    connect(ext, cur.p);
    connect(int, cur.n);
    connect(g.p, int);
  end CurrentClamp;

  model HH
    Membrane m;
    // I = 40 => recurring depolarizations
    // I = 0 => V returns to 0
    CurrentClamp c(I=40);
  equation
    connect(m.outside, c.ext);
    connect(m.inside, c.int);
  annotation(
    experiment(StartTime = 0, StopTime = 0.03, Tolerance = 1e-6, Interval = 1e-05),
    __OpenModelica_simulationFlags(outputFormat = "csv", s = "dassl")
  );
  end HH;
end Components;
