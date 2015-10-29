function export_era_dialog(~,~)
global leda2
    if ~leda2.file.open
        if leda2.intern.prompt
            msgbox('No open File!','Export Event-Related Activation','error')
        end
        return
    end
    
    height = 10;
    leda2.gui.export.fig_pl = figure('Units','characters','Position',[20 30 80 height],...
        'Name','Export Event-Related Activation','MenuBar','none','NumberTitle','off',...
        'DefaultUicontrolUnits','characters','DefaultUicontrolBackgroundColor',[1,1,1]);
    
    uicontrol('Style','text','Position',[2 height-2 40 1],'BackgroundColor',[.8 .8 .8],'String','SCR window relative to event (start - end) [sec]:','HorizontalAlignment','left');
    leda2.gui.export.edit_scrWindowStart = uicontrol('Style','edit','Position',[45 height-2 8 1],'String',num2str(leda2.set.export.SCRstart,'%1.2f'));
    leda2.gui.export.edit_scrWindowEnd   = uicontrol('Style','edit','Position',[55 height-2 8 1],'String',num2str(leda2.set.export.SCRend,'%1.2f'));

    uicontrol('Style','text','Position',[2 height-4 40 1],'BackgroundColor',[.8 .8 .8],'String','SCR amplitude minimum [muS]:','HorizontalAlignment','left');
    leda2.gui.export.edit_scrAmplitudeMin = uicontrol('Style','edit','Position',[45 height-4 8 1],'String',num2str(leda2.set.export.SCRmin,'%1.2f'));

    uicontrol('Style','text','Position',[2 height-6 40 1], 'BackgroundColor',[.8 .8 .8], 'String','z-scale values');
    leda2.gui.export.edit_zscale = uicontrol('Style','checkbox', 'Position', [45 height-6 2 1], 'Value', leda2.set.export.zscale);
 
    leda2.gui.export.butt_savePeaks = uicontrol('Position',[2 height-8 20 1],'String','Export','Callback',@exportBtnCallback);
    leda2.gui.export.popm_type = uicontrol('Style','popupmenu','Position',[45 height-8 20 1],'String',{'Matlab-File';'Text-File'; 'Excel-File'},'Value',leda2.set.export.savetype);
end

function exportBtnCallback(~,~)
    global leda2
    leda2.set.export.SCRstart = str2double(get(leda2.gui.export.edit_scrWindowStart,'String'));
    leda2.set.export.SCRend = str2double(get(leda2.gui.export.edit_scrWindowEnd,'String'));
    leda2.set.export.SCRmin = str2double(get(leda2.gui.export.edit_scrAmplitudeMin,'String'));
    leda2.set.export.zscale = get(leda2.gui.export.edit_zscale,'Value');
    leda2.set.export.savetype = get(leda2.gui.export.popm_type,'Value');
    export_era;
    close(leda2.gui.export.fig_pl);
end
