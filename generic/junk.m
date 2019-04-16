function junk(myval, varargin)

sprintf('stuff')

if ~isstr(myval)
            % if the first argument is not a string (a file name), we
            % assume it's a data buffer and we're running in Real Time mode
            % in that case, we fill in the scaninfo by hand
            % rt_rec_setup simply sticks values into the args struct.

            inBuffer = myval;
            args = varargin(1);
            scaninfo = varargin(2);
            kinfo = varargin(3);

            RTMODE = 1;

else
    
            sprintf('myval is a string');

end
return
            