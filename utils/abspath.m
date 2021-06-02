function abspath = abspath(relpath)
    tmp = pwd;
    if ~isdir(relpath), mkdir(relpath); end
    cd(relpath)
    abspath = pwd;
    cd(tmp)
end