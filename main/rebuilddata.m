function rebuilddata
global leda2

n = length(leda2.data.conductance.data);
dt = 1/leda2.data.samplingrate;
tau = leda2.analysis.tau;

if leda2.file.version <= 3.11

    t_ext = [leda2.analysis.time_ext, leda2.data.time.data];
    n_ext = length(t_ext);
    impulse = leda2.analysis.impulse;
    overshoot = leda2.analysis.overshoot;
    onset_idx = leda2.analysis.onset_idx;
    tb = t_ext - t_ext(1) + dt;
    kernel = bateman_gauss(tb, 0, 0, tau(1), tau(2), 0);


    n_offset = n_ext - n;
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
        impResp = impResp(n_offset+1:end);
        phasicComponent(i) = {impResp};
        phasicRemainder(i+1) = {phasicRemainder{i} + impResp};
    end

    leda2.analysis.phasicComponent = phasicComponent;
    leda2.analysis.phasicRemainder = phasicRemainder;
    leda2.analysis.method = 'nndeco';


else %V3.2.0+

    if strcmp(leda2.analysis.method,'nndeco')

        t_ext = [leda2.analysis.prefix.time, leda2.data.time.data];
        n_ext = length(t_ext);
        n_offset = n_ext - n;

        impulse = [leda2.analysis.prefix.impulse, leda2.analysis.impulse];
        overshoot = [leda2.analysis.prefix.overshoot, leda2.analysis.overshoot];
        onset_idx = [leda2.analysis.prefix.onset_idx, leda2.analysis.onset_idx + n_offset];
        tb = t_ext - t_ext(1) + dt;
        kernel = bateman_gauss(tb, 0, 0, tau(1), tau(2), 0);


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
            impResp = impResp(n_offset+1:end);
            phasicComponent(i) = {impResp};
            phasicRemainder(i+1) = {phasicRemainder{i} + impResp};
        end

        leda2.analysis.phasicComponent = phasicComponent(length(leda2.analysis.prefix.onset_idx)+1:end);
        leda2.analysis.phasicRemainder = phasicRemainder(length(leda2.analysis.prefix.onset_idx)+1:end);

    else %method = sdeco
    %nothing to do

    end
end
