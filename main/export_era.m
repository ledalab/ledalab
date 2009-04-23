function export_era(action)
% postleda: Saving results of ledafit-file into textfile (*_results.txt)
%
%  - Choose SCR-Window times relative to event
%  - Choose minimum deflection for SCR
%
%  - Textfile-Variables are:
%       column 1: EpochNr
%     Based on Bateman-Decomposition Fit
%       column 2-5: #SCRs, amplitude sum, area sum and onset latency (of the SCRs within the response window)
%       column 6: mean tonic activation
%     Based on Trough-to-Peak (Min/Max) Method
%       column 7-9: #SCRs, amplitude sum, onset time (of the SCRs within the response window)
%     Based on global analysis
%       column 10: mean of response window data
%       column 11: maximum positive difference of succeeding samples (within response window)
%     Event info
%       column 12-14: event.nid, event.name, event.userdata


% further possible parameters
%      rise-time of first peak within SCR-window
%      inclination of first peak within SCR-window in muS/sec
%      relative amplitude sum (sum of amplitudes divided by initialvalue of the first deflection)
%      area under Bateman functions related to SCRs within SCR window


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
if isempty(leda2.analysis)
    if leda2.intern.prompt
        msgbox('File has no Fit yet!','Export Fit','error')
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
leda2.gui.export.popm_type = uicontrol('Style','popupmenu','Units','normalized','Position',[.5 .2 .3 dy],'String',{'Matlab-File';'Text-File';'Matlab & Text-File'},'Value',leda2.set.export.savetype);



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

for iEvent = 1:leda2.data.events.N

    event = leda2.data.events.event(iEvent);
    era(iEvent).event_nid = event.nid;
    era(iEvent).event_name = event.name;
    era(iEvent).event_ud = event.userdata;

    [t_respwin, cs_respwin, idx_respwin] = subrange(event.time + scrWindow_t1, event.time + scrWindow_t2);  %data of response window

    for iFit = 1:2

        phasics = [];
        switch iFit
            case 1, %Bateman-Fit
                phasics.onset = leda2.analysis.impulsePeakTime;
                phasics.amp = leda2.analysis.amp;
                phasics.area = leda2.analysis.area;
            case 2, %Trough-to-peak (Min/Max) analysis
                phasics.onset = leda2.analysis.trough2peak.onset;
                phasics.amp = leda2.analysis.trough2peak.amp;
        end

        scr_idx = find(phasics.onset >= (event.time + scrWindow_t1) & phasics.onset <= (event.time + scrWindow_t2) & phasics.amp > scrAmplitudeMin);
        nPeaks = length(scr_idx);
        tonic = mean(leda2.analysis.tonicData(idx_respwin));

        if nPeaks == 0
            ampsum = 0;
            areasum = 0;
            onsetT1 = 0;
            %riseT1 = 0;
            %inclination1 = 0;
            %ampsumrel = 0;

        else  %nPeaks > 0
            ampsum = sum(phasics.amp(scr_idx));
            scr1 = scr_idx(1);
            onsetT1_abs = phasics.onset(scr1);          % = onset_time of first peak in SCR-window
            onsetT1 = onsetT1_abs - event.time;         % = onset_time of first peak in SCR-window relative to event
            if iFit == 1
                areasum = sum(phasics.area(scr_idx));
            else
                tonic = [];
            end

        end %if nPeaks

        switch iFit
            case 1, %Bateman-Fit
                era(iEvent).deconv.npeaks = nPeaks;
                era(iEvent).deconv.ampsum = ampsum;
                era(iEvent).deconv.areasum = areasum;
                era(iEvent).deconv.tonic = tonic;
                era(iEvent).deconv.onset = onsetT1;

            case 2 %Trough-to-Peak (TTP)
                era(iEvent).ttp.npeaks = nPeaks;
                era(iEvent).ttp.ampsum = ampsum;
                era(iEvent).ttp.onset = onsetT1;
        end

    end %iFit


    %Global measures
    %%%%%%%%%%%%%%%%%%
    if ~isempty(idx_respwin)
        era(iEvent).global.mean = mean(leda2.data.conductance.data(idx_respwin));       %simple mean of data within response window
    else
        era(iEvent).global.mean = mean(leda2.data.conductance.data);
    end

    %Maximum-deflection
    diff = 0;
    for i = 1:length(cs_respwin)-1
        diff(i) = max(cs_respwin(i+1:end)) - cs_respwin(i);
    end
    era(iEvent).global.max_deflection = max([diff, 0]);

end %iEvent


%Export
%%%%%%%%%
savefname = [leda2.file.filename(1:end-4), '_era'];
%-Text Export
if any(leda2.set.export.savetype == [2,3])
    fid = fopen([savefname,'.txt'],'wt');
    fprintf(fid,'EventNr\tnSCR\tAmpSum\tAreaSum\tOnset\tTonic\tnSCR_ttp\tAmpSum_ttp\tOnset_ttp\tMean\tMaxDeflection\tEventNId\tEventName\tUserdata\n');

    for i = 1:leda2.data.events.N
        if isempty(era(i).event_ud) || ~ischar(era(i).event_ud)
            ud = '-';
        else
            ud = era(i).event_ud;
        end
        fprintf(fid,'%3.0f\t%2.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%2.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%3.0f\t"%s"\t"%s"\n',i , era(i).deconv.npeaks, era(i).deconv.ampsum, era(i).deconv.areasum, era(i).deconv.onset, era(i).deconv.tonic, era(i).ttp.npeaks, era(i).ttp.ampsum, era(i).ttp.onset, era(i).global.mean, era(i).global.max_deflection, era(i).event_nid, era(i).event_name, ud);
    end
    fclose(fid);
end
%-Matlab Export
if any(leda2.set.export.savetype == [1,3])
    results = era;
    save(savefname,'results');
end

add2log(1,[num2str(leda2.data.events.N),' events written to ',fullfile(cd, savefname)],1,1,1,0,0,1)
