function ledagui
global leda2

%Menu
%-File
leda2.gui.fig_main = figure('Units','normalized','Position',[.00 .03 1 .92],'Name',[leda2.intern.name,' V',num2str(leda2.intern.version,'%1.2f')],'KeyPressFcn','leda_keypress',...
    'MenuBar','none','NumberTitle','off','Color',leda2.gui.col.fig,'CloseRequestFcn','exit_leda');
maximize(leda2.gui.fig_main);
leda2.gui.menu.menu_1  = uimenu(leda2.gui.fig_main,'Label','File');  
leda2.gui.menu.menu_1a = uimenu(leda2.gui.menu.menu_1,'Label','Open','Callback','open_ledafile;','Accelerator','o');   %
leda2.gui.menu.menu_1b = uimenu(leda2.gui.menu.menu_1,'Label','Import Data...'); %,'Accelerator','i'
leda2.gui.menu.menu_1b1 = uimenu(leda2.gui.menu.menu_1b,'Label','Matlab File','Callback','import_data(''mat'')');
leda2.gui.menu.menu_1b2 = uimenu(leda2.gui.menu.menu_1b,'Label','Text File','Callback','import_data(''text'')');
leda2.gui.menu.menu_1b3 = uimenu(leda2.gui.menu.menu_1b,'Label','Cassy Lab','Callback','import_data(''cassylab'')');
leda2.gui.menu.menu_1b4 = uimenu(leda2.gui.menu.menu_1b,'Label','BioTrace (Text Export)','Callback','import_data(''biotrace'')');
leda2.gui.menu.menu_1b5 = uimenu(leda2.gui.menu.menu_1b,'Label','Vision Analyzer (Matlab Export)','Callback','import_data(''visionanalyzer'')');
leda2.gui.menu.menu_1b6 = uimenu(leda2.gui.menu.menu_1b,'Label','User-defined Data','Callback','import_data(''userdef'')','Enable','off');

leda2.gui.menu.menu_1c = uimenu(leda2.gui.menu.menu_1,'Label','Import Event-Info...'); %,'Accelerator','i'
leda2.gui.menu.menu_1c1 = uimenu(leda2.gui.menu.menu_1c,'Label','User-defined Event-Info','Callback','import_eventinfo(''userdef'')');
leda2.gui.menu.menu_1d = uimenu(leda2.gui.menu.menu_1,'Label','Save','Callback','save_ledafile','Accelerator','s','Separator','on');
leda2.gui.menu.menu_1e = uimenu(leda2.gui.menu.menu_1,'Label','Save as...','Callback','save_ledafile(1)');
leda2.gui.menu.menu_1f = uimenu(leda2.gui.menu.menu_1,'Label','Exit','Callback','exit_leda','Accelerator','x','Separator','on');

%--Oldfile-list
if ~isempty(leda2.intern.prevfile)
    for i = 1:length(leda2.intern.prevfile)
        if i == 1
            leda2.gui.menu.menu_of(i) = uimenu(leda2.gui.menu.menu_1,'Label',leda2.intern.prevfile(i).filename,'Callback','open_ledafile(1)','Separator','on');
        else
            leda2.gui.menu.menu_of(i) = uimenu(leda2.gui.menu.menu_1,'Label',leda2.intern.prevfile(i).filename,'Callback',['open_ledafile(',num2str(i),')']);
        end
    end
end

%-Preprocessing
leda2.gui.menu.menu_2  = uimenu(leda2.gui.fig_main,'Label','Preprocessing');
leda2.gui.menu.menu_2a  = uimenu(leda2.gui.menu.menu_2,'Label','Cut data (keep selection)','Callback','cut_ledafile'); %,'Enable','off'
leda2.gui.menu.menu_2b  = uimenu(leda2.gui.menu.menu_2,'Label','Downsampling','Callback','downsample');
leda2.gui.menu.menu_2c  = uimenu(leda2.gui.menu.menu_2,'Label','Artifact correction','Callback','artifact_interp','Accelerator','a');

%-Settings
leda2.gui.menu.menu_3  = uimenu(leda2.gui.fig_main,'Label','Settings');
leda2.gui.menu.menu_3a  = uimenu(leda2.gui.menu.menu_3,'Label','Analysis settings','Callback','ledaset');
leda2.gui.menu.menu_3b  = uimenu(leda2.gui.menu.menu_3,'Label','Visual settings','Callback','ledapref');
leda2.gui.menu.menu_3c  = uimenu(leda2.gui.menu.menu_3,'Label','Resore default settings','Callback','restore_settings','Separator','on');

