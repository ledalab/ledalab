function [err, x] = deconv_analysis(x)
global leda2

%Check Limits
x(1) = withinlimits(x(1), leda2.set.tauMin, 2);  %leda2.set.tauMax);
x(2) = withinlimits(x(2), leda2.set.tauMin, leda2.set.tauMax);
x(3) = withinlimits(x(3), leda2.set.dist0_min, leda2.data.conductance.min);
if x(2) < x(1)   %tau1 < tau2
    x(1:2) = fliplr(x(1:2));
end
if abs(x(1)-x(2)) < leda2.set.tauMinDiff
    x(2) = x(2) + leda2.set.tauMinDiff;
end

tau(1) = x(1);
tau(2) = x(2);
dist0 = x(3);

data = leda2.analysis0.target.d; %leda2.data.conductance.data;
t = leda2.analysis0.target.t;  %leda2.data.time.data;
sr = leda2.analysis0.target.sr;  %leda2.data.samplingrate;
smoothwin = leda2.analysis0.smoothwin * 8;  %%% Gauss 8 SD
dt = 1/sr;
n = length(data);
winwidth_max = 3; %sec
swin = round(min(smoothwin, winwidth_max) * sr);

%d = data + dist0; %d = data - min(data) + dist0;
d = data;

%Data preparation
tb = t - t(1) + dt;
bg = bateman_gauss(tb, 5, 1, tau(1), tau(2), .4);
[mx, idx] = max(bg);

