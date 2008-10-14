function snz = succnz(data, crit, fac)

nzL = [];
cntr = 0;
n = length(data);

for i = 1:n
    if data(i) > crit
        cntr = cntr + 1;
    else
        if cntr > 0
            nzL = [nzL, cntr];
            cntr = 0;
        end
    end

end

if cntr > 0
    nzL = [nzL, cntr];
end

if ~isempty(nzL)
    snz = sum(nzL.^fac)/n;
else
    snz = 0;
end
