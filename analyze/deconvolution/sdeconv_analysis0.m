function [err, x] = sdeconv_analysis(x, tonic_flag)
global leda2

if nargin < 2
    tonic_flag = 1;
end

%Check Limits
x(1) = withinlimits(x(1), leda2.set.tauMin, 10);
x(2) = withinlimits(x(2), leda2.set.tauMin, 20);
%x(3) = withinlimits(x(3), leda2.set.dist0_min, leda2.data.conductance.min);
if x(2) < x(1)   %tau1 < tau2
    x(1:2) = fliplr(x(1:2));
end
if x(1) == x(2)
    x(2) = x(2) + 10*eps;
    err = 10^10;
    return;
end

tau(1) = x(1);
tau(2) = x(2);
%dist0 = x(3);

data = leda2.analysis0.target.d; %leda2.data.conductance.data;
t = leda2.analysis0.target.t;  %leda2.data.time.data;
sr = leda2.analysis0.target.sr;  %leda2.data.samplingrate;
smoothwin = leda2.analysis0.smoothwin;  %%%
dt = 1/sr;
winwidth_max = 3; %sec
swin = round(min(smoothwin, winwidth_max) * sr);

d = data;

%Data preparation
tb = t - t(1) + dt;

bg = bateman_gauss(tb, 5, 1, 2, 40, .4);
[mx, idx] = max(bg);

