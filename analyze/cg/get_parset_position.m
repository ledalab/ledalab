function x = get_parset_position(wparset)
global leda2

%x = [onsets, amps, taus, sigmas, groundlevel]

x = [wparset.onset, wparset.amp];

if ~isempty(wparset.tau)
    if leda2.set.tauBinding
        x = [x, reshape(wparset.tau(:,1),1,[])]; %take first tau
    else
        x = [wparset.onset, wparset.amp, reshape(wparset.tau,1,[])];
    end
end

if leda2.set.optimizeSigma
    x = [x, wparset.sigma];
end

if leda2.set.optimizeGround
    x = [x, wparset.groundlevel];
end
