function rebuilddata  
global leda2

%fit
time = leda2.data.time.data;
phasicData = zeros(size(time));
phasicComponent = {};
phasicRemainder = {};
pc = leda2.analyze.fit.phasiccoef;

for p = 1:length(pc.onset)

    phasicComponent(p) = {bateman(time, pc.onset(p), pc.amp(p), pc.tau(1,p), pc.tau(2,p))};
    phasicRemainder(p) = {phasicData};
    phasicData = phasicData + phasicComponent{p};

end
phasicRemainder(p+1) = {phasicData};

leda2.analyze.fit.data.tonic = ppval(leda2.analyze.fit.toniccoef.polycoef, time);
leda2.analyze.fit.data.phasic = phasicData;
leda2.analyze.fit.data.residual = leda2.data.conductance.data - (leda2.analyze.fit.data.tonic + leda2.analyze.fit.data.phasic);
leda2.analyze.fit.data.phasicComponent = phasicComponent;
leda2.analyze.fit.data.phasicRemainder = phasicRemainder;
