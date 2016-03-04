function sdeco(nr_iv)
global leda2

if nargin < 1
    nr_iv = 0;
end

leda2.current.method = 'sdeco';

leda2.set.dist0_min = 0; %leda2.data.conductance.error * 10;  %override setting  %*10
leda2.set.segmWidth = 12;
%leda2.set.autoSmooth = 1;  %-> adaptive smoothing

leda2.analysis0 = [];

%Downsample data for preanalysis, downsample if N > N_max but keep
%samplingrate at 4 Hz minimum
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

if isempty(leda2.analysis) || ~isfield(leda2.analysis,'method') || ~strcmp(leda2.analysis.method,'sdeco')
    leda2.analysis0.tau = leda2.set.tau0_sdeco;
    leda2.analysis0.smoothwin = leda2.set.smoothwin_sdeco; %sec
    leda2.analysis0.tonicGridSize = leda2.set.tonicGridSize_sdeco;
else
    leda2.analysis0.tau = leda2.analysis.tau;
    leda2.analysis0.smoothwin = leda2.analysis.smoothwin;
    if isfield(leda2.analysis,'tonicGridSize')  %workaround since this var is introduced in V3.2.0
        leda2.analysis0.tonicGridSize = leda2.analysis.tonicGridSize;
    else
        leda2.set.tonicGridSize_sdeco = round(mean(diff(leda2.analysis.groundtime)));
    end
end


if ~leda2.intern.batchmode
    %     if exist('leda2.gui.deconv.fig') && ishandle(leda2.gui.deconv.fig)
    %         close(leda2.gui.deconv.fig)
    %     end
    
    leda2.gui.deconv.fig = figure('Units','normalized','Position',[.1 .05 .8 .9],'Name','Continuous Decomposition Analysis','Color',leda2.gui.col.fig,'ToolBar','figure','NumberTitle','off','MenuBar','none');  %
    
    leda2.gui.deconv.text_tau1 = uicontrol('Style','text','Units','normalized','Position',[.1 .01 .05 .02],'String','tau1','BackgroundColor',get(gcf,'Color'));
    leda2.gui.deconv.text_tau2 = uicontrol('Style','text','Units','normalized','Position',[.18 .01 .05 .02],'String','tau2','BackgroundColor',get(gcf,'Color'));
    %leda2.gui.deconv.text_dist0 = uicontrol('Style','text','Units','normalized','Position',[.26 .01 .05 .02],'String','dist0','BackgroundColor',get(gcf,'Color'));
    leda2.gui.deconv.edit_tau1 = uicontrol('Style','edit','Units','normalized','Position',[.1 .04 .05 .03],'String',leda2.analysis0.tau(1));  %tmp_tau1
    leda2.gui.deconv.edit_tau2 = uicontrol('Style','edit','Units','normalized','Position',[.18 .04 .05 .03],'String',leda2.analysis0.tau(2));  %tmp_tau2
    %leda2.gui.deconv.edit_dist0 = uicontrol('Style','edit','Units','normalized','Position',[.26 .04 .05 .03],'String',leda2.analysis0.dist0);  %tmp_dist0
    
    leda2.gui.deconv.text_smoothWinSize = uicontrol('Style','text','Units','normalized','Position',[.31 .065 .08 .025],'String','Smooth-Win [sec]  (SD of Gauss)','BackgroundColor',get(gcf,'Color'));
    leda2.gui.deconv.text_gridsize = uicontrol('Style','text','Units','normalized','Position',[.34 .035 .05 .02],'String','Grid-Size','BackgroundColor',get(gcf,'Color'));
    leda2.gui.deconv.text_sigPeak = uicontrol('Style','text','Units','normalized','Position',[.34 .005 .05 .02],'String','Sig-Peak','BackgroundColor',get(gcf,'Color'));
    leda2.gui.deconv.edit_smoothWinSize = uicontrol('Style','edit','Units','normalized','Position',[.4 .07 .05 .02],'String',leda2.analysis0.smoothwin);
    leda2.gui.deconv.edit_gridSize = uicontrol('Style','edit','Units','normalized','Position',[.4 .04 .05 .02],'String',leda2.set.tonicGridSize_sdeco);
    leda2.gui.deconv.edit_sigPeak = uicontrol('Style','edit','Units','normalized','Position',[.4 .01 .05 .02],'String',leda2.set.sigPeak);
    
    %leda2.gui.deconv.chbx_d0Autoupdate = uicontrol('Style','checkbox','Units','normalized','Position',[.48 .07 .09 .02],'String','d0 autopdate','Value',leda2.set.d0Autoupdate,'BackgroundColor',get(gcf,'Color'));  %tmp_tau1
    leda2.gui.deconv.chbx_tonicIsConst = uicontrol('Style','checkbox','Units','normalized','Position',[.48 .04 .09 .02],'String','tonic = const','Value',leda2.set.tonicIsConst,'BackgroundColor',get(gcf,'Color'),'Enable','Off');  %tmp_tau1
    leda2.gui.deconv.chbx_tonicSlowIncrease = uicontrol('Style','checkbox','Units','normalized','Position',[.48 .01 .09 .02],'String','tonic slow increase','Value',leda2.set.tonicSlowIncrease,'BackgroundColor',get(gcf,'Color'),'Enable','Off');  %tmp_tau1
    
    leda2.gui.deconv.butt_analyze = uicontrol('Style','pushbutton','Units','normalized','Position',[.6 .05 .1 .03],'String','Analyze','Callback',@deconv_analysis_gui);
    leda2.gui.deconv.butt_optimize = uicontrol('Style','pushbutton','Units','normalized','Position',[.6 .02 .1 .02],'String','Optimize','Callback',@deconv_opt);
    leda2.gui.deconv.butt_apply = uicontrol('Style','pushbutton','Units','normalized','Position',[.75 .03 .15 .05],'String','Apply','Callback',@deconv_apply);
    
    deconv_analysis_gui;
    
