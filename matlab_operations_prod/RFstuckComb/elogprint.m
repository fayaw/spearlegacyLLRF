function elogprint(theTitle,theText,theLogbook,theUser)

% function elogprint(theTitle,theText,theLogbook,theUser)
%
% This function creates an .xml file to be sent to the elog.
% theTitle, theLogbook and theUser are user supplied strings
% (in single quotes).
%
% Example elogprint('This Title','This text','tlog','colocho')

% Auth: W. Colocho 30-Mar-2004, (colocho)
% Mod:


fileName = [datestr(datevec(now),30), '_Matlab.xml' ];
fileId = fopen(fileName,'w');

fprintf(fileId,'<?xml version="1.0" encoding="ISO-8859-1"?> \n');
fprintf(fileId,'<log_entry type="LOGENTRY"> \n');
fprintf(fileId,'<title>%s</title> \n', theTitle);
fprintf(fileId,'<program>105</program> \n') ;
fprintf(fileId,'<logbook>%s</logbook> \n', theLogbook); 
fprintf(fileId,'<log_user>%s</log_user>\n', theUser) ;
fprintf(fileId,'<text type="text/plain">%s</text>\n', theText); 
fprintf(fileId,'</log_entry> \n');

fclose(fileId);
[status, result] =caShell(['lpr -Pelog_', theLogbook, ' ', fileName ]);
%[status, result] =caShell(['cp ', fileName, ' /nfs/slac/g/cd/mccelog/logxml/new']);
if (status == 0)
     fprintf('Logbook entry sent to %s \n', theLogbook);
end 
return
