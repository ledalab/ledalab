function deco(nr_iv)
global leda2

if nargin < 1
    nr_iv = 0;
end

leda2.set.dist0_min = leda2.data.conductance.error * 10;  %override setting
leda2.set.segmWidth = 12;
leda2.set.sigPeak = .01;  %.003
leda2.set.tonicGridSize = 100; %100
leda2.set.d0Autoupdate = 1;
leda2.set.tonicIsConst = 0;
%leda2.set.autoSmooth = 1;  %-> adaptive smoothing

leda2.analysis0 = [];

%Downsample data for preanalysis, downsample if N > N_max
leda2.analysis0.target.t = leda2.data.time.data;
leda2.analysis0.target.d = leda2.data.conductance.data;
leda2.analysis0.target.sr = leda2.data.samplingrate;

Fs_min = 4;
N_max = 3000;
Fs = round(leda2.data.samplingrate);
N = leda2.data.N;

if N > N_max
    factorL = divisors(Fs);
    FsL = Fs./ factorL;
    idx = find(FsL >= Fs_min);
    factorL = factorL(idx);
    FsL = FsL(idx);
    if ~isempty(factorL)
        N_new = N ./ factorL;
        idx = find(N_new < N_max);
        if ~isempty(idx)
            idx = idx(1);
        else
            idx = length(factorL);  %if no factor meets criterium, take largest factor
        end
        fac =  factorL(idx);
        [td, scd] = downsamp(leda2.data.time.data, leda2.data.conductance.data, fac, 'step');
        leda2.analysis0.target.t = td;
        leda2.analysis0.target.d = scd;
        leda2.analysis0.target.sr = FsL(idx);
    else
        %can not be downsampled any further
    end
end


if leda2.intern.batchmode
    leda2.analysis = [];
end

if isempty(leda2.analysis)
    leda2.analysis0.tau = [.75, 20];
    leda2.analysis0.dist0 = 0;
    leda2.analysis0.smoothwin = 0;
else
    leda2.analysis0.tau = leda2.analysis.tau;
    leda2.analysis0.dist0 = leda2.analysis.dist0;
    leda2.analysis0.smoothwin = leda2.analysis.smoothwin;
end


if ~leda2.intern.batchmode
    %     if exist('leda2.gui.deconv.fig') && ishandle(leda2.gui.deconv.fig)
    %         close(leda2.gui.deconv.fig)
    %     end

    leda2.gui.deconv.fig = figure('Units','normalized','Position',[.1 .05 .8 .9],'Name','Deconvolve data','Color',leda2.gui.col.fig,'ToolBar','figure','NumberTitle','off','MenuBar','none');  %
    leda2.gui.deconv.edit_tau1 = uicontrol('Style','edit','Units','normalized','Position',[.1 .03 .05 .04],'String',leda2.analysis0.tau(1));  %tmp_tau1
    leda2.gui.deconv.edit_tau2 = uicontrol('Style','edit','Units','normalized','Position',[.18 .03 .05 .04],'String',leda2.analysis0.tau(2));  %tmp_tau2
    leda2.gui.deconv.edit_dist0 = uicontrol('Style','edit','Units','normalized','Position',[.26 .03 .05 .04],'String',leda2.analysis0.dist0);  %tmp_dist0
    
    leda2.gui.deconv.chbx_d0Autoupdate = uicontrol('Style','checkbox','Units','normalized','Position',[.36 .06 .09 .02],'String','d0 autopdate','Value',leda2.set.d0Autoupdate,'BackgroundColor',get(gcf,'Color'));  %tmp_tau1
    leda2.gui.deconv.chbx_tonicIsConst = uicontrol('Style','checkbox','Units','normalized','Position',[.36 .03 .09 .02],'String','tonic = const','Value',leda2.set.tonicIsConst,'BackgroundColor',get(gcf,'Color'));  %tmp_tau1
    leda2.gui.deconv.edit_smoothWinSize = uicontrol('Style','edit','Units','normalized','Position',[.48 .03 .05 .04],'String',leda2.analysis0.smoothwin,'Enable','inactive');  %tmp_dist0

    leda2.gui.deconv.butt_analyze = uicontrol('Style','pushbutton','Units','normalized','Position',[.6 .05 .1 .03],'String','Analyze','Callback',@deconv_analysis_gui);
    leda2.gui.deconv.butt_optimize = uicontrol('Style','pushbutton','Units','normalized','Position',[.6 .02 .1 .02],'String','Optimize','Callback',@deconv_opt);
    leda2.gui.deconv.butt_apply = uicontrol('Style','pushbutton','Units','normalized','Position',[.75 .03 .15 .05],'String','Apply','Callback',@deconv_apply);

    deconv_analysis_gui;

else

    %[err, leda2.analysis0.tau, leda2.analysis0.dist0, leda2.analysis0.opthistory] = deconv_analysis([leda2.analysis0.tau, leda2.analysis0.dist0]);
    [leda2.analysis0.tau, leda2.analysis0.dist0, leda2.analysis0.opthistory] = deconv_optimize([leda2.analysis0.tau, leda2.analysis0.dist0], nr_iv);
    deconv_apply;

