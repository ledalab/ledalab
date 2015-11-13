function nndeco(nr_iv)
global leda2

if nargin < 1
    nr_iv = 0;
end

leda2.current.method = 'nndeco';

leda2.set.dist0_min = leda2.data.conductance.error * 10;  %override setting  %*10
leda2.set.segmWidth = 12;
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

if isempty(leda2.analysis) || ~isfield(leda2.analysis,'method') || ~strcmp(leda2.analysis.method,'nndeco')
    leda2.analysis0.tau = leda2.set.tau0;
    leda2.analysis0.dist0 = 0;
    leda2.analysis0.smoothwin = leda2.set.smoothwin; %sec
else
    leda2.analysis0.tau = leda2.analysis.tau;
    leda2.analysis0.dist0 = leda2.analysis.dist0;
    leda2.analysis0.smoothwin = leda2.analysis.smoothwin;
end


if ~leda2.intern.batchmode
    %     if exist('leda2.gui.deconv.fig') && ishandle(leda2.gui.deconv.fig)
    %         close(leda2.gui.deconv.fig)
    %     end

    leda2.gui.deconv.fig = figure('Units','normalized','Position',[.1 .05 .8 .9],'Name','Decomposition analysis','Color',leda2.gui.col.fig,'ToolBar','figure','NumberTitle','off','MenuBar','none');  %

    leda2.gui.deconv.text_tau1 = uicontrol('Style','text','Units','normalized','Position',[.1 .01 .05 .02],'String','tau1','BackgroundColor',get(gcf,'Color'));
    leda2.gui.deconv.text_tau2 = uicontrol('Style','text','Units','normalized','Position',[.18 .01 .05 .02],'String','tau2','BackgroundColor',get(gcf,'Color'));
    leda2.gui.deconv.text_dist0 = uicontrol('Style','text','Units','normalized','Position',[.26 .01 .05 .02],'String','dist0','BackgroundColor',get(gcf,'Color'));
    leda2.gui.deconv.edit_tau1 = uicontrol('Style','edit','Units','normalized','Position',[.1 .04 .05 .03],'String',leda2.analysis0.tau(1));  %tmp_tau1
    leda2.gui.deconv.edit_tau2 = uicontrol('Style','edit','Units','normalized','Position',[.18 .04 .05 .03],'String',leda2.analysis0.tau(2));  %tmp_tau2
    leda2.gui.deconv.edit_dist0 = uicontrol('Style','edit','Units','normalized','Position',[.26 .04 .05 .03],'String',leda2.analysis0.dist0);  %tmp_dist0
    
    leda2.gui.deconv.text_smoothWinSize = uicontrol('Style','text','Units','normalized','Position',[.325 .065 .08 .025],'String','Smooth-Win [sec]  (SD of Gauss)','BackgroundColor',get(gcf,'Color'));
    leda2.gui.deconv.text_gridsize = uicontrol('Style','text','Units','normalized','Position',[.34 .035 .05 .02],'String','Grid-Size','BackgroundColor',get(gcf,'Color'));
    leda2.gui.deconv.text_sigPeak = uicontrol('Style','text','Units','normalized','Position',[.34 .005 .05 .02],'String','Sig-Peak','BackgroundColor',get(gcf,'Color'));
    leda2.gui.deconv.edit_smoothWinSize = uicontrol('Style','edit','Units','normalized','Position',[.4 .07 .05 .02],'String',leda2.analysis0.smoothwin);
    leda2.gui.deconv.edit_gridSize = uicontrol('Style','edit','Units','normalized','Position',[.4 .04 .05 .02],'String',leda2.set.tonicGridSize);    
    leda2.gui.deconv.edit_sigPeak = uicontrol('Style','edit','Units','normalized','Position',[.4 .01 .05 .02],'String',leda2.set.sigPeak);
    
    leda2.gui.deconv.chbx_d0Autoupdate = uicontrol('Style','checkbox','Units','normalized','Position',[.48 .07 .09 .02],'String','d0 autopdate','Value',leda2.set.d0Autoupdate,'BackgroundColor',get(gcf,'Color'));  %tmp_tau1
    leda2.gui.deconv.chbx_tonicIsConst = uicontrol('Style','checkbox','Units','normalized','Position',[.48 .04 .09 .02],'String','tonic = const','Value',leda2.set.tonicIsConst,'BackgroundColor',get(gcf,'Color'));  %tmp_tau1
    leda2.gui.deconv.chbx_tonicSlowIncrease = uicontrol('Style','checkbox','Units','normalized','Position',[.48 .01 .09 .02],'String','tonic slow increase','Value',leda2.set.tonicSlowIncrease,'BackgroundColor',get(gcf,'Color'));  %tmp_tau1

    leda2.gui.deconv.butt_analyze = uicontrol('Style','pushbutton','Units','normalized','Position',[.6 .05 .1 .03],'String','Analyze','Callback',@deconv_analysis_gui);
    leda2.gui.deconv.butt_optimize = uicontrol('Style','pushbutton','Units','normalized','Position',[.6 .02 .1 .02],'String','Optimize','Callback',@deconv_opt);
    leda2.gui.deconv.butt_apply = uicontrol('Style','pushbutton','Units','normalized','Position',[.75 .03 .15 .05],'String','Apply','Callback',@deconv_apply);

    deconv_analysis_gui;

