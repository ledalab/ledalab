function update_prevfilelist(pathname, filename)
global leda2

if leda2.intern.batchmode
    return;
end

%Update previous files - list
pf = leda2.intern.prevfile;
n = length(pf);
if n == 0 %prevfile-list was empty
    leda2.intern.prevfile.filename = filename;
    leda2.intern.prevfile.pathname = pathname;
    leda2.gui.menu.menu_of(1) = uimenu(leda2.gui.menu.menu_1,'Label',leda2.intern.prevfile(1).filename,'Callback','open_ledafile(1);','Separator','on');
else
    indx = find(strcmp({pf.filename},filename) & strcmp({pf.pathname},pathname));
    if ~isempty(indx) %if not already in prevfile-list
        pf(2:n) = pf([1:indx-1, indx+1:end]);
    else
        pf(2:n+1) = pf;
        pf = pf(1:min(n+1, leda2.pref.oldfile_maxn));
    end
    pf(1).filename = filename;
    pf(1).pathname = pathname;
    leda2.intern.prevfile = pf;
    save_ledamem;
    n2 = length(pf);

    for i = 1:n2
        if i <= n
            set(leda2.gui.menu.menu_of(i),'Label',leda2.intern.prevfile(i).filename);
        else %prevfile-menu becomes longer
            leda2.gui.menu.menu_of(i) = uimenu(leda2.gui.menu.menu_1,'Label',leda2.intern.prevfile(i).filename,'Callback',['open_ledafile(',num2str(i),');']);
        end
    end
end
