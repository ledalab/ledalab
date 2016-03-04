function [err, x] = sdeconv_analysis(x, estim_tonic)
global leda2

if nargin < 2
    estim_tonic = 1;
end

%Check Limits
x(1) = withinlimits(x(1), leda2.set.tauMin, 10);
x(2) = withinlimits(x(2), leda2.set.tauMin, 20);
if x(2) < x(1)   %tau1 < tau2
    x(1:2) = fliplr(x(1:2));
end
if abs(x(1)-x(2)) < leda2.set.tauMinDiff
    x(2) = x(2) + leda2.set.tauMinDiff;
end

tau(1) = x(1);
tau(2) = x(2);
%dist0 = x(3);

data = leda2.analysis0.target.d; %leda2.data.conductance.data;
t = leda2.analysis0.target.t;  %leda2.data.time.data;
sr = leda2.analysis0.target.sr;  %leda2.data.samplingrate;
smoothwin = leda2.analysis0.smoothwin * 8;  %%% Gauss 8 SD
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
n_prefix = length(prefix);
d_ext = [prefix(:)', d];

t_ext = (t(1)-dt):-dt:(t(1)-n_prefix*dt);
t_ext = [fliplr(t_ext), t];
tb = t_ext - t_ext(1) + dt;

kernel = bateman_gauss(tb, 0, 0, tau(1), tau(2), 0);
%Adaptive kernel size
[mx, midx] = max(kernel);
kernelaftermx = kernel(midx+1:end);
kernel = [kernel(1:midx), kernelaftermx(kernelaftermx > 10^-5)];
kernel = kernel / sum(kernel); %normalize to sum = 1

sigc = max(.1, leda2.set.sigPeak/max(kernel)*10);  %threshold for burst peak

%ESTIMATE TONIC
[driverSC, remainderSC] = deconv([d_ext, d_ext(end)*ones(1,length(kernel)-1)], kernel);
driverSC_smooth = smooth(driverSC, swin, 'gauss');
%Shorten to data range
driverSC = driverSC(n_prefix+1:end);
driverSC_smooth = driverSC_smooth(n_prefix+1:end);
remainderSC = remainderSC(n_prefix+1:length(d)+n_prefix);
%Inter-impulse fit
[onset_idx, impulse, overshoot, impMin, impMax] = segment_driver(driverSC_smooth, zeros(size(driverSC_smooth)), sigc, round(sr * leda2.set.segmWidth));  %Segmentation of non-extended data!
if estim_tonic
    [tonicDriver, tonicData] = sdeco_interimpulsefit(driverSC_smooth, kernel, impMin, impMax);
else
    tonicDriver = leda2.analysis0.target.tonicDriver;
    nKernel = length(kernel);
    tonicData = conv([tonicDriver(1)*ones(1,nKernel), tonicDriver], kernel);
    tonicData = tonicData(nKernel:length(tonicData) - nKernel);
end

%Build tonic and phasic data
phasicData = d - tonicData;
%phasicData(phasicData < 0) = 0;
phasicDriverRaw = driverSC - tonicDriver;
phasicDriver = smooth(phasicDriverRaw, swin, 'gauss');  %%%


%Compute model error
err_MSE = fiterror(data, tonicData+phasicData, 0, 'MSE');
err_RMSE = sqrt(err_MSE);
err_chi2 = err_RMSE / leda2.data.conductance.error;
err1d = deverror(phasicDriver, .2);
err1s = succnz(phasicDriver, max(.01, max(phasicDriver)/20), 2, sr);
phasicDriverNeg = phasicDriver;
phasicDriverNeg(phasicDriverNeg > 0) = 0;
err_discreteness = err1s;
err_negativity = sqrt(mean(phasicDriverNeg.^2));
%err1s = mean((diff(impMin')/sr).^2);
%nSCR_per_min = length(onset_idx)/t_ext(end)*60;

%CRITERION
alpha = 5;
%err = (err_discreteness + 1)*(err_negativity * alpha + 1) - 1;  %compound err criterion to be optimized
err = err_discreteness + err_negativity * alpha;

%(1+ err_RMSE) *

%SAVE VARS
leda2.analysis0.tau = tau;
leda2.analysis0.driver = phasicDriver;  %i.e. smoothed driver
leda2.analysis0.tonicDriver = tonicDriver;
leda2.analysis0.driverSC = driverSC_smooth;
leda2.analysis0.remainder = remainderSC;
leda2.analysis0.kernel = kernel;
leda2.analysis0.phasicData = phasicData;
leda2.analysis0.tonicData = tonicData;
leda2.analysis0.phasicDriverRaw = phasicDriverRaw;

%ERROR
leda2.analysis0.error.MSE = err_MSE;
leda2.analysis0.error.RMSE = err_RMSE;
leda2.analysis0.error.chi2 = err_chi2;
leda2.analysis0.error.deviation = [err1d, 0];
leda2.analysis0.error.discreteness = [err_discreteness, 0];
leda2.analysis0.error.negativity = err_negativity;
leda2.analysis0.error.compound = err;
