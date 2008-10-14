function cparset = set_parset_position(wparset, x, epoch)
global leda2

cparset = wparset;
n = length(wparset.onset); %n = nSCR
k = 1; %current position reading gradient vector

if leda2.set.optimizeOnset
    cparset.onset = x(k:n);
    k = k + n;
end

if leda2.set.optimizeAmp
    cparset.amp = x(k : k + n - 1);
    k = k + n;
end

if leda2.set.optimizeSigma
    cparset.sigma = x(k : k + n - 1);
    k = k + n;
end

if leda2.set.optimizeTau
    if leda2.set.tauBinding
        cparset.tau = reshape(x(k : k + 2*(n>0) - 1), 2, []);
    else
        cparset.tau = reshape(x(k : k + 2*n - 1), 2, []);
    end
end

if leda2.set.optimizeGround
    %ng = length(wparset.groundlevel);
    cparset.groundlevel = x(k : end);
end


%Check Limits %Settings!!
for i = 1:length(cparset.onset)

    cparset.onset(i) = withinlimits(cparset.onset(i), epoch.start, epoch.end);
    cparset.amp(i) = withinlimits(cparset.amp(i), leda2.set.ampMin, leda2.set.ampMax);
    cparset.sigma(i) = withinlimits(cparset.sigma(i), leda2.set.sigmaMin, leda2.set.sigmaMax);

    if i == 1 || ~leda2.set.tauBinding
        cparset.tau(1,i) = withinlimits(cparset.tau(1,i), leda2.set.tauMin, leda2.set.tauMax);
        cparset.tau(2,i) = withinlimits(cparset.tau(2,i), leda2.set.tauMin, leda2.set.tauMax);
        if cparset.tau(2,i) - cparset.tau(1,i) < leda2.set.tauMinDiff
            cparset.tau(2,i) = cparset.tau(1,i) + leda2.set.tauMinDiff;
        end
    end

end

for i = 1:length(cparset.groundlevel)
    withinlimits(cparset.groundlevel(i), 0, leda2.data.conductance.max);
end
