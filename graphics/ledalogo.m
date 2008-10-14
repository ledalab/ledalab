function ledalogo
global leda2

screen = get(0,'screensize');
swidth  = screen(3);
sheight = screen(4);

im = imread('ledalogo.jpg');
iwidth  = size(im,2);
iheight = size(im,1);

pos = [(swidth-iwidth)/2 (sheight-iheight)/2 iwidth iheight];

leda2.gui.fig_logo = figure('visible','on','menubar','none','paperpositionmode','auto','numbertitle','off','resize','off','position',pos,'name',['About ',leda2.intern.name]);

image(im);
set(gca,'visible','off','Position',[0 0 1 1]);

text(30,90, [leda2.intern.versiontxt,'  (',leda2.intern.version_datestr,')'],'units','pixel','horizontalalignment','left','fontsize',14,'color',[.1 .1 .1]);
text(30,70, 'Code by Mathias Benedek & Christian Kaernbach','units','pixel','horizontalalignment','left','fontsize',8,'color',[.1 .1 .1]);
