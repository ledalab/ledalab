function ledamem = save_ledamem(type)
% type: 'custom' or 'default'
global leda2
% load ledamem to workspace
private_ledamem_path = [prefdir(1) '/ledamem.mat'];
if exist(private_ledamem_path,'file')
    ledamem_path = private_ledamem_path;
    add2log(0,['Using private ledamem.mat in ' prefdir()],1);
else
    ledamem_path = fullfile(leda2.intern.install_dir,'main','settings','ledamem.mat');
end

try
    load(ledamem_path);
    leda2.intern.prevfile = ledamem.prevfile; %#ok<NODEF>
catch
    add2log(0,'No ledamem available',1);
end

%saving the default settings may replace an unavailable ledamem, if necessary
ledamem.prevfile = leda2.intern.prevfile;
ledamem.set.(type) = leda2.set;
ledamem.pref.(type) = leda2.pref;
try
    save(ledamem_path, 'ledamem');
catch % try the per-user preference path
    save(private_ledamem_path, 'ledamem');
end

end