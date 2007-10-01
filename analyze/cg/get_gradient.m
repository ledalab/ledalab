function gradient = get_gradient(wparset, epoch)

x = get_parset_position(wparset);
Npars = length(x);
gradient = zeros(Npars,1);

for i = 1:Npars
    
    xc = x;  %x_copy
    xc(i) = xc(i) + wparset.h;
    cparset = set_parset_position(wparset, xc, epoch);
    error = fiterror_parset(epoch, cparset);
    
    if error < wparset.error
        gradient(i) = (error - wparset.error) / wparset.h;
        
    else %try opposite direction    
        xc = x;
        xc(i) = xc(i) - wparset.h;
        cparset = set_parset_position(wparset, xc, epoch);
        error = fiterror_parset(epoch, cparset);
        
        if error < wparset.error 
            gradient(i) = - (error - wparset.error) / wparset.h;
        else
            gradient(i) = 0;
        end
    end
    
end
gradient = gradient(:)';
