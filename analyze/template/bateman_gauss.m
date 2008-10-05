function component = bateman_gauss(time, onset, amp, tau1, tau2, sigma)
global leda2

b = bateman(time,onset,amp,tau1,tau2);

sr = leda2.data.samplingrate;
winwidth2 = ceil(sr*sigma*4); %round half winwidth: 4 SD to each side
t = 1:(winwidth2*2+1); %odd number (2*winwidth-half+1)
g = normpdf(t, winwidth2+1, sigma*sr);
g = g / sum(g);
bg = conv([ones(1,winwidth2)*b(1), b, ones(1,winwidth2)*b(end)], g);

component = bg((winwidth2*2+1) : (end-winwidth2*2));

