function error = fiterror_parset(epoch, parset)
global leda2

phasic = fitparset(epoch.data.ca_time, parset);
ground = [leda2.analyze.fit.toniccoef.ground(1:epoch.n_tonicsbefore), parset.groundlevel, leda2.analyze.fit.toniccoef.ground(end-epoch.n_tonicsafter+1:end)];
tonic = interp1(leda2.analyze.fit.toniccoef.time, ground, epoch.data.ca_time, leda2.set.initVal.groundInterp);

data = epoch.data.cond2fit;
fit = phasic + tonic;
npars = length(get_parset_position(parset));

error = fiterror(data, fit, npars, leda2.set.errorType);
