function ledaset
global leda2

leda2.gui.set.fig = figure('Units','normalized','Position',[.05 .1 .4 .8],'Menubar','None','Name','Analysis Settings','Numbertitle','Off','Resize','Off');

dx = .12; %Breite der UIs
dy = .025; %Höhe der UIs
dy2 = .003; %Abstand zwischen Zeilen
dw = [.1 .6 .75]; %Abstand Felder von links (west)
ds = .93; %Abstand des ersten Felds von unten (south)
fs = [.6 .60];

leda2.gui.set.text_general = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*0 .5 dy],'String','General','FontUnits','normalized','FontSize',fs(2),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'),'FontWeight','bold');
leda2.gui.set.text_template = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*1 .5 dy],'String','Template:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.popm_template = uicontrol('Style','popupmenu','Units','normalized','Position',[dw(2) ds-(dy+dy2)*1 dw(3)-dw(2)+dx dy],'String', leda2.set.templateL,'FontUnits','normalized','FontSize',fs(1),'Value',leda2.set.template); %,'Enable','off'
leda2.gui.set.text_tonicGridSize = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*2 .5 dy],'String','Grid size for tonic component fit [sec]:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.edit_tonicGridSize = uicontrol('Style','edit','Units','normalized','Position',[dw(2) ds-(dy+dy2)*2 dx dy],'String',leda2.set.tonicGridSize,'FontUnits','normalized','FontSize',fs(1));
%get initial values
%leda2.gui.set.frame_getpeaks = uicontrol('Style','frame','Units','normalized','Position',[dw(1)-.05 ds-(dy+dy2)*2 .9 (dy+dy2)*2],'String','','FontUnits','normalized','FontSize',fs(2),'HorizontalAlignment','left');
leda2.gui.set.text_getpeaks = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*4 .5 dy],'String','Peaks Detection','FontUnits','normalized','FontSize',fs(2),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'),'FontWeight','bold');
leda2.gui.set.text_hannWinWidth = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*5 .5 dy],'String','Smoothing window width [sec]:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.edit_hannWinWidth = uicontrol('Style','edit','Units','normalized','Position',[dw(2) ds-(dy+dy2)*5 dx dy],'String', leda2.set.initVal.hannWinWidth,'FontUnits','normalized','FontSize',fs(1));
leda2.gui.set.text_signHeight = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*6 .5 dy],'String','Significant Height [muS]:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.edit_signHeight = uicontrol('Style','edit','Units','normalized','Position',[dw(2) ds-(dy+dy2)*6 dx dy],'String', leda2.set.initVal.signHeight,'FontUnits','normalized','FontSize',fs(1));
%get initial solution
leda2.gui.set.text_initSol = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*8 .5 dy],'String','Get Initial Solution','FontUnits','normalized','FontSize',fs(2),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'),'FontWeight','bold');
leda2.gui.set.text_considerUnderestimOnset = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*9 .5 dy],'String','Compensate for underestimated onset:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.chbx_considerUnderestimOnset = uicontrol('Style','checkbox','Units','normalized','Position',[dw(2) ds-(dy+dy2)*9 .04 dy],'String', '','Value',leda2.set.initSol.compensateUnderestimOnset,'FontUnits','normalized','FontSize',fs(1));
leda2.gui.set.text_considerUnderestimAmp = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*10 .5 dy],'String','Compensate for underestimated amplitude','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.chbx_considerUnderestimAmp = uicontrol('Style','checkbox','Units','normalized','Position',[dw(2) ds-(dy+dy2)*10 .04 dy],'String', '','Value',leda2.set.initSol.compensateUnderestimAmp,'FontUnits','normalized','FontSize',fs(1));
%setup epochs
leda2.gui.set.text_epochs = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*12 .5 dy],'String','Setup Epochs','FontUnits','normalized','FontSize',fs(2),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'),'FontWeight','bold');
leda2.gui.set.text_epochSize = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*13 .5 dy],'String','Epoch size [sec]:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.edit_epochSize = uicontrol('Style','edit','Units','normalized','Position',[dw(2) ds-(dy+dy2)*13 dx dy],'String', leda2.set.epoch.size, 'FontUnits','normalized','FontSize',fs(1));
leda2.gui.set.text_fringe = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*14 .5 dy],'String','Extended error section (extension to left/right) [sec]:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.edit_leftFringe = uicontrol('Style','edit','Units','normalized','Position',[dw(2) ds-(dy+dy2)*14 dx dy],'String', leda2.set.epoch.leftFringe,'FontUnits','normalized','FontSize',fs(1));
leda2.gui.set.edit_rightFringe = uicontrol('Style','edit','Units','normalized','Position',[dw(3) ds-(dy+dy2)*14 dx dy],'String', leda2.set.epoch.rightFringe,'FontUnits','normalized','FontSize',fs(1));
leda2.gui.set.text_overlap = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*15 .5 dy],'String','Epoch overlap [sec]:', 'FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.edit_overlap = uicontrol('Style','edit','Units','normalized','Position',[dw(2) ds-(dy+dy2)*15 dx dy],'String', leda2.set.epoch.overlap, 'FontUnits','normalized','FontSize',fs(1));
% initialize parsets
leda2.gui.set.text_parsets = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*17 .5 dy],'String','Initialize Parsets','FontUnits','normalized','FontSize',fs(2),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'),'FontWeight','bold');
leda2.gui.set.text_tau = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*18 .5 dy],'String','Initial tau (tau1, tau2):','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.edit_tau1 = uicontrol('Style','edit','Units','normalized','Position',[dw(2) ds-(dy+dy2)*18 dx dy],'String', leda2.set.parset.tmp.tau(1),'FontUnits','normalized','FontSize',fs(1));
leda2.gui.set.edit_tau2 = uicontrol('Style','edit','Units','normalized','Position',[dw(3) ds-(dy+dy2)*18 dx dy],'String', leda2.set.parset.tmp.tau(2),'FontUnits','normalized','FontSize',fs(1));
leda2.gui.set.text_smallPeak = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*19 .5 dy],'String','Small peak threshold [muS]:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.edit_smallPeak = uicontrol('Style','edit','Units','normalized','Position',[dw(2) ds-(dy+dy2)*19 dx dy],'String', leda2.set.parset.smallPeakThresh, 'FontUnits','normalized','FontSize',fs(1));
leda2.gui.set.text_maxParsets = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*20 .5 dy],'String','Maximal parset number:', 'FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.edit_maxParsets = uicontrol('Style','edit','Units','normalized','Position',[dw(2) ds-(dy+dy2)*20 dx dy],'String', leda2.set.parset.maxParsets, 'FontUnits','normalized','FontSize',fs(1));
%optimize
leda2.gui.set.text_optimize = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*22 .5 dy],'String','Optimize','FontUnits','normalized','FontSize',fs(2),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'),'FontWeight','bold');
leda2.gui.set.text_errorThresholdFac = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*23 .5 dy],'String','Error threshold (multiple of conductance error):','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.edit_errorThresholdFac = uicontrol('Style','edit','Units','normalized','Position',[dw(2) ds-(dy+dy2)*23 dx dy],'String', leda2.set.errorThresholdFac, 'FontUnits','normalized','FontSize',fs(1));
leda2.gui.set.text_hTreshold = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*24 .5 dy],'String','Minimal gradient step h:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.edit_hTreshold = uicontrol('Style','edit','Units','normalized','Position',[dw(2) ds-(dy+dy2)*24 dx dy],'String', leda2.set.hThreshold, 'FontUnits','normalized','FontSize',fs(1));
leda2.gui.set.text_optimizeGround = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*25 .5 dy],'String','Optimize tonic component:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.chbx_optimizeGround = uicontrol('Style','checkbox','Units','normalized','Position',[dw(2) ds-(dy+dy2)*25 .04 dy],'String', '','Value',leda2.set.optimizeGround ,'FontUnits','normalized','FontSize',fs(1));
leda2.gui.set.text_ampLimit = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*26 .5 dy],'String','Amplitude valid range (min - max) [muS]:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.edit_ampMin = uicontrol('Style','edit','Units','normalized','Position',[dw(2) ds-(dy+dy2)*26 dx dy],'String', leda2.set.ampMin,'FontUnits','normalized','FontSize',fs(1));
leda2.gui.set.edit_ampMax = uicontrol('Style','edit','Units','normalized','Position',[dw(3) ds-(dy+dy2)*26 dx dy],'String', leda2.set.ampMax,'FontUnits','normalized','FontSize',fs(1));
leda2.gui.set.text_tauLimit = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*27 .5 dy],'String','Tau valid range (min - max):','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.edit_tauMin = uicontrol('Style','edit','Units','normalized','Position',[dw(2) ds-(dy+dy2)*27 dx dy],'String', leda2.set.tauMin,'FontUnits','normalized','FontSize',fs(1));
leda2.gui.set.edit_tauMax = uicontrol('Style','edit','Units','normalized','Position',[dw(3) ds-(dy+dy2)*27 dx dy],'String', leda2.set.tauMax,'FontUnits','normalized','FontSize',fs(1));
leda2.gui.set.text_tauMinDiff = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*28 .5 dy],'String','Tau minimal difference:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.edit_tauMinDiff = uicontrol('Style','edit','Units','normalized','Position',[dw(2) ds-(dy+dy2)*28 dx dy],'String', leda2.set.tauMinDiff, 'FontUnits','normalized','FontSize',fs(1));
%leda2.gui.set.text_tauBinding = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*28 .5 dy],'String','Tau bound per Epoch:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
%leda2.gui.set.chbx_tauBinding = uicontrol('Style','checkbox','Units','normalized','Position',[dw(2) ds-(dy+dy2)*28 .04 dy],'String', '','Value',leda2.set.tauBinding ,'FontUnits','normalized','FontSize',fs(1),'Enable','off');


