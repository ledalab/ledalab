function delay = batemandelay(tau1,tau2)

if tau1 < 0 | tau2 < 0
	error('tau1 or tau2 < 0: (%f, %f)\n', tau1, tau2);
end

if tau1 == tau2
	tau1
	error('tau1 == tau2');
end

delay = tau1 * tau2 * log(tau1/tau2) / (tau1 - tau2);
