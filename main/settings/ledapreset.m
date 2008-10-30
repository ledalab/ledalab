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
leda2.analyze.initialvalues = [];
leda2.analyze.initialsolution = [];
leda2.analyze.epoch = [];
leda2.analyze.fit = [];
leda2.analyze.history = [];
leda2.analyze.current.optimizing = 0;
leda2.analyze.current.optimizing_epoch = 0;
leda2.analyze.current.manualedit = 0;
leda2.analyze.current.iEpoch = 0;
leda2.analyze.current.iParset = 0;

leda2.gui.overview.driver = [];
leda2.gui.overview.tonic_component = [];
leda2.gui.overview.phasic = [];

leda2.analysis = [];

%Default Setting:

%LEDASET
%general
leda2.set.templateL = {'Bateman'; 'Bateman x Gauss'};
leda2.set.template = 2;
leda2.set.tonicGridSize = 12;
% get peaks
leda2.set.initVal.hannWinWidth = .5;
leda2.set.initVal.signHeight = .01;
leda2.set.initVal.groundInterp = 'spline'; %'pchip' keeps only S(x)' continuous
% get initial solution
leda2.set.initSol.compensateUnderestimOnset = 1;
leda2.set.initSol.compensateUnderestimAmp = 1;
%setup epochs
leda2.set.epoch.size = 12; %sec
leda2.set.epoch.leftFringe = 4; %additional area relative to epochsize where goodness of fit is calculated
leda2.set.epoch.rightFringe = 4; 
leda2.set.epoch.overlap = 2;
leda2.set.epoch.core = leda2.set.epoch.size - leda2.set.epoch.overlap;
leda2.set.errorType = 'RMSE'; %not settable so far
%initialize parset
leda2.set.parset.smallPeakThresh = .2;
leda2.set.parset.maxParsets = 2^4;
parset_tmp = [];
parset_tmp.id = 0;
parset_tmp.onset = [];
parset_tmp.amp = [];
parset_tmp.tau = [.3; 6];
parset_tmp.sigma = 1/4;
parset_tmp.groundtime = [];
parset_tmp.groundlevel = [];
parset_tmp.error = [];
parset_tmp.df = [];
parset_tmp.iteration = 0;
parset_tmp.h = .2;
parset_tmp.alive = 1;
parset_tmp.history.x = [];
parset_tmp.history.direction = [];
parset_tmp.history.step = 0;
parset_tmp.history.h = parset_tmp.h;
parset_tmp.history.error = [];
leda2.set.parset.tmp = parset_tmp;
%optimize
leda2.set.errorThresholdFac = 10;%1.35;
leda2.set.hThreshold = .0005;
leda2.set.optimizeOnset = 1;
leda2.set.optimizeAmp = 1;
leda2.set.optimizeSigma = 1;
leda2.set.optimizeTau = 0;
leda2.set.optimizeGround = 0;
leda2.set.ampMin = .001;
leda2.set.ampMax = 15;
leda2.set.tauMin = 0; %.1
leda2.set.tauMax = 160;
leda2.set.tauMinDiff = .001;
leda2.set.tauBinding = 0;
leda2.set.sigmaMin = .001;
leda2.set.sigmaMax = .8; % 1: 1SD = 1sec
leda2.set.dist0_min = .001;
%leda2.set.downsampleType
%Export (ERA)
leda2.set.export.SCRstart = 1.00; %sec
leda2.set.export.SCRend   = 3.00; %sec
leda2.set.export.SCRmin   = .02; %muS
leda2.set.export.savetype = 1;
%Artifact
leda2.set.artifact.ckk_thresh = .25;

%Ledapref
leda2.pref.showSmoothData = 0;
leda2.pref.showMinMax = 0;
leda2.pref.showOvershoot = 0;
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