else

    [err, x] = deconv_analysis([leda2.analysis0.tau, leda2.analysis0.dist0]);  %set dist0
    [xopt, leda2.analysis0.opt_history] = deconv_optimize(x, nr_iv, 'nndeco');
    leda2.analysis0.tau = xopt(1:2);
    leda2.analysis0.dist0 = xopt(3);
    deconv_apply;
    
end


function deconv_analysis_gui(scr, event)
global leda2

x(1) = str2double(get(leda2.gui.deconv.edit_tau1,'String'));
x(2) = str2double(get(leda2.gui.deconv.edit_tau2,'String'));
x(3) = str2double(get(leda2.gui.deconv.edit_dist0,'String'));
leda2.set.d0Autoupdate = get(leda2.gui.deconv.chbx_d0Autoupdate,'Value');
leda2.set.tonicIsConst = get(leda2.gui.deconv.chbx_tonicIsConst,'Value');
leda2.set.tonicSlowIncrease = get(leda2.gui.deconv.chbx_tonicSlowIncrease,'Value');
leda2.analysis0.smoothwin = str2double(get(leda2.gui.deconv.edit_smoothWinSize, 'String'));
leda2.set.tonicGridSize = str2double(get(leda2.gui.deconv.edit_gridSize,'String'));
leda2.set.sigPeak = str2double(get(leda2.gui.deconv.edit_sigPeak,'String'));

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
%kernel = leda2.analysis0.kernel;
driver = leda2.analysis0.driver;
remd = leda2.analysis0.remainder;
%t_ext = [leda2.analysis0.time_ext, t];
%d_ext = [leda2.analysis0.data_ext, d];
%n_off = length(leda2.analysis0.time_ext);
onset_idx = leda2.analysis0.onset_idx;
impulse = leda2.analysis0.impulse;
overshoot = leda2.analysis0.overshoot;
minL = leda2.analysis0.impMin_idx;
maxL = leda2.analysis0.impMax_idx;
phasicRemainder = leda2.analysis0.phasicRemainder;
%c0 = conv(driver, kernel);
phasicData = leda2.analysis0.phasicData;
driver_rawdata = leda2.analysis0.driver_rawdata;


%Plot
figure(leda2.gui.deconv.fig);


subplot(5,1,1); hold on;
cla; hold on;
title('Raw data')
plot(leda2.data.time.data, leda2.data.conductance.data,'k');
set(gca,'XLim',[t(1), t(end)]);

subplot(5,1,2); hold on;
cla; hold on;
title('Standard Deconvolution - Estimate tonic component')
plot(t, driver_rawdata,'k')
plot(iif_t, iif_data,'b.')
plot(t, tonic0 - dist0,'m')
plot(groundtime, groundlevel_pre,'c*')
plot(groundtime, groundlevel,'m*')
set(gca,'XLim',[t(1), t(end)], 'YLim',[min(driver_rawdata), max(driver_rawdata)*1.1]);

subplot(5,1,3);
cla; hold on;
title('Raw data minus tonic component')
plot(t, phasicData, 'm')
%plot(t, dist0 + d_ext,'Color',[.5 .5 .5])
plot(t, dist0 + d, 'k');
set(gca,'XLim',[t(1), t(end)]);

