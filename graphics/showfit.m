function showfit(start, ende)
global leda2

if leda2.intern.batchmode || isempty(leda2.analysis)
    return;
end

if nargin == 0
    start = leda2.gui.rangeview.start;
    ende = leda2.gui.rangeview.start + leda2.gui.rangeview.range;
end
analysis = leda2.analysis;
N = length(analysis.phasicData);
N_ext = length(analysis.driver);

axes(leda2.gui.rangeview.ax);

%clear all plotted fit-components
ch = get(leda2.gui.rangeview.ax,'Children');
delete(ch(strcmp(get(ch,'Tag'),'FitComp')));

idx = find((analysis.onset > (start - 60)) & ([analysis.onset] < ende));
nPhasics = length(idx);

[ts, cs, t_idx] = subrange(start-.5, ende+.5);
x = [ts ts(end) ts(1)];

%tonic
y_tonic = [analysis.tonicData(t_idx) 0 0];
leda2.gui.rangeview.tonic_component = fill(x, y_tonic, [.5 .5 .5], 'linestyle', 'none');

%phasic
for iPhasic = idx
    if mod(iPhasic, 2) == 1 %odd number
        col = [.4 .6 .8];
        col2 = [.8 .6 .8];%[.8 .5 .7];
    else
        col = [.5 .7 .9];
        col2 = [.8 .6 .8];
    end

    if leda2.pref.showOvershoot
        ons_idx = analysis.onset_idx(iPhasic);
        ovs = analysis.overshoot{iPhasic};
        overshoot = zeros(1, N_ext);
        overshoot(ons_idx:ons_idx + length(ovs)-1) = ovs;
        overshoot = overshoot(N_ext-N+1:end);

        y_phasic_ovs = analysis.phasicRemainder{iPhasic} + analysis.phasicComponent{iPhasic};
        %y_phasic_ovs = analysis.phasicRemainder{iPhasic+1};
        y_phasic = y_phasic_ovs - overshoot;

        y_phasic_ovs = [y_phasic_ovs(t_idx) 0 0];
        y_phasic = [y_phasic(t_idx) 0 0];
        fill(x, y_tonic + y_phasic, col, 'linestyle', 'none');
        fill(x, y_tonic + y_phasic_ovs, col2, 'linestyle', 'none');

    else
        y_phasic = analysis.phasicRemainder{iPhasic} + analysis.phasicComponent{iPhasic};
        y_phasic = [y_phasic(t_idx) 0 0];
        fill(x, y_tonic + y_phasic, col, 'linestyle', 'none');

    end

end

kids = get(leda2.gui.rangeview.ax, 'Children');
fitcomps = kids(1:(leda2.pref.showOvershoot+1)*nPhasics + 1);
set(fitcomps,'Tag','FitComp');
set(leda2.gui.rangeview.ax, 'Children',[kids(((leda2.pref.showOvershoot+1)*nPhasics+2):end); fitcomps(end:-1:1)]);


%driver_sc = leda2.analysis.driver(length(leda2.analysis.time_ext)+1 : end);
%driver_sc = leda2.gui.overview + driver_sc / max(leda2.analysis.driver_dirac) * (leda2.gui.rangeview.top-leda2.gui.rangeview.bottom)/10;
%driver_dirac = leda2.analysis.driver_dirac;
%driver_dirac_sc = leda2.gui.rangeview.bottom + driver_dirac(t_idx) / max(driver_dirac) * (leda2.gui.rangeview.top-leda2.gui.rangeview.bottom)/5;
%leda2.gui.rangeview.driver_dirac = plot(ts, stairs(driver_dirac_sc), 'Color', [1 1 0], 'Tag','FitComp');

drawnow;

showdriver;
