function showfit(start, ende)
global leda2

if isempty(leda2.analyze.fit)
    return;
end

if nargin == 0
    start = leda2.gui.rangeview.start;
    ende = leda2.gui.rangeview.start + leda2.gui.rangeview.range;
end
fit = leda2.analyze.fit;

axes(leda2.gui.rangeview.ax);

%clear all plotted fit-components
ch = get(leda2.gui.rangeview.ax,'Children');
delete(ch(strcmp(get(ch,'Tag'),'FitComp')));

idx = find((fit.phasiccoef.onset > (start - 30)) & ([fit.phasiccoef.onset] < ende));
nPhasics = length(idx);

[ts, cs, t_idx] = subrange(start-.5, ende+.5);
x = [ts ts(end) ts(1)];

%tonic
y_tonic = [fit.data.tonic(t_idx) 0 0];
leda2.gui.rangeview.tonic_component = fill(x, y_tonic, [.5 .5 .5], 'linestyle', 'none');

%phasic
for iPhasic = idx
    if mod(iPhasic, 2) == 1 %odd number
        col = [.3 .5 .7]; %[.0 .4 .6];
    else
        col = [.3 .6 .8]; %[.0 .5 .7];
    end
    
    y_phasic = fit.data.phasicRemainder{iPhasic} + fit.data.phasicComponent{iPhasic};
    if iPhasic+1 <= length(fit.phasiccoef.onset); %update following remainders, which may be more than updated by update_fit
        fit.data.phasicRemainder{iPhasic+1} = y_phasic;
    end
    y_phasic = [y_phasic(t_idx) 0 0];
    phasic = fill(x, [y_tonic + y_phasic], col, 'linestyle', 'none');
    
end

kids = get(leda2.gui.rangeview.ax, 'Children');
fitcomps = kids(1:nPhasics + 1);
set(fitcomps,'Tag','FitComp');
set(leda2.gui.rangeview.ax, 'Children',[kids((nPhasics+2):end); fitcomps(end:-1:1)]);

drawnow;
