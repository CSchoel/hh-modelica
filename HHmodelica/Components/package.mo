within HHmodelica;
package Components
  connector TemperatureInput = input Real(unit="degC") "membrane temperature"
    annotation(
      Icon(
        coordinateSystem(
          preserveAspectRatio=true,
          extent={{-100,-100},{100,100}}
        ),
        graphics={
          Ellipse(
            extent={{-100,100},{100,-100}},
            lineColor={255,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid
          )
        }
      )
    );
  connector TemperatureOutput = output Real(unit="degC") "membrane temperature"
    annotation(
      Icon(
        coordinateSystem(
          preserveAspectRatio=true,
          extent={{-100,-100},{100,100}}
        ),
        graphics={
          Ellipse(
            extent={{-100,100},{100,-100}},
            lineColor={255,0,0},
            fillColor={255,0,0},
            fillPattern=FillPattern.Solid
          )
        }
      )
    );

  connector ElectricalPin "electrical connector for membrane currents"
    flow Real i(unit="uA/cm2") "ionic current through membrane";
    Real v(unit="mV") "membrane potential (as displacement from resting potential)";
  end ElectricalPin;

  connector PositivePin
    extends ElectricalPin;
    annotation(
      Icon(
        coordinateSystem(
          preserveAspectRatio=true,
          extent={{-100,-100},{100,100}}
        ),
        graphics={
          Rectangle(
            extent={{-100,100},{100,-100}},
            lineColor={0,0,255},
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid
          )
        }
      )
    );
  end PositivePin;

  connector NegativePin
    extends ElectricalPin;
    annotation(
      Icon(
        coordinateSystem(
          preserveAspectRatio=true,
          extent={{-100,-100},{100,100}}
        ),
        graphics={
          Rectangle(
            extent={{-100,100},{100,-100}},
            lineColor={0,0,255},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid
          )
        }
      )
    );
  end NegativePin;

  partial model TwoPinComponent
    PositivePin p annotation (Placement(transformation(extent={{-10, 90},{10, 110}})));
    NegativePin n annotation (Placement(transformation(extent={{-10, -90},{10, -110}})));
    Real v(unit="mV");
  equation
    0 = p.i + n.i;
    v = p.v - n.v;
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
    input Real x "membrane potential (as displacement from resting potential)";
    input Real x0 "offset for x (fitting parameter)";
    input Real sx "scaling factor for x (fitting parameter)";
    input Real sy "scaling factor for y (fitting parameter)";
    output Real y "rate of change of the gating variable at given V=x";
  protected
    Real x_adj "adjusted x with offset and scaling factor";
  algorithm
    x_adj := sx * (x - x0);
    if abs(x - x0) < 1e-6 then
      y := sy; // using L'Hôpital to find limit for x_adj->0
    else
      y := sy * x_adj / (exp(x_adj) - 1);
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
    // TODO not so sure about where that reference to goldman comes from anymore
    // => compare with ghkFlux again
  end goldmanFit;

  function logisticFit "logistic function with flipped x-axis"
    input Real x "input value";
    input Real x0 "x-value of sigmoid midpoint (fitting parameter)";
    input Real sx "growth rate/steepness (fitting parameter)";
    input Real y_max "maximum value";
    output Real y "result";
  protected
    Real x_adj "adjusted x with offset and scaling factor";
  algorithm
    x_adj := sx * (x - x0);
    y := y_max / (exp(-x_adj) + 1);
  end logisticFit;

  // TODO: better use "fopen" and "fclose" than "falpha" and "fbeta"
  model Gate "gating molecule with an open conformation and a closed conformation"
    replaceable function falpha = scaledExpFit(x0=0, sy=1, sx=1) "rate of transfer from closed to open conformation";
    replaceable function fbeta = scaledExpFit(sx=1, sy=1) "rate of transfer from open to closed conformation";
    Real n(start=falpha(0)/(falpha(0) + fbeta(0)), fixed=true) "ratio of molecules in open conformation";
    input Real v(unit="mV") "membrane potential (as displacement from resting potential)";
    TemperatureInput temp;
  protected
    Real phi = 3^((temp-6.3)/10);
  equation
    der(n) = phi * (falpha(v) * (1 - n) - fbeta(v) * n);
  end Gate;

  partial model IonChannel "ionic current through the membrane"
    extends TwoPinComponent;
    extends HHmodelica.Icons.IonChannel;
    Real g(unit="mmho/cm2") "ion conductance";
    parameter Real v_eq(unit="mV") "equilibrium potential (as displacement from resting potential)";
    parameter Real g_max(unit="mmho/cm2") "maximum conductance";
  equation
    p.i = g * (v - v_eq);
  end IonChannel;

  partial model GatedIonChannel "ion channel that has voltage-dependent gates"
    extends IonChannel;
    TemperatureInput temp "membrane temperature to determine reaction coefficient"
      annotation (Placement(transformation(extent={{-40, 48},{-60, 68}})));
  end GatedIonChannel;

  model PotassiumChannel "channel selective for K+ ions"
    extends GatedIonChannel(g_max=36, v_eq=12);
    extends HHmodelica.Icons.Activatable;
    Gate gate_act(
      redeclare function falpha= goldmanFit(x0=-10, sy=100, sx=0.1),
      redeclare function fbeta= scaledExpFit(sx=1/80, sy=125),
      v=v, temp=temp
    ) "activation gate";
  equation
    g = g_max * gate_act.n ^ 4;
  end PotassiumChannel;

  model SodiumChannel "channel selective for Na+ ions"
    extends GatedIonChannel(g_max=120, v_eq=-115);
    extends HHmodelica.Icons.Activatable;
    extends HHmodelica.Icons.Inactivatable;
    Gate gate_act(
      redeclare function falpha= goldmanFit(x0=-25, sy=1000, sx=0.1),
      redeclare function fbeta= scaledExpFit(sx=1/18, sy=4000),
      v=v, temp=temp
    ) "activation gate";
    Gate gate_inact(
      redeclare function falpha= scaledExpFit(sx=1/20, sy=70),
      redeclare function fbeta= logisticFit(x0=-30, sx=-0.1, y_max=1000),
      v=v, temp=temp
    ) "inactivation gate";
  equation
    g = g_max * gate_act.n ^ 3 * gate_inact.n;
  end SodiumChannel;

  model LeakChannel "constant leakage current of ions through membrane"
    extends IonChannel(g_max=0.3, v_eq=-10.613);
    extends HHmodelica.Icons.OpenChannel;
  equation
    g = g_max;
  end LeakChannel;

  model LipidBilayer "lipid bilayer separating external and internal potential (i.e. acting as a capacitor)"
    extends TwoPinComponent;
    extends HHmodelica.Icons.LipidBilayer;
    TemperatureOutput temp = temp_m annotation (Placement(transformation(extent={{40, 48},{60, 68}})));
    parameter Real temp_m(unit="degC") = 6.3 "membrane temperature";
    parameter Real c(unit="uF/cm2") = 1 "membrane capacitance";
    parameter Real V_init(unit="mV") = -90 "short initial stimulation";
  initial equation
    v = V_init;
  equation
    der(v) = 1000 * p.i / c; // multiply with 1000 to get mV/s instead of v/s
  end LipidBilayer;

  model ConstantCurrent
    extends TwoPinComponent;
    parameter Real i;
  equation
    p.i = i;
  end ConstantCurrent;

  model Ground
    PositivePin p;
  equation
    p.v = 0;
  end Ground;

  model Membrane
    extends HHmodelica.Icons.LipidBilayer;
    PositivePin p annotation (Placement(transformation(extent={{-10, 90},{10, 110}})));
    NegativePin n annotation (Placement(transformation(extent={{-10, -90},{10, -110}})));
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
    connect(p, l.p);
    connect(n, l.n);
    connect(c_pot.temp, l.temp);
    connect(c_sod.temp, l.temp);
  end Membrane;

  model CurrentClamp
    extends HHmodelica.Icons.CurrentClamp;
    PositivePin p "extracellular electrode" annotation (Placement(transformation(extent={{-10, 90},{10, 110}})));
    NegativePin n "intracellular electrode(s)" annotation (Placement(transformation(extent={{-10, -90},{10, -110}})));
    parameter Real i = 40 "current applied to membrane";
    ConstantCurrent cur(i=i) "external current applied to membrane";
    Ground g;
    Real v = -n.v "measured membrane potential";
  equation
    connect(p, cur.p);
    connect(n, cur.n);
    connect(g.p, p);
  end CurrentClamp;

end Components;