end


function deconv_analysis_gui(scr, event)
global leda2

x(1) = str2double(get(leda2.gui.deconv.edit_tau1,'String'));
x(2) = str2double(get(leda2.gui.deconv.edit_tau2,'String'));
x(3) = str2double(get(leda2.gui.deconv.edit_dist0,'String'));
leda2.set.d0Autoupdate = get(leda2.gui.deconv.chbx_d0Autoupdate,'Value');
leda2.set.tonicIsConst = get(leda2.gui.deconv.chbx_tonicIsConst,'Value');

[err, x] = deconv_analysis(x);

set(leda2.gui.deconv.edit_tau1, 'String', x(1));
set(leda2.gui.deconv.edit_tau2, 'String', x(2));
set(leda2.gui.deconv.edit_dist0, 'String', x(3));
set(leda2.gui.deconv.edit_smoothWinSize, 'String', leda2.analysis0.smoothwin);

%get vars from analysis0
t = leda2.analysis0.target.t; %leda2.data.time.data;
iif_t = leda2.analysis0.target.iif_t;
iif_data = leda2.analysis0.target.iif_data;
dist0 = leda2.analysis0.dist0;
groundtime = leda2.analysis0.target.groundtime;
groundlevel = leda2.analysis0.target.groundlevel0 - dist0;
groundlevel_pre = leda2.analysis0.target.groundlevel_pre;

tonic0 = leda2.analysis0.target.tonic0;
d = leda2.analysis0.target.d0;
kernel = leda2.analysis0.kernel;
driver = leda2.analysis0.driver;
remd = leda2.analysis0.remainder;
t_ext = [leda2.analysis0.time_ext, t];
d_ext = [leda2.analysis0.data_ext, d];
n_off = length(leda2.analysis0.time_ext);
onset_idx = leda2.analysis0.onset_idx;
impulse = leda2.analysis0.impulse;
overshoot = leda2.analysis0.overshoot;
minL = leda2.analysis0.impMin_idx;
maxL = leda2.analysis0.impMax_idx;
phasicRemainder = leda2.analysis0.phasicRemainder;
c0 = conv(driver, kernel);
driver_rawdata = leda2.analysis0.driver_rawdata;


%Plot
figure(leda2.gui.deconv.fig);


subplot(5,1,1); hold on;
cla; hold on;
plot(leda2.data.time.data, leda2.data.conductance.data,'k');
set(gca,'XLim',[t_ext(1), t_ext(end)]);

subplot(5,1,2); hold on;
cla; hold on;
%     plot(t_ext, leda2.analysis0.driver_standarddeconv,'Color',[.4 .4 .4])
plot(t_ext, driver_rawdata,'k')
plot(iif_t, iif_data,'b.')
plot(t, tonic0 - dist0,'m')
plot(groundtime, groundlevel_pre,'c*')
plot(groundtime, groundlevel,'m*')
set(gca,'XLim',[t_ext(1), t_ext(end)], 'YLim',[min(driver_rawdata(n_off+1:end)), max(driver_rawdata(n_off+1:end))*1.1]);

subplot(5,1,3);
cla; hold on;
plot(t_ext, c0(1:length(t_ext)), 'm')
plot(t_ext, dist0 + d_ext,'Color',[.5 .5 .5])
plot(t, dist0 + d, 'k');
set(gca,'XLim',[t_ext(1), t_ext(end)]);

subplot(5,1,4);
cla; hold on;
plot(0,0,'b'); plot(0,0,'r'); plot(0,0,'k');
plot(t_ext, driver, 'Color', [.75 .75 .75]);
plot(t_ext, -remd*2, 'Color', [.8 .4 .4]);
for i = 1:length(maxL)
    if mod(i,2)
        col = [0 0 1];
    else
        col = [.5 .5 1];
    end
    imp_nzidx = find(impulse{i});
    ovs_nzidx = find(overshoot{i});
    %    plot(t_ext([onset_idx(i), onset_idx(i)+imp_nzidx-1, onset_idx(i)+imp_nzidx(end)-1]), [0, impulse{i}(imp_nzidx), 0], 'Color',col)
    plot(t_ext(onset_idx(i)+imp_nzidx-1), impulse{i}(imp_nzidx),'Color',col)
    plot(t_ext(onset_idx(i)+ovs_nzidx-1), -2*overshoot{i}(ovs_nzidx),'Color',col)
end
plot(t_ext(minL), driver(minL), 'g*');
plot(t_ext(maxL), driver(maxL), 'r*');
set(gca,'XLim',[t_ext(1),t_ext(end)], 'YLim',[-max(remd)*2 - .2, max(driver(n_off+1:end)) + .2])
% err1d = deverror(driver, [0, .2]);
% err2d = deverror(remd, [0, 005]);
% err1s = succnz(driver, .05, 1.4);
% err2s = succnz(remd, .05, 1.7);
legend(sprintf('Driver (error = %4.3f,  %4.1f)', leda2.analysis0.err_dev(1), leda2.analysis0.err_succz(1)), sprintf('Remainder (error = %4.3f,  %4.1f)', leda2.analysis0.err_dev(2), leda2.analysis0.err_succz(2)), sprintf('Total error = %4.4f, %4.4f', sum(leda2.analysis0.err_dev), sum(leda2.analysis0.err_succz)),'Location','NorthWest');

