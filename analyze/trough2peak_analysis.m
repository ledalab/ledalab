function trough2peak_analysis
global leda2

ds = leda2.data.conductance.smoothData;% smoothData;
t = leda2.data.time.data;
[minL, maxL] = get_peaks(ds, 1);
minL = minL(1:length(maxL));
%dmm = ds(maxL)-ds(minL(1:end-1));
%tau1 = leda2.analysis.tau(1);
%tau2 = leda2.analysis.tau(2);
%if tau1 ~= 0
%    maxx = tau1 * tau2 * log(tau1/tau2) / (tau1 - tau2);
%    maxamp = abs(exp(-maxx/tau2) - exp(-maxx/tau1));
%else
%    maxamp =  1;
%end
%sigc = maxamp/((tau2-tau1)*leda2.data.samplingrate)*leda2.set.sigPeak;
%minL = minL(dmm >= sigc);
%maxL = maxL(dmm >= sigc);
leda2.trough2peakAnalysis.onset = t(minL);
leda2.trough2peakAnalysis.peaktime = t(maxL);
leda2.trough2peakAnalysis.onset_idx = minL;
leda2.trough2peakAnalysis.peaktime_idx = maxL;
leda2.trough2peakAnalysis.amp = ds(maxL) - ds(minL);


