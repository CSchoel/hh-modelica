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
    input Real v "membrane potential (as displacement from resting potential)";
    input Real V_off "offset for v (fitting parameter)";
    input Real sdn "scaling factor for dn (fitting parameter)";
    input Real sV "scaling factor for v (fitting parameter)";
    output Real dn "rate of change of the gating variable at given v";
  protected
    Real V_adj "adjusted v with offset and scaling factor";
  algorithm
    V_adj := sV * (v + V_off);
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

  // TODO: better use "fopen" and "fclose" than "falpha" and "fbeta"
  model Gate "gating molecule with an open conformation and a closed conformation"
    replaceable function falpha = goldmanFit(V_off=0, sdn=1, sV=1) "rate of transfer from closed to open conformation";
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
      redeclare function falpha= goldmanFit(V_off=10, sdn=100, sV=0.1),
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
      redeclare function falpha= goldmanFit(V_off=25, sdn=1000, sV=0.1),
      redeclare function fbeta= scaledExpFit(sx=1/18, sy=4000),
      v=v, temp=temp
    ) "activation gate";
    Gate gate_inact(
      redeclare function falpha= scaledExpFit(sx=1/20, sy=70),
      redeclare function fbeta= decliningLogisticFit(x0=-30, k=0.1, L=1000),
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
    PositivePin outside annotation (Placement(transformation(extent={{-10, 90},{10, 110}})));
    NegativePin inside annotation (Placement(transformation(extent={{-10, -90},{10, -110}})));
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
    connect(c_pot.temp, l.temp);
    connect(c_sod.temp, l.temp);
  end Membrane;

  model CurrentClamp
    extends HHmodelica.Icons.CurrentClamp;
    PositivePin ext "extracellular electrode" annotation (Placement(transformation(extent={{-10, 90},{10, 110}})));
    NegativePin int "intracellular electrode(s)" annotation (Placement(transformation(extent={{-10, -90},{10, -110}})));
    parameter Real i = 40 "current applied to membrane";
    ConstantCurrent cur(i=i) "external current applied to membrane";
    Ground g;
    Real v = -int.v "measured membrane potential";
  equation
    connect(ext, cur.p);
    connect(int, cur.n);
    connect(g.p, ext);
  end CurrentClamp;

end Components;
