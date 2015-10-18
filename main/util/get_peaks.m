function [cccrimin, cccrimax] = get_peaks(data, ndiff)

cccrimin = [];
cccrimax = [];
ccd = diff(data); %Differential

%Search for signum changes in first differntial:
%slower but safer method to determine extrema than looking for zeros (taking into account
%plateaus where ccd does not immediatly change the signum at extrema)
start_idx = find(ccd,1);
if isempty(start_idx) %data == zeros(1,n)
    return;
end

cccri = zeros(1, length(ccd), 'uint32');
cccriidx = 2;
csi = sign(ccd(start_idx)); %currentsignum = current slope
signvec = sign(ccd);
for i = start_idx+1:length(ccd)
    if signvec(i) ~= csi
        cccri(cccriidx) = i;
        cccriidx = cccriidx + 1;
        csi = -csi;
    end
end

if cccriidx == 2 % no peak as data is increasing only
   return;
end

%if first extrema = maximum, insert minimum before
if (sign(ccd(start_idx)) == 1)
   predataidx = start_idx:cccri(2)-1;
   [mn, idx] = min(data(predataidx));
   cccri(1) =  predataidx(idx);
end

%if last extremum is maximum add minimum after it
if mod(cccriidx - (cccri(1)==0), 2);
    cccri(cccriidx) = length(data);
    cccriidx = cccriidx + 1;
end

% crop cccri from the first minimum to the last written index
cccri = cccri(1+(cccri(1)==0):cccriidx-1);

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
