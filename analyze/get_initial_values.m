function [onset, amp, sigma] = get_initial_values(time, data)
global leda2

%sigc = leda2.set.initVal.signHeight;
sr = leda2.data.samplingrate;

%Kernel
tau = leda2.set.parset.tmp.tau;
tb = 0:(1/sr):200;
b = bateman(tb, 0 ,0 ,tau(1), tau(2));
b = nonzeros(b); %first value must be non-zero!
%b = b/ sr;
%b = b / sum(b); %normalize kernel
nb = length(b);

%Deconvolution
d = data - min(data)*.95;
%add fade-in/out
bg = bateman_gauss(tb(1:nb), 4, 1, tau(1), tau(2), 1);
[mx, idx] = max(bg);
fade_in = bg(1:(idx+sr)) / bg(idx+sr) * d(1); %fade-in: in order to estimate first remainder
fade_in = fade_in(1:end-1);
nfi = length(fade_in);
fade_out = [bg((idx+11):end) / bg(idx+11) * d(end), ones(1,idx+10-1)*bg(end)]; %fade-out: in order to compensate for shortening by deconv
%fade_out = ((nb-1):-1:1)/nb * d(end);
d = [fade_in, d, fade_out]; %fade_out will be cut be deconv

[q, r] = deconv(d, b);
qs = smooth(q, 35, 'gauss'); %smooth until error < c
%qs = qs(nfi+1:end);
leda2.analyze.initialvalues.deconv_driver = qs(nfi+1:end);

amp_min = .2;
sigma_max = leda2.set.sigmaMax;
ndiff = 1;

%Decompose driver
% dr = qs;
% dr(dr < 0) = 0;
% [onset, peaktime, amp] = get_peaks(time, dr, amp_min, ndiff);
% sigma = (peaktime - onset)/3;
% onset = peaktime;

% t = (time(1)-1/sr):(-1/sr):(time(1)-nfi/sr);
% time = [fliplr(t), time];
% [onset, amp, sigma] = decompose_driver(time, qs, amp_min, sigma_max, ndiff);  %sigc
[onset0, onset, amp] = get_peaks(time, qs, amp_min, ndiff);
sigma = ones(size(onset)) * .5;



%Plots
% figure; 
% subplot(2,1,1); hold on; 
% plot(time, qs,'k')
% plot(onset, amp,'r*')
% recomposed_driver = zeros(size(qs));
% for i = 1:length(onset)
%     g = normpdf(time, onset(i), sigma(i));
%     g = g / max(g) * amp(i);
%     plot(time, g, 'g')
%     recomposed_driver = recomposed_driver + g;
% end
% plot(time, recomposed_driver,'b--')
% set(gca, 'YLim', [-.5, 8]) %robust_ylim(recomposed_driver)  
% 
% subplot(2,1,2); hold on; 
% plot(time((nfi+1):end), data-min(data), 'k')
% c = conv(qs, b);
% plot(time, c(1:length(time)),'g')
% cdr = conv(recomposed_driver, b);
% plot(time, cdr(1:length(time)),'m')
%drawnow;
