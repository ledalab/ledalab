function export_era(action)
% Saving results into Matlab/textfile/or Excel (*_results.mat/txt/xls)
%
%  - Choose SCR-Window times relative to event
%  - Choose minimum deflection for SCR


if nargin < 1,
    action = 'start';
end

switch action,
    case 'start', start;
    case 'take_settings',take_settings;
    case 'savePeaks', savePeaks;
end

function start
global leda2

dy = .13;


if ~leda2.file.open
    if leda2.intern.prompt
        msgbox('No open File!','Export Fit','error')
    end
    return
end
if leda2.data.events.N < 1
    if leda2.intern.prompt
        msgbox('File has no Events!','Export Fit','error')
    end
    return
end


leda2.gui.export.fig_pl = figure('Units','normalized','Position',[.2 .5 .6 .2],'Name','Export Fit','MenuBar','none','NumberTitle','off');

leda2.gui.export.text_scrWindowLimits = uicontrol('Style','text','Units','normalized','Position',[.1 .75 .35 dy],'BackgroundColor',[.8 .8 .8],'String','SCR window relative to event (start - end) [sec]:','HorizontalAlignment','left');
leda2.gui.export.edit_scrWindowStart = uicontrol('Style','edit','Units','normalized','Position',[.5 .75 .1 dy],'BackgroundColor',[1 1 1],'String',num2str(leda2.set.export.SCRstart,'%1.2f'));
leda2.gui.export.edit_scrWindowEnd   = uicontrol('Style','edit','Units','normalized','Position',[.65 .75 .1 dy],'BackgroundColor',[1 1 1],'String',num2str(leda2.set.export.SCRend,'%1.2f'));

leda2.gui.export.text_scrAmplitudeMin = uicontrol('Style','text','Units','normalized','Position',[.1 .5 .35 .08],'BackgroundColor',[.8 .8 .8],'String','SCR amplitude minimum [muS]:','HorizontalAlignment','left');
leda2.gui.export.edit_scrAmplitudeMin = uicontrol('Style','edit','Units','normalized','Position',[.5 .5 .1 dy],'BackgroundColor',[1 1 1],'String',num2str(leda2.set.export.SCRmin,'%1.2f'));

leda2.gui.export.butt_savePeaks = uicontrol('Units','normalized','Position',[.1 .2 .3 dy],'String','Export','Callback','export_era(''take_settings'')');
leda2.gui.export.popm_type = uicontrol('Style','popupmenu','Units','normalized','Position',[.5 .2 .3 dy],'String',{'Matlab-File';'Text-File'; 'Excel-File'},'Value',leda2.set.export.savetype);



function take_settings
global leda2

leda2.set.export.SCRstart = str2double(get(leda2.gui.export.edit_scrWindowStart,'String'));
leda2.set.export.SCRend = str2double(get(leda2.gui.export.edit_scrWindowEnd,'String'));
leda2.set.export.SCRmin = str2double(get(leda2.gui.export.edit_scrAmplitudeMin,'String'));
leda2.set.export.savetype = get(leda2.gui.export.popm_type,'Value');

savePeaks;

close(leda2.gui.export.fig_pl)



function savePeaks
global leda2

scrWindow_t1 = leda2.set.export.SCRstart;
scrWindow_t2 = leda2.set.export.SCRend;
scrAmplitudeMin = leda2.set.export.SCRmin;
sr = leda2.data.samplingrate;

onset_ttp = leda2.trough2peakAnalysis.onset;
amp_ttp = leda2.trough2peakAnalysis.amp;
if ~isempty(leda2.analysis)
    if strcmp(leda2.analysis.method,'nndeco')
        onset_nndeco = leda2.analysis.impulsePeakTime;
        amp_nndeco = leda2.analysis.amp;
    end
end


