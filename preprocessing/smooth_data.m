function smooth_data(width, type)
global leda2

if nargin == 0 %batchmode

    fig = figure('Units','normalized','Position',[.3 .3 .3 .1],'Menubar','None','Name','Smoothing','Numbertitle','Off','Resize','Off');
    uicontrol('Units','normalized','Style','Text','Position',[.1 .6 .2 .15],'String','Window width:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
    edit_winwidth = uicontrol('Units','normalized','Style','edit','Position',[.3 .6 .1 .2],'String', 8);
    smoothWinL = {'hann window','moving average','gauss window'};
    uicontrol('Units','normalized','Style','Text','Position',[.1 .2 .2 .25],'String','Type:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
    popm = uicontrol('Units','normalized','Style','popupmenu','Position',[.3 .2 .3 .3],'String',smoothWinL,'Value',3);
    uicontrol('Style','pushbutton','Units','normalized','Position',[.7 .1 .2 .2],'String','OK','Callback','uiresume(gcbf)','FontUnits','normalized');

    uiwait(fig);
    if ~ishandle(fig)  %deleted to cancel
        return
    end

    if ~isempty(leda2.analyze.fit)
        cmd = questdlg('The current fit will be deleted!','Warning','Continue','Cancel','Continue');
        if isempty(cmd) || strcmp(cmd, 'Cancel')
            return
        end
    end

    width = str2double(get(edit_winwidth,'String'));

    typeTxtL = {'hann', 'mean', 'gauss'};
    typenr = get(popm,'Value');
    type = typeTxtL{typenr};

    close(fig);

end


scs = smooth(leda2.data.conductance.data, width, type);
%downsampling (type factor mean) may result in an additional offset = time(1), which will not be substracted (tim = time - offset) in order not to affect event times
leda2.data.conductance.data = scs(:)';
%update data statistics
leda2.data.conductance.error = sqrt(mean(diff(scs).^2)/2);
leda2.data.conductance.min = min(scs);
leda2.data.conductance.max = max(scs);
leda2.data.conductance.smoothData = smooth(leda2.data.conductance.data, leda2.set.initVal.hannWinWidth * leda2.data.samplingrate);

delete_fit(0);
plot_data;
file_changed(1);
add2log(1,['Data smoothed with ',  smoothWinL{typenr},' (',num2str(width), ' samples width)'],1,1,1);
