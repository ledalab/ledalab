function artifact_detect(ckk_thresh)
global leda2

if ~leda2.intern.batchmode
    answer = inputdlg('Artifact Threshold:', '', 1, {num2str(leda2.set.artifact.ckk_thresh)});
    leda2.set.artifact.ckk_thresh = str2double(answer);
end

if nargin == 0
    ckk_thresh = leda2.set.artifact.ckk_thresh;
end


%c = leda2.data.conductance.data;
s = leda2.data.conductance.smoothData;
t = leda2.data.time.data;
sr = leda2.data.samplingrate;

cdd = diff(diff(s));

ckk = ((abs(cdd)/sr^2))*1000000;
ckk = [ckk(1) ckk ckk(end)]; %extended to match data length

idx = find(ckk > ckk_thresh);
leda2.current.artifact_samples = t(idx);


%Graphics
if ~leda2.intern.batchmode
    axes(leda2.gui.overview.ax);
    ch = get(leda2.gui.overview.ax,'Children');
    delete(ch(strcmp(get(ch,'Tag'),'Artifact')));
    plot(t(idx), ones(size(idx))*leda2.gui.overview.max*.95, '*', 'Color',[1 .5 0],'Tag','Artifact')
end
