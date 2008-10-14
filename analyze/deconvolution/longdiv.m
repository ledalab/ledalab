function [driver, remainder] = longdiv(convdata, kernel)

nd = length(convdata);
driver = zeros(1, nd);

for i = 1:nd

    k = kernel(1:end-i+1);
    dvl = convdata(i:end) ./ k;
    dv = min(dvl);
    dv = max(0, dv);

    driver(i) = dv;
    convdata(i:end) = convdata(i:end) - k * dv;

end

remainder = convdata;