subplot(5,1,4);
cla; hold on;
title('Nonnegative deconvolution')
plot(0,0,'b'); plot(0,0,'r'); plot(0,0,'k');
plot(t, driver, 'Color', [.75 .75 .75]);
plot(t, -remd*2, 'Color', [.8 .4 .4]);
for i = 1:length(maxL)
    if mod(i,2)
        col = [0 0 1];
    else
        col = [.5 .5 1];
    end
    imp_nzidx = find(impulse{i});
    ovs_nzidx = find(overshoot{i});
    %    plot(t([onset_idx(i), onset_idx(i)+imp_nzidx-1, onset_idx(i)+imp_nzidx(end)-1]), [0, impulse{i}(imp_nzidx), 0], 'Color',col)
    plot(t(onset_idx(i)+imp_nzidx-1), impulse{i}(imp_nzidx),'Color',col)
    plot(t(onset_idx(i)+ovs_nzidx-1), -2*overshoot{i}(ovs_nzidx),'Color',col)
end
plot(t(minL), driver(minL), 'g*');
plot(t(maxL), driver(maxL), 'r*');
set(gca,'XLim',[t(1),t(end)], 'YLim',[-max(remd)*2 - .2, max(driver) + .2])

legend(sprintf('Driver error (dev/discr) = %4.3f,  %4.1f)', leda2.analysis0.error.deviation(1), leda2.analysis0.error.discreteness(1)), ...
    sprintf('Remainder error (dev/discr) = %4.3f,  %4.1f)', leda2.analysis0.error.deviation(2), leda2.analysis0.error.discreteness(2)), ...
    sprintf('Total error (dev/discr) = %4.4f, %4.4f', sum(leda2.analysis0.error.deviation), sum(leda2.analysis0.error.discreteness)),'Location','NorthEast');

subplot(5,1,5);
cla; hold on;
title('Reconstruction of data')
plot(t, tonic0 - dist0, 'k');
for i = 2:length(phasicRemainder)
    plot(t, tonic0 - dist0 + phasicRemainder{i}) %leda2.analysis.tonicData +
end
plot(t, tonic0 + d, 'k');
set(gca,'XLim',[t(1),t(end)])

% %residual = d - (tonic + phasicData);
% %err_chi2 = sqrt(mean(residual.^2));
% residual = d - phasicData;
% err_chi2 = sqrt(mean(residual.^2));
legend(sprintf('chi2 = %4.3f,  err = %4.3f', leda2.analysis0.error.chi2, leda2.analysis0.error.compound),'Location','NorthEast')


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
leda2.analysis0.target.d = leda2.data.conductance.data; %smoothData;  % - leda2.analysis0.target.tonic0
leda2.analysis0.target.sr = leda2.data.samplingrate;

%leda2.set.sigPeak = .003;
deconv_analysis([leda2.analysis0.tau, leda2.analysis0.dist0]);

leda2.analysis0.tonicData = leda2.analysis0.target.tonic0 - leda2.analysis0.dist0;
leda2.analysis0.tonic_poly = leda2.analysis0.target.tonic0_poly;
leda2.analysis0.tonic_poly.coefs(:,end) = leda2.analysis0.tonic_poly.coefs(:,end) - leda2.analysis0.dist0;
leda2.analysis0.groundtime = leda2.analysis0.target.groundtime;
leda2.analysis0.groundlevel = leda2.analysis0.target.groundlevel0 - leda2.analysis0.dist0;

delete_fit(0);
leda2.analysis0 = rmfield(leda2.analysis0, 'target');
leda2.analysis = leda2.analysis0;
leda2.analysis.method = 'nndeco';
leda2 = rmfield(leda2, 'analysis0');

add2log(1,'Discrete Decomposition Analysis.',1,1,1)
leda2.file.version = leda2.intern.version;

if leda2.intern.batchmode
    return;
end

%Graphics update
close(leda2.gui.deconv.fig);

leda2.gui.rangeview.range = min(leda2.gui.rangeview.range, 60);  %show no more than 60 sec epoch, since differentiated fir model display is memory-consuming
change_range;

file_changed(1);
refresh_fitinfo;
refresh_fitoverview;
showfit;


