function trough2peak_analysis
global leda2

ds = leda2.data.conductance.smoothData;% smoothData;
t = leda2.data.time.data;
[minL, maxL] = get_peaks(ds);
minL = minL(1:length(maxL));


leda2.trough2peakAnalysis.onset = t(minL);
leda2.trough2peakAnalysis.peaktime = t(maxL);
leda2.trough2peakAnalysis.onset_idx = minL;
leda2.trough2peakAnalysis.peaktime_idx = maxL;
leda2.trough2peakAnalysis.amp = ds(maxL) - ds(minL);


