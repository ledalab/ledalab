function smooth_data(width, type)
global leda2

smoothWinL = {'hann window','moving average','gauss window'};
if nargin == 0 %non-batchmode

    fig = figure('Units','normalized','Position',[.3 .3 .3 .1],'Menubar','None','Name','Smoothing','Numbertitle','Off','Resize','Off');
    uicontrol('Units','normalized','Style','Text','Position',[.1 .6 .2 .15],'String','Window width:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
    edit_winwidth = uicontrol('Units','normalized','Style','edit','Position',[.3 .6 .1 .2],'String', 8);
    uicontrol('Units','normalized','Style','Text','Position',[.1 .2 .2 .25],'String','Type:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
    popm = uicontrol('Units','normalized','Style','popupmenu','Position',[.3 .2 .3 .3],'String',smoothWinL,'Value',3);
    uicontrol('Style','pushbutton','Units','normalized','Position',[.7 .1 .2 .2],'String','OK','Callback','uiresume(gcbf)','FontUnits','normalized');

    uiwait(fig);
    if ~ishandle(fig)  %deleted to cancel
        return
    end

    if ~isempty(leda2.analysis)
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

delete_fit(0);
refresh_data(~leda2.intern.batchmode);
file_changed(1);

if leda2.intern.batchmode    
    typenr = find(strcmpi({'hann', 'mean', 'gauss'}, type));
end;

add2log(1,['Data smoothed with ',  smoothWinL{typenr},' (',num2str(width), ' samples width)'],1,1,1);
