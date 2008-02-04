function Ledalab

clc;
close all;
clear global leda2

global leda2

leda2.intern.name = 'Ledalab';
leda2.intern.version = 2.12;
leda2.intern.version_datestr = '2008-02-05';

%Add all subdirectories to Matlab path
file = which('Ledalab.m');
if isempty(file)
    errormessage('Can''t find Ledalab installation. Change to Ledalab install directory');
    return;
end
leda2.intern.install_dir = fileparts(file);
addpath(genpath(leda2.intern.install_dir));  

ledapreset;

if 1
    ledalogo;
    pause(1);
    delete(leda2.gui.fig_logo);
end

ledagui;

add2log(0,['>>>> ',datestr(now,31), ' Session started'],1,1);
