function cparset = set_parset_position(wparset, x, epoch)
global leda2

cparset = wparset;
n = length(wparset.onset);

cparset.onset = x(1:n);
cparset.amp = x(n+1 : 2*n);

if leda2.set.tauBinding
    cparset.tau = reshape(x(2*n+1 : 2*n+2*(n>0)),2,[]);
else
    cparset.tau = reshape(x(2*n+1 : 2*n+2*n),2,[]);
end

if leda2.set.optimizeGround
    ng = length(wparset.groundlevel);
    cparset.groundlevel = x(end-ng+1:end);
end

%Check Limits %Settings!!
for i = 1:length(cparset.onset)
    cparset.onset(i) = withinlimits(cparset.onset(i), epoch.start, epoch.end);
    cparset.amp(i) = withinlimits(cparset.amp(i), leda2.set.ampMin, leda2.set.ampMax);

    if i == 1 || ~leda2.set.tauBinding
        cparset.tau(1,i) = withinlimits(cparset.tau(1,i), leda2.set.tauMin, leda2.set.tauMax);
        cparset.tau(2,i) = withinlimits(cparset.tau(2,i), leda2.set.tauMin, leda2.set.tauMax);
        if cparset.tau(2,i) - cparset.tau(1,i) < leda2.set.tauMinDiff
            cparset.tau(2,i) = cparset.tau(1,i) + leda2.set.tauMinDiff;
        end
    end
end
