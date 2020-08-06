within HHmodelica.CompleteModels;
partial model PotentialAdapter "base class that converts membrane potential to current standards"
  parameter Real e_r(unit="mV") = -75 "resting potential";
  Real v_m(unit="mV") = e_r - v "absolute membrane potential (v_in - v_out)";
  Real v(unit="mV") "membrane potential as displacement from resting potential (out - in)";
  annotation(
    experiment(StartTime = 0, StopTime = 30, Tolerance = 1e-6, Interval = 0.01),
    __OpenModelica_simulationFlags(s = "dassl"),
    __MoST_experiment(variableFilter="v_m|v|gK|gNa|n|m|h"),
    Documentation(info="
      <html>
        <p>The variable e_r in this adapter can be used to plot the absolute
        membrane potential as difference between the potential on the inside
        and the potential on the outside of the cell.
        This conforms with current standards, but not to the original equations
        by Hodgkin and Huxley, which define V as the displacement from the
        resting potential with opposite sign.</p>
        <p>For this conversion, a value for the resting potential e_r must be
        assumed, which is not given in the original article. We use e_r = -75 mV,
        because this is the value that is used by the BioModels implementation of
        the Hodgkin-Huxley model and corresponds to the resting potential
        measured for the squid giant axon <i>in vivo</i>
        (cf. Moore and Cole, 1960, https://doi.org/10.1085/jgp.43.5.961).</p>
      </html>
    ")
  );
end PotentialAdapter;
