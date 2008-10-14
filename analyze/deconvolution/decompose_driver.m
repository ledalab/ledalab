function [onset, amp, sigma] = decompose_driver(time, driver, amp_min, sigma_max, ndiff)
%stepwise substraction of maximum gauss component
global leda2

sr = leda2.data.samplingrate;

d = driver;
%d = driver - min(driver); %force positive values sind negative become equal zero
%xs = zeros(size(d));
i = 0;

%figure;

while 1
    i = i + 1;

    d(d < 0) = 0;
    x = zeros(size(d));

    [onset0, peaktime0, amp0, f20] = get_peaks(1:length(d), d, amp_min, ndiff);
    if isempty(onset0)
        break
    end

    [amp_max, amp_idx] = max(amp0);
     s = (peaktime0(amp_idx) - onset0(amp_idx)) / sr;
     sigma0 = min(s/2.6, sigma_max);
      % sigma = max - f'' = 0 (inflection point is at 1 SD):
%     idx = find(f20 < peaktime0(amp_idx));
%     idx = idx(end);
%     sigma0 = (peaktime0(amp_idx) - f20(idx)) / sr;

    
    winwidth2 = ceil(sr*sigma0*4); %round half winwidth: 4 SD to each side
    t = 1:(winwidth2*2+1); %odd number (2*winwidth-half+1)
    g = normpdf(t, winwidth2+1, sigma0*sr);
    g = g / max(g) * amp_max;

    x_idx = peaktime0(amp_idx)-winwidth2 : peaktime0(amp_idx)+winwidth2;
    valid_idx = (x_idx >= 1 & x_idx <= length(d));
    x(x_idx(valid_idx)) = g(valid_idx);
    d = d - x;
    %xs = xs + x;

    onset(i) = time(peaktime0(amp_idx));
    amp(i) = amp_max;
    sigma(i) = sigma0;

    %     subplot(2,1,1)
    %     cla; hold on;
    %     plot(driver,'k');
    %     plot(xs,'b');
    %     plot(driver-xs,'r');
    %     subplot(2,1,2);
    %     cla; hold on;
    %     plot(d+x,'k')
    %     plot(d,'b')
    %     plot(x_idx(valid_idx), g(valid_idx), 'm');
    %     pause;

end

[onset, idx] = sort(onset);
amp = amp(idx);
sigma = sigma(idx);


%melt close peaks
