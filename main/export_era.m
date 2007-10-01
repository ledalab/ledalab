function export_era(action, file)
% postleda: Saving results of ledafit-file into textfile (*_results.txt)
%
%  - Choose SCR-Window times relative to event
%  - Choose minimum deflection for SCR
%
%  - Textfile-Variables are:
%      column 1: EpochNr, 
%      column 2: #peaks (number of peaks/deflections found in the SCR-window),
%      column 3: sum of amplitudes (of the peaks found)
%      column 4: onset-time of first peak within SCR-window
%      column 5: rise-time of first peak within SCR-window
%      column 6: inclination of first peak within SCR-window in muS/sec
%      column 7: relative amplitude sum (sum of amplitudes divided by initialvalue of the first deflection)
%      column 8: area under Bateman functions related to SCRs within SCR window
%      column 9: maximum positive difference of succeeding points in time
%      column 10-11: event.nid, event.userdata, event.name 

global leda_exp

leda_exp.SCRstart = 1.00; %sec
leda_exp.SCRend   = 4.00; %sec
leda_exp.SCRmin   =  .03; %muS
leda_exp.savetype = 3;

if nargin < 1, action = 'start'; end

switch action
    case 'start', start;
    case 'file', openFitFile;
    case 'take_settings',take_settings;
    case 'savePeaks', savePeaks;
end

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

text_scrWindowLimits = uicontrol('Style','text','Units','normalized','Position',[.1 .75 .35 dy],'BackgroundColor',[.8 .8 .8],'String','SCR window relative to event (start - end) [sec]:','HorizontalAlignment','left');
leda_exp.edit_scrWindowStart = uicontrol('Style','edit','Units','normalized','Position',[.5 .75 .1 dy],'BackgroundColor',[1 1 1],'String',num2str(leda_exp.SCRstart,'%1.2f'));
leda_exp.edit_scrWindowEnd   = uicontrol('Style','edit','Units','normalized','Position',[.65 .75 .1 dy],'BackgroundColor',[1 1 1],'String',num2str(leda_exp.SCRend,'%1.2f'));

text_scrAmplitudeMin = uicontrol('Style','text','Units','normalized','Position',[.1 .5 .35 .08],'BackgroundColor',[.8 .8 .8],'String','SCR amplitude minimum [muS]:','HorizontalAlignment','left');
leda_exp.edit_scrAmplitudeMin = uicontrol('Style','edit','Units','normalized','Position',[.5 .5 .1 dy],'BackgroundColor',[1 1 1],'String',num2str(leda_exp.SCRmin,'%1.2f'));

butt_savePeaks = uicontrol('Units','normalized','Position',[.1 .2 .3 dy],'String','Export','Callback','export_era(''take_settings'')');
leda_exp.popm_type = uicontrol('Style','popupmenu','Units','normalized','Position',[.5 .2 .3 dy],'String',{'Textfile';'Mat-Variable';'Text & Mat'});


function take_settings
global leda_exp leda2

leda_exp.SCRstart = str2num(get(leda_exp.edit_scrWindowStart,'String'));
leda_exp.SCRend = str2num(get(leda_exp.edit_scrWindowEnd,'String'));
leda_exp.SCRmin = str2num(get(leda_exp.edit_scrAmplitudeMin,'String'));
leda_exp.savetype = get(leda_exp.popm_type,'Value');

savePeaks;


function savePeaks
global leda_exp leda2

scrWindow_t1 = leda_exp.SCRstart;
scrWindow_t2 = leda_exp.SCRend;
scrAmplitudeMin = leda_exp.SCRmin;

