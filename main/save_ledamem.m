function save_ledamem
global leda2

prevfile = leda2.intern.prevfile;
save(fullfile(leda2.intern.install_dir,'leda2_mem.mat'),'prevfile');
