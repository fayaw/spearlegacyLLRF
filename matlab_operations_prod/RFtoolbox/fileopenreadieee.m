function [fId] = fileopenreadieee( fileName, tWait )
% function [fId] = fileopenreadieee( fileName, tWait )
% fileopenreadieee opens a file in ieee big endian 'ieee-be' format with a
% maximum wait time of tWait and returns the file ID
%
% fileName  name of file to open
% tWait     number of seconds to wait before timing out
% fId       file identifier (-1 if unsuccessful)

fId = -1;
dt = 0.1; % wait time between attempts
nTries = ceil(tWait/dt);

for ind=1:nTries,
    fId = fopen( fileName, 'r', 'ieee-be' );
    if (fId == -1),
        pause(dt);
    else
        return;
    end % if (fId == -1),
end % for ind=1:nTries,
fprintf(1, 'unable to open file %s after %f seconds\n', fileName, tWait);

return
end