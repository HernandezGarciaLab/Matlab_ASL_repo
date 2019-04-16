function errormesg(mesg)
% Displays error message to a text box

errorwin;
errortext = findobj('Tag', 'ErrorText');
set(errortext,'String', mesg)

return