%-Analyze
leda2.gui.menu.menu_4  = uimenu(leda2.gui.fig_main,'Label','Analyze');
leda2.gui.menu.menu_4a = uimenu(leda2.gui.menu.menu_4,'Label','Fit data','Callback','optimize');
leda2.gui.menu.menu_4b = uimenu(leda2.gui.menu.menu_4,'Label','Initial Solution','Separator','on','Callback','initial_solution'); 
leda2.gui.menu.menu_4c = uimenu(leda2.gui.menu.menu_4,'Label','Optimize all','Callback','optimize'); 
leda2.gui.menu.menu_4d = uimenu(leda2.gui.menu.menu_4,'Label','Optimize selection','Callback','optimize(-1)'); 
leda2.gui.menu.menu_4e = uimenu(leda2.gui.menu.menu_4,'Label','Edit fit','Callback','manual_edit','Separator','on'); 
leda2.gui.menu.menu_4f = uimenu(leda2.gui.menu.menu_4,'Label','Delete fit','Callback','delete_fit(1)'); 

%-Tools
leda2.gui.menu.menu_5  = uimenu(leda2.gui.fig_main,'Label','Tools'); 
leda2.gui.menu.menu_5a = uimenu(leda2.gui.menu.menu_5,'Label','FFT','Callback','leda_fft'); 

%-Results
leda2.gui.menu.menu_6  = uimenu(leda2.gui.fig_main,'Label','Results');
leda2.gui.menu.menu_6a = uimenu(leda2.gui.menu.menu_6,'Label','Export SCR-List','Callback','export_scrlist'); 
leda2.gui.menu.menu_6b = uimenu(leda2.gui.menu.menu_6,'Label','Export Event-Related Activation','Callback','export_era','Accelerator','e'); 

%-Info
leda2.gui.menu.menu_7 =  uimenu(leda2.gui.fig_main,'Label','Info');  
leda2.gui.menu.menu_7a = uimenu(leda2.gui.menu.menu_7,'Label','Ledalab Website','Callback','web(''www.ledalab.de'',''-browser'')');   
leda2.gui.menu.menu_7b = uimenu(leda2.gui.menu.menu_7,'Label','Documentation','Callback','web(''www.ledalab.de/download/Ledalab_Documentation.pdf'',''-browser'')');
leda2.gui.menu.menu_7c = uimenu(leda2.gui.menu.menu_7,'Label','Check for updates','Callback','version_check');
leda2.gui.menu.menu_7d = uimenu(leda2.gui.menu.menu_7,'Label','About Ledalab','Callback','ledalogo','Separator','on');

%Overview (= Data Display)
dy = .79;
leda2.gui.overview.ax = axes('Units','normalized','Position',[.05 dy .87 .18],'ButtonDownFcn','leda_click(1)');
set(leda2.gui.overview.ax,'XLim',[0,60],'YLim',[0,20],'Color',[.9 .9 .9]);
set(get(leda2.gui.overview.ax,'YLabel'),'String','SC [\muS]')
set(get(leda2.gui.overview.ax,'XLabel'),'String','Time [sec]')

leda2.gui.overview.edit_max = uicontrol('Units','normalized','Style','edit','Position',[.94 dy+.155 .04 .025],'String','20','Callback','edits_cb(4)');
leda2.gui.overview.edit_min = uicontrol('Units','normalized','Style','edit','Position',[.94 dy .04 .025],'String','0','Callback','edits_cb(4)');
leda2.gui.overview.text_max = uicontrol('Units','normalized','Style','text','Position',[.94 dy+.095 .04 .025],'String','-','HorizontalAlignment','center','BackgroundColor',leda2.gui.col.fig);
leda2.gui.overview.text_min = uicontrol('Units','normalized','Style','text','Position',[.94 dy+.065 .04 .025],'String','-','HorizontalAlignment','center','BackgroundColor',leda2.gui.col.fig);


