function refresh_epochinfo
global leda2

if leda2.intern.batchmode
    return;
end

if isempty(leda2.analyze.fit)
    set(leda2.gui.epochinfo.list_scr,'String', 'No Fit available');
    set(leda2.gui.epochinfo.list_tonic,'String', 'No Fit available');
return;
end


epoch = leda2.analyze.epoch(leda2.analyze.current.iEpoch);
parset = epoch.parset(epoch.bestparset);

scr_str = {};
for i = 1:length(parset.onset)
    scr_str(i) = {[sprintf('%6.2f',parset.onset(i)),' s:  amp =  ',num2str(parset.amp(i),'%4.3f'),' muS,  tau = ',sprintf('%3.1f',parset.tau(1,i)),', ',sprintf('%3.1f',parset.tau(2,i)),',  s = ',sprintf('%1.3f',parset.sigma(i))]};
end
set(leda2.gui.epochinfo.list_scr,'String', scr_str);

tonic_str = {};
for i = 1:length(parset.groundtime)
    tonic_str(i) = {[sprintf('%6.2f',parset.groundtime(i)),' s:  level =  ',num2str(parset.groundlevel(i),'%4.3f'),' muS']};
end
set(leda2.gui.epochinfo.list_tonic,'String', tonic_str);


if leda2.analyze.current.manualedit
    if isempty(parset.onset)
        set(leda2.gui.manualedit.butt_change,'Enable','off');
        set(leda2.gui.manualedit.butt_del,'Enable','off');
    else
        set(leda2.gui.manualedit.butt_change,'Enable','on');
        set(leda2.gui.manualedit.butt_del,'Enable','on');
    end
    if isempty(parset.groundtime)
        set(leda2.gui.manualedit.butt_tpchange,'Enable','off');
        set(leda2.gui.manualedit.butt_tpdel,'Enable','off');
    else
        set(leda2.gui.manualedit.butt_tpchange,'Enable','on');
        set(leda2.gui.manualedit.butt_tpdel,'Enable','on');
    end
end