else
    
    [err, x] = sdeconv_analysis(leda2.analysis0.tau);  %set dist0
    [leda2.analysis0.tau, leda2.analysis0.opt_history] = deconv_optimize(x, nr_iv,'sdeco');
    deconv_apply;
    
end


function deconv_analysis_gui(scr, event)
global leda2

x(1) = str2double(get(leda2.gui.deconv.edit_tau1,'String'));
x(2) = str2double(get(leda2.gui.deconv.edit_tau2,'String'));
%x(3) = str2double(get(leda2.gui.deconv.edit_dist0,'String'));
%leda2.set.d0Autoupdate = get(leda2.gui.deconv.chbx_d0Autoupdate,'Value');
leda2.set.tonicIsConst = get(leda2.gui.deconv.chbx_tonicIsConst,'Value');
leda2.set.tonicSlowIncrease = get(leda2.gui.deconv.chbx_tonicSlowIncrease,'Value');
leda2.analysis0.smoothwin = str2double(get(leda2.gui.deconv.edit_smoothWinSize, 'String'));
leda2.set.tonicGridSize_sdeco = str2double(get(leda2.gui.deconv.edit_gridSize,'String'));
leda2.set.sigPeak = str2double(get(leda2.gui.deconv.edit_sigPeak,'String'));

[err, x] = sdeconv_analysis(x);

set(leda2.gui.deconv.edit_tau1, 'String', x(1));
set(leda2.gui.deconv.edit_tau2, 'String', x(2));
set(leda2.gui.deconv.edit_smoothWinSize, 'String', leda2.analysis0.smoothwin);

%get vars from analysis0
t = leda2.analysis0.target.t; %leda2.data.time.data;
iif_t = leda2.analysis0.target.iif_t;
iif_data = leda2.analysis0.target.iif_data;
groundtime = leda2.analysis0.target.groundtime;
groundlevel = leda2.analysis0.target.groundlevel;

phasicData = leda2.analysis0.phasicData;
tonicData = leda2.analysis0.tonicData;
tonicDriver = leda2.analysis0.tonicDriver;
data = leda2.analysis0.target.d;
driver = leda2.analysis0.driver;
driverSC =leda2.analysis0.driverSC;


%Plot
figure(leda2.gui.deconv.fig);


subplot(5,1,1); hold on;
cla; hold on;
title('SC data')
plot(leda2.data.time.data, leda2.data.conductance.data,'k');
set(gca,'XLim',[t(1), t(end)]);

subplot(5,1,2); hold on;
cla; hold on;
title('Standard Deconvolution: Inter-impulse Fit = Tonic Driver')
plot(t, driverSC,'b')
plot(iif_t, iif_data,'.','Color',[.5 .5 .5])
plot(t, tonicDriver,'Color',[.3 .3 .3])
plot(groundtime, groundlevel,'o','LineWidth',1,'MarkerEdgeColor',[.5 .5 .5],'MarkerFaceColor',[.9 .9 .9],'MarkerSize',5)
set(gca,'XLim',[t(1), t(end)], 'YLim',[min(driverSC)*.9, max(driverSC)*1.1]);

subplot(5,1,3);
cla; hold on;
title('SC Data minus Tonic Data')
plot(t, phasicData, 'm')
plot(t,data - tonicData, 'k');
plot([t(1) t(end)], [0 0],':','Color',[.5 .5 .5])
set(gca,'XLim',[t(1), t(end)], 'YLim',[min(phasicData)-.1, max(1, max(phasicData) *1.1)]);

