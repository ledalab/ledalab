function save_ledamem
global leda2

%get available ledamem data
try
    load(fullfile(leda2.intern.install_dir,'main','settings','ledamem.mat'));
catch
    add2log(0,'No ledamem available',1)
end

ledamem.prevfile = leda2.intern.prevfile;
ledamem.set.custom = leda2.set;
ledamem.pref.custom = leda2.pref;

save(fullfile(leda2.intern.install_dir,'main','settings','ledamem'), 'ledamem','-v6')
