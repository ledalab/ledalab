function component = scr_template(time, onset, amp, tau1, tau2, sigma)
global leda2

switch leda2.set.template
    case 1, %bateman     
        component = bateman(time, onset, amp, tau1, tau2);
        
    case 2, %bateman x gauss        
        component = bateman_gauss(time, onset, amp, tau1, tau2, sigma);
        
end
