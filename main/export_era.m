function export_era(action, file)
% postleda: Saving results of ledafit-file into textfile (*_results.txt)
%
%  - Choose SCR-Window times relative to event
%  - Choose minimum deflection for SCR
%
%  - Textfile-Variables are:
%       column 1: EpochNr
%     Based on Bateman-Decomposition Fit
%       column 2-4: #SCRs, amplitude sum, onset time (of the SCRs within the response window) 
%       column 5: mean tonic activation
%     Based on Trough-to-Peak (Min/Max) Method
%       column 6-8: #SCRs, amplitude sum, onset time (of the SCRs within the response window)
%     Based on global analysis
%       column 9: mean of response window data
%       column 10: maximum positive difference of succeeding samples (within response window)
%     Event info
%       column 11-13: event.nid, event.name, event.userdata


% further possible parameters
%      rise-time of first peak within SCR-window
%      inclination of first peak within SCR-window in muS/sec
%      relative amplitude sum (sum of amplitudes divided by initialvalue of the first deflection)
%      area under Bateman functions related to SCRs within SCR window

global leda_exp

leda_exp.SCRstart = 1.00; %sec
leda_exp.SCRend   = 4.00; %sec
leda_exp.SCRmin   = .03; %muS
leda_exp.savetype = 1;

if nargin < 1,
    action = 'start';
end

switch action,
    case 'start', start;
    case 'file', openFitFile;
    case 'take_settings',take_settings;
    case 'savePeaks', savePeaks;
end
disp('OK')

function start
global leda_exp leda2

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
if isempty(leda2.analyze.fit)
    if leda2.intern.prompt
        msgbox('File has no Fit yet!','Export Fit','error')
    end
    return
end


leda_exp.fig_pl = figure('Units','normalized','Position',[.2 .5 .6 .2],'Name','Export Fit','MenuBar','none','NumberTitle','off');

leda_exp.text_scrWindowLimits = uicontrol('Style','text','Units','normalized','Position',[.1 .75 .35 dy],'BackgroundColor',[.8 .8 .8],'String','SCR window relative to event (start - end) [sec]:','HorizontalAlignment','left');
leda_exp.edit_scrWindowStart = uicontrol('Style','edit','Units','normalized','Position',[.5 .75 .1 dy],'BackgroundColor',[1 1 1],'String',num2str(leda_exp.SCRstart,'%1.2f'));
leda_exp.edit_scrWindowEnd   = uicontrol('Style','edit','Units','normalized','Position',[.65 .75 .1 dy],'BackgroundColor',[1 1 1],'String',num2str(leda_exp.SCRend,'%1.2f'));

leda_exp.text_scrAmplitudeMin = uicontrol('Style','text','Units','normalized','Position',[.1 .5 .35 .08],'BackgroundColor',[.8 .8 .8],'String','SCR amplitude minimum [muS]:','HorizontalAlignment','left');
leda_exp.edit_scrAmplitudeMin = uicontrol('Style','edit','Units','normalized','Position',[.5 .5 .1 dy],'BackgroundColor',[1 1 1],'String',num2str(leda_exp.SCRmin,'%1.2f'));

leda_exp.butt_savePeaks = uicontrol('Units','normalized','Position',[.1 .2 .3 dy],'String','Export','Callback','export_era(''take_settings'')');
leda_exp.popm_type = uicontrol('Style','popupmenu','Units','normalized','Position',[.5 .2 .3 dy],'String',{'Matlab-File';'Text-File';'Matlab & Text-File'});



function take_settings
global leda_exp

leda_exp.SCRstart = str2double(get(leda_exp.edit_scrWindowStart,'String'));
leda_exp.SCRend = str2double(get(leda_exp.edit_scrWindowEnd,'String'));
leda_exp.SCRmin = str2double(get(leda_exp.edit_scrAmplitudeMin,'String'));
leda_exp.savetype = get(leda_exp.popm_type,'Value');

savePeaks;



function savePeaks
global leda_exp leda2

scrWindow_t1 = leda_exp.SCRstart;
scrWindow_t2 = leda_exp.SCRend;
scrAmplitudeMin = leda_exp.SCRmin;

