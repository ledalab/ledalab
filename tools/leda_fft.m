function leda_fft
global leda2


x = leda2.data.conductance.data;
n = leda2.data.N;
sr = leda2.data.samplingrate;

hw = hannwin(n);
hw = hw * n;
x = x .* hw; %hanning window to avoid leakage

%FFT
Y = fft(x);
Pyy = Y.* conj(Y) / (n/2)^2;
Pyy = Pyy(1:floor(n/2)); %2nd half is redundant
f = sr*(0:floor(n/2)-1)/n; %meaningful frequency scale

%select frequency range for x-axis
 f_min = 1;
 f_max = round(sr/2);
 idx = find(f >= f_min & f <= f_max);
 f_rg = f(idx);
 Pyy_rg = Pyy(idx);

%get maximum
[mx, idx] = max(Pyy_rg);
fmax_rg = f_rg(idx(1));


%Plot FFT
if 1
    figure('Name','FFT Spectrum','Menubar','None','Numbertitle','Off');   %
    axes;
    plot(f_rg, Pyy_rg,'k')
    text(f_rg(round(length(f_rg)*.3)), mx, ['fmax = ',sprintf(' (%4.2fHz)', fmax_rg)]);
    set(gca,'YLim',[0, mx*1.3],'XLim',[f_min, f_max]);  %,'YScale','log'
end




function hw = hannwin(winsize)

hw = .5*(1-cos(2*pi*(1:winsize)/(winsize+1)));
hw = hw ./ sum(hw(:));
