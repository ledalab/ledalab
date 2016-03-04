function export_era
% Saving results into Matlab/textfile/or Excel (*_era.mat/txt/xls)
%
%  - Choose SCR-Window times relative to event
%  - Choose minimum amplitude threshold for SCR

global leda2;

if leda2.data.events.N < 1
    if leda2.intern.prompt
        msgbox('File has no Events!','Export Event-Related Activation','error')
    end
    return
end

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
        
    else %sdeco
        if leda2.intern.version <= 3.34  %see sdeco lines ~235+
            t = leda2.data.time.data;
            driver = leda2.analysis.driver;
            [minL, maxL] = get_peaks(driver);
            minL = [minL(1:length(maxL)), length(t)];
            leda2.analysis.impulseOnset = t(minL(1:end-1));
            leda2.analysis.impulsePeakTime = t(maxL);   % = effective peak-latency
            for iPeak = 1:length(maxL)
                sc_reconv = conv(leda2.analysis.driver(minL(iPeak):minL(iPeak+1)), leda2.analysis.kernel);
                leda2.analysis.amp(iPeak) = max(sc_reconv);
            end
        end
        onset_sdeco = leda2.analysis.impulsePeakTime; %impulse peak-time = peak-latency
        amp_sdeco = leda2.analysis.amp;
        
    end
end


for iEvent = 1:leda2.data.events.N
    
    %Set event data
    event = leda2.data.events.event(iEvent);
    era.Event.time(iEvent) = event.time;
    era.Event.nid(iEvent) = event.nid;
    era.Event.name{iEvent} = event.name;
    era.Event.ud{iEvent} = event.userdata;
    
    [~, cs_respwin, idx_respwin] = subrange(event.time + scrWindow_t1, event.time + scrWindow_t2);  %data of response window

    % RESET ALL MEASURES
    % Measures yielded by Continuous Decomposition Analysis (CDA)
    if ~isempty(leda2.analysis)
        if strcmp(leda2.analysis.method,'sdeco')
            era.CDA.nSCR(iEvent) = NaN;       % Number of significant (= above threshold) SCRs within response window
            era.CDA.Latency(iEvent) = NaN;  % Latency of first sign SCR within response window (= time of corresponding impulse-peak)
            era.CDA.AmpSum(iEvent) = NaN;   % Amplitude-Sum of sign SCRs (reconvolved from phasic driver-peaks)
            era.CDA.SCR(iEvent) = NaN;          % Average phasic driver activity (time integral over response window by size of responsewindow)
            era.CDA.ISCR(iEvent) = NaN;         % Phasic driver area (time integral over response window)
            era.CDA.PhasicMax(iEvent) = NaN;  % Driver maximum within response window
            era.CDA.Tonic(iEvent) = NaN;        % Average level of (decomposed) Tonic component
            
        elseif strcmp(leda2.analysis.method,'nndeco')
            % Measures yielded by Discrete Decomposition Analysis (DDA)
            era.DDA.nSCR(iEvent) = NaN;       % Number of significant (= above threshold) SCRs within response window
            era.DDA.Latency(iEvent) = NaN;  % Latency of first sign SCR within response window (= time of corresponding impulse-peak)
            era.DDA.AmpSum(iEvent) = NaN;   % Amplitude-Sum of sign SCRs within response window
            era.DDA.AreaSum(iEvent) = NaN;  % Area of SCRs within response window
            era.DDA.Tonic(iEvent) = NaN;        % Average level of (decomposed) Tonic component
        end
    end
    % Measures yielded by Trough-To-Peak Analysis
    era.TTP.nSCR(iEvent) = NaN;       % Number of significant (= above threshold) SCRs within response window
    era.TTP.Latency(iEvent) = NaN;  % Latency of first sign SCR within response window
    era.TTP.AmpSum(iEvent) = NaN;   % Amplitude-Sum of sign SCRs (EDA-Max - EDA-Min)
    
    % Measures based on raw SC data
    era.Global.Mean(iEvent) = NaN;
    era.Global.MaxDeflection(iEvent) = NaN;
    
    
    if isempty(idx_respwin)
        warning(['Data doesn''t contain ERA-window for event nr. %d.\n'...
            'Is the marker too close to the end of the recording?'],iEvent);
        break;
    end
    
    
    %Set Measures
    %TTP
    scr_idx = find(onset_ttp >= (event.time + scrWindow_t1) & onset_ttp <= (event.time + scrWindow_t2) & amp_ttp >= scrAmplitudeMin);
    nPeaks = length(scr_idx);
    
    era.TTP.nSCR(iEvent) = nPeaks;
    era.TTP.AmpSum(iEvent) = sum(amp_ttp(scr_idx));
    if nPeaks > 0
        era.TTP.Latency(iEvent) = onset_ttp(scr_idx(1)) - event.time;
    end
    
    %Global measures
    era.Global.Mean(iEvent) = mean(leda2.data.conductance.data(idx_respwin));       %simple Mean of data within response window
    diff = zeros(1,length(cs_respwin)-1);
    for i = 1:length(cs_respwin)-1
        diff(i) = max(cs_respwin(i+1:end)) - cs_respwin(i);
    end
    era.Global.MaxDeflection(iEvent) = max([diff, 0]);
    
    %Decomposition measures
    if ~isempty(leda2.analysis)
        
        if strcmp(leda2.analysis.method,'sdeco') %CDA
            scr_idx = find(onset_sdeco >= (event.time + scrWindow_t1) & onset_sdeco <= (event.time + scrWindow_t2) & amp_sdeco >= scrAmplitudeMin);
            nPeaks = length(scr_idx);
            
            era.CDA.nSCR(iEvent) = nPeaks;
            if nPeaks > 0
                era.CDA.Latency(iEvent) = onset_sdeco(scr_idx(1)) - event.time;
            end
            era.CDA.AmpSum(iEvent) = sum(amp_sdeco(scr_idx));

            era.CDA.ISCR(iEvent) = max(0, sum(leda2.analysis.driver(idx_respwin))/sr);  % ISCR = phasic_area  [muS*sec]
            era.CDA.SCR(iEvent) = era.CDA.ISCR(iEvent) / (sr*(scrWindow_t2-scrWindow_t1));% SCR = average phasic driver activity  [muS]
            era.CDA.PhasicMax(iEvent) = max(0, max(leda2.analysis.driver(idx_respwin)));
            era.CDA.Tonic(iEvent) = mean(leda2.analysis.tonicData(idx_respwin));
            
        elseif strcmp(leda2.analysis.method,'nndeco') %DDA
            scr_idx = find(onset_nndeco >= (event.time + scrWindow_t1) & onset_nndeco <= (event.time + scrWindow_t2) & amp_nndeco >= scrAmplitudeMin);
            nPeaks = length(scr_idx);
            
            era.DDA.nSCR(iEvent) = nPeaks;
            if nPeaks > 0
                era.DDA.Latency(iEvent) = onset_nndeco(scr_idx(1)) - event.time;
            end
            era.DDA.AmpSum(iEvent) = sum(amp_nndeco(scr_idx));
            era.DDA.AreaSum(iEvent) = sum(leda2.analysis.area(scr_idx)); % / (scrWindow_t2 - scrWindow_t1) would result in real muS/sec
            era.DDA.Tonic(iEvent) = mean(leda2.analysis.tonicData(idx_respwin));
            
        end
        
    end
    
