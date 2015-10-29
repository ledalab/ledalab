function snz = succnz(data, crit, fac, sr)
% succnz calculates an index of how many successive values are
% above the parameter crit as described in section 4.3 of
% Benedek, M. & Kaernbach, C. (2010). A continuous measure of phasic
% electrodermal activity. J. Neurosci. Methods, 190, 80–91.

n = length(data);

abovecrit = abs(data) > crit;
nzidx = find(diff(abovecrit)) + 1;

if isempty(nzidx)
    snz = 0;
    return
end

% if the sequence begins with a value above crit prepend 1
if abovecrit(1) == 1
    nzidx = [1 nzidx];
end
% if the sequence ends with a value above crit append the length
if abovecrit(end) == 1
    nzidx = [nzidx n+1];
end

% now nzidx contains every position where data rises above crit (odd
% indices) or dips below crit (even indices).
% The lengths of spans above crit is the difference between the start index
% and the end index
nzL = nzidx(2:2:end) - nzidx(1:2:end);

snz = sum((nzL/sr).^fac)/(n/sr);