for iEvent = 1:leda2.data.events.N
    
    %Set event data
    event = leda2.data.events.event(iEvent);
    era.event.time(iEvent) = event.time;
    era.event.nid(iEvent) = event.nid;
    era.event.name{iEvent} = event.name;
    era.event.ud{iEvent} = event.userdata;
    
    [t_respwin, cs_respwin, idx_respwin] = subrange(event.time + scrWindow_t1, event.time + scrWindow_t2);  %data of response window
    
    %Reset all measures
    %Measures yielded by Discrete Decomposition Analysis (DDA)
    era.DDA.scr_nr(iEvent) = NaN;
    era.DDA.scr_ampsum(iEvent) = NaN;
    era.DDA.scr_areasum(iEvent) = NaN;
    era.DDA.scr_latency(iEvent) = NaN;
    era.DDA.tonic(iEvent) = NaN;  %average tonic level
    %Measures yielded by Continuous Decomposition Analysis (CDA)
    era.CDA.SCR(iEvent) = NaN;  %phasic driver area (time integral over response window)
    era.CDA.ISCR(iEvent) = NaN;  %average phasic driver activity (time integral over response window by size of responsewindow)
    era.CDA.phasic_max(iEvent) = NaN;   %Driver maximum within response window
    era.CDA.SCR_ITTP(iEvent) = NaN;   %SCR amp resulting from phasic segment re-convoluted with driver impulse
    era.CDA.tonic(iEvent) = NaN;   %average tonic level
    %Measures yielded by Trough-To-Peak Analysis
    era.TTP.scr_nr(iEvent) = NaN;
    era.TTP.scr_ampsum(iEvent) = NaN;
    era.TTP.scr_latency(iEvent) = NaN;
    %Measures based on raw SC data
    era.global.mean(iEvent) = NaN;
    era.global.max_deflection(iEvent) = NaN;
    
    
    %Set Measures
    %TTP
    scr_idx = find(onset_ttp >= (event.time + scrWindow_t1) & onset_ttp <= (event.time + scrWindow_t2) & amp_ttp >= scrAmplitudeMin);
    nPeaks = length(scr_idx);
    
    era.TTP.scr_nr(iEvent) = nPeaks;
    era.TTP.scr_ampsum(iEvent) = sum(amp_ttp(scr_idx));
    if nPeaks > 0
        era.TTP.scr_latency(iEvent) = onset_ttp(scr_idx(1)) - event.time;
    end
    
    %Global measures
    era.global.mean(iEvent) = mean(leda2.data.conductance.data(idx_respwin));       %simple mean of data within response window
    diff = 0;
    for i = 1:length(cs_respwin)-1
        diff(i) = max(cs_respwin(i+1:end)) - cs_respwin(i);
    end
    era.global.max_deflection(iEvent) = max([diff, 0]);
    
    %Decomposition measures
    if ~isempty(leda2.analysis)
        if strcmp(leda2.analysis.method,'nndeco')
            %DDA
            scr_idx = find(onset_nndeco >= (event.time + scrWindow_t1) & onset_nndeco <= (event.time + scrWindow_t2) & amp_nndeco >= scrAmplitudeMin);
            nPeaks = length(scr_idx);
            
            era.DDA.scr_nr(iEvent) = nPeaks;
            era.DDA.scr_ampsum(iEvent) = sum(amp_nndeco(scr_idx));
            era.DDA.scr_areasum(iEvent) = sum(leda2.analysis.area(scr_idx)); % / (scrWindow_t2 - scrWindow_t1) would result in real muS/sec
            if nPeaks > 0
                era.DDA.scr_latency(iEvent) = onset_nndeco(scr_idx(1)) - event.time;
            end
            era.DDA.tonic(iEvent) = mean(leda2.analysis.tonicData(idx_respwin));
            
        elseif strcmp(leda2.analysis.method,'sdeco')
            %CDA
            era.CDA.SCR(iEvent) = max(0, sum(leda2.analysis.driver(idx_respwin))/(sr*(scrWindow_t2-scrWindow_t1)));  % ISCR = average phasic driver activity  [muS]            
            era.CDA.ISCR(iEvent) = max(0, sum(leda2.analysis.driver(idx_respwin))/sr);  % ISCR = phasic_area  [muS*sec]
            era.CDA.phasic_max(iEvent) = max(0, max(leda2.analysis.driver(idx_respwin)));
            sc_reconv = conv(leda2.analysis.driver(idx_respwin), leda2.analysis.kernel);
            if max(sc_reconv) >= scrAmplitudeMin
                era.CDA.SCR_ITTP(iEvent) = max(sc_reconv);
            else
                era.CDA.SCR_ITTP(iEvent) = 0;
            end
            era.CDA.tonic(iEvent) = mean(leda2.analysis.tonicData(idx_respwin));
            
        end
        
    end
    
end %iEvent


%% Export
%%%%%%%%%
savefname = [leda2.file.filename(1:end-4), '_era'];

%-Matlab Export
if leda2.set.export.savetype == 1
    results = era;
    save(savefname,'results');
end

