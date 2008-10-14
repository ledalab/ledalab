function refresh_fitinfo
global leda2

if leda2.intern.batchmode
    return;
end


if isempty(leda2.analysis)
    set(leda2.gui.text_tau,'String','Tau: ');
    set(leda2.gui.text_adjR2,'String','Adj. R2: ');
    set(leda2.gui.text_rmse,'String','RMSE: ');
    set(leda2.gui.text_nPhasic,'String','SCRs: ');
    set(leda2.gui.text_nTonic,'String','TPs: ');
    set(leda2.gui.text_df,'String','DF: ');
    return;
end

nTonic = length(leda2.analysis.groundlevel);
nPhasic = length(leda2.analysis.onset);
nPar = 3 + nPhasic * 2 + (nTonic-1)*4 + 1;
df = leda2.data.N - nPar;

%may soon be removed
leda2.analysis.err_RMSE = fiterror(leda2.data.conductance.data, leda2.data.conductance.data, df, 'RMSE');
leda2.analysis.err_adjR2 = fiterror(leda2.data.conductance.data, leda2.data.conductance.data, df, 'adjR2');
%---
set(leda2.gui.text_tau,'String',sprintf('Tau: %4.2f  %4.2f', leda2.analysis.tau(1), leda2.analysis.tau(2)));
set(leda2.gui.text_adjR2,'String',['Adj. R2: ', sprintf('%6.4f',leda2.analysis.err_adjR2)]);
set(leda2.gui.text_rmse,'String',['RMSE: ', sprintf('%6.4f', leda2.analysis.err_RMSE)]);
set(leda2.gui.text_nPhasic,'String',['SCRs: ', num2str(nPhasic)]);
set(leda2.gui.text_nTonic,'String',['TPs: ', num2str(nTonic)]);
set(leda2.gui.text_df,'String',['DF: ', num2str(df)]);
