function conductance = bateman(time,onset,amp,tau1,tau2)

if tau1 < 0 || tau2 < 0
    error('tau1 or tau2 < 0: (%f, %f)\n', tau1, tau2);
end

if tau1 == tau2
    error('tau1 == tau2 == %f', tau1);
end

conductance = zeros(size(time));
range = find(time > onset);
if isempty(range);
    return;
end
xr = time(range) - onset;


if amp > 0
    maxx = tau1 * tau2 * log(tau1/tau2) / (tau1 - tau2);  %b' = 0
    maxamp = abs(exp(-maxx/tau2) - exp(-maxx/tau1));
    c =  amp/maxamp;

else %amp == 0: normalized bateman, area(bateman) = 1/sr
    sr = round(1/mean(diff(time)));
    c = 1/((tau2 - tau1) * sr);

end

if tau1 > 0
    conductance(range) = c * (exp(-xr/tau2) - exp(-xr/tau1));
else
    conductance(range) = c * exp(-xr/tau2);
end
