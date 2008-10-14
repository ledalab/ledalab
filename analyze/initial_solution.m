function initial_solution
global leda2

if ~leda2.file.open
    add2log(0,'Please open data file!',0,0,0,0,0,1);
    return;
end
add2log(1,' Get initial solution',1,1,1);

delete_fit(0);

timeData = leda2.data.time.data;
condData = leda2.data.conductance.data;
tau1_tmp = leda2.set.parset.tmp.tau(1);
tau2_tmp = leda2.set.parset.tmp.tau(2);
%sigma_tmp = .8; %leda2.set.parset.tmp.sigma;


cond_smooth = smooth(condData, leda2.set.initVal.hannWinWidth * leda2.data.samplingrate);  %smooth data
leda2.data.conductance.smoothData = cond_smooth;

%Identify peaks (initial values)
[onset, amp, sigma] = get_initial_values(timeData, cond_smooth);  %also yields tau
leda2.analyze.initialvalues.onset = onset;
leda2.analyze.initialvalues.amp = amp;
leda2.analyze.initialvalues.sigma = sigma;

%Generate initial solution
[phasicData, phasicComponent, phasicRemainder] = fit_iv(timeData, tau1_tmp, tau2_tmp, onset, amp, sigma);
%leda2.analyze.initialsolution.phasiccoef.onset = onset;
%leda2.analyze.initialsolution.phasiccoef.amp = amp;
%leda2.analyze.initialsolution.phasiccoef.peaktime = sigma;
%tau and sigma have default values

%Tonic
tonicRawData = condData - phasicData;
groundtimes = [timeData(1),(leda2.set.epoch.size/2) : leda2.set.tonicGridSize : timeData(end), timeData(end)];
for i = 1:length(groundtimes)
    ground(i) = median(tonicRawData(subrange_idx(timeData, groundtimes(i)-leda2.set.epoch.size/2, groundtimes(i)+leda2.set.epoch.size/2))); %#ok<AGROW>
end
% groundtimes = [timeData(1), timeData(end)];
% ground = [min(condData), min(condData)]*.95;
leda2.set.initVal.groundInterp = 'spline';

tonicData = interp1(groundtimes, ground, timeData, leda2.set.initVal.groundInterp);
leda2.analyze.initialsolution.toniccoef.polycoef = interp1(groundtimes, ground,leda2.set.initVal.groundInterp, 'pp');
leda2.analyze.initialsolution.toniccoef.groundtimes = groundtimes;
leda2.analyze.initialsolution.toniccoef.ground = ground;

%Set initial values as first fit values
leda2.analyze.fit.phasiccoef.onset = onset;
leda2.analyze.fit.phasiccoef.amp = amp;
leda2.analyze.fit.phasiccoef.tau = [tau1_tmp; tau2_tmp] * ones(1,length(onset));
leda2.analyze.fit.phasiccoef.sigma = sigma;

leda2.analyze.fit.toniccoef.ground = ground;
leda2.analyze.fit.toniccoef.time = groundtimes;
leda2.analyze.fit.toniccoef.polycoef = leda2.analyze.initialsolution.toniccoef.polycoef;
leda2.analyze.fit.data.tonic = tonicData;
leda2.analyze.fit.data.phasic = phasicData;
leda2.analyze.fit.data.residual =  leda2.data.conductance.data - (leda2.analyze.fit.data.tonic + leda2.analyze.fit.data.phasic);
leda2.analyze.fit.data.phasicComponent = phasicComponent;
leda2.analyze.fit.data.phasicRemainder = phasicRemainder;

leda2.analyze.fit.info.iterations = 0;

if leda2.intern.batchmode
    return;
end

%Graphics
refresh_fitoverview;
refresh_fitinfo;
%refresh_progressinfo;

axes(leda2.gui.rangeview.ax);
hold on;
ch = get(leda2.gui.rangeview.ax,'Children');
delete(ch(strcmp(get(ch,'Tag'),'InitialSolutionInfo')));
leda2.gui.rangeview.cond_smooth = plot(timeData, cond_smooth,'m','Tag','InitialSolutionInfo','Visible',onoffstr(leda2.pref.showSmoothData));
leda2.gui.rangeview.groundpoints = plot(groundtimes, ground,'ws','MarkerFaceColor',[.8 .8 .8],'Tag','InitialSolutionInfo');
leda2.gui.rangeview.estim_ground = plot(timeData, tonicRawData,'Color',[.8 .8 .8],'Tag','InitialSolutionInfo','Visible',onoffstr(leda2.pref.showTonicRawData));

%  for i=1:length(leda2.analyze.initialvalues.onset)
%     onset_idx(i) = time_idx(leda2.data.time.data, leda2.analyze.initialvalues.onset(i));
% %    sc_idx(i) = any(find((leda2.analyze.initialvalues.onset(i) - [leda2.data.events.event.time]) > -4 & (leda2.analyze.initialvalues.onset(i) - [leda2.data.events.event.time]) < 0.3));
%  end
%  plot(leda2.analyze.initialvalues.onset, leda2.data.conductance.data(onset_idx),'s','Color',[.2 .9 .2],'MarkerFaceColor',[.2 .9 .2],'Tag','InitialSolutionInfo','MarkerSize',5);
% % plot(leda2.analyze.initialvalues.onset(find(sc_idx)), leda2.data.conductance.data(onset_idx(find(sc_idx))),'s','Color',[.9 .2 .2],'MarkerEdgeColor','k','MarkerFaceColor',[.9 .2 .2],'Tag','InitialSolutionInfo','MarkerSize',10);
%  for i=1:length(leda2.analyze.initialvalues.peaktime)
%     peaktime_idx(i) = time_idx(leda2.data.time.data, leda2.analyze.initialvalues.peaktime(i));
%  end
% plot(leda2.analyze.initialvalues.peaktime, leda2.data.conductance.data(peaktime_idx),'s','Color',[.9 .2 .2],'MarkerFaceColor',[.9 .2 .2],'Tag','InitialSolutionInfo','MarkerSize',5); 

ni = 1 + leda2.pref.showSmoothData + leda2.pref.showTonicRawData;
kids = get(leda2.gui.rangeview.ax, 'Children');
set(leda2.gui.rangeview.ax, 'Children',[kids((ni+1):end); kids(ni:-1:1)]);

drawnow;
showfit;
change_range;