%-Text Export
if leda2.set.export.savetype == 2
    fid = fopen([savefname,'.txt'],'wt');
    
    if isempty(leda2.analysis)
        fprintf(fid,'EvNr\tnSCR_ttp\tAmpSum_ttp\tOnset1_ttp\tMean\tMaxDeflection\tEventNId\tEventName\n');
        for i = 1:leda2.data.events.N
            fprintf(fid,'%3.0f\t%2.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%3.0f\t"%s"\n', ...
                i, era.TTP.scr_nr(i), era.TTP.scr_ampsum(i), era.TTP.scr_latency(i), era.global.mean(i), era.global.max_deflection(i), era.event.nid(i), era.event.name{i});
        end
        
    else
        
        if strcmp(leda2.analysis.method,'sdeco')
            fprintf(fid,'EvNr\tSCR\tISCR\tPhasicMax\tSCR_ITTP\tTonic\tnSCR_ttp\tAmpSum_ttp\tOnset1_ttp\tMean\tMaxDeflection\tEventNId\tEventName\n');
            for i = 1:leda2.data.events.N
                fprintf(fid,'%3.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%2.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%3.0f\t"%s"\n',...
                    i, era.CDA.SCR(i), era.CDA.ISCR(i), era.CDA.phasic_max(i), era.CDA.SCR_ITTP(i), era.CDA.tonic(i), era.TTP.scr_nr(i), era.TTP.scr_ampsum(i), era.TTP.scr_latency(i), era.global.mean(i), era.global.max_deflection(i), era.event.nid(i), era.event.name{i});
            end
            
        elseif strcmp(leda2.analysis.method,'nndeco')
            fprintf(fid,'EvNr\tnSCR\tAmpSum\tAreaSum\tOnset1\tTonic\tnSCR_ttp\tAmpSum_ttp\tOnset1_ttp\tMean\tMaxDeflection\tEventNId\tEventName\n');
            for i = 1:leda2.data.events.N
                fprintf(fid,'%3.0f\t%2.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%2.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%3.0f\t"%s"\n',...
                    i, era.DDA.scr_nr(i), era.DDA.scr_ampsum(i), era.DDA.scr_areasum(i), era.DDA.scr_latency(i), era.DDA.tonic(i), era.TTP.scr_nr(i), era.TTP.scr_ampsum(i), era.TTP.scr_latency(i), era.global.mean(i), era.global.max_deflection(i), era.event.nid(i), era.event.name{i});
            end
            
        end
    end
    fclose(fid);
end


%-Excel Export
if leda2.set.export.savetype == 3
    
    if isempty(leda2.analysis)
        xlswrite(savefname, {'Event-Nr','Event-NId','Event-Name','nSCR_ttp','AmpSum_ttp [muS]','Onset1_ttp [s]','SC_Mean [muS]','MaxDeflection [muS]'}, 'TTP', 'A1')
        xlswrite(savefname, [(1:leda2.data.events.N)', era.event.nid', nan(leda2.data.events.N,1), era.TTP.scr_nr', era.TTP.scr_ampsum', era.TTP.scr_latency', era.global.mean', era.global.max_deflection'], 'TTP', 'A2');
        xlswrite(savefname, era.event.name', 'TTP', 'C2');
        
    else        
        if strcmp(leda2.analysis.method,'sdeco')
            xlswrite(savefname, {'Event-Nr','Event-NId','Event-Name','SCR [muS]','ISCR [muSxs]','PhasicMax [muS]','SCR_ITTP [muS]','Tonic [muS]','nSCR_ttp','AmpSum_ttp [muS] ','Onset1_ttp [s]','Mean [muS]','MaxDeflection [muS]'}, 'CDA', 'A1');
            xlswrite(savefname, [(1:leda2.data.events.N)', era.event.nid', nan(leda2.data.events.N,1), era.CDA.SCR', era.CDA.ISCR', era.CDA.phasic_max', era.CDA.SCR_ITTP', era.CDA.tonic', era.TTP.scr_nr', era.TTP.scr_ampsum', era.TTP.scr_latency', era.global.mean', era.global.max_deflection'], 'CDA', 'A2');
            xlswrite(savefname, era.event.name', 'CDA', 'C2');
            
        elseif strcmp(leda2.analysis.method,'nndeco')
            xlswrite(savefname, {'Event-Nr','Event-NId','Event-Name','nSCR','AmpSum [muS]','AreaSum [muSxs]','Onset1 [s]','Tonic [muS]','nSCR_ttp','AmpSum_ttp [muS]','Onset1_ttp [s]','Mean [muS]','MaxDeflection [muS]'}, 'DDA', 'A1');
            xlswrite(savefname, [(1:leda2.data.events.N)', era.event.nid', nan(leda2.data.events.N,1), era.DDA.scr_nr', era.DDA.scr_ampsum', era.DDA.scr_areasum', era.DDA.scr_latency', era.DDA.tonic', era.TTP.scr_nr', era.TTP.scr_ampsum', era.TTP.scr_latency', era.global.mean', era.global.max_deflection'], 'DDA', 'A2');
            xlswrite(savefname, era.event.name', 'DDA', 'C2');
            
        end
        
    end
    
end


add2log(1,[num2str(leda2.data.events.N),' events written to ',fullfile(cd, savefname)],1,1,1,0,0,1)
