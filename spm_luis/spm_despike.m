function spm_despike(P,thresh)
% function spm_despike(P,thresh)
% INPUT:
%  P - filename or matrix of filenames of images to despike
%       can also be a cell array of the above for multiple
%       subjects/sessions
%  thresh - number of standard deviations from mean to qualify as spike
%  (default is 3)
%
% OUTPUT:
%  Despiked files are prepended with a 'd'
%
% For each voxel in a time-series, computes the (detrended) mean and
% standard deviation
% Voxels falling outside thresh * std from the mean are replaced with the
% average of surrounding time points
%
% Written by Derek Evan Nee, Indiana University, 2009

SPMid = spm('FnBanner',mfilename,'$Rev: 112 $');
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','Despike');
spm_help('!ContextHelp',mfilename);

if nargin < 1
    % get number of subjects
    nsubjects = spm_input('number of subjects/sessions',1, 'e', 1);
    if nsubjects < 1,
        spm_figure('Clear','Interactive');
    	return;
    end
	for i = 1:nsubjects
		% Choose the images
		PP = [];
		PP = spm_select(Inf,'image',...
			['Select images to despike for subject/session ' num2str(i)]);
		P{i} = PP;
    end
end

if iscell(P),
	nsubjects = length(P);
else
	nsubjects = 1;
	P = {P};
end

if nargin < 2
    thresh = spm_input('threshold for spike in s.d.',2,'e',3);
    if thresh == 0
        spm_figure('Clear','Interactive');
        return
    end
end

spm('Pointer','Watch')

for subj = 1:nsubjects
    spm('FigName',['Despiking: subject/session ' num2str(subj)],Finter,CmdLine);
    PP = P{subj};
    Vin = spm_vol(PP);
    nimgo = size(Vin,1);
    nslices = Vin(1).dim(3);
    
    % create new header files
    Vout = Vin;
    for i = 1:nimgo
        [pth,nm,xt,vr] = fileparts(deblank(Vin(i).fname));
        Vout(i).fname = fullfile(pth,['d' nm xt vr]);
        if isfield(Vout(i),'descrip')
            desc = [Vout(i).descrip ' '];
        else
            desc = '';
        end
        Vout(i).descrip = [desc 'despiked'];
    end
    Vout = spm_create_vol(Vout);
    
    % Set up large matrix for holding image info
    % Organization is time by voxels
    slices = zeros([Vin(1).dim(1:2) nimgo]);
    stack = zeros([nimgo Vin(1).dim(1)]);

    spm_progress_bar('Init',nslices,'Despiking','planes complete');

    for i = 1:nslices
        B = spm_matrix([0 0 i]);
        for j = 1:nimgo
            slices(:,:,j) = spm_slice_vol(Vin(j),B,Vin(1).dim(1:2),1);
        end
    
        for j = 1:Vin(1).dim(2)
            stack = reshape(slices(:,j,:),[Vin(1).dim(1) nimgo])';
            for k = 1:size(stack,2)
                col = detrend(stack(:,k));
                m = mean(col);
                s = std(col);
                highthresh = m + (thresh*s);
                lowthresh = m - (thresh*s);
                badvox = [find(col > highthresh); find(col < lowthresh)];
                for l = 1:length(badvox)
                    %disp(['spike at ' num2str(k) ' ' num2str(j) ' ' num2str(i) ' in image ' num2str(badvox(l))]);
                    if (badvox(l) > 1 && badvox(l) < nimgo)
                        stack(badvox(l),k) = 0.5*stack(badvox(l)-1,k) + 0.5*stack(badvox(l)+1,k);
                    elseif (badvox(l) == 1)
                        stack(badvox(l),k) = 0.5*stack(badvox(l),k) + 0.5*stack(badvox(l)+1,k);
                    elseif (badvox(l) == nimgo)
                        stack(badvox(l),k) = 0.5*stack(badvox(l)-1,k) + 0.5*stack(badvox(l),k);
                    end
                end
            end
            slices(:,j,:) = reshape(stack(1:nimgo,:)',[Vin(1).dim(1) 1 nimgo]);
        end
    
        for j = 1:nimgo
            Vout(j) = spm_write_plane(Vout(j),slices(:,:,j),i);
        end
        spm_progress_bar('Set',i);
    end
    spm_progress_bar('Clear');
end

spm('FigName','Despiking: done',Finter,CmdLine);
spm('Pointer');

return