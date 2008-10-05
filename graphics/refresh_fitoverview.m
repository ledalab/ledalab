function refresh_fitoverview
global leda2

if isempty(leda2.analyze.fit) || leda2.intern.batchmode
    return;
end

axes(leda2.gui.overview.ax);

if isempty(leda2.gui.overview.residual) %setup

    x = [leda2.data.time.data leda2.data.time.data(end) leda2.data.time.data(1)];

    %residual
    residual_p = log(1 + leda2.analyze.fit.data.residual.^2 * 100);
    residual_psc = leda2.gui.overview.min + residual_p * (leda2.gui.overview.max-leda2.gui.overview.min)/4; %scale residual
    leda2.gui.overview.residual = plot(leda2.data.time.data, residual_psc, 'Color', [.9 .9 .0]);

    %tonic
    leda2.gui.overview.tonic_component = fill(x, [leda2.analyze.fit.data.tonic 0 0], [.5 .5 .5], 'linestyle', 'none');

    %phasic
    y = (leda2.analyze.fit.data.tonic+leda2.analyze.fit.data.phasic);
    leda2.gui.overview.phasic = fill(x, [y 0 0], [.0 .5 .7], 'linestyle', 'none'); %[.7 .7 .9]

    n = 3;
    kids = get(leda2.gui.overview.ax, 'Children');
    fitcomps = kids(1:n);
    set(fitcomps,'Tag','FitComp');
    set(leda2.gui.overview.ax, 'Children',[kids((n+1):end); fitcomps(n:-1:1)]);

else %refresh


    set(leda2.gui.overview.tonic_component, 'YData', [leda2.analyze.fit.data.tonic 0 0]);

    y = (leda2.analyze.fit.data.tonic+leda2.analyze.fit.data.phasic);
    set(leda2.gui.overview.phasic, 'YData', [y 0 0]);
    
    residual_p = log(1 + leda2.analyze.fit.data.residual.^2 * 100);
    residual_psc = leda2.gui.overview.min + residual_p * (leda2.gui.overview.max-leda2.gui.overview.min)/4; %scale residual
    set(leda2.gui.overview.residual, 'YData', residual_psc);

end
