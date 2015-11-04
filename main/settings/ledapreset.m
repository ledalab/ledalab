function ledapreset
global leda2


leda2.intern.sessionlog = {};
leda2.intern.prevfile = [];
leda2.intern.prompt = 1;

leda2.gui.rangeview.start = 0;
leda2.gui.rangeview.range = 60;
leda2.gui.rangeview.fit_component = 0;
leda2.gui.eventinfo.showEvent = 0;
leda2.gui.rangeview.fitcomps = [];
leda2.file.open = 0;
leda2.file.filename = '';
leda2.data.events.event = [];
leda2.data.events.N = 0;

leda2.gui.overview.driver = [];
leda2.gui.overview.tonic_component = [];
leda2.gui.overview.phasic = [];

leda2.analysis = [];

% define structure for GUI of leda_split.m
leda2.gui.split = [];


%Default Setting:

%LEDASET
%NNDECO
leda2.set.template = 2;
leda2.set.smoothwin = .2;
leda2.set.tonicGridSize = 60;
leda2.set.sigPeak = .001;
leda2.set.d0Autoupdate = 1;
leda2.set.tonicIsConst = 0;
leda2.set.tonicSlowIncrease = 0;
leda2.set.tau0 = [.50 30];     %see Benedek & Kaernbach, 2010, Psychophysiology

%SDECO
leda2.set.tonicGridSize_sdeco = 10;
leda2.set.tau0_sdeco = [1 3.75];  %see Benedek & Kaernbach, 2010, J Neurosc Meth
leda2.set.d0Autoupdate_sdeco = 0;
leda2.set.smoothwin_sdeco = .2;


% get peaks
leda2.set.initVal.hannWinWidth = .5;
leda2.set.initVal.signHeight = .01;
leda2.set.initVal.groundInterp = 'spline'; %'pchip' keeps only S(x)' continuous
leda2.set.tauMin = .001; %.1
leda2.set.tauMax = 100;
leda2.set.tauMinDiff = .01;
leda2.set.dist0_min = .001;

% %Export (ERA)
leda2.set.export.SCRstart = 1.00; %sec
leda2.set.export.SCRend   = 4.00; %sec
leda2.set.export.SCRmin   = .01; %muS
leda2.set.export.savetype = 1;
leda2.set.export.zscale = 0;


% settings for leda_split.m
leda2.set.split.start = -1;   % sec
leda2.set.split.end = 5;        % sec
leda2.set.split.variables = {'driver','phasicData'}; % possible variables, 2012-03-13 only one by now.
leda2.set.split.var = 1;        % index for VARIABLES
leda2.set.split.stderr = 0;
%leda2.set.split.variable = 'phasicData';
%leda2.set.split.selectedconditions = [];
%leda2.set.split.plot = 1;


%Ledapref
leda2.pref.showSmoothData = 0;
leda2.pref.showMinMax = 0;
leda2.pref.showOvershoot = 1;
%not settable inside of Ledalab
leda2.pref.eventWindow = [5, 15];
leda2.pref.oldfile_maxn = 5;
leda2.pref.scalewidth_min = .6; %muS
leda2.gui.col.fig = [.8 .8 .8];
leda2.gui.col.frame1 = [.85 .85 .85];


%Save defaults
% load ledamem to workspace
try
    load(fullfile(leda2.intern.install_dir,'main','settings','ledamem.mat'));
    leda2.intern.prevfile = ledamem.prevfile; %#ok<NODEF>
catch
    add2log(0,'No ledamem available',1)
end

%saving the default settings may replace an unavailable ledamem, if necessary
ledamem.prevfile = leda2.intern.prevfile;
ledamem.set.default = leda2.set;
ledamem.pref.default = leda2.pref;
save(fullfile(leda2.intern.install_dir,'main','settings','ledamem.mat'), 'ledamem');


%Apply custom settings if available
if isfield(ledamem.set,'custom') && isstruct(ledamem.set.custom)
    leda2.set = mergestructs(ledamem.set.custom, ledamem.set.default);
end
if isfield(ledamem.pref,'custom') && ~isempty(ledamem.pref.custom)
    leda2.pref = mergestructs(ledamem.pref.custom, ledamem.pref.default);
end
end

function old = mergestructs(old,new)
% merges the supplid structs without overwriting contents in the first
    fn = fieldnames(new);
    for i=1:length(fn)
        f = fn{i};
        if ~isfield(old,f)
            old.(f) = new.(f);
        elseif isstruct(old.(f)) && isstruct(new.(f))
            old.(f) = mergestructs(old.(f),new.(f));
        end
    end
end