for iEvent = 1: leda2.data.events.N
    
    event = leda2.data.events.event(iEvent);
    mv(iEvent).event_nid = event.nid;
    mv(iEvent).event_name = event.name;
    mv(iEvent).event_ud = event.userdata;
    
    win_tidx = time_idx(leda2.data.time.data, event.time + scrWindow_t1) : time_idx(leda2.data.time.data, event.time + scrWindow_t2);
    %mv.phasic = mean(leda2.analyze.fit.data.phasic(win_tidx));
    mv(iEvent).tonic = mean(leda2.analyze.fit.data.tonic(win_tidx));
    
    for iFit = 1%:2
        
        switch iFit
            case 1, phasics = leda2.analyze.fit.phasiccoef; %Bateman-Fit
            case 2, phasics = leda2.analyze.convolution.phasiccoef; %convolution
        end
        
        scr_idx = find(phasics.onset >= (event.time + scrWindow_t1) & phasics.onset <= (event.time + scrWindow_t2) & phasics.amp > scrAmplitudeMin);
        nPeaks = length(scr_idx);       
        
        if nPeaks > 0
            ampsum = sum(phasics.amp(scr_idx));
            
            peak1 = scr_idx(1);
            onsetT1 = phasics.onset(peak1); % = onset_time of first peak in SCR-window
            onsetT1_rel = onsetT1 - event.time;         % = onset_time of first peak in SCR-window relative to event
            if iFit == 1
                riseT1 = batemandelay(phasics.tau(1,peak1), phasics.tau(2,peak1)); %riseT1 = time when first peak in SCR-window reaches maximum, relative to onset
            elseif iFit == 2
                riseT1 = phasics.peaktime(peak1) - onsetT1;
            end
            amp1 = phasics.amp(peak1); %peakcoef1 = amplitude of first peak in SCR-window
            inclination1 = atan(amp1/riseT1)/(pi/2)*90;
            
            if iFit == 1
                peakInitValue = leda2.analyze.fit.data.phasicRemainder{peak1}(time_idx(leda2.data.time.data, onsetT1));
                ampsumrel = ampsum/peakInitValue; 
                
                area = 0;
                for p = 1:nPeaks
                    tau1 = phasics.tau(1, scr_idx(p));
                    tau2 = phasics.tau(2, scr_idx(p));
                    delay = tau1 * tau2 * log(tau1/tau2) / (tau1 - tau2);
                    maxamp = exp(-delay/tau1) - exp(-delay/tau2);
                    area = area + phasics.amp(scr_idx(p)) / maxamp * (tau1 - tau2);
                end
            end
            
        else %dummy-values if no peak within SCR-window
            onsetT1_rel = 0;
            riseT1 = 0;
            inclination1 = 0;
            ampsumrel = 0;
            ampsum = 0;
            area = 0;
            
        end %Fit: nPeaks >0
        
        switch iFit
            case 1,
                mv(iEvent).npeaks = nPeaks;
                mv(iEvent).ampsum = ampsum;
                mv(iEvent).onset1 = onsetT1_rel;
                mv(iEvent).risetime1 = riseT1;
                mv(iEvent).inclination1 = inclination1;
                mv(iEvent).ampsumrel = ampsumrel;
                mv(iEvent).area = area;
            case 2
                mv(iEvent).npeaks_conv = nPeaks;
                mv(iEvent).ampsum_conv = ampsum;
                mv(iEvent).ampsum = ampsum;
                mv(iEvent).ampsum_corr_conv = sum(phasics.amp_corr(scr_idx));
                mv(iEvent).onset1_conv = onsetT1_rel;
                mv(iEvent).risetime1_conv = riseT1;
                mv(iEvent).inclination1_conv = inclination1;
        end
        
    end %iFit
    
    %iFit = 3: max-deflection
    [ts, cs, t_idx] = subrange(event.time + scrWindow_t1, event.time + scrWindow_t2);
    clear diff;
    for i = 1:length(cs)-1
        diff(i) = max(cs(i+1:end)) - cs(i);
    end
    mv(iEvent).max_deflection = max([diff, 0]);
    
    
end %iEvent


savefname = [leda2.file.filename(1:end-4), '_eralist'];
if any(leda_exp.savetype == [1,3])
    
    fid = fopen([savefname,'.txt'],'wt');
    
    for i = 1:leda2.data.events.N
        %if isempty(event.userdata) | iscell(event.userdata)
        %    event.userdata = ' ';
        %end
        fprintf(fid,'%3.0f\t%2.0f\t%6.4f\t%6.4f\t%4.2f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%3.0f\t"%s"\t"%s"\n',i, mv(i).npeaks, mv(i).ampsum, mv(i).tonic, mv(i).onset1, mv(i).risetime1, mv(i).inclination1, mv(i).ampsumrel, mv(i).area, mv(i).max_deflection, mv(i).event_nid, mv(i).event_ud, mv(i).event_name);
    end
    fclose(fid);
end

if any(leda_exp.savetype == [2,3])
    results = mv;
    save(savefname,'results');
end

add2log(1,[num2str(leda2.data.events.N),' events written to ',fullfile(cd,savefname)],1,1,1,1,0,1)

close(leda_exp.fig_pl)
