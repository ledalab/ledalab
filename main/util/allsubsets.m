function [subsets, idx] = allsubsets(input_list)
%[subsets, idx] = ALLSUBSETS(input_list)
%
%get a cellarray of all possible subsets of the input_list
%as well as an cellarray containing the corresponding index

list_n = length(input_list);
idx_ref = 1:list_n;

idx(1) = {[]};
cntr = 1;

for i = 1:list_n
    
    ssi = nchoosek(idx_ref,i);
    ssi_n = size(nchoosek(idx_ref,i),1);
    
    for j = 1:ssi_n
        
        cntr = cntr + 1;
        idx(cntr) = {ssi(j,:)};
    end
end

for s = 1:2^list_n
    subsets(s) = {input_list(idx{s})};
end
