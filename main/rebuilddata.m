function rebuilddata  
global leda2

n = length(leda2.data.conductance.data);
t_ext = [leda2.analysis.time_ext, leda2.data.time.data];
n_ext = length(t_ext);
dt = 1/leda2.data.samplingrate;
tau = leda2.analysis.tau;
impulse = leda2.analysis.impulse;
overshoot = leda2.analysis.overshoot;
onset_idx = leda2.analysis.onset_idx;
tb = t_ext - t_ext(1) + dt;
kernel = bateman_gauss(tb, 0, 0, tau(1), tau(2), 0);


n_offs = n_ext - n;
phasicComponent = {};
phasicRemainder = {};
phasicRemainder(1) = {zeros(1, n)};

for i = 1:length(onset_idx)
    ons = onset_idx(i);
    imp = impulse{i};
    ovs = overshoot{i};
    pco = conv(imp, kernel);

    impResp = zeros(1, n_ext);
    impResp(ons:ons+length(ovs)-1) = ovs;
    impResp(ons:end) = impResp(ons:end) + pco(1:length(t_ext) - (ons-1));
    impResp = impResp(n_offs+1:end);
    phasicComponent(i) = {impResp};
    phasicRemainder(i+1) = {phasicRemainder{i} + impResp};
end

leda2.analysis.phasicComponent = phasicComponent;
leda2.analysis.phasicRemainder = phasicRemainder;
