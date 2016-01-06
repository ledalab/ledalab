function  [tonicDriver, tonicData] = sdeco_interimpulsefit(driver, kernel, minL, maxL)
global leda2

t = leda2.analysis0.target.t;
d = leda2.analysis0.target.d;
sr = leda2.analysis0.target.sr;
tonicGridSize = leda2.set.tonicGridSize_sdeco;
nKernel = length(kernel);


%Get inter-impulse data index
iif_idx = [];
if length(maxL) > 2
    for i = 1: length(maxL)-1
        gap_idx = minL(i,2):minL(i+1,1); %+1: removed otherwise no inter-impulse points may be available at highly smoothed data
        iif_idx = [iif_idx, gap_idx];
    end
    iif_idx = [minL(2,1), iif_idx, minL(end,2):length(driver)-sr];
else  %no peaks (exept for pre-peak and may last peak) so data represents tonic only, so ise all data for tonic estimation
    iif_idx = find(t > 0);
end
iif_t = t(iif_idx);
iif_data = driver(iif_idx);


groundtime = [0:tonicGridSize:t(end-1), t(end)];

if tonicGridSize < 30
    tonicGridSize = tonicGridSize*2;
end
for i = 1:length(groundtime)
    %Select relevant interimpulse time points for tonic estimate at groundtime
    if i == 1
        t_idx = iif_t <= groundtime(i) + tonicGridSize & iif_t > 1;
        grid_idx = t <= groundtime(i) + tonicGridSize & t > 1;
    elseif i == length(groundtime)
        t_idx = iif_t > groundtime(i) - tonicGridSize & iif_t < t(end) - 1;
        grid_idx = t > groundtime(i) - tonicGridSize & t < t(end) - 1;
    else
        t_idx = iif_t > groundtime(i) - tonicGridSize/2 & iif_t <= groundtime(i) + tonicGridSize/2;
        grid_idx = t > groundtime(i) - tonicGridSize/2 & t <= groundtime(i) + tonicGridSize/2;
    end
    %Estimate groundlevel at groundtime
    if length(find(t_idx)) > 2
        groundlevel(i) = min(mean(iif_data(t_idx)),  d(time_idx(t, groundtime(i))));
    else  %if no inter-impulses data is available ...
        groundlevel(i) = min(median(driver(grid_idx)),  d(time_idx(t, groundtime(i))));
    end
end

tonicDriver = pchip(groundtime, groundlevel, t);
groundtime_pre = groundtime;
groundlevel_pre = groundlevel;
tonicDriver_pre = tonicDriver;

tonicData = conv([tonicDriver(1)*ones(1,nKernel), tonicDriver], kernel);
tonicData = tonicData(nKernel:length(tonicData)-nKernel);
tonicData_pre = tonicData;



%Correction for tonic sections still higher than raw data
% Move closest groundtime at time of maximum difference of tonic surpassing data
for i = (length(groundtime)-1):-1:1

    t_idx = subrange_idx(t, groundtime(i), groundtime(i+1));
    [ddd, idx] = max((tonicData(t_idx) + leda2.set.dist0_min) - d(t_idx));

    if ddd > eps
        %Move closest groundtime to maxmimum difference position and level
%         if idx < length(t_idx)/2
%             groundtime(i) = t(t_idx(idx));
%             groundlevel(i) = tonicDriver(t_idx(idx)) - ddd*2;  %*2 because driver changes results in postponed data change
%         else
%             groundtime(i+1) = t(t_idx(idx));
%             groundlevel(i+1) = tonicDriver(t_idx(idx)) - ddd*2;
%         end
        groundlevel(i) = groundlevel(i) - ddd;
        groundlevel(i+1) = groundlevel(i+1) - ddd;

        tonicDriver = pchip(groundtime, groundlevel, t);
        tonicData = conv([tonicDriver(1)*ones(1,nKernel), tonicDriver], kernel);
        tonicData = tonicData(nKernel:length(tonicData)-nKernel);

    end

end
pp = pchip(groundtime, groundlevel);



%Save to vars
leda2.analysis0.target.poly = pp;
leda2.analysis0.target.groundtime = groundtime;
leda2.analysis0.target.groundlevel = groundlevel;
leda2.analysis0.target.groundlevel_pre = groundlevel_pre;

leda2.analysis0.target.iif_t = iif_t;
leda2.analysis0.target.iif_data = iif_data;

%Plot tonic fit
if 0
    figure;
    plot(t, d,'k')
    hold on;
    plot(t, driver,'k')
    plot(iif_t,iif_data,'.','Color',[.5 .5 .5])

    plot(groundtime_pre, groundlevel_pre,'bo')
    plot(t, tonicDriver_pre,'b:')

    plot(groundtime, groundlevel,'go')
    plot(t, tonicDriver,'g')

    plot(t, tonicData_pre,'r');
    plot(t, tonicData,'m')


    legend('Data','Driver','Inter-impulse data','Groundlevel-pre','TonicDriver-pre','Groundlevel','TonicDriver','TonicData-pre','TonicData')
end
