fs = dir('*.mat');

a = zeros(numel(fs), 1);
f = zeros(numel(fs), 1);
d = zeros(numel(fs), 1);

for i = 1:numel(fs)
    load(fs(i).name);
    a(i) = exist('analysis', 'var');
    f(i) = exist('fileinfo', 'var');
    d(i) = exist('data', 'var');
    fprintf('\n%s = anal: %d; finf: %d; data: %d', fs(i).name, a(i), f(i), d(i))
    clear analysis fileinfo data        
end
