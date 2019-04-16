function [VOI_avg, de_VOI_avg, stim_avg, grand_avg, eff_v] = ...
    f_Dboldavg_D(subjDir, Runs, iVOI, window_len, th)
%function [VOI_avg, de_VOI_avg, stim_avg, grand_avg, eff_v] = ...
%	f_Dboldavg(subjDir, Runs, iVOI, window_len, th)
% modified from f_avg_activation.m to apply to Dagfinn's data
%     - Heng 06/2004
% subjDir = '020708pc/'; temp = 47; window_len = 30; th = 1.5;
% this function calculate the average amplitude and average coordinates of
% the functional MRI response within a volume of interest (VOI) specified by
% index ind_vol (1~19).
% INPUT:
%   subjDir:    subject directory (eg. subjDir = '020419lc/')
%   Runs:       The Runs to extract bold time series(eg. Runs = [1 4 9])
%	iVOI:		The VOI mask to work on. iVOI can be 1 to 34.
%   window_len: window length, in units of seconds
%   th:         threshold of T value; only voxels with T > th considered.
% OUTPUT:
%   VOI_avg:    average amplitude of the functional response
%	de_VOI_avg:	detrended VOI_avg;
%   eff_v: 		the # of effective voxels

rootDir = '/media/MAXTOR/data/';
fmriTR = 1.5; % seconds
nRun = length(Runs); % # of runs to consider.

funcDir = strcat(rootDir, subjDir, subjDir, 'func/pain2/');

eff_v = zeros(1, nRun);     % effective # of voxels in each VOI

for iRun = 1:nRun

    % locate the mask image for the specified VOI.
    runDirNo = num2str(100+Runs(iRun));
    maskDir = [rootDir, 'tsD/',subjDir,'run_',runDirNo(2:3), '/'];
    maskVOI_hdrfile = [maskDir, 's2f/fmask', num2str(iVOI), '_f.hdr'];
    maskVOI_imgfile = [maskDir, 's2f/fmask', num2str(iVOI), '_f.img'];
    m_hdr = read_hdr(maskVOI_hdrfile);
    m_img = read_img2(m_hdr, maskVOI_imgfile);

    % locate the T-map for the thresholding
    T_mapfile = 'tstat1';
    T_hdrfile = strcat(maskDir, T_mapfile, '.hdr');
    T_imgfile = strcat(maskDir, T_mapfile, '.img');
    T_hdr = read_hdr(T_hdrfile);
    T_img = read_img2(T_hdr, T_imgfile);

    % specify the onset/offset times
    onsetDir = [rootDir, 'tsD/', subjDir, 'onset/'];
    onsetfile = [onsetDir, subjDir(7:8), '-', num2str(Runs(iRun)), '-fsl.txt'];
    onsetdata = load(onsetfile);
    onset = round(onsetdata(:,1) / fmriTR);
    offset = onset + round(window_len/fmriTR);

    % locate the functional images for the current run
    runid = num2str(100+Runs(iRun));
    runDir = [funcDir, 'run_', runid(2:3), '/ra_img/'];
    %runDir = [funcDir, 'run_', num2str(Runs(iRun)), '/ra_img/'];
    cd(runDir);
    spm_file = dir('*_0001.img');
    sz = size(spm_file.name,2);
    name = spm_file.name(1,1:sz-8);

    nScan = 96; % 184 for 1st group, 96 for 2nd group
    for serial_no = 1:nScan
        txt_sn = num2str(10000 + serial_no);
        txt_sn = txt_sn(2:5);
        func_file_hdr = strcat(name, txt_sn, '.hdr');
        func_file_img = strcat(name, txt_sn, '.img');
        spm_hdr = read_hdr(func_file_hdr);
        spm_img = read_img2(spm_hdr, func_file_img);

        T_mask = (T_img >= th);		% apply threshold, generate T mask
        m_mask = (m_img > 0); 		% mask for the VOI
        final_mask = T_mask .* m_mask;
        amp = spm_img .* final_mask;

        eff_v(Runs(iRun)) = sum(sum(sum(final_mask)));

        % calculate the average amplitude
        ind_imgfile = serial_no;
        if eff_v(Runs(iRun)) ~= 0
            VOI_avg(iRun, ind_imgfile) = sum(sum(sum(amp))) / eff_v(Runs(iRun));
        else
            VOI_avg(iRun, ind_imgfile) = 0;
        end
    end  % serial_no 1:nScan

end  % iRun
subplot(211), plot(de_VOI_avg';)
% detrend, remove low freq. shift.
[de_VOI_avg coeff] = polydetrend(VOI_avg, 1, 2);

% calculate signal percent change ???

for p=1:nRun
    de_VOI_avg(p,:) = 100* de_VOI_avg(p,:) / coeff(p,2);
end
subplot(212), plot(de_VOI_avg';)

% calculate average across stimuli within a run
nStim = length(onset);
stim_avg(1:nRun, 1:round(window_len/fmriTR+1) ) = 0;
for iStim = 1:nStim
    stim_avg = stim_avg + de_VOI_avg(:, onset(iStim):offset(iStim));
end
stim_avg = stim_avg / nStim;
activeRuns = sum(all(stim_avg'));
if activeRuns == 0
    grand_avg = sum(stim_avg, 1);
else
    grand_avg = sum(stim_avg, 1)/activeRuns;
end


