function gradient = cgd_get_gradient(x, error0, error_fcn, h)

Npars = length(x);
gradient = zeros(Npars,1);

for i = 1:Npars

    xc = x;  %x_copy
    xc(i) = xc(i) + h(i);

    error1 = error_fcn(xc);

    if error1 < error0
        gradient(i) = (error1 - error0);% / h(i);

    else %try opposite direction
        xc = x;
        xc(i) = xc(i) - h(i);
        error1 = error_fcn(xc);

        if error1 < error0
            gradient(i) = -(error1 - error0);% / h(i);

        else
            gradient(i) = 0;
        end
    end

end
gradient = gradient(:)';
