function [onset, peaktime, amp, phasicData, phasicComponents, phasicRemainder] = fit_iv(time, tau1, tau2, onset_iv, peaktime_iv, amp_iv)
global leda2

onset = [];
peaktime = [];
amp = [];
phasicData = zeros(size(time));
phasicComponents = {};
phasicRemainder = {};

delay = batemandelay(tau1, tau2);

for p = 1:length(peaktime_iv)

    %correct for underestimation of peaktimes
    %unprecise correction term correcting for that a peak is visible in the data before
    %the real maximum of the scr
    if leda2.set.initSol.compensateUnderestimOnset
        peaktime(1) = peaktime_iv(1);
        if p>1
            pd = peaktime_iv(p) - peaktime(p-1);
            %corrt = 1.5/abs(pd-3) *  amp_iv(p-1) / (1+amp_iv(p)); %(1+(pd-3)^2)      %(max(.5 ,amp_iv(p)+.1) - amp_iv(p))
            corrt = 2.5/abs(pd-3) *  amp_iv(p-1) * (max(.5 ,amp_iv(p)+.1) - amp_iv(p)); %(1+(pd-3)^2)      %
            corrt = min(corrt, 2);
            peaktime(p) = peaktime_iv(p) + corrt;
        end
    else
        peaktime(p) = peaktime_iv(p);
    end


    onset(p) = peaktime(p) - delay;
    if onset(p) < time(1)   %maybe handle negative onsets later
        onset(p) = time(1);
    end


    %correct for underestimation of amplitudes
    if leda2.set.initSol.compensateUnderestimAmp
        if onset(p) >= time(1) && peaktime(p) < time(end)
            peak_idx = time_idx(time, peaktime(p));
            onset_idx = time_idx(time, onset(p));
            drop = phasicData(onset_idx) - phasicData(peak_idx);
            amp(p) = amp_iv(p) + drop;
        else
            amp(p) = amp_iv(p);
        end
    else
        amp = amp_iv;
    end

    phasicComponents(p) = {bateman(time, onset(p), amp(p), tau1, tau2)};
    phasicRemainder(p) = {phasicData};
    phasicData = phasicData + phasicComponents{p};

end

phasicRemainder(p+1) = {phasicData};