fade_in = bg(1:(idx+10)) / bg(idx+10) * d(1);
fade_in = nonzeros(fade_in);
nfi = length(fade_in);
d_ext = [fade_in(:)', d];

t_ext = (t(1)-dt):-dt:(t(1)-nfi*dt);
t_ext = [fliplr(t_ext), t];
tb = t_ext - t_ext(1) + dt;
kernel = bateman_gauss(tb, 0, 0, tau(1), tau(2), 0);
kernel = kernel / sum(kernel); %normalize to sum = 1
kernel(kernel == 0) = 10*eps;

sigc = max(.01, 2*leda2.set.sigPeak/max(bg));  %threshold for burst peak
%sigc = max(.01, leda2.set.sigPeak/(5*max(kernel)));  %replaced because max(kernel) is dependent of sr

%Estimate tonic
qt = deconv([d_ext,ones(1,length(kernel)-1)], kernel);
%[qts, win] = smooth_adapt(qt, 'gauss', winwidth_max, .0002);  %.0002
qts = smooth(qt, swin, 'gauss');  %%%
[onset_idx, impulse, overshoot, impMin, impMax] = segment_driver(qts, zeros(size(qts)), sigc*20, round(sr * leda2.set.segmWidth));  %.05,
targetdata_min = interimpulsefit(qts, t_ext, impMin, impMax);  %writes target.xxx0

%if the dist0 is always overwriten dist0 can not be fitted, but is set by taus
if leda2.analysis0.dist0 == 0 || leda2.set.d0Autoupdate  %first analysis OR autoupdate
    dist0 = targetdata_min;
    x(3) = targetdata_min;
end


%Data preparation 2
d = leda2.analysis0.target.d0 + dist0;
fade_in = bg(1:(idx+10)) / bg(idx+10) * d(1);
fade_in = nonzeros(fade_in);
nfi = length(fade_in);
d_ext = [fade_in(:)', d];


%Deconvolution
[q, r] = longdiv(d_ext, kernel);
r = r(1:n+nfi);
driver = smooth(q, swin, 'gauss');
remd = smooth(r, swin, 'gauss'); %%%

%[driver, smoothwin_driver] = smooth_adapt(q, 'gauss', winwidth_max, .0005);  %.0002
%driver_s = smooth(driver, swin, 'gauss');  %%%
%remd_s = smooth(remd, swin, 'gauss'); %%%
q0 = deconv([d_ext,ones(1,length(kernel)-1)], kernel);
q0s = smooth(q0, swin, 'gauss');  %%%
%r0s = smooth(r0, smoothwin_driver, 'gauss');
[onset_idx, impulse, overshoot, impMin, impMax] = segment_driver(driver, remd, sigc, round(sr * leda2.set.segmWidth));  %.05,  %leda2.set.sigPeak*max(1,(tau(2)-tau(1)))


%Calculate impulse response
n_ext = length(t_ext);
n_offs = n_ext - n;
phasicComponent = {};
phasicRemainder = {};
phasicRemainder(1) = {zeros(1, n)};
amp = [];
area = [];
overshoot_amp = [];
peaktime_idx = [];
for i = 1:length(onset_idx)
    ons = onset_idx(i);
    imp = impulse{i};
    ovs = overshoot{i};
    pco = conv(imp, kernel);

    impResp = zeros(1, n_ext);
    impResp(ons:ons+length(ovs)-1) = ovs;
    impResp(ons:end) = impResp(ons:end) + pco(1:length(t_ext) - (ons-1));
    impResp = impResp(n_offs+1:end);
    phasicComponent(i) = {impResp};
    phasicRemainder(i+1) = {phasicRemainder{i} + impResp};
    
    [amp(i), peaktime_idx(i)] = max(impResp);
    area(i) = (sum(imp) + sum(ovs)) / sr;
    overshoot_amp(i) = max(overshoot{i});
end
phasicData = phasicRemainder{end};



%Rescale to data range
onset = t_ext(onset_idx);
tidx = find(onset >= 0);
n_offset = length(t_ext) - length(t);
driver = driver(n_offset+1:end);
remainder = remd(n_offset+1:end);
driver_raw = q(n_offset+1:end);
driver_rawdata = qts(n_offset+1:end);
driver_sdeconv = q0s(n_offset+1:end);


%Compute model error
err_MSE = fiterror(d, phasicData, 0, 'MSE');
err_RMSE = sqrt(err_MSE);
err_chi2 = err_RMSE / leda2.data.conductance.error;
err1d = deverror(driver, .2);
err2d = deverror(remainder, .005);
err1s = succnz(driver, max(.01, max(driver)/20), 2, sr);
err2s = succnz(remainder, max(.001, max(remainder)/20), 2, sr);
err_negativity = sqrt(sum(driver(driver < 0).^2)) / length(driver)*10^3;

err = (err1d + err2d) * (err1s + err2s) * err_chi2 * (10 + length(onset_idx)/4)/t(end);  %compound err criterion to be optimized


%Save vars
leda2.analysis0.tau = tau;
leda2.analysis0.dist0 = dist0;
%data
%leda2.analysis0.time_ext = t_ext(1:n_offset);
%leda2.analysis0.data_ext = d_ext(1:n_offset) - dist0;
leda2.analysis0.driver = driver;
leda2.analysis0.remainder = remainder;
leda2.analysis0.kernel = kernel;
leda2.analysis0.phasicData = phasicData;
leda2.analysis0.phasicComponent = phasicComponent(onset >= 0);
leda2.analysis0.phasicRemainder = phasicRemainder((length(find(onset < 0))+1):end);
leda2.analysis0.driver_raw = driver_raw;
leda2.analysis0.driver_standarddeconv = driver_sdeconv;
leda2.analysis0.driver_rawdata = driver_rawdata;
%phasic
leda2.analysis0.onset = onset(tidx);
leda2.analysis0.amp = amp(tidx);
leda2.analysis0.area = area(tidx);
leda2.analysis0.impulseOnset = t_ext(impMin(tidx));
leda2.analysis0.impulsePeakTime = t_ext(impMax(tidx));
leda2.analysis0.scrPeakTime = t_ext(peaktime_idx(tidx));
leda2.analysis0.onset_idx = onset_idx(tidx) - n_offset;
leda2.analysis0.scrPeakTime_idx = peaktime_idx(tidx) - n_offset;
leda2.analysis0.impMin_idx = impMin(tidx,:) - n_offset;
leda2.analysis0.impMax_idx = impMax(tidx) - n_offset;
leda2.analysis0.impulse = impulse(tidx);
leda2.analysis0.overshoot = overshoot(tidx);
leda2.analysis0.overshoot_amp = overshoot_amp(tidx);
leda2.analysis0.prefix.time = t_ext(1:n_offset);
leda2.analysis0.prefix.data = d_ext(1:n_offset);
leda2.analysis0.prefix.onset_idx = onset_idx(onset < 0);
leda2.analysis0.prefix.impulse = impulse(onset < 0);
leda2.analysis0.prefix.overshoot = overshoot(onset < 0);
leda2.analysis0.prefix.phasicComponent = phasicComponent(onset < 0);
leda2.analysis0.prefix.phasicRemainder = phasicRemainder(onset < 0);
%error
leda2.analysis0.error.MSE = err_MSE;
leda2.analysis0.error.RMSE = err_RMSE;
leda2.analysis0.error.chi2 = err_chi2;
leda2.analysis0.error.deviation = [err1d, err2d];
leda2.analysis0.error.discreteness = [err1s, err2s];
leda2.analysis0.error.negativity = err_negativity;
leda2.analysis0.error.compound = err;
