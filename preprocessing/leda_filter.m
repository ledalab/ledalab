function leda_filter(settings)
global leda2

filterTypeL = {'Butterworth - Lowpass filter'};
typenr = 1;

if nargin == 1  %batchmode
    order = settings(1);
    lo_cutoff_freq = settings(2);
    
elseif nargin == 0
    
    fig = figure('Units','normalized','Position',[.3 .3 .3 .15],'Menubar','None','Name','Filter SC data','Numbertitle','Off','Resize','Off');
    uicontrol('Units','normalized','Style','Text','Position',[.03 .7 .2 .15],'String','Type:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
    popm = uicontrol('Units','normalized','Style','popupmenu','Position',[.4 .7 .4 .15],'String',filterTypeL,'Value',typenr);
    uicontrol('Units','normalized','Style','Text','Position',[.03 .45 .5 .15],'String','Order:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
    edit_order = uicontrol('Units','normalized','Style','edit','Position',[.4 .45 .1 .15],'String', 1);
    uicontrol('Units','normalized','Style','Text','Position',[.03 .2 .5 .15],'String','Lower cutoff frequency:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
    edit_lowercuttoff = uicontrol('Units','normalized','Style','edit','Position',[.4 .2 .1 .15],'String', 5);
    %edit_uppercuttoff = uicontrol('Units','normalized','Style','edit','Position',[.6 .6 .1 .2],'String', round(leda2.data.samplingrate/2));
    
    uicontrol('Style','pushbutton','Units','normalized','Position',[.7 .1 .15 .2],'String','OK','Callback','uiresume(gcbf)','FontUnits','normalized');
    
    uiwait(fig);
    if ~ishandle(fig)  %deleted to cancel
        return
    end
    if ~leda2.file.open
        close(fig)
        return;
    end
    if ~isempty(leda2.analysis)
        cmd = questdlg('The current fit will be deleted!','Warning','Continue','Cancel','Continue');
        if isempty(cmd) || strcmp(cmd, 'Cancel')
            return
        end
    end
    
    
    order = str2double(get(edit_order,'String'));
    lo_cutoff_freq = str2double(get(edit_lowercuttoff,'String'));
    %limits = [str2double(get(edit_lowercuttoff,'String')), str2double(get(edit_uppercuttoff,'String'))];
    %typeTxtL = {'butter'};
    typenr = get(popm,'Value');
    %type = typeTxtL{typenr};
    
    close(fig);
    
end

%%MB V3.4.6:
nyquist_freq = leda2.data.samplingrate/2;  % Nyquist frequency
Wn = lo_cutoff_freq/nyquist_freq;    % non-dimensional frequency
[filtb,filta] = butter(order,Wn,'low'); % construct the filter
filtered_signal = filtfilt(filtb,filta,leda2.data.conductance.data); % filter the data with zero phase

leda2.data.conductance.data = filtered_signal(:)';

delete_fit(0);
refresh_data(~leda2.intern.batchmode);
file_changed(1);
add2log(1,['Data filtered with ',  filterTypeL{typenr},' (order: ', num2str(order),', lower-cutoff: ',num2str(lo_cutoff_freq),')'],1,1,1);
