function export_scrlist_dialog(~,~)
    global leda2
    
    if ~leda2.file.open
        if leda2.intern.prompt
            msgbox('No open File!','Export SCR-List','error')
        end
        return
    end
    height = 8;
    leda2.gui.export.fig_pl = figure('Units','characters','Position',[20 30 80 height],...
        'Name','Export SCR-List','MenuBar','none','NumberTitle','off',...
        'DefaultUicontrolUnits','characters','DefaultUicontrolBackgroundColor',[1,1,1]);

    uicontrol('Style','text','Position',[2 height-2 40 1],'BackgroundColor',[.8 .8 .8],...
        'String','SCR amplitude minimum [muS]:','HorizontalAlignment','left');
    leda2.gui.export.edit_scrAmplitudeMin = uicontrol('Style','edit',...
        'Position',[45 height-2 10 1],'BackgroundColor',[1 1 1],'String',num2str(leda2.set.export.SCRmin,'%1.2f'));

    uicontrol('Style','text','Position',[2 height-4 40 1], 'BackgroundColor',[.8 .8 .8], 'String','z-scale values');
    leda2.gui.export.edit_zscale = uicontrol('Style','checkbox', 'Position', [45 height-4 2 1], 'Value', leda2.set.export.zscale);
    
    uicontrol('Position',[2 height-7 40 2],'String','Export','Callback',@exportBtnCallback);
    leda2.gui.export.popm_type = uicontrol('Style','popupmenu','Position',[45 height-7 20 2],...
        'String',{'Matlab-File';'Text-File'; 'Excel-File'},'Value',leda2.set.export.savetype);
end

function exportBtnCallback(~,~)
    global leda2
    leda2.set.export.SCRmin = str2double(get(leda2.gui.export.edit_scrAmplitudeMin,'String'));
    leda2.set.export.savetype = get(leda2.gui.export.popm_type,'Value');
    leda2.set.export.zscale = get(leda2.gui.export.edit_zscale,'Value');
    export_scrlist;
    close(leda2.gui.export.fig_pl);
end
