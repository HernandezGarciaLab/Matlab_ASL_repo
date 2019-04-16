%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START EDIT 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fmriDIR fmriTEST

fmriTEST = 0;
study='inhibition'
NumRuns=2;
TR=1.0
NumSlices=17;

subject =  [ ...
	'000test'];
%;...
%	'020219ns';...
%	'020314mr';...
%	'020314rg';...
%	'020415gb';...
%	'020415mm';...
%	'020426aj';...
%%	'020426mo';...
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END EDIT 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

curDir = pwd;
curDT = clock;
fmriDIR = pwd;
fmriDIR=sprintf('%s/%s/%s/func/%s',fmriDIR,subject,subject,study)

TA = (NumSlices-1)*TR/(NumSlices)

for iSubject = 1:size(subject,1)
    
    % Now build which runs to realign.
    expDir = [];
    rootName = [];
    for iRun = 1:NumRuns
        % Set the directory of the current images.
        tmp=sprintf('run_%d/img  ', iRun) 
        expDir = [expDir; tmp]
        rootName = [rootName;'vol*']	
    end  
    
    

    f99_slice_timing(...
        expDir,... % directories where images are
        rootName,... % root of image names for those dirs.
        1,... % slice order = ascending 
	4, ...% order of acquisition=sequential
        1,... % reference slice = 0th
        TR,... % TR
        TA);   % time between first slice and last slice 

    fprintf('\n done with interpolation, cleaning up ....%s ', subject); 
    % Moving the the images to where tehy belong: 
    expDir = [];
    for iRun = 1:NumRuns
        % Set the directory of the current images.
        str=sprintf('! move %s/run_%d/img/avol*img  %s/run_%d/a_img/ ', ...
	fmriDIR,iRun, ...
	fmriDIR,iRun	) ;
	eval(str)        

	str=sprintf('! move %s/run_%d/img/avol*hdr  %s/run_%d/a_img/ ', ...
	fmriDIR,iRun, ...
	fmriDIR,iRun	) 
	eval(str);

    end  
    
    
end
