function [segmOnset, segmImpulse, segmOversh, impMin, impMax] = segment_driver(data, remd, sigc, segmWidth)

segmOnset = [];
segmImpulse = {};
segmOversh = {};
impMin = [];
impMax = [];

[cccrimin, cccrimax] = get_peaks(data);
if isempty(cccrimax)
    return
end

%sigc = max(data(cccrimax(2:end)))/100;  %relative criterium for sigc
[minL, maxL] = signpeak(data, cccrimin, cccrimax, sigc);
%for i = 1:length(cccrimax);
%s(i) = sum(data(cccrimin(i):cccrimin(i+1))) * dt;  %area of possible segment
%maximum difference of min-max or max-min
%end
%maxL = cccrimax(data(cccrimax) - data(cccrimin(1:end-1)) > sigc);
%maxL = cccrimax(s > sigc);


[rmdimin, rmdimax] = get_peaks(remd);%get peaks of remainder
[rmdimins, rmdimaxs] = signpeak(remd, rmdimin, rmdimax, .005); %get remainder segments

%Segments: 12 sec, max 3 sec preceding maximum
for i = 1:length(maxL)
    segm_start = max(minL(i,1), maxL(i) - round(segmWidth/2));
    segm_end   = min(segm_start + segmWidth - 1, length(data));

    %impulse
    segm_idx = segm_start:segm_end;
    segm_data = data(segm_idx);
    segm_data(segm_idx >= minL(i,2)) = 0;
    segmOnset(i) = segm_start;
    segmImpulse(i) = {segm_data};

    %overshoot
    oversh_data = zeros(size(segm_idx));
    if i < length(maxL)
        rmi = find(rmdimaxs > maxL(i) & rmdimaxs < maxL(i+1));
    else
        rmi = find(rmdimaxs > maxL(i));
    end
    %no zero overshoots
    if isempty(rmi)
        if i < length(maxL)
            rmi = find(rmdimax > maxL(i) & rmdimax < maxL(i+1));
        else
            rmi = find(rmdimax > maxL(i));
        end
        rmdimaxs = rmdimax;
        rmdimins = [rmdimin(1:end-1)',rmdimin(2:end)'];
    end

    if ~isempty(rmi)
        rmi = rmi(1);
        oversh_start = max(rmdimins(rmi,1), segm_start);
        oversh_end = min(rmdimins(rmi,2), segm_end); %min(rmdimins(rmi+1), segm_end);
        oversh_data((oversh_start - segm_start + 1) : end - (segm_end - oversh_end)) = remd(oversh_start:oversh_end);
    end
    %     %     if mean(oversh_data) < 2*leda2.data.conductance_error
    %     %         oversh_data = zeros(size(segm_idx));
    %     %     end

    %     oversh_data = remd(segm_idx);
    %     oversh_data(segm_idx < maxL(i)) = 0;
    %     if i < length(maxL)
    %         oversh_data(segm_idx >= maxL(i+1)) = 0;
    %     end
    %
    segmOversh(i) = {oversh_data};
end

impMin = minL;
impMax = maxL;


function [minL, maxL] = signpeak(data, cccrimin, cccrimax, sigc)

minL = [];
maxL = [];
if isempty(cccrimax)
    return;
end

dmm = [data(cccrimax) - data(cccrimin(1:end-1)); data(cccrimax) - data(cccrimin(2:end))];
maxL = cccrimax(max(dmm) > sigc);

%keep only minima right before and after sign maxima
minL = [];
for i = 1:length(maxL)
    minm1_idx = find(cccrimin < maxL(i));
    before_smpl = cccrimin(minm1_idx(end));
    after_smpl  = cccrimin(minm1_idx(end)+1);
    minL = [minL; [before_smpl, after_smpl]];
end
