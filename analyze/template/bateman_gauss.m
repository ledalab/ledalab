function component = bateman_gauss(time, onset, amp, tau1, tau2, sigma)

component = bateman(time,onset,0,tau1,tau2);

if sigma > 0
    sr = round(1/mean(diff(time)));
    winwidth2 = ceil(sr*sigma*4); %round half winwidth: 4 SD to each side
    t = 1:(winwidth2*2+1); %odd number (2*winwidth-half+1)
    g = normpdf(t, winwidth2+1, sigma*sr);
    g = g / max(g) * amp;
    bg = conv([ones(1,winwidth2)*component(1), component, ones(1,winwidth2)*component(end)], g);
    
    component = bg((winwidth2*2+1) : (end-winwidth2*2));

end

%component = component / max(component) * amp;
