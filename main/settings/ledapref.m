function ledapref
global leda2

leda2.gui.set.fig = figure('Units','normalized','Position',[.05 .5 .4 .4],'Menubar','None','Name','Visual Settings','Numbertitle','Off','Resize','Off');

dx = .12; %Breite der UIs
dy = .05; %Höhe der UIs
dy2 = .006; %Abstand zwischen Zeilen
dw = [.1 .6 .75]; %Abstand Felder von links (west)
ds = .82; %Abstand des ersten Felds von unten (south)
fs = [.6 .60];

%get initial values
leda2.gui.set.text_getpeaks = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*0 .5 dy],'String','Selection Display','FontUnits','normalized','FontSize',fs(2),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'),'FontWeight','bold');
leda2.gui.set.text_showSmoothData = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*1 .5 dy],'String','Show smoothed data:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.chbx_showSmoothData = uicontrol('Style','checkbox','Units','normalized','Position',[dw(2) ds-(dy+dy2)*1 .026 dy],'Value', leda2.pref.showSmoothData,'FontUnits','normalized','FontSize',fs(1));
leda2.gui.set.text_showMinMax = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*2 .5 dy],'String','Show Min/Max:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
leda2.gui.set.chbx_showMinMax = uicontrol('Style','checkbox','Units','normalized','Position',[dw(2) ds-(dy+dy2)*2 .026 dy],'Value', leda2.pref.showMinMax,'FontUnits','normalized','FontSize',fs(1));
% leda2.gui.set.text_eventWindow = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*3 .5 dy],'String','Event window (time before/after event) [sec]:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
% leda2.gui.set.edit_eventWindow1 = uicontrol('Style','edit','Units','normalized','Position',[dw(2) ds-(dy+dy2)*3 dx dy],'String', leda2.pref.eventWindow(1),'FontUnits','normalized','FontSize',fs(1));
% leda2.gui.set.edit_eventWindow2 = uicontrol('Style','edit','Units','normalized','Position',[dw(3) ds-(dy+dy2)*3 dx dy],'String', leda2.pref.eventWindow(2),'FontUnits','normalized','FontSize',fs(1));

% leda2.gui.set.text_updateOptimize = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*5 .5 dy],'String','Optimization Graphics','FontUnits','normalized','FontSize',fs(2),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'),'FontWeight','bold');
% leda2.gui.set.text_showEpochfringe = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*6 .5 dy],'String','Show extended error section:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
% leda2.gui.set.chbx_showEpochfringe = uicontrol('Style','checkbox','Units','normalized','Position',[dw(2) ds-(dy+dy2)*6 .026 dy],'Value', leda2.pref.showEpochFringe,'FontUnits','normalized','FontSize',fs(1));
% leda2.gui.set.text_updateFit = uicontrol('Style','text','Units','normalized','Position',[dw(1) ds-(dy+dy2)*7 .5 dy],'String','Refresh fit:','FontUnits','normalized','FontSize',fs(1),'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
% leda2.gui.set.popm_updateFit = uicontrol('Style','popupmenu','Units','normalized','Position',[dw(2) ds-(dy+dy2)*7 dx*2+.03 dy],'String', {'Never';'Every Epoch';'Every improvement'},'Value',leda2.pref.updateFit,'FontUnits','normalized','FontSize',fs(1));

leda2.gui.set.butt_apply = uicontrol('Style','pushbutton','Units','normalized','Position',[.75 .05 .15 .06],'String', 'Apply','Callback',@apply,'FontUnits','normalized');




function apply(scr, event) %#ok<INUSL>
global leda2

%get initial values
leda2.pref.showSmoothData = get(leda2.gui.set.chbx_showSmoothData,'Value');
leda2.pref.showMinMax = get(leda2.gui.set.chbx_showMinMax,'Value');
% leda2.pref.eventWindow(1) = str2double(get(leda2.gui.set.edit_eventWindow1,'String'));
% leda2.pref.eventWindow(2) = str2double(get(leda2.gui.set.edit_eventWindow2,'String'));
% leda2.pref.showEpochFringe = get(leda2.gui.set.chbx_showEpochfringe,'Value');
% leda2.pref.updateFit = get(leda2.gui.set.popm_updateFit,'Value');

close(leda2.gui.set.fig)

change_range;
set(leda2.gui.rangeview.cond_smooth,'Visible',onoffstr(leda2.pref.showSmoothData));
set(leda2.gui.rangeview.minima,'Visible',onoffstr(leda2.pref.showMinMax))
set(leda2.gui.rangeview.maxima,'Visible',onoffstr(leda2.pref.showMinMax))
% if ~isempty(leda2.analysis.fit)
%     set(leda2.gui.rangeview.estim_ground,'Visible',onoffstr(leda2.pref.showMinMax));
% end
refresh_fitoverview;
