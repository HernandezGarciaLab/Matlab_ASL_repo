
function genScannerPulses(rf1, G, dt)
%
% this function makes the files for the GE scanner to use
% it calls xlatebin
%
% function genScannerPulses(rf1, G, dt)
% dt is in msec.
% the output files are in 4 usec rampling period

SAMPRATE = 0.004;
NPOINTS = floor(length(rf1) * dt / SAMPRATE);
dnsample = floor(SAMPRATE/dt);

rf1 = rf1(1:dnsample:end);
G = G(1:dnsample:end);

% if it's an odd number of points, put a zero at the end
if floor(NPOINTS/2) ~= (NPOINTS/2)
    rf1 = [rf1 ; 0];
    G = [G; 0];
    NPOINTS = NPOINTS+1;
end

dacmax = hex2dec('7ffe');

% Now write out scanner files:  magnitude
tmp = abs(rf1);
tmp = tmp * dacmax / max(tmp);
tmp = 2*round(tmp/2);
figure(1)
set(gcf,'Name', 'Pulse sequence ')

subplot(312)
plot( tmp ) ;    title('RF mag')


filename = sprintf('myVSI_%d.rho.txt',NPOINTS);
fp=fopen(filename,'w');
for n=1:NPOINTS, fprintf(fp,'%d\n',tmp(n)); end
fclose(fp);

% first write it as intt16
filename = sprintf('myVSI_%d.rho.bin',NPOINTS);
fp = fopen(filename,'wb','b');
fwrite(fp, tmp, 'int16');
fclose(fp);

% then use GE software to put in proper format
str = sprintf('!xlatebin -o myVSI_%d.rho myVSI_%d.rho.bin', NPOINTS, NPOINTS);
eval(str)

% Now write out scanner files:   phase
tmp = angle(rf1);
tmp = tmp * dacmax / pi;
tmp = 2*round(tmp/2);

subplot(313)
plot( tmp );    title('RF phase')


filename = sprintf('myVSI_%d.theta.txt',NPOINTS);
fp=fopen(filename,'w');
for n=1:NPOINTS, fprintf(fp,'%d\n',tmp(n)); end
fclose(fp);

% first write it as intt16
filename = sprintf('myVSI_%d.theta.bin',NPOINTS);
fp = fopen(filename,'wb','b');
fwrite(fp, tmp, 'int16');
fclose(fp);

% then use GE software to put in proper format
str = sprintf('!xlatebin -o myVSI_%d.theta myVSI_%d.theta.bin', NPOINTS, NPOINTS);
eval(str)




% Now write out scanner files:
tmp = G ;
tmp = tmp * dacmax / max(tmp);
tmp = 2*round(tmp/2);
tmp(isnan(tmp)) = 0;
subplot(311)
area( tmp)
title('Grad')

% write out a text file with the gradient waveform
filename = sprintf('myVSI_%d.grad.txt',NPOINTS);
fp=fopen(filename,'w');
for n=1:NPOINTS, fprintf(fp,'%d\n',tmp(n)); end
fclose(fp);


% first write it as intt16
filename = sprintf('myVSI_%d.grad.bin',NPOINTS);
fp = fopen(filename,'wb','b');
fwrite(fp, tmp, 'int16');
fclose(fp);

% then use GE software to put in proper format
str = sprintf('!xlatebin -o myVSI_%d.grad myVSI_%d.grad.bin', NPOINTS, NPOINTS);
eval(str)

fprintf('\n...Generated GE wavefiles for:')
fprintf('\n myVSI_%d.blah.txt \n',NPOINTS)

%% Now do Varian format:
% Now write out scanner files:   phase
phs = rad2deg(angle(rf1));
mag = abs(rf1);
mag = abs(rf1) * 1023 / max(mag);
dur = ones(size(mag));
varianRF = [phs mag dur]; 
str = ['save VSI_' num2str(NPOINTS) '.RF -ascii  varianRF ']; 
eval(str);

varianGz = [ones(size(G)) G*dacmax/max(G)];
str = ['save VSI_' num2str(NPOINTS) '.GRD  -ascii varianGz']; 
eval(str);

return