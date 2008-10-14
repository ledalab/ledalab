function initialize_parset
global leda2

iEpoch = leda2.analyze.current.iEpoch;

leda2.analyze.epoch(iEpoch).parset = [];
leda2.analyze.epoch(iEpoch).iteration = 0;

epoch = leda2.analyze.epoch(iEpoch);

phasic_idx = find(leda2.analyze.fit.phasiccoef.onset >= epoch.start & leda2.analyze.fit.phasiccoef.onset <= epoch.end); %index to scrs in epoch
tonic_idx = find(leda2.analyze.fit.toniccoef.time >= epoch.start & leda2.analyze.fit.toniccoef.time <= epoch.end); %index to groundtimes in epoch

onset_epoch = leda2.analyze.fit.phasiccoef.onset(phasic_idx);
amp_epoch = leda2.analyze.fit.phasiccoef.amp(phasic_idx);
tau_epoch = leda2.analyze.fit.phasiccoef.tau(1:2, phasic_idx);
sigma_epoch = leda2.analyze.fit.phasiccoef.sigma(phasic_idx);


%Identifiy small and big peaks
smallpeak_bool = amp_epoch < leda2.set.parset.smallPeakThresh;
smallpeak_idx = find(smallpeak_bool);
bigpeak_idx = find(~smallpeak_bool);
% get respective parameters
smallpeak_onset = onset_epoch(smallpeak_idx);
smallpeak_amp = amp_epoch(smallpeak_idx);
smallpeak_tau = tau_epoch(1:2, smallpeak_idx);
smallpeak_sigma = sigma_epoch(smallpeak_idx);
%smallpeak_N = length(smallpeak_idx);
bigpeak_onset = onset_epoch(bigpeak_idx);
bigpeak_amp = amp_epoch(bigpeak_idx);
bigpeak_tau = tau_epoch(1:2, bigpeak_idx);
bigpeak_sigma = sigma_epoch(bigpeak_idx);

%if no small peaks, at least one is given
% if isempty(smallpeak_onset) %smallpeak_N == 0
%     smallpeak_onset = (epoch.start + epoch.end)/2;
%     smallpeak_amp = leda2.set.parset.smallPeakThresh/2;
%     smallpeak_tau = leda2.set.parset.tmp.tau; %or last peak
%     smallpeak_sigma = leda2.set.parset.tmp.sigma;
%     %smallpeak_N = 1;
% end
max_parsets = leda2.set.parset.maxParsets;
[smallpeak_onset_ss, subset_idx] = allsubsets(smallpeak_onset);
if length(smallpeak_onset_ss) > max_parsets %take the last (max_parset) parsets
    %add2log(1,[' Epoch ',num2str(iEpoch),': Actually ',num2str(length(smallpeak_onset_ss)),' parsets for ',num2str(length(onset_epoch)),' peaks'],1,1,0,0,1);
    smallpeak_onset_ss = smallpeak_onset_ss([1:3,end+4-max_parsets:end]); %(end+1-max_parsets:end);
    subset_idx = subset_idx([1:3,end+4-max_parsets:end]); %(end+1-max_parsets:end);
end


%Initialize parsets
for p = 1:length(smallpeak_onset_ss)  % 2^smallpeak_N
    parset(p) = leda2.set.parset.tmp;
    parset(p).id = p;
    parset(p).onset = [smallpeak_onset_ss{p}, bigpeak_onset];
    parset(p).amp = [smallpeak_amp(subset_idx{p}), bigpeak_amp];
    parset(p).tau = [smallpeak_tau(1:2,subset_idx{p}), bigpeak_tau];
    parset(p).sigma = [smallpeak_sigma(subset_idx{p}), bigpeak_sigma];
    %sort onset_times
    [parset(p).onset, idx] = sort(parset(p).onset);
    parset(p).amp = parset(p).amp(idx);
    if isempty(parset(p).onset),
        parset(p).tau = [];
    else
        parset(p).tau = parset(p).tau(1:2, idx);
        if leda2.set.tauBinding  %tau binding: 1 tau per epoch calculated as mean weighted by amps
            weighted_tau = (parset(p).tau * parset(p).amp') / sum(parset(p).amp);
            parset(p).tau = weighted_tau * ones(1, length(parset(p).onset));
        end
    end
    parset(p).sigma = parset(p).sigma(idx);
    
    %tonic
    parset(p).groundtime = leda2.analyze.fit.toniccoef.time(tonic_idx);
    parset(p).groundlevel = leda2.analyze.fit.toniccoef.ground(tonic_idx);
    %error
    parset(p).df = length(epoch.data.ca_time) - (length(parset(p).onset)*2 + 2 + length(parset(p).groundlevel)); %datapoints - amps & taus, groundlevel
    parset(p).error = fiterror_parset(epoch, parset(p));
    %history
    %parset(p).history.x(1,:) = get_parset_position(parset(p));
    %parset(p).history.direction(1,:) = zeros(size(parset(p).history.x));
    parset(p).history.error = parset(p).error;
end

leda2.analyze.epoch(iEpoch).parset = parset;
[leda2.analyze.epoch(iEpoch).error, bestparset] = min([parset.error]);
leda2.analyze.epoch(iEpoch).bestparset = bestparset;

leda2.analyze.current.iParset = 1;