subplot(5,1,5);
cla; hold on;
plot(t, tonic0 - dist0, 'k');
for i = 2:length(phasicRemainder)
    plot(t, tonic0 - dist0 + phasicRemainder{i}) %leda2.analysis.tonicData +
end
plot(t, tonic0 + d, 'k');
set(gca,'XLim',[t_ext(1),t_ext(end)])

% %residual = d - (tonic + phasicData);
% %err_chi2 = sqrt(mean(residual.^2));
% residual = d - phasicData;
% err_chi2 = sqrt(mean(residual.^2));
legend(sprintf('chi2 = %4.3f,  err = %4.3f', leda2.analysis0.err_chi2, leda2.analysis0.err),'Location','NorthWest')  %, sprintf('chi2 (fit t) = %4.5f', err_chi2_t)


function deconv_opt(scr, event)
global leda2

tau(1) = str2double(get(leda2.gui.deconv.edit_tau1,'String'));
tau(2) = str2double(get(leda2.gui.deconv.edit_tau2,'String'));
dist0 = str2double(get(leda2.gui.deconv.edit_dist0,'String'));
leda2.set.d0Autoupdate = get(leda2.gui.deconv.chbx_d0Autoupdate,'Value');
leda2.set.tonicIsConst = get(leda2.gui.deconv.chbx_tonicIsConst,'Value');

[x, history] = cgd([tau, dist0], @deconv_analysis, [.3 20 .02], .01, 20, .05);
leda2.analysis0.tau = x(1:2);
leda2.analysis0.dist0 = x(3);
leda2.analysis0.opt_history = history;

set(leda2.gui.deconv.edit_tau1, 'String', x(1));
set(leda2.gui.deconv.edit_tau2, 'String', x(2));
set(leda2.gui.deconv.edit_dist0, 'String', x(3));

deconv_analysis_gui;


function deconv_apply(scr, event)
global leda2

%Prepare target data for full resolution analysis
if leda2.set.tonicIsConst
    leda2.analysis0.target.tonic0 = leda2.analysis0.target.groundlevel0 * ones(size(leda2.data.time.data));
else
    leda2.analysis0.target.tonic0 = ppval(leda2.analysis0.target.tonic0_poly, leda2.data.time.data);
end
leda2.analysis0.target.t = leda2.data.time.data;
leda2.analysis0.target.d = leda2.data.conductance.smoothData;  % - leda2.analysis0.target.tonic0
leda2.analysis0.target.sr = leda2.data.samplingrate;

leda2.set.sigPeak = .001;
deconv_analysis([leda2.analysis0.tau, leda2.analysis0.dist0]);

leda2.analysis0.tonicData = leda2.analysis0.target.tonic0 - leda2.analysis0.dist0;
leda2.analysis0.tonic_poly = leda2.analysis0.target.tonic0_poly;
leda2.analysis0.tonic_poly.coefs(:,end) = leda2.analysis0.tonic_poly.coefs(:,end) - leda2.analysis0.dist0;
leda2.analysis0.groundtime = leda2.analysis0.target.groundtime;
leda2.analysis0.groundlevel = leda2.analysis0.target.groundlevel0 - leda2.analysis0.dist0;

leda2.analysis0 = rmfield(leda2.analysis0, 'target');
leda2.analysis = leda2.analysis0;
leda2 = rmfield(leda2, 'analysis0');

trough2peak_analysis;

add2log(1,'Deconvolution analysis.',1,1,1)

if leda2.intern.batchmode
    return;
end

%Graphics update
close(leda2.gui.deconv.fig);

file_changed(1);
refresh_fitinfo;
refresh_fitoverview;
showfit;


function trough2peak_analysis
global leda2

ds = leda2.data.conductance.smoothData;  %smooth(leda2.data.conductance.data, round(leda2.data.samplingrate / 2), 'gauss');
t = leda2.data.time.data;
[minL, maxL] = get_peaks(ds, 1);
dmm = ds(maxL)-ds(minL(1:end-1));
tau1 = leda2.analysis.tau(1);
tau2 = leda2.analysis.tau(2);
if tau1 ~= 0
    maxx = tau1 * tau2 * log(tau1/tau2) / (tau1 - tau2);
    maxamp = abs(exp(-maxx/tau2) - exp(-maxx/tau1));
else
    maxamp =  1;
end
sigc = maxamp/((tau2-tau1)*leda2.data.samplingrate)*leda2.set.sigPeak;
minL = minL(dmm >= sigc);
maxL = maxL(dmm >= sigc);
leda2.analysis.trough2peak.onset = t(minL);
leda2.analysis.trough2peak.peaktime = t(maxL);
leda2.analysis.trough2peak.onset_idx = minL;
leda2.analysis.trough2peak.peaktime_idx = maxL;
leda2.analysis.trough2peak.amp = ds(maxL) - ds(minL);