prefix = bg(1:(idx+1)) / bg(idx+1) * d(1); %+10
prefix = nonzeros(prefix);
nfi = length(prefix);
d_ext = [prefix(:)', d];

t_ext = (t(1)-dt):-dt:(t(1)-nfi*dt);
t_ext = [fliplr(t_ext), t];
tb = t_ext - t_ext(1) + dt;

kernel = bateman_gauss(tb, 0, 0, tau(1), tau(2), 0);
%Adaptive kernel size
[mx, midx] = max(kernel);
kernelaftermx = kernel(midx+1:end);
kernel = [kernel(1:midx), kernelaftermx(kernelaftermx > 10^-5)];
kernel = kernel / sum(kernel); %normalize to sum = 1

sigc = max(.01, leda2.set.sigPeak/max(kernel));  %threshold for burst peak

if tonic_flag

    %Estimate tonic
    qt = deconv([d_ext,d_ext(end)*ones(1,length(kernel)-1)], kernel);
    qts = smooth(qt, swin, 'gauss');  %%%
    [onset_idx, impulse, overshoot, impMin, impMax] = segment_driver(qts, zeros(size(qts)), 1, sigc*10, round(sr * leda2.set.segmWidth));  %.05,
    sdeco_interimpulsefit(qts, t_ext, d_ext, impMin, impMax);  %writes target.xxx0

end


%Data preparation 2
d = leda2.analysis0.target.phasicData;
prefix = prefix / data(1) * d(1);
n_prefix = length(prefix);
% t_ext = (t(1)-dt):-dt:(t(1)-nfi*dt);
% t_ext = [fliplr(t_ext), t];
d_ext = [prefix(:)', d];


%Deconvolution
q = deconv([d_ext,d_ext(end)*ones(1,length(kernel)-1)], kernel);
r = zeros(size(q));
driver = smooth(q, swin, 'gauss');
%driver(driver<0) = 0;
remd = smooth(r, swin, 'gauss');

phasicData = conv(driver, kernel);
tonicData = leda2.analysis0.target.tonicData;


%Shorten to data range
phasicData = phasicData(n_prefix+1:length(d_ext));
driver = driver(n_prefix+1:end);
remainder = remd(n_prefix+1:end);
driver_phasic = q(n_prefix+1:end);


%Compute model error
err_MSE = fiterror(data, tonicData+phasicData, 0, 'MSE');
err_RMSE = sqrt(err_MSE);
err_chi2 = err_RMSE / leda2.data.conductance.error;
err1d = deverror(driver, [0, .2]);
err1s = succnz(driver, max(.01, max(driver)/20), 2);
err_negativity = sqrt(sum(driver(driver < 0).^2)) / length(driver)*10^3;
%err1s = mean((diff(impMin')/sr).^2);
%nSCR_per_min = length(onset_idx)/t_ext(end)*60;

%CRITERION
err = err_RMSE * (1+err_negativity) * err1s * 10^3;  %compound err criterion to be optimized


%[onset_idx, impulse, overshoot, impMin, impMax] = segment_driver(driver,remd, 1, sigc, round(sr * leda2.set.segmWidth));  %.05,  %leda2.set.sigPeak*max(1,(tau(2)-tau(1)))

%Calculate impulse response
% n_ext = length(t_ext);
% n_offs = n_ext - n;
% phasicComponent = {};
% phasicRemainder = {};
% phasicRemainder(1) = {zeros(1, n)};
% driver_dirac = zeros(1, n_ext);
% amp = [];
% area = [];
% overshoot_amp = [];
% peaktime_idx = [];
% for i = 1:length(onset_idx)
%     ons = onset_idx(i);
%     imp = impulse{i};
%     ovs = overshoot{i};
%     pco = conv(imp, kernel);
% 
%     impResp = zeros(1, n_ext);
%     impResp(ons:ons+length(ovs)-1) = ovs;
%     impResp(ons:end) = impResp(ons:end) + pco(1:length(t_ext) - (ons-1));
%     impResp = impResp(n_offs+1:end);
%     phasicComponent(i) = {impResp};
%     phasicRemainder(i+1) = {phasicRemainder{i} + impResp};
% 
%     [amp(i), peaktime_idx(i)] = max(impResp);
%     area(i) = (sum(imp) + sum(ovs)) / sr;
%     driver_dirac(impMax(i)) = area(i);
%     overshoot_amp(i) = max(overshoot{i});
% end
% phasicData = phasicRemainder{end};
% driver_dirac = driver_dirac(n_offs+1:end);


%Save vars
leda2.analysis0.tau = tau;
%leda2.analysis0.dist0 = dist0;
%data
%leda2.analysis0.time_ext = t_ext(1:n_prefix);
%leda2.analysis0.data_ext = d_ext(1:n_prefix) - dist0;
leda2.analysis0.driver = driver;  %i.e. smoothed driver
leda2.analysis0.remainder = remainder;
leda2.analysis0.kernel = kernel;
leda2.analysis0.phasicData = phasicData;
%leda2.analysis0.phasicComponent = phasicComponent;
%leda2.analysis0.phasicRemainder = phasicRemainder;
leda2.analysis0.rawdriver = driver_phasic;
if tonic_flag
    leda2.analysis0.driver_SC = qts(n_prefix+1:end);  %deconv of data not phasicData
end
%leda2.analysis0.driver_dirac = driver_dirac;
%phasic
%leda2.analysis0.onset = t_ext(onset_idx);
%leda2.analysis0.amp = amp;
%leda2.analysis0.area = area;
%leda2.analysis0.impulsePeakTime = t_ext(impMax);
%leda2.analysis0.scrPeakTime = t_ext(peaktime_idx);
%leda2.analysis0.onset_idx = onset_idx;
%leda2.analysis0.scrPeakTime_idx = peaktime_idx;
%leda2.analysis0.impMin_idx = impMin;
%leda2.analysis0.impMax_idx = impMax;
%leda2.analysis0.impulse = impulse;
%leda2.analysis0.overshoot = overshoot;
%leda2.analysis0.overshoot_amp = overshoot_amp;
%ERROR
leda2.analysis0.error.MSE = err_MSE;
leda2.analysis0.error.RMSE = err_RMSE;
leda2.analysis0.error.chi2 = err_chi2;
leda2.analysis0.error.deviation = [err1d, 0];
leda2.analysis0.error.discreteness = [err1s, 0];
leda2.analysis0.error.negativity = err_negativity;
leda2.analysis0.error.compound = err;
