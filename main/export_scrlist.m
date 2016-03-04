function export_scrlist
% Saving scr_list to Excel (*_scrlist.mat/txt/xls)
%
%  - Choose minimum amplitude threshold for SCR

global leda2

scrAmplitudeMin = leda2.set.export.SCRmin;

if ~isempty(leda2.analysis)
    if strcmp(leda2.analysis.method,'nndeco')
        onset = leda2.analysis.impulsePeakTime;
        amp = leda2.analysis.amp;
        
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
        onset = leda2.analysis.impulsePeakTime; %impulse peak-time = peak-latency
        amp = leda2.analysis.amp;
        
    end
end
onset_ttp = leda2.trough2peakAnalysis.onset;
amp_ttp = leda2.trough2peakAnalysis.amp;

if ~isempty(leda2.analysis)
    scr_idx = find(onset >= 0 & amp >= scrAmplitudeMin);
    if isempty(scr_idx)
        if strcmp(leda2.analysis.method,'sdeco')
            add2log(1,['SCR-List export for ',leda2.file.filename,': No SCRs detected (method CDA)!'], 1,1,1,1,0,1);
        else
            add2log(1,['SCR-List export for ',leda2.file.filename,': No SCRs detected (method DDA)!'], 1,1,1,1,0,1);
        end
    end
    if strcmp(leda2.analysis.method,'sdeco')
        scrList.CDA.onset = onset(scr_idx);
        scrList.CDA.amp = amp(scr_idx);
    else
        scrList.DDA.onset = onset(scr_idx);
        scrList.DDA.amp = amp(scr_idx);
    end
end

scr_ttpidx = find(onset_ttp >= 0 & amp_ttp >= scrAmplitudeMin);
if isempty(scr_ttpidx)
    add2log(1,['SCR-List export for ',leda2.file.filename,': No SCRs detected (method TTP)!'], 1,1,1,1,0,1);
end
scrList.TTP.onset = onset_ttp(scr_ttpidx);
scrList.TTP.amp = amp_ttp(scr_ttpidx);


%% z-scaling
%%%%%%%%%%%%

if leda2.set.export.zscale
    % better than zscore from the stats toolbox as it's free and handles NaN better
    zscore = @(x) (x-mean(x(~isnan(x))))/std(x(~isnan(x)));
    if(strcmp(leda2.analysis.method,'sdeco'))
        scrList.CDA.amp = zscore(scrList.CDA.amp);
    elseif strcmp(leda2.analysis.method,'nndeco')
        scrList.DDA.amp = zscore(scrList.DDA.amp);
    end
    scrList.TTP.amp = zscore(scrList.TTP.amp);
end

%% Export
%%%%%%%%%
savefname = [leda2.file.filename(1:end-4), '_scrlist'];
if leda2.set.export.zscale
    savefname = [savefname, '_z'];
end

%-Matlab Export
if leda2.set.export.savetype == 1
    savefname = [savefname,'.mat'];
    save(savefname,'scrList');
end

%-Text Export
if leda2.set.export.savetype == 2
    savefname = [savefname,'.txt'];
    fid = fopen(savefname,'wt');
    
    if isempty(leda2.analysis)
        fprintf(fid,'TTP.SCR-Onset\tTTP.SCR-Amplitude\r\n');
        for i = 1:length(scrList.TTP.onset)
            fprintf(fid,'%8.4f\t%8.4f\r\n', scrList.TTP.onset(i), scrList.TTP.amp(i));
        end
    else
        if strcmp(leda2.analysis.method,'sdeco')
            fprintf(fid,'CDA.SCR-Onset\tCDA.SCR-Amplitude\r\n');
            for i = 1:length(scrList.CDA.onset)
                fprintf(fid,'%8.4f\t%8.4f\r\n', scrList.CDA.onset(i), scrList.CDA.amp(i));
            end
            
        elseif strcmp(leda2.analysis.method,'nndeco')
            fprintf(fid,'DDA.SCR-Onset\tDDA.SCR-Amplitude\r\n');
            for i = 1:length(scrList.DDA.onset)
                fprintf(fid,'%8.4f\t%8.4f\r\n', scrList.DDA.onset(i), scrList.DDA.amp(i));
            end
        end
    end
    fclose(fid);
end

%%EXCEL
if leda2.set.export.savetype == 3
    savefname = [savefname,'.xls'];
    
    if isempty(leda2.analysis)
        xlswrite(savefname, {'TTP.SCR-Onset','TTP.SCR-Amplitude'}, 'TTP', 'A1')
        if ~isempty(scr_ttpidx)
            xlswrite(savefname, [scrList.TTP.onset', scrList.TTP.amp'], 'TTP', 'A2');
        end
    else
        if strcmp(leda2.analysis.method,'sdeco')
            xlswrite(savefname, {'CDA.SCR-Onset','CDA.SCR-Amplitude'}, 'CDA', 'A1');
            if ~isempty(scr_idx)
                xlswrite(savefname, [scrList.CDA.onset', scrList.CDA.amp'], 'CDA', 'A2');
            end
            xlswrite(savefname, {'TTP.SCR-Onset','TTP.SCR-Amplitude'}, 'TTP', 'A1')
            if ~isempty(scr_ttpidx)
                xlswrite(savefname, [scrList.TTP.onset', scrList.TTP.amp'], 'TTP', 'A2');
            end
            
        elseif strcmp(leda2.analysis.method,'nndeco')
            xlswrite(savefname, {'DDA.SCR-Onset','DDA.SCR-Amplitude'}, 'DDA', 'A1');
            if ~isempty(scr_idx)
                xlswrite(savefname, [scrList.DDA.onset', scrList.DDA.amp'], 'DDA', 'A2');
            end
            xlswrite(savefname, {'TTP.SCR-Onset','TTP.SCR-Amplitude'}, 'TTP', 'A1')
            if ~isempty(scr_ttpidx)
                xlswrite(savefname, [scrList.TTP.onset', scrList.TTP.amp'], 'TTP', 'A2');
            end
            
        end
        
    end
end

add2log(1,['SCR-List exported to ',savefname], 1,1,1,0,0,1);

