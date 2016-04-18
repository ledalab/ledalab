function Ledalab(varargin)

clc;
close all;
clear global leda2

global leda2

leda2.intern.name = 'Ledalab';
leda2.intern.version = 3.49;
versiontxt = num2str(leda2.intern.version,'%3.2f');
leda2.intern.versiontxt = ['V',versiontxt(1:3),'.',versiontxt(4:end)];
leda2.intern.version_datestr = '2016-04-18';

%Add all subdirectories to Matlab path
file = which('Ledalab.m');
if isempty(file)
    errormessage('Can''t find Ledalab installation. Change to Ledalab install directory');
    return;
end
leda2.intern.install_dir = fileparts(file);
addpath(genpath(leda2.intern.install_dir));

ledapreset;


if nargin > 0
    %Batch-Mode
    leda2.intern.batchmode = 1;
    leda2.intern.prompt = 0;
    leda2.pref.updateFit = 0;
    leda_batchanalysis(varargin{:});

else
    leda2.intern.batchmode = 0;
    
    ledalogo;
    pause(1);
    delete(leda2.gui.fig_logo);

    ledagui;

    add2log(0,['>>>> ',datestr(now,31), ' Session started'],1,1);
end
