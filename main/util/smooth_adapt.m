function [scs, winwidth] = smooth_adapt(data, type, winwidth_max, err_crit)

success = 0;
iterL = 2:4:winwidth_max;
for i = 1:length(iterL)

    scs = smooth(data, iterL(i), type);
    scd = diff(scs);
    ce(i) = sqrt(mean(scd.^2)/2);  %conductance_error

    if i > 1
        if abs(ce(i) - ce(i-1)) < err_crit
            success = 1;
            break;
        end
    end

end

if success
    
    if i > 2
        scs = smooth(data, iterL(i-1), type);
        winwidth = iterL(i-1);
    else %data already satisfy smoothness criteria
        scs = data;
        winwidth = 0;
    end

else
    winwidth = winwidth_max;
    
end
