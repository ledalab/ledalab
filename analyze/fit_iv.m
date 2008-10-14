function [phasicData, phasicComponents, phasicRemainder] = fit_iv(time, tau1, tau2, onset, amp, sigma)

phasicData = zeros(size(time));
phasicComponents = {};
phasicRemainder = {phasicData};  %set, esp for case isempty(onset)

for p = 1:length(amp)

    phasicComponents(p) = {scr_template(time, onset(p), amp(p), tau1, tau2, sigma(p))};
    phasicRemainder(p) = {phasicData};
    phasicData = phasicData + phasicComponents{p};

end

phasicRemainder(p+1) = {phasicData};
