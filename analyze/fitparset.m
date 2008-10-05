function phasic = fitparset(time, parset)
%global leda2

phasic = zeros(size(time));

for p = 1:length(parset.onset)
%    if ~leda2.set.tauBinding
        phasic = phasic + scr_template(time, parset.onset(p), parset.amp(p), parset.tau(1,p), parset.tau(2,p), parset.sigma(p));
 %   else
 %       phasic = phasic + scr_template(time, parset.onset(p), parset.amp(p), parset.tau(1,1), parset.tau(2,1), parset.sigma(p));
 %   end
end
