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
leda2.set.tau0 = [.75 20];

%SDECO
leda2.set.tonicGridSize_sdeco = 10;
leda2.set.tau0_sdeco = [.75 2];
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
% %leda2.set.downsampleType
% %Export (ERA)
leda2.set.export.SCRstart = 1.00; %sec
leda2.set.export.SCRend   = 3.00; %sec
leda2.set.export.SCRmin   = .02; %muS
leda2.set.export.savetype = 1;
% %Artifact
% leda2.set.artifact.ckk_thresh = .25;

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
    load(fullfile(leda2.intern.install_dir,'main\settings\ledamem.mat'));
    leda2.intern.prevfile = ledamem.prevfile; %#ok<NODEF>
catch
    add2log(0,'No ledamem available',1)
end

%saving the default settings may replace an unavailble ledamem, if necessary
ledamem.prevfile = leda2.intern.prevfile;
ledamem.set.default = leda2.set;
ledamem.pref.default = leda2.pref;
save(fullfile(leda2.intern.install_dir,'main\settings\ledamem'), 'ledamem','-v6')


%Apply custom settings if available
if any(strcmp(fieldnames(ledamem.set),'custom')) && ~isempty(ledamem.set.custom)
    leda2.set = ledamem.set.custom;
    %disp('Custom settings loaded.')
end
if any(strcmp(fieldnames(ledamem.pref),'custom')) && ~isempty(ledamem.pref.custom)
    leda2.pref = ledamem.pref.custom;
    %disp('Custom preferences loaded.')
end
