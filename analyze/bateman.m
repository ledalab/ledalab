function conductance = bateman(time,onset,amp,tau1,tau2)

conductance = zeros(size(time));

range = find(time > onset); 
if isempty(range); return; end

maxx   = batemandelay(tau1,tau2);
maxamp = exp(-maxx/tau1) - exp(-maxx/tau2);

xr = time(range) - onset;
conductance(range) = amp/maxamp * (exp(-xr/tau1) - exp(-xr/tau2)); 
