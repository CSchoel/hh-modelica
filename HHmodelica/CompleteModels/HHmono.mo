within HHmodelica.CompleteModels;
model HHmono "monolithic version of the Hodgkin-Huxley model"
  parameter Real Cm(unit = "uF/cm2")       = 1;
  parameter Real gbarNa(unit = "mmho/cm2")   = 120 "max sodium conductance";
  parameter Real gbarK(unit = "mmho/cm2")    = 36 "max potassium conductance";
  parameter Real gbar0(unit = "mmho/cm2")    = 0.3;
  parameter Real VNa(unit = "mV")      = -115;
  parameter Real VK(unit = "mV")       = 12;
  parameter Real Vl(unit = "mV")       = -10.613;
  parameter Real Temp     = 6.3 ;
  parameter Real phi      = 3^((Temp-6.3)/10);
  parameter Real Vdepolar(unit = "mV") = -90;
  parameter Real Vnorm(unit = "mV")    = 1 "for non-dimensionalizing V in function expressions, i.e. exp(V/Vnorm) replaces exp(V).";
  parameter Real msecm1(unit = "1/msec") = 1 "for adding units to alpha and beta variables";
  parameter Real alphan0 (unit="1/msec") = 0.1/(exp(1)-1) "always use V=0 to calculate i.c.";
  parameter Real betan0  (unit="1/msec") = 0.125;
  parameter Real alpham0 (unit="1/msec") = 2.5/(exp(2.5)-1);
  parameter Real betam0  (unit="1/msec") = 4;
  parameter Real alphah0 (unit="1/msec") = 0.07;
  parameter Real betah0  (unit="1/msec") = 1/(exp(3)+1);

  parameter Real minusI(unit = "uA/cm2") = 40;
  input Real Vclamp(unit = "mV");

  parameter Real clamp_0no_1yes = 0;

  //Variables for all the algebraic equations
  Real INa(unit = "uA/cm2") "Ionic currents";
  Real IK(unit = "uA/cm2") "Ionic currents";
  Real Il(unit = "uA/cm2") "Ionic currents";
  Real alphan(unit = "1/msec")  "rate constant of particles from out to in";
  Real betan(unit = "1/msec")   "rate constant from in to out";
  Real alpham(unit = "1/msec")  "rate constant of activating molecules from out to in";
  Real betam(unit = "1/msec")   "rate constant of activating molecules from in to out";
  Real alphah(unit = "1/msec")  "rate constant of inactivating molecules from out to in";
  Real betah(unit = "1/msec")   "rate constant of inactivating molecules from in to out";
  Real gNa(unit = "mmho/cm2")   "Sodium conductance";
  Real gK(unit = "mmho/cm2")    "potassium conductance";
  Real Iion(unit = "uA/cm^2");

  //State variables for all the ODEs
  Real VV(unit="mV");
  Real V(unit="mV") "displacement of the membrane potential from its resting value (depolarization negative)";
  Real n "proportion of the particles in a certain position";
  Real m "proportion of activating molecules on the inside";
  Real h "proportion of inactivating molecules on the outside";

protected
  Real ninf;
  Real minf;
  Real hinf;
  Real taun(unit="msec");
  Real taum(unit="msec");
  Real tauh(unit="msec");

initial equation
  VV = if clamp_0no_1yes == 0 then Vdepolar else Vclamp;

  n = alphan0/(alphan0+betan0);
  m = alpham0/(alpham0+betam0);
  h = alphah0/(alphah0+betah0);

equation
  //if V/Vnorm == -10 then
  //  alphan = 0.1;
  //else
  alphan = 0.01 * (V / Vnorm + 10) / (exp((V / Vnorm + 10) / 10) - 1);
  //end if;
  betan = msecm1 * (0.125 * exp(V / Vnorm / 80));
  //if V/Vnorm == -25 then
  //  alpham = 1;
  //else
  alpham = 0.1 * (V / Vnorm + 25) / (exp((V / Vnorm + 25) / 10) - 1);
  //end if;
  betam = msecm1 * (4 * exp(V / Vnorm / 18));
  alphah  = msecm1*(0.07*exp((V/Vnorm)/20));
  betah   = msecm1*(1/(exp(( V/Vnorm+30)/10)+1));
  minf    = alpham/(alpham+betam);
  ninf    = alphan/(alphan+betan);
  hinf    = alphah/(alphah+betah);
  taun    =1/(alphan+betan);
  tauh    =1/(alphah+betah);
  taum    =1/(alpham+betam);
  gNa     = gbarNa * m^3 * h;
  gK      = gbarK  * n^4;
  INa     = gNa * (V-VNa);
  IK      = gK  * (V-VK);
  Il      = gbar0 * (V-Vl);
  Iion    = INa + IK + Il;
  if (clamp_0no_1yes == 0) then
    der(VV) = (-minusI-INa-IK-Il)/Cm;
    V = VV;
  else
    der(VV) = 0;
    V = Vclamp;
  end if;
  der(n) = phi*(alphan*(1-n)-betan*n);
  der(m) = phi*(alpham*(1-m)-betam*m);
  der(h) = phi*(alphah*(1-h)-betah*h);
annotation(
    experiment(StartTime = 0, StopTime = 30, Tolerance = 1e-6, Interval = 0.01),
    __OpenModelica_simulationFlags(s = "dassl")
);
end HHmono;
