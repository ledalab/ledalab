function export_era(action)
% postleda: Saving results of ledafit-file into textfile (*_results.txt)
%
%  - Choose SCR-Window times relative to event
%  - Choose minimum deflection for SCR
%
%  - Textfile-Variables are:
%       column 1: EpochNr
%     Based on Bateman-Decomposition Fit
%       column 2-6: #SCRs, amplitude sum, area sum, driver area and onset latency (of the SCRs within the response window)
%       column 7: mean tonic activation
%     Based on Trough-to-Peak (Min/Max) Method
%       column 8-10: #SCRs, amplitude sum, onset time (of the SCRs within the response window)
%     Based on global analysis
%       column 11: mean of response window data
%       column 12: maximum positive difference of succeeding samples (within response window)
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


leda2.gui.export.fig_pl = figure('Units','normalized','Position',[.2 .5 .6 .2],'Name','Export Fit','MenuBar','none','NumberTitle','off');

leda2.gui.export.text_scrWindowLimits = uicontrol('Style','text','Units','normalized','Position',[.1 .75 .35 dy],'BackgroundColor',[.8 .8 .8],'String','SCR window relative to event (start - end) [sec]:','HorizontalAlignment','left');
leda2.gui.export.edit_scrWindowStart = uicontrol('Style','edit','Units','normalized','Position',[.5 .75 .1 dy],'BackgroundColor',[1 1 1],'String',num2str(leda2.set.export.SCRstart,'%1.2f'));
leda2.gui.export.edit_scrWindowEnd   = uicontrol('Style','edit','Units','normalized','Position',[.65 .75 .1 dy],'BackgroundColor',[1 1 1],'String',num2str(leda2.set.export.SCRend,'%1.2f'));

leda2.gui.export.text_scrAmplitudeMin = uicontrol('Style','text','Units','normalized','Position',[.1 .5 .35 .08],'BackgroundColor',[.8 .8 .8],'String','SCR amplitude minimum [muS]:','HorizontalAlignment','left');
leda2.gui.export.edit_scrAmplitudeMin = uicontrol('Style','edit','Units','normalized','Position',[.5 .5 .1 dy],'BackgroundColor',[1 1 1],'String',num2str(leda2.set.export.SCRmin,'%1.2f'));

