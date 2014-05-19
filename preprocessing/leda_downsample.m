function leda_downsample(fac, type)  %MB 11.06.2013 (changed from downsample.m)
global leda2

Fs = round(leda2.data.samplingrate);
factorL = divisors(Fs);
FsL = Fs./ factorL;    %list of possible new sampling rates

if nargin == 0 %batchmode


    if isempty( FsL)
        mb = msgbox('Current sampling rate can not be further broken down');
        waitfor(mb);
        return;
    end

    for i = 1:length(FsL)
        FsL_txt{i} = sprintf('%d Hz   (Factor %d)', FsL(i), factorL(i)); %#ok<AGROW>
    end

    fig = figure('Units','normalized','Position',[.4 .3 .2 .4],'Menubar','None','Name','Downsampling','Numbertitle','Off','Resize','Off');
    uicontrol('Units','normalized','Style','Text','Position',[.1 .92 .8 .04],'String',['Downsample from ',num2str(Fs),'Hz to:'],'HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
    list_fs = uicontrol('Units','normalized','Style','listbox','Position',[.1 .3 .8 .6],'String', FsL_txt);
    downsTypeL = {'factor steps','factor mean','factor gauss'};
    uicontrol('Units','normalized','Style','Text','Position',[.1 .18 .3 .06],'String','Type:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
    popm = uicontrol('Units','normalized','Style','popupmenu','Position',[.3 .18 .4 .06],'String',downsTypeL,'Value',2);
    uicontrol('Style','pushbutton','Units','normalized','Position',[.65 .05 .25 .06],'String','OK','Callback','uiresume(gcbf)','FontUnits','normalized');

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

    sel_fac = get(list_fs,'Value');
    fac =  factorL(sel_fac);

    typeTxtL = {'step', 'mean','gauss'};
    type = typeTxtL{get(popm,'Value')};

    close(fig);

end


[td, scd] = downsamp(leda2.data.time.data, leda2.data.conductance.data, fac, type);
%downsampling (type factor mean) may result in an additional offset = time(1), which will not be substracted (tim = time - offset) in order not to affect event times
leda2.data.time.data = td(:)';
leda2.data.conductance.data = scd(:)';
refresh_data(0);
leda2.data.conductance.smoothData = smooth_adapt(leda2.data.conductance.data, 'gauss', leda2.data.samplingrate*.5, .0003);
trough2peak_analysis;

delete_fit(0);
add2log(1,['Data downsampled to ',  sprintf('%4.2f Hz   (Factor %d)', leda2.data.samplingrate, fac),'.'],1,1,1);
if leda2.intern.batchmode
    return;
end

plot_data;
file_changed(1);

