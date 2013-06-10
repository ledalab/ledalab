function export_scrlist(action)
% Saving scr_list to Excel (*_scrlist.mat/txt/xls)
%
%  - Choose minimum amplitude threshold for SCR


if nargin < 1,
    action = 'start';
end

switch action,
    case 'start', start;
    case 'take_settings',take_settings;
    case 'saveList', saveList;
end

function start
global leda2

dy = .13;


if ~leda2.file.open
    if leda2.intern.prompt
        msgbox('No open File!','Export SCR-List','error')
    end
    return
end


leda2.gui.export.fig_pl = figure('Units','normalized','Position',[.2 .5 .6 .2],'Name','Export SCR-List','MenuBar','none','NumberTitle','off');

leda2.gui.export.text_scrAmplitudeMin = uicontrol('Style','text','Units','normalized','Position',[.1 .5 .35 .08],'BackgroundColor',[.8 .8 .8],'String','SCR amplitude minimum [muS]:','HorizontalAlignment','left');
leda2.gui.export.edit_scrAmplitudeMin = uicontrol('Style','edit','Units','normalized','Position',[.5 .5 .1 dy],'BackgroundColor',[1 1 1],'String',num2str(leda2.set.export.SCRmin,'%1.2f'));

leda2.gui.export.butt_savePeaks = uicontrol('Units','normalized','Position',[.1 .2 .3 dy],'String','Export','Callback','export_scrlist(''take_settings'')');
leda2.gui.export.popm_type = uicontrol('Style','popupmenu','Units','normalized','Position',[.5 .2 .3 dy],'String',{'Matlab-File';'Text-File'; 'Excel-File'},'Value',leda2.set.export.savetype);



function take_settings
global leda2

leda2.set.export.SCRmin = str2double(get(leda2.gui.export.edit_scrAmplitudeMin,'String'));
leda2.set.export.savetype = get(leda2.gui.export.popm_type,'Value');

saveList;

close(leda2.gui.export.fig_pl)



function saveList
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
            [minL, maxL] = get_peaks(driver, 1);
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
    if isempty(scr_idx)   %JG17.09.2012 Warnung eingefügt, Zusammenhang siehe andere Änderungen JG17.09.2012 bei Excel-Export
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
if isempty(scr_ttpidx)   %JG17.09.2012 Warnung eingefügt, Zusammenhang siehe andere Änderungen JG17.09.2012 bei Excel-Export
    add2log(1,['SCR-List export for ',leda2.file.filename,': No SCRs detected (method TTP)!'], 1,1,1,1,0,1);
end
scrList.TTP.onset = onset_ttp(scr_ttpidx);
scrList.TTP.amp = amp_ttp(scr_ttpidx);



%% Export
%%%%%%%%%
savefname = [leda2.file.filename(1:end-4), '_scrlist'];

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
        if ~isempty(scr_ttpidx)   %JG17.09.2012 eingefügt, damit xlswrite nicht aufgrund von empty data mit Fehler abbricht, was zu Meldung "ERROR!" im Batchmode führte
            xlswrite(savefname, [scrList.TTP.onset', scrList.TTP.amp'], 'TTP', 'A2');
        end
    else
        if strcmp(leda2.analysis.method,'sdeco')
            xlswrite(savefname, {'CDA.SCR-Onset','CDA.SCR-Amplitude'}, 'CDA', 'A1');
            if ~isempty(scr_idx)   %JG17.09.2012 eingefügt, damit xlswrite nicht aufgrund von empty data mit Fehler abbricht, was zu Meldung "ERROR!" im Batchmode führte
                xlswrite(savefname, [scrList.CDA.onset', scrList.CDA.amp'], 'CDA', 'A2');
            end
            xlswrite(savefname, {'TTP.SCR-Onset','TTP.SCR-Amplitude'}, 'TTP', 'A1')
            if ~isempty(scr_ttpidx)   %JG17.09.2012 eingefügt, damit xlswrite nicht aufgrund von empty data mit Fehler abbricht, was zu Meldung "ERROR!" im Batchmode führte
                xlswrite(savefname, [scrList.TTP.onset', scrList.TTP.amp'], 'TTP', 'A2');
            end
            
        elseif strcmp(leda2.analysis.method,'nndeco')
            xlswrite(savefname, {'DDA.SCR-Onset','DDA.SCR-Amplitude'}, 'DDA', 'A1');
            if ~isempty(scr_idx)   %JG17.09.2012 eingefügt, damit xlswrite nicht aufgrund von empty data mit Fehler abbricht, was zu Meldung "ERROR!" im Batchmode führte
                xlswrite(savefname, [scrList.DDA.onset', scrList.DDA.amp'], 'DDA', 'A2');
            end
            xlswrite(savefname, {'TTP.SCR-Onset','TTP.SCR-Amplitude'}, 'TTP', 'A1')
            if ~isempty(scr_ttpidx)   %JG17.09.2012 eingefügt, damit xlswrite nicht aufgrund von empty data mit Fehler abbricht, was zu Meldung "ERROR!" im Batchmode führte
                xlswrite(savefname, [scrList.TTP.onset', scrList.TTP.amp'], 'TTP', 'A2');
            end
            
        end
        
    end
end

add2log(1,['SCR-List exported to ',savefname], 1,1,1,0,0,1);
