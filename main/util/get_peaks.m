function [cccrimin, cccrimax] = get_peaks(data, ndiff)

cccrimin = [];
cccrimax = [];
ccd = diff(data); %Differential

%Search for signum changes in first differntial:
%slower but safer method to determine extrema than looking for zeros (taking into account
%plateaus where ccd does not immediatly change the signum at extrema)
cccri = [];
start_idx = find(ccd);
if isempty(start_idx) %data == zeros(1,n)
    return;
end

start_idx = start_idx(1);
csi = sign(ccd(start_idx)); %currentsignum = current slope
for i = start_idx+1:length(ccd)
    if sign(ccd(i)) ~= csi

        if (isempty(cccri) && csi == 1)   %if first extrema = maximum, insert minimum before
            predataidx = start_idx:i-1;
            [mn, idx] = min(data(predataidx));
            cccri =  predataidx(idx);
        end

        cccri = [cccri, i];
        csi = -csi;
    end
end

%if last extremum is maximum add minimum after it
if ~mod(size(cccri,2),2);
    cccri = [cccri, length(data)];
end

if ndiff >= 2

    %Find zeros in second differential
    ccdd = diff(ccd);
    f20 = [];
    csi = sign(ccdd(1)); %currentsignum = current slope
    for i = 1:length(ccdd)
        if sign(ccdd(i)) ~= csi %inflection point
            if ccd(i) > 0 && csi < 0  %ascending slope with inflection point changing from neg to pos flexion f''
                if ndiff > 1
                    cccri = [cccri, i, i]; %f''=0 is maximum and minimum
                end
            elseif ccd(i) > 0 && csi > 0
                f20 = [f20, i];
            end
            csi = -csi;
        end
    end
    cccri = [cccri, f20];

end

cccri = sort(cccri);

cccrimin = cccri(1:2:end);      % list of minima
cccrimax = cccri(2:2:end);      % list of maxima
