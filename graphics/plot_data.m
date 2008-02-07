function plot_data
global leda2

leda2.gui.rangeview.start = 0;

cond = leda2.data.conductance;
time = leda2.data.time;
events = leda2.data.events;
rgview = leda2.gui.rangeview;

leda2.gui.eventinfo.current_event = 0;

%OVERVIEW (Data Display)
axes(leda2.gui.overview.ax);
cla;
hold on
leda2.gui.overview.conductance = plot(time.data, cond.data,'ButtonDownFcn','leda_click(1)','Color',[0 0 0],'LineWidth',1);

%range-indicator-field
rg_start = rgview.start;
rg_end = rgview.start + rgview.range;
leda2.gui.overview.rangefld = fill([rg_start, rg_start, rg_end, rg_end],[.5, cond.max+.5, cond.max+.5, .5],[1 1 1], 'EdgeColor',[0 0 0], 'FaceAlpha',.4,'ButtonDownFcn','leda_click(1)');

%Events - overview
if events.N > 0
    for ev = 1:events.N
        ev_x = events.event(ev).time;
        leda2.gui.overview.markerL(ev) = plot([ev_x ev_x], [0, cond.max+20], '-','Color',[1 0 .3],'ButtonDownFcn','leda_click(1)');
    end
end

leda2.gui.overview.max = (cond.max + .4); %ceil
leda2.gui.overview.min = (cond.min - .4); %floor
set(leda2.gui.overview.ax,'XLim',[0,time.data(end)],'Ylim',[leda2.gui.overview.min, leda2.gui.overview.max],'Color',[.9 .9 .9])
set(get(leda2.gui.overview.ax,'XLabel'),'String','Time [sec]')
set(get(leda2.gui.overview.ax,'YLabel'),'String','SC [\muS]')

set(leda2.gui.overview.edit_max,'String', num2str(leda2.gui.overview.max,'%3.1f'));
set(leda2.gui.overview.text_max,'String', num2str(cond.max,'%3.1f'));
set(leda2.gui.overview.edit_min,'String', num2str(leda2.gui.overview.min,'%3.1f'));
set(leda2.gui.overview.text_min,'String', num2str(cond.min,'%3.1f'));

set(leda2.gui.text_N,'String',['N: ',num2str(leda2.data.N),' smpls'])
set(leda2.gui.text_time,'String',['Time: ',num2str(leda2.data.time.data(end),'%5.2f'),' s'])
set(leda2.gui.text_smplrate,'String',['Freq: ',num2str(leda2.data.samplingrate,'%5.2f'),' Hz'])
set(leda2.gui.text_conderr,'String',['Error: ',num2str(leda2.data.conductance.error,'%5.4f')]);
set(leda2.gui.text_Nevents,'String',['Events: ',num2str(events.N)]);

refresh_fitoverview;


%RANGEVIEW (Epoch Display)
axes(rgview.ax);
cla;
hold on
leda2.gui.rangeview.conductance = plot(time.data, cond.data, 'Color',[0 0 0], 'LineWidth',1,'ButtonDownFcn','leda_click(2)');

leda2.data.conductance.smoothData = smooth(cond.data, leda2.set.initVal.hannWinWidth * leda2.data.samplingrate);
leda2.gui.rangeview.cond_smooth = plot(time.data, leda2.data.conductance.smoothData ,'m','Tag','InitialSolutionInfo','Visible',onoffstr(leda2.pref.showSmoothData),'ButtonDownFcn','leda_click(2)');

if ~isempty(leda2.analyze.fit)
    leda2.gui.rangeview.groundpoints = plot(leda2.analyze.fit.toniccoef.time, leda2.analyze.fit.toniccoef.ground,'ws','MarkerFaceColor',[.8 .8 .8],'MarkerEdgeColor',[1 1 1],'Tag','InitialSolutionInfo','ButtonDownFcn','leda_click(2)');
    tonicRawData = cond.data - leda2.analyze.fit.data.phasic;
    leda2.gui.rangeview.estim_ground = plot(time.data, tonicRawData,'Color',[.8 .8 .8],'Tag','InitialSolutionInfo','Visible',onoffstr(leda2.pref.showTonicRawData),'ButtonDownFcn','leda_click(2)');
end

%ni = 1 + leda2.pref.showSmoothData + leda2.pref.showTonicRawData*(~isempty(leda2.analyze.fit));
%set(leda2.gui.rangeview.ax, 'Children',[kids((ni+1):end); kids(ni:-1:1)]);
kids = get(leda2.gui.rangeview.ax, 'Children');
set(leda2.gui.rangeview.ax, 'Children',kids(end:-1:1));

%Events - rangeview
leda2.gui.rangeview.markerL = [];
leda2.gui.rangeview.eventtxt = [];

for ev = 1:events.N
    ev_x = events.event(ev).time;
    leda2.gui.rangeview.markerL(ev) = plot([ev_x ev_x], [0,100], '-','Color',[1 0 .3],'ButtonDownFcn','leda_click(2)');
    leda2.gui.rangeview.eventtxt(ev) = text(ev_x, cond.max, sprintf('%.1f:  %s (%s)', ev_x, events.event(ev).name, num2str(events.event(ev).nid)),'rotation',90,'verticalalignment','baseline','Color',[1 0 .3],'ButtonDownFcn','leda_click(2)');
end

set(leda2.gui.rangeview.ax, 'XLim', [rg_start, rg_end], 'Color',[.95 .95 1]); %, 'Ylim', [0,cond.max+.25]
set(get(leda2.gui.rangeview.ax,'XLabel'),'String','Time [sec]')
set(get(leda2.gui.rangeview.ax,'YLabel'),'String','Skin Conductance [\muS]')

refresh_fitinfo;
change_range;
refresh_progressinfo;
