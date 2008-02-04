function d = divisors(a)
%all divisors of a

ps = powerset(factor(a));

for i = 1:length(ps)
    
    d(i) = prod(ps{i});
    
end

d = [1 unique(d)]; %all divisors
d = d(2:end-1); %non trivial divisors
