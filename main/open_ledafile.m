function open_ledafile(flag, pathname, filename)
global leda2

leda2.current.fileopen_ok = 0;

if nargin == 0
    [filename, pathname] = uigetfile(' *.mat','Choose a ledalab-file');
elseif nargin == 1
    filename = leda2.intern.prevfile(flag).filename;
    pathname = leda2.intern.prevfile(flag).pathname;
elseif nargin == 3 %File is handed over
end

if all(filename == 0) || all(pathname == 0) %Cancel
    return
end
file = fullfile(pathname, filename);


%Try to open file
try
    ledafile = load(file, '-mat');
    cd(pathname);
catch
    add2log(0,['Unable to open ',file],1,1,0,1,0,1);
    return;
end


%Try if file supplies valid data
ledafile_vars = fieldnames(ledafile); %isstruct?

if any(strcmp(ledafile_vars,'epocharray')) %V1.x
    add2log(0,['Unable to open ',file,': This is a ledafit-file. Please open corresponding ledadata-file instead..'],1,1,0,1,0,1);
    return;
end

if (~any(strcmp(ledafile_vars,'fileinfo'))) && (~any(strcmp(ledafile_vars,'ledalab'))) %JG 01.11.2012
    if leda2.intern.batchmode
            add2log(0,['Unable to open ',file,': This is not a native Ledalab-file. Please use batch mode parameter settings ''open'',''mat'' instead of ''open'',''leda''!'],1,1,0,1,0,1);        
    else
            add2log(0,['Unable to open ',file,': This is not a native Ledalab-file. Please use "Import Data"->"Matlab File" instead of "Open"!'],1,1,0,1,0,1);
    end
    return;
end
    

if any(strcmp(ledafile_vars,'data'))
    try
        cond_tmp = ledafile.data.conductance;
        time_tmp = ledafile.data.time;
        timeoff_tmp = ledafile.data.timeoff;        
        if isempty(cond_tmp) || isempty(time_tmp)
                add2log(0,['Unable to open ',pathname, filename,':  Requested data not available!'],1,1,0,1,0,1);
                return
        end            
    catch
        add2log(0,['Unable to open ',pathname, filename],1,1,0,1,0,1);
        return
    end
else
    add2log(0,['Unable to open ',file,': Could not load data.'],1,1,0,1,0,1);
    return;
end
%Valid ledadata available and ready to load!

close_ledafile; %includes reset
if leda2.file.open  %closing failed
    return;
end


%Load data
leda2.data.conductance.data = ledafile.data.conductance;
leda2.data.time.data = ledafile.data.time;
leda2.data.time.timeoff = ledafile.data.timeoff;
refresh_data(0); %stats
%[leda2.data.conductance.smoothData, leda2.data.conductance.smoothData_win] = smooth_adapt(leda2.data.conductance.data, 'gauss', .5 * leda2.data.samplingrate, .0003);  %also done in plot
%trough2peak_analysis;

leda2.file.filename = filename;
leda2.file.pathname = pathname;
leda2.intern.current_dir = leda2.file.pathname;
leda2.file.open = 1;
file_changed(0);

%Try to load optional data
%Events
leda2.data.events.event = [];
leda2.data.events.N = 0;
if any(strcmp(fieldnames(ledafile.data),'event'))
    leda2.data.events.event = ledafile.data.event;
    leda2.data.events.N = length(leda2.data.events.event);
elseif any(strcmp(ledafile_vars,'event')) %for backward compatiblity
    try
        leda2.data.events.event = ledafile.event;
        leda2.data.events.N = length(leda2.data.events.event);
    catch
        disp('Could not load Event-Info properly!');
    end
end

%Fileinfo
leda2.file.version = 0;
leda2.file.date = 0;
leda2.file.log = {};
if any(strcmp(ledafile_vars,'ledalab')) %version 1.x
    try
        leda2.file.version = ledafile.ledalab.version;
        leda2.file.date = ledafile.ledalab.date;        
    catch
        disp('Could not load File-Info properly!');
    end    
elseif any(strcmp(ledafile_vars,'fileinfo')) %version 2.x or higher
    try
        leda2.file.version = ledafile.fileinfo.version;
        leda2.file.date = ledafile.fileinfo.date;
        leda2.file.log = ledafile.fileinfo.log;
    catch
        disp('Could not load File-Info properly!');
    end
end
add2log(0,[datestr(now,31), ' Open ',file,' ',leda2.intern.versiontxt],1,1,1);

%Fit
% if leda2.file.version >= 2 && leda2.file.version < 2.15
%     leda2.analyze.fit = [];
%     if any(strcmp(ledafile_vars,'fit'))
%         try
%             leda2.analyze.fit = ledafile.fit;
%             %forward compatibility V2.00
%             if any(strcmp(fieldnames(leda2.analyze.fit.info),'error'))
%                 leda2.analyze.fit.info = rmfield(leda2.analyze.fit.info, 'error');
%             end
%             if any(strcmp(fieldnames(leda2.analyze.fit.info),'err'))
%                 leda2.analyze.fit.info = rmfield(leda2.analyze.fit.info, 'err');
%             end
%             if any(strcmp(fieldnames(leda2.analyze.fit.info),'rms'))
%                 leda2.analyze.fit.info = rmfield(leda2.analyze.fit.info, 'rms');
%             end
%             rebuilddata;
%         catch
%             add2log(0,'Could not load Fit-Info properly!',1,1,0,0,0,1)
%         end
%
%         if any(strcmp(ledafile_vars,'initvals'))  %V2.14+
%             try
%                 leda2.analyze.initialvalues = ledafile.initvals;
%             catch
%                 add2log(0,'Could not load Initial Values Info properly!',1,1,0,0,0,1)
%             end
%         end
%
%     end
% end

leda2.analysis = [];
if leda2.file.version >= 2.15
    if any(strcmp(ledafile_vars,'analysis'))
%        try
            leda2.analysis = ledafile.analysis;
            rebuilddata;
%        catch
%            add2log(0,'Could not load Analysis Info properly!',1,1,0,0,0,1)
%        end
    end
end

leda2.current.fileopen_ok = 1;

if leda2.intern.batchmode
    return;
end

plot_data;

update_prevfilelist(pathname, filename);
