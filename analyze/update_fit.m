function update_fit(updatetype)
global leda2

%updatetype == 1 : only fit.phasiccoefs
%updatetype == 2 : include fit.data.phasicComponents and actual phasicRemainders and further fit data
%updatetype == 3 : include all all phasicRemainders


if nargin == 0
    updatetype = 3;
end

iEpoch = leda2.analyze.current.iEpoch;

n1 = leda2.analyze.epoch(iEpoch).n_phasicsbefore;
n2 = leda2.analyze.epoch(iEpoch).n_phasicsafter;

%sort onsets
for p = 1:length(leda2.analyze.epoch(iEpoch).parset)
    [sl,idx] = sort(leda2.analyze.epoch(iEpoch).parset(p).onset);
    leda2.analyze.epoch(iEpoch).parset(p).onset = leda2.analyze.epoch(iEpoch).parset(p).onset(idx);
    leda2.analyze.epoch(iEpoch).parset(p).amp = leda2.analyze.epoch(iEpoch).parset(p).amp(idx);
    leda2.analyze.epoch(iEpoch).parset(p).tau = leda2.analyze.epoch(iEpoch).parset(p).tau(:,idx);
    leda2.analyze.epoch(iEpoch).parset(p).sigma = leda2.analyze.epoch(iEpoch).parset(p).sigma(idx);
end

bparset = leda2.analyze.epoch(iEpoch).parset(leda2.analyze.epoch(iEpoch).bestparset);

leda2.analyze.epoch(iEpoch).error = bparset.error;
np = length(bparset.onset);


%Update SCR-List
leda2.analyze.fit.phasiccoef.onset = [leda2.analyze.fit.phasiccoef.onset(1:n1), bparset.onset, leda2.analyze.fit.phasiccoef.onset(end-n2+1:end)];
leda2.analyze.fit.phasiccoef.amp   = [leda2.analyze.fit.phasiccoef.amp(1:n1), bparset.amp, leda2.analyze.fit.phasiccoef.amp(end-n2+1:end)];
leda2.analyze.fit.phasiccoef.tau   = [leda2.analyze.fit.phasiccoef.tau(:,1:n1), bparset.tau, leda2.analyze.fit.phasiccoef.tau(:,end-n2+1:end)];
leda2.analyze.fit.phasiccoef.sigma   = [leda2.analyze.fit.phasiccoef.sigma(1:n1), bparset.sigma, leda2.analyze.fit.phasiccoef.sigma(end-n2+1:end)];
leda2.analyze.fit.toniccoef.time = [leda2.analyze.fit.toniccoef.time(1:leda2.analyze.epoch(iEpoch).n_tonicsbefore), bparset.groundtime, leda2.analyze.fit.toniccoef.time(end-leda2.analyze.epoch(iEpoch).n_tonicsafter+1:end)];
leda2.analyze.fit.toniccoef.ground = [leda2.analyze.fit.toniccoef.ground(1:leda2.analyze.epoch(iEpoch).n_tonicsbefore), bparset.groundlevel, leda2.analyze.fit.toniccoef.ground(end-leda2.analyze.epoch(iEpoch).n_tonicsafter+1:end)];

if updatetype == 1
    return
end


%Update phasicComponent
new_phasicComponent = {};
for i = 1:np
    new_phasicComponent(i) = {scr_template(leda2.data.time.data, bparset.onset(i), bparset.amp(i), bparset.tau(1,i), bparset.tau(2,i), bparset.sigma(i))};  
end

leda2.analyze.fit.data.phasicComponent = [leda2.analyze.fit.data.phasicComponent(1:n1), new_phasicComponent, leda2.analyze.fit.data.phasicComponent(end-n2+1:end)];


%Update phasicRemainder
if updatetype == 3
    lastpeak = n1+np+n2+1; %all
else
    lastpeak = n1+np+1; %#phasicRemainder can temporarily (updatetype = 2) be #phasicComp +1 
end

leda2.analyze.fit.data.phasicRemainder = leda2.analyze.fit.data.phasicRemainder(1:n1+1); %keep first remainders before epoch
for i = n1+2:lastpeak
    leda2.analyze.fit.data.phasicRemainder(i) = {leda2.analyze.fit.data.phasicRemainder{i-1} + leda2.analyze.fit.data.phasicComponent{i-1}};
end
%During optimization phasicRemainder is incomplete for later time periods,
%but will always be completed in the end by update_fit(3)


%Update Data
leda2.analyze.fit.data.phasic = sum(reshape([leda2.analyze.fit.data.phasicComponent{:}], leda2.data.N, n1+np+n2),2)';
leda2.analyze.fit.data.tonic = interp1(leda2.analyze.fit.toniccoef.time, leda2.analyze.fit.toniccoef.ground, leda2.data.time.data, leda2.set.initVal.groundInterp);
leda2.analyze.fit.toniccoef.polycoef = interp1(leda2.analyze.fit.toniccoef.time, leda2.analyze.fit.toniccoef.ground, leda2.set.initVal.groundInterp, 'pp');
tonicRawData = leda2.data.conductance.data - leda2.analyze.fit.data.phasic;
leda2.analyze.fit.data.residual = tonicRawData - leda2.analyze.fit.data.tonic;


if leda2.intern.batchmode
    return;
end

%Graphics
set(leda2.gui.rangeview.estim_ground, 'YData', tonicRawData);
set(leda2.gui.rangeview.groundpoints, 'YData', leda2.analyze.fit.toniccoef.ground);

refresh_fitoverview;
refresh_fitinfo;
