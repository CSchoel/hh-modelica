within HHmodelica.Components;
package OnePin "simplified modular variant that is closer to equations, but farther from electrical analogy"
  partial model IonChannel "ionic current through the membrane"
    ElectricalPin p "connection to the membrane";
    Real g(unit="mmho/cm2") "ion conductance";
    parameter Real v_eq(unit="mV") "equilibrium potential (as displacement from resting potential)";
    parameter Real g_max(unit="mmho/cm2") "maximum conductance";
  equation
    p.i = g * (p.v - v_eq);
  end IonChannel;

  partial model GatedIonChannel
    extends IonChannel;
    TemperatureInput temp "membrane temperature to determine reaction coefficient";
  end GatedIonChannel;

  model PotassiumChannel "channel selective for K+ ions"
    extends GatedIonChannel(g_max=36, v_eq=12);
    Gate gate_act(
      redeclare function falpha= goldmanFit(x0=-10, sy=100, sx=0.1),
      redeclare function fbeta= scaledExpFit(sx=1/80, sy=125),
      v= p.v, temp= temp
    ) "actiaction gate (A = open, B = closed)";
  equation
    g = g_max * gate_act.n ^ 4;
  end PotassiumChannel;

  model SodiumChannel "channel selective for Na+ ions"
    extends GatedIonChannel(g_max=120, v_eq=-115);
    Gate gate_act(
      redeclare function falpha= goldmanFit(x0=-25, sy=1000, sx=0.1),
      redeclare function fbeta= scaledExpFit(sx=1/18, sy=4000),
      v= p.v, temp= temp
    ) "activation gate (A = open, B = closed)";
    Gate gate_inact(
      redeclare function falpha= scaledExpFit(sx=1/20, sy=70),
      redeclare function fbeta= logisticFit(x0=-30, sx=-0.1, y_max=1000),
      v= p.v, temp= temp
    ) "inactivation gate (A = closed, b = open)";
  equation
    g = g_max * gate_act.n ^ 3 * gate_inact.n;
  end SodiumChannel;

  model LeakChannel "constant leakage current of ions through membrane"
    extends IonChannel(g_max=0.3, v_eq=-10.613);
  equation
    g = g_max;
  end LeakChannel;

  model LipidBilayer "lipid bilayer separating external and internal potential (i.e. acting as a capacitor)"
    ElectricalPin p;
    TemperatureOutput temp = temp_m "constant membrane temperature";
    parameter Real temp_m(unit="degC") = 6.3 "membrane temperature";
    parameter Real c(unit="uF/cm2") = 1 "membrane capacitance";
    parameter Real v_init(unit="mV") = -90 "short initial stimulation";
  initial equation
    p.v = v_init;
  equation
    der(p.v) = 1000 * p.i / c; // multiply with 1000 to get mV/s instead of v/s
  end LipidBilayer;

  model ConstantCurrent
    parameter Real i;
    ElectricalPin p;
  equation
    p.i = i;
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
    connect(l.temp, c_pot.temp);
    connect(l.temp, c_sod.temp);
  end Membrane;

end OnePin;
