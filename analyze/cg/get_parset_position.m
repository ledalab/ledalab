function x = get_parset_position(wparset)
global leda2

%x = [onsets, amps, sigmas, tau, groundlevel]
x = [];
if leda2.set.optimizeOnset
    x = [x, wparset.onset];
end

if leda2.set.optimizeAmp
    x = [x, wparset.amp];
end

if leda2.set.optimizeSigma
    x = [x, wparset.sigma];
end

if leda2.set.optimizeTau
    if ~isempty(wparset.tau)
        if leda2.set.tauBinding
            x = [x, reshape(wparset.tau(:,1),1,[])]; %take first tau
        else
            x = [x, reshape(wparset.tau,1,[])];
        end
    end
end

if leda2.set.optimizeGround
    x = [x, wparset.groundlevel];
end
