function [onset, peaktime, amp] = get_peaks(time, data, sigc)
% find and return significant peaks with estimated times and amplitudes in data

ts = time;
ccd = diff(data); %Differential

%Search for signum changes in first differntial: 
%slower but safer method to determine extrema than looking for zeros (taking into account
%plateaus where ccd does not immediatly change the signum at extrema)
cccri = [];
csi = sign(ccd(1)); %currentsignum = current slope
for i = 2:length(ccd)
    if sign(ccd(i)) ~= csi
        
        if (isempty(cccri) && csi == 1)   %if first extrema = maximum, insert minimum before
            [mn, idx] = min(data(1:i-1)); 
            cccri =  idx;
        end

        cccri = [cccri, i];
        csi = -csi;
    end
end


if mod(size(cccri,2),2);        % skip last crossing if odd number of crossings
    cccri = cccri(1:end-1); 
end


%Find zeros in second differential
ccdd = diff(ccd);
csi = sign(ccdd(1)); %currentsignum = current slope
for i = 1:length(ccdd)
    if sign(ccdd(i)) ~= csi %inflection point
        if ccd(i) > 0 && csi < 0  %ascending slope with inflection point changing from neg to pos flexion f''
            cccri = [cccri, i, i];
        end
        csi = -csi;
    end
end

cccri = sort(cccri);


if isempty(cccri)
    onset = [];
    peaktime = [];
    amp = [];
    return
end


cccrimin = cccri(1:2:end);      % list of minima
cccrimax = cccri(2:2:end);      % list of maxima

cdif = data(cccrimax) - data(cccrimin);   % (how deep is the ocean) how high is the peak

csigdif = find(cdif > sigc); % & tmax>leda2.analyze.current.epoch.start & tmax<leda2.analyze.current.epoch.end); % find significant peaks
cccriminsig = cccrimin(csigdif);
cccrimaxsig = cccrimax(csigdif);

onset = ts(cccriminsig);
peaktime = ts(cccrimaxsig);
amp = cdif(csigdif); %estimated peak-amplitude
