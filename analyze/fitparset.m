function phasic = fitparset(time, parset)

phasic = zeros(size(time));
for p = 1:length(parset.onset)
    phasic = phasic + bateman(time, parset.onset(p), parset.amp(p), parset.tau(1,p), parset.tau(2,p));
end
