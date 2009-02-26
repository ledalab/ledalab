function [tau, dist0, opthistory] = deconv_optimize(x0, nr_iv)

if nr_iv == 0
    tau = x0(1:2);
    dist0 = x0(3);
    opthistory = [];
    return;
end
    

xList = {x0, [.75 40 x0(end)], [.75 60 x0(end)], [.75 2 x0(end)]};

x_opt = {};
err_opt = [];

for i = 1: min(nr_iv, length(xList))
    [x, history] = cgd(xList{i}, @deconv_analysis, [.3 20 .02], .01, 20, .05);
    opthistory(i) = history;
    x_opt(i) = {x};
    err_opt(i) = history.error(end);
    
end

[mn, idx] = min(err_opt);

tau = x_opt{idx}(1:2);
dist0 = x_opt{idx}(3);
