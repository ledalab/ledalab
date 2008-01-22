function version_check
global leda2

try    
    web_version = str2double(urlread('http://www.ledalab.de/version.htm'));    
catch
    msgbox('Could not connect to internet');
end

if leda2.intern.version < web_version
    msgbox('There is an update available at www.ledalab.de!')    
else
    msgbox('You are using the most recent version.')
end