%Overview-Info (= Data Info Display)
dy = .71; dy1 = dy+.01;
leda2.gui.frame = uicontrol('Units','normalized','Style','frame','Position',[.02 dy .96 .04],'String','Frame Ov','BackgroundColor',leda2.gui.col.frame1);
leda2.gui.text_title = uicontrol('Units','normalized','Style','text','Position',[.025 dy1+.01 .08 .015],'String','DATA ','HorizontalAlignment','left','BackgroundColor',leda2.gui.col.frame1,'FontWeight','bold');
leda2.gui.text_N = uicontrol('Units','normalized','Style','text','Position',[.08 dy1 .08 .015],'String','N: ','HorizontalAlignment','left','BackgroundColor',leda2.gui.col.frame1);
leda2.gui.text_time = uicontrol('Units','normalized','Style','text','Position',[.16 dy1 .08 .015],'String','Time: ','HorizontalAlignment','left','BackgroundColor',leda2.gui.col.frame1);
leda2.gui.text_smplrate = uicontrol('Units','normalized','Style','text','Position',[.24 dy1 .08 .015],'String','Freq: ','HorizontalAlignment','left','BackgroundColor',leda2.gui.col.frame1);
leda2.gui.text_conderr = uicontrol('Units','normalized','Style','text','Position',[.32 dy1 .08 .015],'String','Error: ','HorizontalAlignment','left','BackgroundColor',leda2.gui.col.frame1);
leda2.gui.text_Nevents = uicontrol('Units','normalized','Style','text','Position',[.40 dy1 .08 .015],'String','Events: ','HorizontalAlignment','left','BackgroundColor',leda2.gui.col.frame1);
leda2.gui.text_title2 = uicontrol('Units','normalized','Style','text','Position',[.53 dy1+.01 .08 .015],'String','FIT ','HorizontalAlignment','left','BackgroundColor',leda2.gui.col.frame1,'FontWeight','bold');
leda2.gui.text_adjR2 = uicontrol('Units','normalized','Style','text','Position',[.58 dy1 .08 .015],'String','Adj. R2: ','HorizontalAlignment','left','BackgroundColor',leda2.gui.col.frame1);
leda2.gui.text_rmse = uicontrol('Units','normalized','Style','text','Position',[.66 dy1 .08 .015],'String','RMSE: ','HorizontalAlignment','left','BackgroundColor',leda2.gui.col.frame1);
leda2.gui.text_nPhasic = uicontrol('Units','normalized','Style','text','Position',[.74 dy1 .08 .015],'String','SCRs: ','HorizontalAlignment','left','BackgroundColor',leda2.gui.col.frame1);
leda2.gui.text_nTonic = uicontrol('Units','normalized','Style','text','Position',[.82 dy1 .08 .015],'String','TPs: ','HorizontalAlignment','left','BackgroundColor',leda2.gui.col.frame1);
leda2.gui.text_df = uicontrol('Units','normalized','Style','text','Position',[.90 dy1 .06 .015],'String','DF: ','HorizontalAlignment','left','BackgroundColor',leda2.gui.col.frame1);
%leda2.gui.ax_epochchart = axes('Units','normalized','Position',[.82 dy .16 .06],'Color',leda2.gui.col.frame1,'XAxisLocation','bottom','YAxisLocation','right');  %,'XTickLabel',[],'YTickLabel',[],'YScale','log','YLim',[0,100],'XLim',[0,100]


%Rangeview (= Epoch Display)
y2 = .67;
y3 = .27;
y5 = .22;
y6 = .19;
leda2.gui.rangeview.ax = axes('Units','normalized','Position',[.05 y3 .6 y2-y3],'XLim',[leda2.gui.rangeview.start, leda2.gui.rangeview.start + leda2.gui.rangeview.range],'YLim',[0,20],'Color',[1 1 1],'DrawMode','fast','ButtonDownFcn','leda_click(2)');
set(get(leda2.gui.rangeview.ax,'YLabel'),'String','Skin Conductance [\muS]')
set(get(leda2.gui.rangeview.ax,'XLabel'),'String','Time [sec]')

leda2.gui.rangeview.edit_start = uicontrol('Units','normalized','Style','edit','Position',[.05 y5 .05 .025],'String',leda2.gui.rangeview.start,'HorizontalAlignment','left','Callback','edits_cb(1)');
leda2.gui.rangeview.edit_range = uicontrol('Units','normalized','Style','edit','Position',[.2 y5 .05 .025],'String',leda2.gui.rangeview.range,'HorizontalAlignment','left','Callback','edits_cb(1)');
leda2.gui.rangeview.edit_end = uicontrol('Units','normalized','Style','edit','Position',[.6 y5 .05 .025],'String',leda2.gui.rangeview.start + leda2.gui.rangeview.range,'HorizontalAlignment','left','Callback','edits_cb(2)');
leda2.gui.rangeview.slider = uicontrol('Style','Slider','Units','normalized','Position',[.05 y6 .6 .02],'Min',0,'Max',1,'SliderStep',[.01 .1],'Callback','edits_cb(3)');

