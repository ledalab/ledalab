function remove_artifact
global leda2

leda2.gui.remartf.fig = figure('Units','normalized','Position',[.1 .2 .6 .5],'Name','Artifact correction by means of interpolation','MenuBar','none','NumberTitle','off','Color',leda2.gui.col.fig);

leda2.gui.remartf.text_select = uicontrol('Style','text','Units','normalized','Position',[.1 .9 .6 .04],'String','Tightly select the artifact range (use the mouse to drag a box around):','FontSize',12,'HorizontalAlignment','left');
leda2.gui.remartf.ax = axes('Units','normalized','Position',[.1 .2 .8 .65],'ButtonDownFcn',@remartf_click);

leda2.gui.remartf.text_preperiod = uicontrol('Style','text','Units','normalized','Position',[.2 .05 .13 .04],'String','Pre/Post-Period [sec]');
leda2.gui.remartf.edit_preperiod = uicontrol('Style','edit','Units','normalized','Position',[.35 .05 .05 .04],'String',1);
leda2.gui.remartf.edit_postperiod = uicontrol('Style','edit','Units','normalized','Position',[.41 .05 .05 .04],'String',1);
interp_txtL = {'linear','spline','cubic'};
leda2.gui.remartf.text_interptype = uicontrol('Style','text','Units','normalized','Position',[.55 .05 .13 .04],'String','Interpolation-Type');
leda2.gui.remartf.popm_interptype = uicontrol('Style','popupmenu','Units','normalized','Position',[.7 .05 .08 .04],'String',interp_txtL,'Value',3);

rv = leda2.gui.rangeview;
[ts, cs, idx] = subrange(rv.start, rv.start + rv.range);
hold on;
%leda2.gui.remartf.plot_data =
plot(ts, cs, 'k', 'ButtonDownFcn',@remartf_click);
set(leda2.gui.remartf.ax,'Xlim',[ts(1), ts(end)], 'Ylim', [rv.bottom, rv.top])



function remartf_click(scr, event)
global leda2

point1 = get(leda2.gui.remartf.ax,'currentpoint');
finalRect = rbbox;
point2 = get(leda2.gui.remartf.ax,'currentpoint');
pointx(1) = point1(1,1);
pointx(2) = point2(1,1);
t1 = min(pointx);
t2 = max(pointx);

time = leda2.data.time.data;
t1 = withinlimits(t1, time(1), time(end));
t2 = withinlimits(t2, time(1), time(end));

%get edits
preT = str2double(get(leda2.gui.remartf.edit_preperiod,'String'));
postT = str2double(get(leda2.gui.remartf.edit_postperiod,'String'));
interpTypeTxt = get(leda2.gui.remartf.popm_interptype,'String');
interpTypeVal = get(leda2.gui.remartf.popm_interptype,'Value');
interpType = interpTypeTxt{interpTypeVal};

%get time index
%sr = leda2.data.samplingrate;
pre_idx = subrange_idx(t1-preT, t1);
post_idx = subrange_idx(t2, t2+postT);
art_idx = pre_idx(end)+1:post_idx(1)-1;
art_time = leda2.data.time.data(art_idx);  %artifact time range

%setup spline points
outside_idx = [];
if length(pre_idx) > 1  %if artifact is not at beginning of data
    outside_idx = sort(pre_idx(end:-ceil(length(pre_idx)/3):1)); %outside of artifact range, in steps of half samplingrate from borders
end
if length(post_idx) > 1  %if artifact is not at end of data
    outside_idx = [outside_idx, post_idx(1:round(length(post_idx)/3):end)];
end
outside_time = leda2.data.time.data(outside_idx);
outside_sc = leda2.data.conductance.data(outside_idx);
%smooth?
art_sc = interp1(outside_time, outside_sc, art_time, interpType);  %interpolation at artifact time

axes(leda2.gui.remartf.ax);
interplot = plot(art_time, art_sc, 'r-');
pointsplot = plot(outside_time, outside_sc, 'r*','MarkerSize',2);  %only border t

%ask accept, retry, exit
cmd = questdlg('Replace the artifact section (this can not be undone)?','','Continue','Cancel','Continue');
if isempty(cmd) || strcmp(cmd, 'Cancel')
    delete(interplot)
    delete(pointsplot)
    return;
end

%replace artifact section
leda2.data.conductance.data(art_idx) = art_sc;
close(leda2.gui.remartf.fig);
set(leda2.gui.rangeview.conductance,'YData',leda2.data.conductance.data);
set(leda2.gui.overview.conductance,'YData',leda2.data.conductance.data);

file_changed(1);
add2log(1,['Artifact section ',sprintf('%5.2f', t1),' : ',sprintf('%5.2f', t2),' corrected.'],1,1,1);