leda2.gui.export.butt_savePeaks = uicontrol('Units','normalized','Position',[.1 .2 .3 dy],'String','Export','Callback','export_era(''take_settings'')');
leda2.gui.export.popm_type = uicontrol('Style','popupmenu','Units','normalized','Position',[.5 .2 .3 dy],'String',{'Matlab-File';'Text-File'},'Value',leda2.set.export.savetype);



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
    era(iEvent).event_time = event.time;
    era(iEvent).event_nid = event.nid;
    era(iEvent).event_name = event.name;
    era(iEvent).event_ud = event.userdata;

    [t_respwin, cs_respwin, idx_respwin] = subrange(event.time + scrWindow_t1, event.time + scrWindow_t2);  %data of response window

    %Reset all measures
    %Measures yielded by nonnegative deconvolution
    era(iEvent).nndeconv.scr_nr = NaN;
    era(iEvent).nndeconv.scr_ampsum = NaN;
    era(iEvent).nndeconv.scr_areasum = NaN;
    era(iEvent).nndeconv.scr_latency = NaN;
    era(iEvent).nndeconv.tonic = NaN;  %average tonic level
    %Measures yielded by (robust) standard deconvolution
    era(iEvent).sdeconv.ISCR = NaN;  %phasic driver area (time integral over response window)
    era(iEvent).sdeconv.phasic_max = NaN;   %Driver maximum within response window
    era(iEvent).sdeconv.phasic_amp = NaN;   %SCR amp resulting from phasic segment re-convoluted with driver impulse
    era(iEvent).sdeconv.tonic = NaN;   %average tonic level
    %Measures yielded by (robust) trough-to-peak analysis
    era(iEvent).ttp.scr_nr = NaN;
    era(iEvent).ttp.scr_ampsum = NaN;
    era(iEvent).ttp.scr_latency = NaN;
    %Measures based on raw SC data
    era(iEvent).global.mean = NaN;
    era(iEvent).global.max_deflection = NaN;


    %Set Measures
    %TTP
    scr_idx = find(onset_ttp >= (event.time + scrWindow_t1) & onset_ttp <= (event.time + scrWindow_t2) & amp_ttp >= scrAmplitudeMin);
    nPeaks = length(scr_idx);

    era(iEvent).ttp.scr_nr = nPeaks;
    era(iEvent).ttp.scr_ampsum = sum(amp_ttp(scr_idx));
    if nPeaks > 0
        era(iEvent).ttp.scr_latency = onset_ttp(scr_idx(1)) - event.time;
    end

    %Global measures
    era(iEvent).global.mean = mean(leda2.data.conductance.data(idx_respwin));       %simple mean of data within response window
    diff = 0;
    for i = 1:length(cs_respwin)-1
        diff(i) = max(cs_respwin(i+1:end)) - cs_respwin(i);
    end
    era(iEvent).global.max_deflection = max([diff, 0]);

    %Decomposition measures
    if ~isempty(leda2.analysis)
        if strcmp(leda2.analysis.method,'nndeco')
            %NNDECONV
            scr_idx = find(onset_nndeco >= (event.time + scrWindow_t1) & onset_nndeco <= (event.time + scrWindow_t2) & amp_nndeco >= scrAmplitudeMin);
            nPeaks = length(scr_idx);

            era(iEvent).nndeconv.scr_nr = nPeaks;
            era(iEvent).nndeconv.scr_ampsum = sum(amp_nndeco(scr_idx));
            era(iEvent).nndeconv.scr_areasum = sum(leda2.analysis.area(scr_idx)); % / (scrWindow_t2 - scrWindow_t1) would result in real muS/sec
            if nPeaks > 0
                era(iEvent).nndeconv.scr_latency = onset_nndeco(scr_idx(1)) - event.time;
            end
            era(iEvent).nndeconv.tonic = mean(leda2.analysis.tonicData(idx_respwin));

        elseif strcmp(leda2.analysis.method,'sdeco')
            %SDECO
            era(iEvent).sdeconv.ISCR = max(0, sum(leda2.analysis.driver(idx_respwin))/sr);  % ISCR = phasic_area  [muS*sec]
            %  mean() == sum()/(sr*winsize)  [muS]
            era(iEvent).sdeconv.phasic_max = max(0, max(leda2.analysis.driver(idx_respwin)));
            sc_reconv = conv(leda2.analysis.driver(idx_respwin), leda2.analysis.kernel);
            if max(sc_reconv) >= scrAmplitudeMin
                era(iEvent).sdeconv.phasic_amp = max(sc_reconv);
            else
                era(iEvent).sdeconv.phasic_amp = 0;
            end
            era(iEvent).sdeconv.tonic = mean(leda2.analysis.tonicData(idx_respwin));

        end

    end

end %iEvent


%Export
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
                i, era(i).ttp.scr_nr, era(i).ttp.scr_ampsum, era(i).ttp.scr_latency, era(i).global.mean, era(i).global.max_deflection, era(i).event_nid, era(i).event_name);
        end

    else
        if strcmp(leda2.analysis.method,'nndeco')
            fprintf(fid,'EvNr\tnSCR\tAmpSum\tAreaSum\tOnset1\tTonic\tnSCR_ttp\tAmpSum_ttp\tOnset1_ttp\tMean\tMaxDeflection\tEventNId\tEventName\n');
            for i = 1:leda2.data.events.N
                fprintf(fid,'%3.0f\t%2.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%2.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%3.0f\t"%s"\n',...
                    i, era(i).nndeconv.scr_nr, era(i).nndeconv.scr_ampsum, era(i).nndeconv.scr_areasum, era(i).nndeconv.scr_latency, era(i).nndeconv.tonic, era(i).ttp.scr_nr, era(i).ttp.scr_ampsum, era(i).ttp.scr_latency, era(i).global.mean, era(i).global.max_deflection, era(i).event_nid, era(i).event_name);
            end

        elseif strcmp(leda2.analysis.method,'sdeco')
            fprintf(fid,'EvNr\tISCR\tPhasicMax\tPhasicAmp\tTonic\tnSCR_ttp\tAmpSum_ttp\tOnset1_ttp\tMean\tMaxDeflection\tEventNId\tEventName\n');
            for i = 1:leda2.data.events.N
                fprintf(fid,'%3.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%2.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%3.0f\t"%s"\n',...
                    i, era(i).sdeconv.ISCR, era(i).sdeconv.phasic_max, era(i).sdeconv.phasic_amp, era(i).sdeconv.tonic, era(i).ttp.scr_nr, era(i).ttp.scr_ampsum, era(i).ttp.scr_latency, era(i).global.mean, era(i).global.max_deflection, era(i).event_nid, era(i).event_name);
            end

        end
    end
    fclose(fid);
end

add2log(1,[num2str(leda2.data.events.N),' events written to ',fullfile(cd, savefname)],1,1,1,0,0,1)
