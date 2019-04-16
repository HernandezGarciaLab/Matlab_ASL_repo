%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START EDIT 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fmriDIR;
global fmriTEST

fmriTEST = 0;
study='inhibition'
NumRuns=2;

subject =  [ ...
	'000test'];
%	'020215ac';...
%	'020219ns';...
%	'020314mr';...
%	'020314rg';...
%	'020415gb';...
%	'020415mm';...
%	'020426aj';...
%	'020426mo';...
%	'020514al';...
%	'020515tw';...
%	'020515mo';...
%	'020517mh';...
%	'020528kh';...
%	'020530pl';...
%	'020530mw';...
%	'020909ac';...
%	'020916hh';...
%	'020916ds'];  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END EDIT 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

curDir = pwd;
curDT = clock;
fmriDIR = pwd;
fmriDIR=sprintf('%s/%s/%s/func/%s',fmriDIR,subject,subject,study)

for iSubject = 1:size(subject,1)
    
    % Now build which runs to realign.
    expDir = [];
    rootName = [];
    for iRun = 1:NumRuns
        % Set the directory of the current images.
	tmp=sprintf('run_%d/a_img  ', iRun) 
        expDir = [expDir; tmp];
        rootName = [rootName;'avol*.img'];	
    end  
    
    
    f99_realign(...
        3,... % realign and reslice
        expDir,... % directories where images are
        rootName,... % root of image names for those dirs.
        -9,... % sinc interpolation 
        3,... % all images + means image
        1,... % maskimages=yes
        0,... % adjust SE = no
        0.5,... % registration quality
        ''); % status flag?

    fprintf('\n done with interpolation, cleaning up ....%s ', subject); 
    
    for iRun = 1:NumRuns
      % Set the directory of the current images.
        str=sprintf('! move %s/run_%d/a_img/ravol*img  %s/run_%d/ra_img/ ', ...
	fmriDIR,iRun, ...
	fmriDIR,iRun	) ;
	eval(str)        

	str=sprintf('! move %s/run_%d/a_img/ravol*hdr  %s/run_%d/ra_img/ ', ...
	fmriDIR,iRun, ...
	fmriDIR,iRun	) 
	eval(str);
 
    end  

end
