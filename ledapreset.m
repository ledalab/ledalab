function ledapreset
global leda2

file = which('Ledalab.m');
if isempty(file)
    errormessage('Can''t find Ledalab installation. Change to Ledalab install directory');
    return;
end

leda2.intern.install_dir = fileparts(file);
addpath(genpath(leda2.intern.install_dir));  %add all subdirectories to Matlab path

leda2.intern.sessionlog = {};

try
    mem = load(fullfile(leda2.intern.install_dir,'leda2_mem.mat'));
    leda2.intern.prevfile = mem.prevfile;
    clear mem
catch
    add2log(0,'Failed to load leda2_mem',1,0,0,1)
end

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

leda2.gui.overview.residual = [];
leda2.gui.overview.tonic_component = [];
leda2.gui.overview.phasic = [];

%LEDASET
%general
leda2.set.tonicGridSize = 20;
% get peaks
leda2.set.initVal.hannWinWidth = .5;
leda2.set.initVal.signHeight = .01;
leda2.set.initVal.groundInterp = 'spline'; %'pchip' keeps only S(x)' continuous
% get initial solution
leda2.set.initSol.compensateUnderestimOnset = 1;
leda2.set.initSol.compensateUnderestimAmp = 1;
%setup epochs
leda2.set.epoch.size = 20; %sec
leda2.set.epoch.leftFringe = 2; %additional area relative to epochsize where goodness of fit is calculated
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
parset_tmp.tau = [.5; 10];
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
leda2.set.errorThresholdFac = 1.35;
leda2.set.hThreshold = .0005;
leda2.set.optimizeGround = 1;
leda2.set.ampMin = .02;
leda2.set.ampMax = 10;
leda2.set.tauMin = .1;
leda2.set.tauMax = 20;
leda2.set.tauMinDiff = .001;
leda2.set.tauBinding = 0;


%Ledapref
leda2.pref.showSmoothData = 0;
leda2.pref.showTonicRawData = 0;
leda2.pref.showEpochFringe = 0;
leda2.pref.eventWindow = [5, 15];
leda2.pref.updateFit = 3;
%not settable inside of Ledalab
leda2.pref.oldfile_maxn = 5;
leda2.pref.scalewidth_min = .6; %muS
leda2.gui.col.fig = [.8 .8 .8];
leda2.gui.col.frame1 = [.85 .85 .85];
