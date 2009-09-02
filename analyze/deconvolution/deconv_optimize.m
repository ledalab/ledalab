function [xopt, opthistory] = deconv_optimize(x0, nr_iv, method)

if nr_iv == 0
    xopt = x0;
    opthistory = [];
    return;
end

if strcmp(method, 'nndeco')
    xList = {x0, [.75 40 x0(end)], [.75 60 x0(end)], [.75 2 x0(end)]};
else
    xList = {x0, [.75 4], [.75 6], [1.5 2], [1.5 4], [1.5 6]};
end


x_opt = {};
err_opt = [];

for i = 1: min(nr_iv, length(xList))
    if strcmp(method, 'nndeco')
        [x, history] = cgd(xList{i}, @deconv_analysis, [.3 20 .02], .01, 20, .05);
    else
        [x, history] = cgd(xList{i}, @sdeconv_analysis, [.3 2], .01, 20, .05);
    end
    opthistory(i) = history;
    x_opt(i) = {x};
    err_opt(i) = history.error(end);

end

[mn, idx] = min(err_opt);

xopt = x_opt{idx};
add2log(0, ['Optimized parameter: ',sprintf(' %5.2f\t',xopt),sprintf(' Error: %6.3f',mn)], 0,1,1,1,0)
