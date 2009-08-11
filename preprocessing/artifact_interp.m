function artifact_interp
global leda2

leda2.gui.remartf.fig = figure('Units','normalized','Position',[.2 .2 .6 .6],'Name','Artifact correction by means of interpolation','MenuBar','none','NumberTitle','off','Color',leda2.gui.col.fig);

leda2.gui.remartf.text_select = uicontrol('Style','text','Units','normalized','Position',[.1 .9 .6 .04],'String','Tightly select the artifact range (use the mouse to drag a box around):','FontSize',12,'HorizontalAlignment','left');
leda2.gui.remartf.ax = axes('Units','normalized','Position',[.1 .2 .8 .65],'ButtonDownFcn',@remartf_click);

leda2.gui.remartf.text_preperiod = uicontrol('Style','text','Units','normalized','Position',[.2 .05 .13 .03],'String','Pre/Post-Period [sec]','BackgroundColor',get(leda2.gui.remartf.fig,'Color'));
leda2.gui.remartf.edit_preperiod = uicontrol('Style','edit','Units','normalized','Position',[.35 .05 .05 .04],'String',1);
leda2.gui.remartf.edit_postperiod = uicontrol('Style','edit','Units','normalized','Position',[.41 .05 .05 .04],'String',1);
interp_txtL = {'linear','spline','cubic'};
leda2.gui.remartf.text_interptype = uicontrol('Style','text','Units','normalized','Position',[.55 .05 .13 .03],'String','Interpolation-Type','BackgroundColor',get(leda2.gui.remartf.fig,'Color'));
leda2.gui.remartf.popm_interptype = uicontrol('Style','popupmenu','Units','normalized','Position',[.7 .05 .08 .04],'String',interp_txtL,'Value',2);

rv = leda2.gui.rangeview;
[ts, cs, idx] = subrange(rv.start, rv.start + rv.range);
hold on;
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
smoothdata = leda2.data.conductance.smoothData;

%get edits
preT = str2double(get(leda2.gui.remartf.edit_preperiod,'String'));
postT = str2double(get(leda2.gui.remartf.edit_postperiod,'String'));
interpTypeTxt = get(leda2.gui.remartf.popm_interptype,'String');
interpTypeVal = get(leda2.gui.remartf.popm_interptype,'Value');
interpType = interpTypeTxt{interpTypeVal};

%get time index
pre_idx = subrange_idx(time, t1-preT, t1);
post_idx = subrange_idx(time, t2, t2+postT);
art_idx = pre_idx(end)+1:post_idx(1)-1;

%setup spline points
outside_idx = [];
if length(pre_idx) > 1  %if artifact is not at beginning of data
    outside_idx = sort(pre_idx(end:-ceil(length(pre_idx)/3):1)); %outside of artifact range, in steps of third samplingrate from borders
else
    art_idx = [pre_idx, art_idx];
end
if length(post_idx) > 1  %if artifact is not at end of data
    outside_idx = [outside_idx, post_idx(1:round(length(post_idx)/3):end)];
else
    art_idx = [art_idx, post_idx];
end
outside_time = leda2.data.time.data(outside_idx);
outside_sc = smoothdata(outside_idx);
art_time = leda2.data.time.data(art_idx);  %artifact time range
art_sc = interp1(outside_time, outside_sc, art_time, interpType);  %interpolation at artifact time

axes(leda2.gui.remartf.ax);
interplot = plot(art_time, art_sc, 'r-');   %,outside_time(1)   %, outside_sc(1)
pointsplot = plot(outside_time, outside_sc, 'r*','MarkerSize',2);  %only border t

%ask accept, retry, exit
cmd = questdlg('Replace the artifact section (this can not be undone)?','','Continue','Cancel','Continue');
if isempty(cmd) || strcmp(cmd, 'Cancel')
    delete(interplot)
    delete(pointsplot)
    return;
end
if ~isempty(leda2.analysis)
    cmd = questdlg('The current fit will be deleted!','Warning','Continue','Cancel','Continue');
    if isempty(cmd) || strcmp(cmd, 'Cancel')
        delete(interplot)
        delete(pointsplot)
        return;
    else
        delete_fit(1);
    end
end

%replace artifact section
leda2.data.conductance.data(art_idx) = art_sc;
close(leda2.gui.remartf.fig);

refresh_data(1);
file_changed(1);
add2log(1,['Artifact section ',sprintf('%5.2f', t1),' : ',sprintf('%5.2f', t2),' corrected.'],1,1,1);