subplot(5,1,4);
cla; hold on;
title('Phasic Driver')
plot(0,0,'b'); plot(0,0,'r'); plot(0,0,'k');
plot(t, driver, 'Color', 'b');
plot([t(1),t(end)],[0 0],'--','Color',[.3 .3 .3])
set(gca,'XLim',[t(1),t(end)], 'YLim',[min(driver)-.1, max(1, max(driver) *1.1)])

legend(sprintf('Driver discreteness = %4.3f', leda2.analysis0.error.discreteness(1)), sprintf('Driver negativity = %4.3f', leda2.analysis0.error.negativity(1)), 'Location','NorthEast');  %sprintf('Fit RMSE = %5.4f', leda2.analysis0.error.RMSE),

subplot(5,1,5);
cla; hold on;
title('Reconstruction of SC Data')
plot(t, tonicData, 'Color',[.5 .5 .5]);
% for i = 2:length(phasicRemainder)
%     plot(t, tonic0 - dist0 + phasicRemainder{i}) %leda2.analysis.tonicData +
% end
plot(t, tonicData + phasicData, 'm');
plot(leda2.data.time.data, leda2.data.conductance.data,'k');
set(gca,'XLim',[t(1),t(end)])

legend(sprintf('err = %4.3f', leda2.analysis0.error.compound),'Location','NorthEast')


function deconv_opt(scr, event)
global leda2

tau(1) = str2double(get(leda2.gui.deconv.edit_tau1,'String'));
tau(2) = str2double(get(leda2.gui.deconv.edit_tau2,'String'));
%dist0 = str2double(get(leda2.gui.deconv.edit_dist0,'String'));
%leda2.set.d0Autoupdate = get(leda2.gui.deconv.chbx_d0Autoupdate,'Value');
leda2.set.tonicIsConst = get(leda2.gui.deconv.chbx_tonicIsConst,'Value');

[x, history] = cgd(tau, @sdeconv_analysis, [.3 2], .01, 20, .05);
leda2.analysis0.tau = x(1:2);
%leda2.analysis0.dist0 = x(3);
leda2.analysis0.opt_history = history;

set(leda2.gui.deconv.edit_tau1, 'String', x(1));
set(leda2.gui.deconv.edit_tau2, 'String', x(2));
%set(leda2.gui.deconv.edit_dist0, 'String', x(3));

deconv_analysis_gui;


function deconv_apply(scr, event)
global leda2

%Prepare target data for full resolution analysis
leda2.analysis0.target.tonicDriver = ppval(leda2.analysis0.target.poly, leda2.data.time.data);
leda2.analysis0.target.t = leda2.data.time.data;
leda2.analysis0.target.d = leda2.data.conductance.data;
leda2.analysis0.target.sr = leda2.data.samplingrate;

sdeconv_analysis(leda2.analysis0.tau, 0);

delete_fit(0);
leda2.analysis0 = rmfield(leda2.analysis0, {'target','driverSC'});
leda2.analysis = leda2.analysis0;
leda2.analysis.method = 'sdeco';
leda2 = rmfield(leda2, 'analysis0');


% SCRs reconvolved from Driver-Peaks
t = leda2.data.time.data;
driver = leda2.analysis.driver;
[minL, maxL] = get_peaks(driver);
minL = [minL(1:length(maxL)), length(t)];

%Impulse data
leda2.analysis.impulseOnset = t(minL(1:end-1));
leda2.analysis.impulsePeakTime = t(maxL);   % = effective peak-latency
leda2.analysis.impulseAmp = driver(maxL);

%SCR data
leda2.analysis.onset = leda2.analysis.impulsePeakTime;
for iPeak = 1:length(maxL)
    driver_segment = leda2.analysis.driver(minL(iPeak):minL(iPeak+1));
    %driver_segment(driver_segment < 0) = 0;  %negative drivers can lead to wrong detection of maxima
    sc_reconv = conv(driver_segment, leda2.analysis.kernel);
    leda2.analysis.amp(iPeak) = max(sc_reconv);
    mx_idx = find(sc_reconv == max(sc_reconv));
    leda2.analysis.peakTime(iPeak) = t(minL(iPeak)) + mx_idx(1)/leda2.data.samplingrate;  %SCR peak could be outside of SC time range
end
negamp_idx = find(leda2.analysis.amp < .001);  % criterion removes peaks at end of sc_reconv due to large negative driver-segments
leda2.analysis.impulseOnset(negamp_idx) = [];
leda2.analysis.impulsePeakTime(negamp_idx) = [];
leda2.analysis.impulseAmp(negamp_idx) = [];
leda2.analysis.onset(negamp_idx) = [];
leda2.analysis.amp(negamp_idx) = [];
leda2.analysis.peakTime(negamp_idx) = [];

add2log(1,'Continuous Decomposition Analysis.',1,1,1)
leda2.file.version = leda2.intern.version; %work around indicating analysis version of current fit

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
