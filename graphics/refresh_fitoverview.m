function refresh_fitoverview
global leda2

if isempty(leda2.analysis) || leda2.intern.batchmode
    return;
end


if isempty(leda2.gui.overview.driver) %setup
    axes(leda2.gui.overview.ax);

    x = [leda2.data.time.data leda2.data.time.data(end) leda2.data.time.data(1)];
    unextended_idx = length(leda2.analysis.time_ext)+1:length(leda2.analysis.driver);

    %overshoot
    overshoot = leda2.analysis.remainder(unextended_idx);
    overshoot_sc = leda2.gui.overview.min + overshoot / max(overshoot) * (leda2.gui.overview.max-leda2.gui.overview.min)/15;
    leda2.gui.overview.overshoot = fill(x, [overshoot_sc, 0, 0], [.8 .4 .4], 'linestyle', 'none','ButtonDownFcn','leda_click(1)');
    %driver
    driver = leda2.analysis.driver(unextended_idx);  %cut
    driver_sc = leda2.gui.overview.min + driver / max(driver) * (leda2.gui.overview.max-leda2.gui.overview.min)/2;
    leda2.gui.overview.driver = fill(x, [driver_sc, 0, 0], [.5 .7 .9], 'linestyle', 'none','ButtonDownFcn','leda_click(1)');

    %tonic
    leda2.gui.overview.tonic_component = fill(x, [leda2.analysis.tonicData 0 0], [.5 .5 .5], 'linestyle', 'none','ButtonDownFcn','leda_click(1)');

    %phasic
    y = leda2.analysis.tonicData + leda2.analysis.phasicData;
    leda2.gui.overview.phasic = fill(x, [y 0 0], [.0 .5 .7], 'linestyle', 'none','ButtonDownFcn','leda_click(1)');

    n = 4;
    kids = get(leda2.gui.overview.ax, 'Children');
    fitcomps = kids(1:n);
    set(fitcomps,'Tag','FitComp');
    set(leda2.gui.overview.ax, 'Children',[kids((n+1):end); fitcomps(n:-1:1)]);
    set(gca,'XLim', [leda2.data.time.data(1), leda2.data.time.data(end)]);
    
    
else %refresh
    axes(leda2.gui.overview.ax);

    set(leda2.gui.overview.tonic_component, 'YData', [leda2.analysis.tonicData 0 0]);

    y = leda2.analysis.tonicData + leda2.analysis.phasicData;
    set(leda2.gui.overview.phasic, 'YData', [y 0 0]);

    unextended_idx = length(leda2.analysis.time_ext)+1:length(leda2.analysis.driver);
    driver = leda2.analysis.driver(unextended_idx);
    driver_sc = leda2.gui.overview.min + driver / max(driver) * (leda2.gui.overview.max-leda2.gui.overview.min)/2;
    set(leda2.gui.overview.driver, 'YData', [driver_sc, 0, 0]);
    overshoot = leda2.analysis.remainder(unextended_idx);
    overshoot_sc = leda2.gui.overview.min + overshoot / max(overshoot) * (leda2.gui.overview.max-leda2.gui.overview.min)/10;
    set(leda2.gui.overview.overshoot, 'YData', [overshoot_sc, 0, 0]);

end
