function save_ledamem
global leda2

ledamem.prevfile = leda2.intern.prevfile;
ledamem.set.custom = leda2.set;
ledamem.pref.custom = leda2.pref;

save(fullfile(leda2.intern.install_dir,'main\settings\ledamem'), 'ledamem','-v6')
