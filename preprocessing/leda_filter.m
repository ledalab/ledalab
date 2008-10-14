function leda_filter(limits, type)
global leda2

if nargin == 0 %batchmode

    fig = figure('Units','normalized','Position',[.3 .3 .3 .1],'Menubar','None','Name','Filter','Numbertitle','Off','Resize','Off');
    uicontrol('Units','normalized','Style','Text','Position',[.1 .6 .2 .15],'String','Window width:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
    edit_lowercuttoff = uicontrol('Units','normalized','Style','edit','Position',[.3 .6 .1 .2],'String', 0);
    edit_uppercuttoff = uicontrol('Units','normalized','Style','edit','Position',[.5 .6 .1 .2],'String', round(leda2.data.samplingrate/2));
    filterTypeL = {'butterworth'};
    uicontrol('Units','normalized','Style','Text','Position',[.1 .2 .2 .25],'String','Type:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
    popm = uicontrol('Units','normalized','Style','popupmenu','Position',[.3 .2 .3 .3],'String',filterTypeL,'Value',1);
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

    limits = [str2double(get(edit_lowercuttoff,'String')), str2double(get(edit_uppercuttoff,'String'))];

    typeTxtL = {'butter'};
    typenr = get(popm,'Value');
    type = typeTxtL{typenr};

    close(fig);

end


if min(limits) <= 0
    ftype = 'low';
    flim = max(limits);
elseif max(limits) >= round(leda2.data.samplingrate/2) 
    ftype = 'high';
    flim = min(limits);
else
    ftype = 'bandpass';
    flim = limits;
end
[b, a] = butter(8, flim/(leda2.data.samplingrate/2), ftype);
sc = filter(b, a, leda2.data.conductance.data);
leda2.data.conductance.data = sc(:)';

delete_fit(0);
refresh_data(1);
file_changed(1);
add2log(1,['Data filtered with ',  typeTxtL{typenr},' (',num2str(limits(1)), ' - ', num2str(limits(2)),')'],1,1,1);
