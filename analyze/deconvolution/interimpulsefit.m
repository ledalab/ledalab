function  targetdata_min = interimpulsefit(driver, t_ext, minL, maxL)  %[tonic, pp, groundtime, groundlevel, targetdata_min, iif_t, iif_data, groundlevel0]
global leda2

t = leda2.analysis0.target.t;
d = leda2.analysis0.target.d;
sr = leda2.analysis0.target.sr;
tonicGridSize = leda2.set.tonicGridSize;


%Get inter-impulse-data
iif_idx = [];
if length(maxL) > 2
    for i = 2: length(maxL)-1
        gap_idx = minL(i,2)+1:minL(i+1,1);  %+1: removed otherwise no inter-impulse points may be available at highly smoothed data
        iif_idx = [iif_idx, gap_idx];
    end
    iif_idx = [minL(2,1), iif_idx, minL(end,2):length(driver)-round(sr)]; %JG 26.10.2012: round() added

else  %no peaks (exept for pre-peak and may last peak) so data represents tonic only, so ise all data for tonic estimation
    iif_idx = find(t_ext > 0);
end

iif_t = t_ext(iif_idx);
iif_data = driver(iif_idx);


%Compute tonic points and level
if leda2.set.tonicIsConst %const
    groundtime = t(end)/2;
    groundlevel = mean(iif_data);
    pp.coefs = groundlevel;
    tonic = groundlevel * ones(size(d));
    groundlevel_pre = groundlevel;

    ddd = min(d - tonic) - leda2.set.dist0_min;
    if ddd < 0
        groundlevel = groundlevel + ddd;
        pp.coefs = groundlevel;
        tonic = groundlevel * ones(size(d));
    end

else
    groundtime = [0:tonicGridSize:t(end-1), t(end)];
    if groundtime(end) - groundtime(end-1) < tonicGridSize && length(groundtime) > 2  %adjust last but one groundtime
        groundtime(end-1) = (groundtime(end-2) + groundtime(end))/2;
    end
    for i = 1:length(groundtime)
        %Select relevant interimpulse time points for tonic estimate at groundtime
        if i == 1
            t_idx = iif_t <= groundtime(i) + tonicGridSize & iif_t > 1;
            grid_idx = t_ext <= groundtime(i) + tonicGridSize & t_ext > 1;
        elseif i == length(groundtime)
            t_idx = iif_t > groundtime(i) - tonicGridSize & iif_t < t(end) - 1;
            grid_idx = t_ext > groundtime(i) - tonicGridSize & t_ext < t(end) - 1;
        else
            t_idx = iif_t > groundtime(i) - tonicGridSize/2 & iif_t <= groundtime(i) + tonicGridSize/2;
            grid_idx = t_ext > groundtime(i) - tonicGridSize/2 & t_ext <= groundtime(i) + tonicGridSize/2;
        end
        %Estimate groundlevel at groundtime
        if length(find(t_idx)) > 2
            p = polyfit(iif_t(t_idx), iif_data(t_idx),1);
            if 0%abs(p(1)) < .1  %polyval usually is better, but if it produces unreasonable results its replaced by median  %abs(p(2)) < .5
                groundlevel(i) = polyval(p, groundtime(i));
            else
                groundlevel(i) = median(iif_data(t_idx));
            end
        else  %if inter-impulses, data may reflect pure tonic so just take median of data
            groundlevel(i) = median(driver(grid_idx));
        end
    end
    groundlevel_pre = groundlevel;


    %Correction of (too fast) increasing tonic level
    if leda2.set.tonicSlowIncrease
        for i = 2:length(groundtime)
            if groundlevel(i) > groundlevel(i-1)
                groundlevel(i) = mean(groundlevel(i-1:i));
            end
        end
    end
    groundlevel_pre1 = groundlevel;
    tonic = spline(groundtime, groundlevel, t);
    pp = spline(groundtime, groundlevel);


    %Correction for tonic sections still higher than raw data
    for i = 1:length(groundtime)-1

        t_idx = subrange_idx(t, groundtime(i), groundtime(i+1));
        ddd = min(d(t_idx) - tonic(t_idx)) - leda2.set.dist0_min;

        if ddd < 0
            groundlevel(i) = groundlevel(i) + ddd;
            groundlevel(i+1) = groundlevel(i+1) + ddd;
            %Correction of (too fast) increasing tonic level
            if leda2.set.tonicSlowIncrease
                for j = 2:length(groundtime)
                    if groundlevel(j) > groundlevel(j-1)
                        groundlevel(j) = mean(groundlevel(j-1:j));
                    end
                end
            end
            tonic = spline(groundtime, groundlevel, t);
        end

    end
    pp = spline(groundtime, groundlevel);
end

%Rereferencing: tonic = tonic + targetdata_min
targetdata_min = min(d - tonic);
if targetdata_min <= 0  %necessary!
    targetdata_min = leda2.set.dist0_min;
end
pp.coefs(:,end) = pp.coefs(:,end) + targetdata_min;
groundlevel = groundlevel + targetdata_min;

if leda2.set.tonicIsConst
    tonic = groundlevel * ones(size(d));
else
    tonic = ppval(pp, t);
end

tonic(tonic < 0) = 0;
d = d - tonic;

%Save to vars
leda2.analysis0.target.d0 = d; %d0 = d - (tonic + targetdata_min),  min(d0) == 0;
leda2.analysis0.target.tonic0 = tonic;
leda2.analysis0.target.tonic0_poly = pp;
leda2.analysis0.target.groundtime = groundtime;
leda2.analysis0.target.groundlevel0 = groundlevel;
leda2.analysis0.target.groundlevel_pre = groundlevel_pre;

leda2.analysis0.target.iif_t = iif_t;
leda2.analysis0.target.iif_data = iif_data;