end %iEvent

%% z-scaling
%%%%%%%%%%%%

if leda2.set.export.zscale
    % better than zscore from the stats toolbox as it's free and handles NaNs better
    zscore = @(x) (x-mean(x(~isnan(x))))/std(x(~isnan(x)));

    if(strcmp(leda2.analysis.method,'sdeco'))
        era.CDA = structfun(zscore, era.CDA, 'UniformOutput', false);
    elseif strcmp(leda2.analysis.method,'nndeco')
        era.DDA = structfun(zscore, era.DDA, 'UniformOutput', false);
    end
    era.TTP.AmpSum = zscore(era.TTP.AmpSum);
end

%% Export
%%%%%%%%%
savefname = [leda2.file.filename(1:end-4), '_era'];
if leda2.set.export.zscale
    savefname = [savefname, '_z'];
end

%-Matlab Export
if leda2.set.export.savetype == 1
    results = era; %#ok<NASGU>
    savefname = [savefname,'.mat'];
    save(savefname,'results');
end

%-Text Export
if leda2.set.export.savetype == 2
    savefname = [savefname,'.txt'];
    fid = fopen(savefname,'wt');
    
    if isempty(leda2.analysis)
        fprintf(fid,'Event.Nr\tTTP.nSCR\tTTP.Latency\tTTP.AmpSum\tGlobal.Mean\tGlobal.MaxDeflection\tEvent.NID\tEvent.Name\r\n');
        for i = 1:leda2.data.events.N
            fprintf(fid,'%3.0f\t%2.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%3.0f\t"%s"\r\n', ...
                i, era.TTP.nSCR(i), era.TTP.Latency(i), era.TTP.AmpSum(i), era.Global.Mean(i), era.Global.MaxDeflection(i), era.Event.nid(i), era.Event.name{i});
        end
        
    else
        if strcmp(leda2.analysis.method,'sdeco')
            fprintf(fid,'Event.Nr\tCDA.nSCR\tCDA.Latency\tCDA.AmpSum\tCDA.SCR\tCDA.ISCR\tCDA.PhasicMax\tCDA.Tonic\tTTP.nSCR\tTTP.Latency\tTTP.AmpSum\tGlobal.Mean\tGlobal.MaxDeflection\tEvent.NID\tEvent.Name\r\n');
            for i = 1:leda2.data.events.N
                fprintf(fid,'%3.0f\t%2.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%2.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%3.0f\t"%s"\r\n',...
                    i, era.CDA.nSCR(i), era.CDA.Latency(i), era.CDA.AmpSum(i), era.CDA.SCR(i), era.CDA.ISCR(i), era.CDA.PhasicMax(i), era.CDA.Tonic(i), era.TTP.nSCR(i), era.TTP.Latency(i), era.TTP.AmpSum(i), era.Global.Mean(i), era.Global.MaxDeflection(i), era.Event.nid(i), era.Event.name{i});
            end
            
        elseif strcmp(leda2.analysis.method,'nndeco')
            fprintf(fid,'Event.Nr\tDDA.nSCR\tDDA.Latency\tDDA.AmpSum\tDDA.AreaSum\tDDA.Tonic\tTTP.nSCR\tTTP.Latency\tTTP.AmpSum\tGlobal.Mean\tGlobal.MaxDeflection\tEvent.NID\tEvent.Name\r\n');
            for i = 1:leda2.data.events.N
                fprintf(fid,'%3.0f\t%2.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%2.0f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%3.0f\t"%s"\r\n',...
                    i, era.DDA.nSCR(i), era.DDA.Latency(i), era.DDA.AmpSum(i), era.DDA.AreaSum(i), era.DDA.Tonic(i), era.TTP.nSCR(i), era.TTP.Latency(i), era.TTP.AmpSum(i), era.Global.Mean(i), era.Global.MaxDeflection(i), era.Event.nid(i), era.Event.name{i});
            end
            
        end
    end
    fclose(fid);