%Epoch Info Display
dx1 = .7;  dx3 = dx1+.02;
leda2.gui.epochinfo.frame = uicontrol('Units','normalized','Style','frame','Position',[dx1 y6 .28 y2-y6],'String','Frame 2','BackgroundColor',leda2.gui.col.frame1);
leda2.gui.epochinfo.text_title = uicontrol('Units','normalized','Style','text','Position',[dx1+.005 y2-.025 .2 .02],'String','Epoch Fit','HorizontalAlignment','left','FontSize',8,'BackgroundColor',leda2.gui.col.frame1,'FontWeight','bold');
leda2.gui.epochinfo.text_SCR = uicontrol('Units','normalized','Style','text','Position',[dx3 y5+.405 .24 .02],'String','SCRs','HorizontalAlignment','center','FontSize',8,'BackgroundColor',leda2.gui.col.frame1,'FontWeight','bold');
leda2.gui.epochinfo.text_TP = uicontrol('Units','normalized','Style','text','Position',[dx3 y5+.195 .24 .02],'String','TPs','HorizontalAlignment','center','FontSize',8,'BackgroundColor',leda2.gui.col.frame1,'FontWeight','bold');
leda2.gui.epochinfo.butt_medit = uicontrol('Units','normalized','Style','pushbutton','Position',[dx1+.22 y6+.015 .04 .02],'String','Edit Fit','Callback','manual_edit');
%ManualEdit
h1 = .02; l1 = .04; dl1 = .005;
leda2.gui.manualedit.text_ons =  uicontrol('Units','normalized','Style','Text','Position',[dx3+(l1+dl1)*0 y5+.25 l1 h1],'String','onset','FontSize',9,'BackgroundColor',leda2.gui.col.frame1);
leda2.gui.manualedit.text_amp =  uicontrol('Units','normalized','Style','Text','Position',[dx3+(l1+dl1)*1 y5+.25 l1 h1],'String','amp','FontSize',9,'BackgroundColor',leda2.gui.col.frame1);
leda2.gui.manualedit.text_tau1 = uicontrol('Units','normalized','Style','Text','Position',[dx3+(l1+dl1)*2 y5+.25 l1 h1],'String','tau1','FontSize',9,'BackgroundColor',leda2.gui.col.frame1);
leda2.gui.manualedit.text_tau2 = uicontrol('Units','normalized','Style','Text','Position',[dx3+(l1+dl1)*3 y5+.25 l1 h1],'String','tau2','FontSize',9,'BackgroundColor',leda2.gui.col.frame1);
leda2.gui.manualedit.edit_ons =  uicontrol('Units','normalized','Style','Edit','Position',[dx3+(l1+dl1)*0 y5+.23 l1 h1],'FontSize',8);
leda2.gui.manualedit.edit_amp =  uicontrol('Units','normalized','Style','Edit','Position',[dx3+(l1+dl1)*1 y5+.23 l1 h1],'FontSize',8);
leda2.gui.manualedit.edit_tau1 = uicontrol('Units','normalized','Style','Edit','Position',[dx3+(l1+dl1)*2 y5+.23 l1 h1],'FontSize',8);
leda2.gui.manualedit.edit_tau2 = uicontrol('Units','normalized','Style','Edit','Position',[dx3+(l1+dl1)*3 y5+.23 l1 h1],'FontSize',8);
l2 = .05; h2 = .018;
leda2.gui.manualedit.butt_change = uicontrol('Units','normalized','Style','pushbutton','Position',[.91 y5+.26 l2 h2],'String','Change SCR','FontWeight','bold','Callback','manual_edit(''change_scr'')');
leda2.gui.manualedit.butt_new    = uicontrol('Units','normalized','Style','pushbutton','Position',[.91 y5+.24 l2 h2],'String','Add SCR','Callback','manual_edit(''add_scr'')');
leda2.gui.manualedit.butt_del    = uicontrol('Units','normalized','Style','pushbutton','Position',[.91 y5+.22 l2 h2],'String','Delete SCR','Callback','manual_edit(''delete_scr'')');
leda2.gui.epochinfo.list_scr = uicontrol('Units','normalized','Style','listbox','Position',[dx3 y5+.22 .24 .19],'Max',1','Min',0,'String','No Fit available','Callback','manual_edit(''select_scr'')','FontSize',9,'Visible','on');

leda2.gui.manualedit.text_t = uicontrol('Units','normalized','Style','Text','Position',[dx3+(l1+dl1)*0 y5+.05 l1 h1],'String','time','FontSize',9,'BackgroundColor',[.85 .85 .85]);
leda2.gui.manualedit.text_g = uicontrol('Units','normalized','Style','Text','Position',[dx3+(l1+dl1)*1 y5+.05 l1 h1],'String','level','FontSize',9,'BackgroundColor',[.85 .85 .85]);
leda2.gui.manualedit.edit_t = uicontrol('Units','normalized','Style','Edit','Position',[dx3+(l1+dl1)*0 y5+.03 l1 h1],'FontSize',8);
leda2.gui.manualedit.edit_g = uicontrol('Units','normalized','Style','Edit','Position',[dx3+(l1+dl1)*1 y5+.03 l1 h1],'FontSize',8);
leda2.gui.manualedit.butt_tpchange = uicontrol('Units','normalized','Style','pushbutton','Position',[.91 y5+.06 l2 h2],'String','Change TP','FontWeight','bold','Callback','manual_edit(''change_tp'')');
leda2.gui.manualedit.butt_tpnew    = uicontrol('Units','normalized','Style','pushbutton','Position',[.91 y5+.04 l2 h2],'String','Add TP','Callback','manual_edit(''add_tp'')');
leda2.gui.manualedit.butt_tpdel    = uicontrol('Units','normalized','Style','pushbutton','Position',[.91 y5+.02 l2 h2],'String','Delete t-p','Callback','manual_edit(''delete_tp'')');
leda2.gui.epochinfo.list_tonic = uicontrol('Units','normalized','Style','listbox','Position',[dx3 y5+.02 .24 .18],'Max',1','Min',0,'String','No Fit available','Callback','manual_edit(''select_tp'')','FontSize',9);

%Optimization Progress Display
y6 = .17;
y7 = .02;
dx1 = .7; dx2 = dx1+.03; dx3 = dx2+.06; dx4 = dx3+.06;
dy = .02;
leda2.gui.progressinfo.frame = uicontrol('Units','normalized','Style','frame','Position',[dx1 y7 .28 y6-y7],'String','Frame 2','BackgroundColor',leda2.gui.col.frame1);
leda2.gui.progressinfo.text_title = uicontrol('Units','normalized','Style','text','Position',[dx1+.005 y6-.025 .2 .02],'String','Optimization Progress','HorizontalAlignment','left','FontSize',8,'BackgroundColor',leda2.gui.col.frame1,'FontWeight','bold');
leda2.gui.progressinfo.text_iteration = uicontrol('Units','normalized','Style','text','Position',[dx3 y6-dy*3 .05 .02],'String','# Iteration','HorizontalAlignment','center','FontSize',8,'BackgroundColor',leda2.gui.col.frame1);
leda2.gui.progressinfo.text_error = uicontrol('Units','normalized','Style','text','Position',[dx4 y6-dy*3 .07 .02],'String',[leda2.set.errorType,' (initial)'],'HorizontalAlignment','center','FontSize',8,'BackgroundColor',leda2.gui.col.frame1);
leda2.gui.progressinfo.text_fit = uicontrol('Units','normalized','Style','text','Position',[dx2 y6-dy*4 .05 .02],'String','Fit','HorizontalAlignment','left','FontSize',8,'BackgroundColor',leda2.gui.col.frame1);
leda2.gui.progressinfo.text_fitIteration = uicontrol('Units','normalized','Style','text','Position',[dx3 y6-dy*4 .05 .02],'String','-','HorizontalAlignment','center','FontSize',8,'BackgroundColor',leda2.gui.col.frame1);
leda2.gui.progressinfo.text_fitError = uicontrol('Units','normalized','Style','text','Position',[dx4 y6-dy*4 .07 .02],'String','-','HorizontalAlignment','center','FontSize',8,'BackgroundColor',leda2.gui.col.frame1);
leda2.gui.progressinfo.text_epochNr = uicontrol('Units','normalized','Style','text','Position',[dx2 y6-dy*5-.01 .06 .02],'String','Epoch','HorizontalAlignment','left','FontSize',8,'BackgroundColor',leda2.gui.col.frame1);
leda2.gui.progressinfo.text_epochIteration = uicontrol('Units','normalized','Style','text','Position',[dx3 y6-dy*5-.01 .05 .02],'String','-','HorizontalAlignment','center','FontSize',8,'BackgroundColor',leda2.gui.col.frame1);
leda2.gui.progressinfo.text_epochError = uicontrol('Units','normalized','Style','text','Position',[dx4 y6-dy*5-.01 .07 .02],'String','-','HorizontalAlignment','center','FontSize',8,'BackgroundColor',leda2.gui.col.frame1);
leda2.gui.progressinfo.text_parsetNr = uicontrol('Units','normalized','Style','text','Position',[dx2 y6-dy*6-.01 .06 .02],'String', 'Parset','HorizontalAlignment','left','FontSize',8,'BackgroundColor',leda2.gui.col.frame1);
leda2.gui.progressinfo.text_parsetIteration = uicontrol('Units','normalized','Style','text','Position',[dx3 y6-dy*6-.01 .05 .02],'String','-','HorizontalAlignment','center','FontSize',8,'BackgroundColor',leda2.gui.col.frame1);
leda2.gui.progressinfo.text_parsetError = uicontrol('Units','normalized','Style','text','Position',[dx4 y6-dy*6-.01 .07 .02],'String','-','HorizontalAlignment','center','FontSize',8,'BackgroundColor',leda2.gui.col.frame1);

%Event Info Display
dx1 = .02; dx2 = dx1+ .03; dx3 = dx2 + .08; dy = .02;
leda2.gui.eventinfo.frame = uicontrol('Units','normalized','Style','frame','Position',[dx1 dy .28 .15],'String','Frame 2','BackgroundColor',leda2.gui.col.frame1);
leda2.gui.eventinfo.text_title = uicontrol('Units','normalized','Style','text','Position',[dx1+.005 dy+.125 .2 .02],'String','Events','HorizontalAlignment','left','FontSize',8,'BackgroundColor',leda2.gui.col.frame1,'FontWeight','bold');
leda2.gui.eventinfo.txtlab_eventnr  = uicontrol('Units','normalized','Style','text','Position',[dx2 dy+.09 .1 .02],'String','Eventnr:','BackgroundColor',leda2.gui.col.frame1,'HorizontalAlignment','left');
leda2.gui.eventinfo.butt_lastevent  = uicontrol('Units','normalized','Style','pushbutton','Position',[dx1+.1 dy+.095 .03 .025],'String','<','BackgroundColor',[.7 .7 .8],'HorizontalAlignment','center','Callback','edits_cb(6)');
leda2.gui.eventinfo.butt_nextevent  = uicontrol('Units','normalized','Style','pushbutton','Position',[dx1+.19 dy+.095 .03 .025],'String','>','BackgroundColor',[.7 .7 .8],'HorizontalAlignment','center','Callback','edits_cb(7)');
leda2.gui.eventinfo.txtlab_name  = uicontrol('Units','normalized','Style','text','Position',[dx2 dy+.06 .1 .02],'String','Name:','BackgroundColor',leda2.gui.col.frame1,'HorizontalAlignment','left');
leda2.gui.eventinfo.txtlab_time  = uicontrol('Units','normalized','Style','text','Position',[dx2 dy+.04 .1 .02],'String','Time:','BackgroundColor',leda2.gui.col.frame1,'HorizontalAlignment','left');
leda2.gui.eventinfo.txtlab_niduserdata  = uicontrol('Units','normalized','Style','text','Position',[dx2 dy+.02 .1 .02],'String','Nid & Userdata:','BackgroundColor',leda2.gui.col.frame1,'HorizontalAlignment','left');

leda2.gui.eventinfo.edit_eventnr  = uicontrol('Units','normalized','Style','edit','Position',[dx1+.13 dy+.095 .06 .025],'String','','HorizontalAlignment','center','Callback','edits_cb(5)'); %,'BackgroundColor',leda2.gui.col.frame1
leda2.gui.eventinfo.txt_name  = uicontrol('Units','normalized','Style','text','Position',[dx3 dy+.06 .1 .02],'String','','BackgroundColor',leda2.gui.col.frame1,'HorizontalAlignment','left');
leda2.gui.eventinfo.txt_time  = uicontrol('Units','normalized','Style','text','Position',[dx3 dy+.04 .1 .02],'String','','BackgroundColor',leda2.gui.col.frame1,'HorizontalAlignment','left');
leda2.gui.eventinfo.txt_niduserdata  = uicontrol('Units','normalized','Style','text','Position',[dx3 dy+.02 .1 .02],'String','','BackgroundColor',leda2.gui.col.frame1,'HorizontalAlignment','left');

%Session History Display
leda2.gui.infobox = uicontrol('Units','normalized','Style','listbox','Position',[.35 .02 .3 .15],'Max',2,'String','','HorizontalAlignment','left','FontSize',7);