leda2.gui.set.butt_apply = uicontrol('Style','pushbutton','Units','normalized','Position',[.75 .05 .15 .04],'String', 'Apply','Callback',@apply,'FontUnits','normalized');




function apply(scr, event) %#ok<INUSD>
global leda2

%general
leda2.set.template = get(leda2.gui.set.popm_template,'Value');
leda2.set.tonicGridSize = str2double(get(leda2.gui.set.edit_tonicGridSize,'String'));
%leda2.set.initval.groundinterp = 'spline';
%get initial values
leda2.set.initVal.hannWinWidth = str2double(get(leda2.gui.set.edit_hannWinWidth,'String'));
leda2.set.initVal.signHeight = str2double(get(leda2.gui.set.edit_signHeight,'String'));
%get initial solution
leda2.set.initSol.compensateUnderestimOnset = get(leda2.gui.set.chbx_considerUnderestimOnset,'Value');
leda2.set.initSol.compensateUnderestimAmp = get(leda2.gui.set.chbx_considerUnderestimAmp,'Value');
%setup epochs
leda2.set.epoch.size = str2double(get(leda2.gui.set.edit_epochSize,'String')); %sec
leda2.set.epoch.leftFringe = str2double(get(leda2.gui.set.edit_leftFringe,'String'));
leda2.set.epoch.rightFringe = str2double(get(leda2.gui.set.edit_rightFringe,'String'));
leda2.set.epoch.overlap = str2double(get(leda2.gui.set.edit_overlap,'String'));
leda2.set.epoch.core = leda2.set.epoch.size - leda2.set.epoch.overlap;
%initialize parsets
leda2.set.parset.tmp.tau(1) = str2double(get(leda2.gui.set.edit_tau1,'String'));
leda2.set.parset.tmp.tau(2) = str2double(get(leda2.gui.set.edit_tau2,'String'));
leda2.set.parset.smallPeakThresh = str2double(get(leda2.gui.set.edit_smallPeak,'String'));
leda2.set.parset.maxParsets = str2double(get(leda2.gui.set.edit_maxParsets,'String'));
%optimize
leda2.set.errorThresholdFac = str2double(get(leda2.gui.set.edit_errorThresholdFac,'String'));
leda2.set.hThreshold = str2double(get(leda2.gui.set.edit_hTreshold,'String'));
leda2.set.optimizeGround = get(leda2.gui.set.chbx_optimizeGround,'Value');
leda2.set.ampMin = str2double(get(leda2.gui.set.edit_ampMin,'String'));
leda2.set.ampMax = str2double(get(leda2.gui.set.edit_ampMax,'String'));
leda2.set.tauMin = str2double(get(leda2.gui.set.edit_tauMin,'String'));
leda2.set.tauMax = str2double(get(leda2.gui.set.edit_tauMax,'String'));
leda2.set.tauMinDiff = str2double(get(leda2.gui.set.edit_tauMinDiff,'String'));
%leda2.set.tauBinding = get(leda2.gui.set.chbx_tauBinding,'Value');

if leda2.file.open
    leda2.data.conductance.smoothData = smooth(leda2.data.conductance.data, leda2.set.initVal.hannWinWidth * leda2.data.samplingrate);
    set(leda2.gui.rangeview.cond_smooth,'YData',leda2.data.conductance.smoothData);
end

close(leda2.gui.set.fig);