for iEvent = 1:leda2.data.events.N

    event = leda2.data.events.event(iEvent);
    era(iEvent).event_nid = event.nid;
    era(iEvent).event_name = event.name;
    era(iEvent).event_ud = event.userdata;

    [t_respwin, cs_respwin, idx_respwin] = subrange(event.time + scrWindow_t1, event.time + scrWindow_t2);  %data of response window

    for iFit = 1:2

        switch iFit
            case 1, phasics = leda2.analyze.fit.phasiccoef; %Bateman-Fit
            case 2, phasics = leda2.analyze.initialvalues; %Trough-to-peak (Min/Max) analysis
        end

        scr_idx = find(phasics.onset >= (event.time + scrWindow_t1) & phasics.onset <= (event.time + scrWindow_t2) & phasics.amp > scrAmplitudeMin);
        nPeaks = length(scr_idx);

        if nPeaks == 0
            ampsum = 0;
            tonic = 0;
            onsetT1 = 0;
            %riseT1 = 0;
            %inclination1 = 0;
            %ampsumrel = 0;
            %area = 0;

        else  %nPeaks > 0
            ampsum = sum(phasics.amp(scr_idx));
            scr1 = scr_idx(1);
            onsetT1_abs = phasics.onset(scr1);          % = onset_time of first peak in SCR-window
            onsetT1 = onsetT1_abs - event.time;         % = onset_time of first peak in SCR-window relative to event

            %             if iFit == 1
            %                 riseT1 = batemandelay(phasics.tau(1,scr1), phasics.tau(2,scr1)); %riseT1 = time when first peak in SCR-window reaches maximum, relative to onset
            %             elseif iFit == 2
            %                 riseT1 = phasics.peaktime(scr1) - onsetT1;
            %             end
            %             amp1 = phasics.amp(scr1);                   % = amplitude of first peak in SCR-window
            %             inclination1 = atan(amp1/riseT1)/(pi/2)*90;

            if iFit == 1
                %                 peakInitValue = leda2.analyze.fit.data.phasicRemainder{scr1}(time_idx(leda2.data.time.data, onsetT1));
                %                 ampsumrel = ampsum/peakInitValue;
                %
                %                 area = 0;
                %                 for p = 1:nPeaks
                %                     tau1 = phasics.tau(1, scr_idx(p));
                %                     tau2 = phasics.tau(2, scr_idx(p));
                %                     delay = tau1 * tau2 * log(tau1/tau2) / (tau1 - tau2);
                %                     maxamp = exp(-delay/tau1) - exp(-delay/tau2);
                %                     area = area + phasics.amp(scr_idx(p)) / maxamp * (tau1 - tau2);
                %                 end
                %phasic = mean(leda2.analyze.fit.data.phasic(rwintidx));
                tonic = mean(leda2.analyze.fit.data.tonic(idx_respwin));
            end

        end %if nPeaks

        switch iFit
            case 1, %Bateman-Fit
                era(iEvent).fit.npeaks = nPeaks;
                era(iEvent).fit.ampsum = ampsum;
                era(iEvent).fit.tonic = tonic;
                era(iEvent).fit.onset = onsetT1;
                %era(iEvent).fit.risetime1 = riseT1;
                %era(iEvent).fit.inclination1 = inclination1;
                %era(iEvent).ampsumrel = ampsumrel;
                %era(iEvent).area = area;

            case 2 %Trough-to-Peak (TTP)
                era(iEvent).ttp.npeaks = nPeaks;
                era(iEvent).ttp.ampsum = ampsum;
                era(iEvent).ttp.onset = onsetT1;
                %era(iEvent).ttp.risetime1 = riseT1;
                %era(iEvent).ttp.inclination1 = inclination1;
        end

    end %iFit


    %Global measures
    %%%%%%%%%%%%%%%%%%
    era(iEvent).global.mean = mean(leda2.data.conductance.data(idx_respwin));       %simple mean of data within response window
    %Maximum-deflection
    clear diff;
    for i = 1:length(cs_respwin)-1
        diff(i) = max(cs_respwin(i+1:end)) - cs_respwin(i);
    end
    era(iEvent).global.max_deflection = max([diff, 0]);

end %iEvent


%Export
%%%%%%%%%
savefname = [leda2.file.filename(1:end-4), '_era'];
%-Text Export
if any(leda_exp.savetype == [2,3])
    fid = fopen([savefname,'.txt'],'wt');

    for i = 1:leda2.data.events.N
        if isempty(era(i).event_ud) || ~isstr(era(i).event_ud)
            ud = '-';
        else
            ud = era(i).event_ud;
        end
        fprintf(fid,'%3.0f\t%2.0f\t%6.4f\t%6.4f\t%6.4f\t%2.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%3.0f\t"%s"\t"%s"\n',i , era(i).fit.npeaks, era(i).fit.ampsum, era(i).fit.onset, era(i).fit.tonic, era(i).ttp.npeaks, era(i).ttp.ampsum, era(i).ttp.onset, era(i).global.mean, era(i).global.max_deflection, era(i).event_nid, era(i).event_name, ud);
    end
    fclose(fid);
end
%-Matlab Export
if any(leda_exp.savetype == [1,3])
    results = era;
    save(savefname,'results');
end

add2log(1,[num2str(leda2.data.events.N),' events written to ',fullfile(cd, savefname)],1,1,1,1,0,1)

close(leda_exp.fig_pl)
