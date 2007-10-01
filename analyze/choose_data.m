function choose_data
global leda2

leda2.gui.fit.fig_choose_data = figure('Units','normalized','Position',[.3 .2 .4 .6],'Name','Choose Data for Analysis','WindowButtonDownFcn','',...
    'MenuBar','none','NumberTitle','off','Color',leda2.intern.color.bkgd);

fit_txt_files = uicontrol('Style','text','Units','normalized','Position',[.1 .9 .8 .03],'String','Choose leda-file(s) ...','BackgroundColor',leda2.intern.color.bkgd,'HorizontalAlignment','left');
leda2.gui.fit.listb_files = uicontrol('Style','listbox','Units','normalized','Position',[.1 .3 .8 .6],'Max',2,'Min',0);
leda2.gui.fit.edit_events = uicontrol('Style','edit','Units','normalized','Position',[.1 .2 .8 .05],'String','','HorizontalAlignment','left');
fit_butt_go = uicontrol('Style','pushbutton','Units','normalized','Position',[.3 .05 .2 .1],'String','GO','Callback','analyze_events','Enable','on');
fit_butt_abort = uicontrol('Style','pushbutton','Units','normalized','Position',[.6 .05 .1 .1],'String','Abort','Callback','close(gcf)');

filedir = 0;
if leda2.file.open
    filedir = leda2.file.pathname;
else
    while ~filedir
        filedir = uigetdir(leda2.intern.current_dir);
    end
    filedir(find(filedir == '\')) = '/';
    filedir = [filedir,'/'];
end

cd(filedir);
leda2.intern.current_dir = filedir;

fileL = dir('*.mat');
filenameL = {fileL.name};
if leda2.file.open 
    idx = find(strcmp(filenameL, leda2.file.filename));
else 
    idx = 1;
end

set(leda2.gui.fit.listb_files,'String',filenameL,'Max',3,'Min',0,'Value',idx)
