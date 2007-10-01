function Ledalab

clc;
close all;
clear global leda2

global leda2
ledapreset;

if 1
    ledalogo;
    pause(1);
    delete(leda2.gui.fig_logo);
end

ledagui;

add2log(0,['>>>> ',datestr(now,31), ' Session started'],1,1);
