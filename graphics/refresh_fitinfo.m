function refresh_fitinfo
global leda2

if leda2.intern.batchmode
    return;
end


if isempty(leda2.analysis)
    set(leda2.gui.text_method,'String','Method:')
    set(leda2.gui.text_tau,'String','Tau: ');
    %set(leda2.gui.text_mse,'String','MSE: ');
    set(leda2.gui.text_rmse,'String','RMSE: ');
    set(leda2.gui.text_nPhasic,'String','SCRs: ');
    set(leda2.gui.text_nTonic,'String','TPs: ');
    return;
end

if leda2.file.version < 3.12
    leda2.analysis.error.MSE = fiterror(leda2.data.conductance.data, leda2.analysis.tonicData + leda2.analysis.phasicData, 0, 'MSE');
    leda2.analysis.error.RMSE = sqrt(leda2.analysis.err_MSE);
end

set(leda2.gui.text_tau,'String',sprintf('Tau: %4.2f  %4.2f', leda2.analysis.tau(1), leda2.analysis.tau(2)));
%set(leda2.gui.text_mse,'String',['MSE: ', sprintf('%6.4f',leda2.analysis.error.MSE)]);
set(leda2.gui.text_rmse,'String',['RMSE: ', sprintf('%6.4f', leda2.analysis.error.RMSE)]);


if strcmp(leda2.analysis.method,'nndeco')

    nTonic = length(leda2.analysis.groundlevel);
    nPhasic = length(leda2.analysis.onset);

    set(leda2.gui.text_method,'String','Method: DDA (NN-Deconv)');
    set(leda2.gui.text_nPhasic,'String',['SCRs: ', num2str(nPhasic)]);
    set(leda2.gui.text_nTonic,'String',['TPs: ', num2str(nTonic)]);

else

    set(leda2.gui.text_method,'String','Method: CDA (S-Deconv)');
    set(leda2.gui.text_nPhasic,'String','');
    set(leda2.gui.text_nTonic,'String','');

end
