function ps = powerset(v)

n = length(v);
ps = {};

for i = 1:n
    
    s = nchoosek(v,i);
    
    for j = 1:size(s,1)
        
        ps = [ps; {s(j,:)}];
        
    end
    
end