end


%-Excel Export
if leda2.set.export.savetype == 3
    savefname = [savefname,'.xls'];
    
    if isempty(leda2.analysis)
        xlswrite(savefname, {'Event.Nr', 'Event.NID', 'Event.Name','TTP.nSCR','TTP.Latency [s]','TTP.AmpSum [muS]','Global.Mean [muS]','Global.MaxDeflection [muS]'}, 'TTP', 'A1')
        xlswrite(savefname, [(1:leda2.data.events.N)', era.Event.nid', nan(leda2.data.events.N,1), era.TTP.nSCR', era.TTP.Latency', era.TTP.AmpSum', era.Global.Mean', era.Global.MaxDeflection'], 'TTP', 'A2');
        xlswrite(savefname, era.Event.name', 'TTP', 'C2');
        
    else
        if strcmp(leda2.analysis.method,'sdeco')
            xlswrite(savefname, {'Event.Nr', 'Event.NID', 'Event.Name', 'CDA.nSCR', 'CDA.Latency [s]', 'CDA.AmpSum [muS]', 'CDA.SCR [muS]', 'CDA.ISCR [muSxs]', 'CDA.PhasicMax [muS]', 'CDA.Tonic [muS]', 'TTP.nSCR', 'TTP.Latency [s]', 'TTP.AmpSum [muS]', 'Global.Mean [muS]', 'Global.MaxDeflection [muS]'}, 'CDA', 'A1');
            xlswrite(savefname, [(1:leda2.data.events.N)', era.Event.nid', nan(leda2.data.events.N,1), era.CDA.nSCR', era.CDA.Latency', era.CDA.AmpSum', era.CDA.SCR', era.CDA.ISCR', era.CDA.PhasicMax', era.CDA.Tonic', era.TTP.nSCR', era.TTP.Latency', era.TTP.AmpSum', era.Global.Mean', era.Global.MaxDeflection'], 'CDA', 'A2');
            xlswrite(savefname, era.Event.name', 'CDA', 'C2');
            
        elseif strcmp(leda2.analysis.method,'nndeco')
            xlswrite(savefname, {'Event.Nr', 'Event.NID', 'Event.Name', 'DDA.nSCR', 'DDA.Latency [s]', 'DDA.AmpSum [muS]', 'DDA.AreaSum [muSxs]', 'DDA.Tonic [muS]', 'TTP.nSCR', 'TTP.Latency [s]', 'TTP.AmpSum [muS]', 'Global.Mean [muS]', 'Global.MaxDeflection [muS]'}, 'DDA', 'A1');
            xlswrite(savefname, [(1:leda2.data.events.N)', era.Event.nid', nan(leda2.data.events.N,1), era.DDA.nSCR', era.DDA.Latency', era.DDA.AmpSum', era.DDA.AreaSum', era.DDA.Tonic', era.TTP.nSCR', era.TTP.Latency', era.TTP.AmpSum', era.Global.Mean', era.Global.MaxDeflection'], 'DDA', 'A2');
            xlswrite(savefname, era.Event.name', 'DDA', 'C2');
            
        end
        
    end
    
end


add2log(1,[num2str(leda2.data.events.N),' events written to ',fullfile(cd, savefname)],1,1,1,0,0,1)
