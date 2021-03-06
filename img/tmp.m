function result = ortho2005(args,varargin)
% function result = ortho2005(args,varargin)
%
% (c) Luis Hernandez-Garcia at University of Michigan
% report bugs to:  hernan@umich.edu
%
% last edits: July 26,2005
%
% This is a program to visualize overlays of FMRI data, extract time
% series and do some quick analyses on those time series like FFT, gaussian
% filters, event averaging, detrending. 
% Images should be in Analyze (AVW) format
% 
%
%         USAGE:
%
% This program will do as much as it can with the information provided.  
% ie - If you give onset times, it will assume you want event averages, 
% You can run this program in a couple of ways:
% The arguments to this function can go in either as a structure like this:
% (fell free to copy and paste the following in order to run the program.  it's what I do)
%
%     args.ROIsize = 0;      
%     args.ROItype = 'cube'; 
%     args.threshold = 0;
%     args.onsets = [];
%     args.window = 10;
%     args.spm_file = [];
%     args.spm_file2 = [];
%     args.anat_file = [];
%     args.tseries_path = [];
%     args.tseries_file = [];
%     args.tseries_file2 = [];
%     args.doDetrend = 0;
%     args.doGfilter = 0;
%     args.doFFT = 0;
%     args.ignore_origin = 0;
%     args.wscale = [];
%     args.interact = 1;
%     args.xyz=[];
%     args.mask_file = [];
%     args.output_name = 'Ortho';
%     args.voxFile = [];
%
% then you call
%
%   ortho2005(args)
%
% OR as variable arguments when you just want to change a couple of the
% defaults. The general syntax is
%
%   ortho2005([],'argument1', value1, 'argument2', value2, ....)
%
% for example:
%
%    ortho2005( [], 'anat_file', '/usr/data/vol_0001.img', 'ROIsize', 1);
%
% 
%
%       INPUTS (arguments). 
%       (their default values are in the above struct)
%
% ROIsize : this is the 'radius' of the ROI if it's a sphere 
%       or the number of neighbors to consider if it's a cubw.
%       it's in mm for the sphere case, and voxels for the cube case
%
% ROItype :  what type of ROI you'll useyou can choose
%       'cube' : average the neighbors in each direction
%       'voxFile': average the values in the voxels specified in an ASCII file
%       'sphere':  average the voxels in a sphere, but only those whose
%              statistics are above threshold
%       'maskFile'  : average the voxels that are non-zero in a mask img file
%
% threshold : statistic theshold for display of the overlay and for ROI
%       averaging.
% 
% voxFile : an ASCI file containing three columns specifying which voxels
%       to extract time series from.  Note- uses scan units and ignores the
%       origin by default.
%
% mask_file = binary mask image to use if you want to choose your ROIs that
%       way
%
% onsets : a vector of onset times, specified in scan units for window averaging;
%
% window : The window of time to average after ach onset (peristimulus interval)
%       also in units of scans;
%
% spm_file : The statistical map to overlay on the orthogonal views;
%
% anat_file : The anatomical image file to overlay;
%
% tseries_path :  this doesn't do aquat right now 
%
% tseries_file : one of the files in the time series.  
%       If the data are 4D, ortho2005 should recognize it and read it in= [];
% 
% tseries_file2 :  this doesn't do squat yet, either = [];
%
% doDetrend :  Detrend the data by fitting and removing a 4th order polynomial.
%       usually works like a charm!;
%
% doGfilter:  Filter the data with a simple Gaussian filter in time.  
%       kernel width (SD) is hard wired to 4 scans ;
%
% doFFT :  show the FFT magnitude and phase of the time series in a separate window;
%
% ignore_origin :  ignore the origin information from SPM.  This can be tricky;
%
% wscale :  window level scaling for display of the anatomical images
%       if you want to do it manually;
%
% interact : allow the user to interactively pick points from the image, or just
%       do one set of coordinates and exit the program.  When interactive,
%       you exit the program by clicking to the left of the images, or by 
%       hitting the Z key.
%
% xyz : voxel coordinates to analyse when not running interactively.
%
% output_name : a prefix to put on all the files generated by the program ('Ortho');
%
%
%       Outputs from ortho2005
%
%  you get some very nice displays of whatever you chose.  if you click the
%  right mouse button instead of the left one, you get these ASCII files:
%
%       *voxels.dat : the voxels that data was extracted from
%       *data.dat: the raw time series data from theose voxels
%       *avg.dat : the means and standard deviation of the events
%   
%

if isempty(args)
    args.ROIsize = 0;
    args.ROItype = 'cube';
    args.threshold = 0;
    args.onsets = [];
    args.window = 20;
    args.spm_file = [];
    args.spm_file2 = [];
    args.anat_file = [];
    args.tseries_path = [];
    args.tseries_file = [];
    args.tseries_file2 = [];
    args.doDetrend = 0;
    args.doGfilter = 0;
    args.doFFT = 0;
    args.ignore_origin = 0;
    args.wscale = [];
    args.interact = 1;
    args.xyz=[];
    args.mask_file = [];
    args.output_name = 'Ortho';
    args.voxFile = [];
end

% Parse the arguments from the command line to override defaults
for a=1:2:length(varargin)

    argtype = lower( cell2mat(varargin(a) ));

    if  strcmp(argtype, 'roisize');
        args.ROIsize = cell2mat(varargin(a+1));

    elseif  strcmp(argtype, 'roitype');
        args.ROItype = cell2mat(varargin(a+1));

    elseif  strcmp(argtype, 'threshold');
        args.threshold = cell2mat(varargin(a+1));

    elseif  strcmp(argtype, 'onsets')
        args.onsets = cell2mat(varargin(a+1));

    elseif  strcmp(argtype, 'window')
        args.window = cell2mat(varargin(a+1));

    elseif  strcmp(argtype, 'spm_file');
        args.spm_file = cell2mat(varargin(a+1));

    elseif  strcmp(argtype, 'spm_file2');
        args.spm_file2 = cell2mat(varargin(a+1));

    elseif  strcmp(argtype, 'anat_file')
        args.anat_file = cell2mat(varargin(a+1));

    elseif  strcmp(argtype, 'tseries_path')
        args.tseries_path = cell2mat(varargin(a+1));

    elseif  strcmp(argtype, 'tseries_file')
        args.tseries_file = cell2mat(varargin(a+1));

    elseif  strcmp(argtype, 'tseries_file2')
        args.tseries_file2 = cell2mat(varargin(a+1));

    elseif  strcmp(argtype, 'dodetrend')
        args.doDetrend = cell2mat(varargin(a+1));

    elseif  strcmp(argtype, 'dotsmooth')
        args.doTsmooth = cell2mat(varargin(a+1));

    elseif  strcmp(argtype, 'dofft')
        args.doFFT = cell2mat(varargin(a+1));

    elseif  strcmp(argtype, 'ignore_origin')
        args.ignore_origin = cell2mat(varargin(a+1));

    elseif  strcmp(argtype, 'wscale')
        args.wscale = cell2mat(varargin(a+1));
        
    elseif  strcmp(argtype, 'interact')
        args.interact = cell2mat(varargin(a+1));
        
    elseif  strcmp(argtype, 'xyz')
        args.xyz = cell2mat(varargin(a+1));
 
    elseif  strcmp(argtype, 'mask_file')
        args.mask_file = cell2mat(varargin(a+1));
 
    elseif  strcmp(argtype, 'output_name')
        args.output_name = cell2mat(varargin(a+1));

    elseif  strcmp(argtype, 'voxfile')
        args.voxFile = cell2mat(varargin(a+1));

    else
        fprintf('\n\n  UNKNOWN OPTION: %s ', argtype);
        fprintf('\n  Get your act together \n\n', argtype);
    end

end

if isempty(args.anat_file)
    args.anat_file=args.tseries_file;
end

args


global SPM_scale_factor
global myfig ACTIVE Evfig FFTfig histFig
ACTIVE = 1;

if ~isempty(args.onsets)
    % open a window for displaying the time courses
    Evfig = figure;
    set(gcf,'Position',[1 1 360,320]);
    set(gcf, 'Name', 'Events image')
end

if args.doFFT
    % open a window for displaying the time courses
    FFTfig = figure;
    set(gcf,'Position',[400 1 360,320]);
    set(gcf, 'Name', 'Frequency Spectrum')
end

histFig = figure;
set(gcf,'Position',[400 400 360,320]);
set(gcf, 'Name', 'Histograms')

myfig = figure;
set(gcf, 'Name', 'Orthogonal Views')
set(gcf,'Position',[1 400 360,320]);
   
if ~isempty(args.anat_file)
    % Load the anatomical image into memory:
    anat_file = args.anat_file;
    hdr = read_hdr(anat_file);
    anat_data = read_img2(hdr,anat_file);
    anat_scale =  SPM_scale_factor;

    fprintf('\nheader info: %d x %d x %d', hdr.xdim, hdr.ydim, hdr.zdim);
    fprintf('\nvox size: %d x %d x %d', hdr.xsize, hdr.ysize, hdr.zsize);

    D = anat_data;

    if isempty(args.spm_file)
        % configure colormap
        my_map=(0:255)';
        my_map=[my_map my_map my_map]/256;
        colormap(my_map);
    end
    % scale image to fit colormap
    range= max(D(:)) - min(D(:));

    if ~isempty(args.wscale)
        wscale = args.wscale
        D = (D - wscale(1))*256 / wscale(2);
    else
        D = (D - min(D(:)))*256 / range;
    end


end

if ~isempty(args.spm_file)
    % load SPM into memory and create the overlay
    spm_file = args.spm_file;
    spm_hdr = read_hdr(spm_file);
    spm_data = read_img2(spm_hdr,spm_file);
    % get rid of the NaNs
    spm_data(find(spm_data==NaN))=0;
    spm_scale =  SPM_scale_factor;

    % resample the paramter map to fit the anatomical one
    [x,y,z] = meshgrid(1:spm_hdr.ydim , 1:spm_hdr.xdim, 1:spm_hdr.zdim);
    [xi,yi, zi] = meshgrid(1:hdr.ydim , 1:hdr.xdim, 1:hdr.zdim);

    % optional in case the origin is not set in the image headers...
    if args.ignore_origin==1
        spm_hdr.origin = [0 0 0];
        hdr.origin = [0 0 0];
    end

    x = ( x - spm_hdr.origin(1) )* spm_hdr.xsize;
    y = ( y - spm_hdr.origin(2) )* spm_hdr.ysize;
    z = ( z - spm_hdr.origin(3) )* spm_hdr.zsize;

    xi = ( xi - hdr.origin(1) )* hdr.xsize;
    yi = ( yi - hdr.origin(2) )* hdr.ysize;
    zi = ( zi - hdr.origin(3) )* hdr.zsize;

    if hdr.zdim >1
        spm_dataR = interp3(x,y,z, spm_data, xi,yi,zi,'nearest');
    else
        spm_dataR=spm_data;
    end
    spm_dataR(find(isnan(spm_dataR)))=0;

    % threshold the map
    if isempty(args.threshold)
        args.threshold = mean(spm_dataR(:)) * 3;
    end
    inds = find(spm_dataR >= args.threshold);

    % scale the maps to use the whole colormap
    spm_dataR = spm_dataR * 255 / max(spm_dataR(:));
    
    
    % combine the two images
    if ~isempty(inds)
        D(inds) =  256 + spm_dataR(inds);
    end
    %configure the colormap:
    set_func_colors

    xstretch = hdr.xdim/spm_hdr.xdim;
    ystretch = hdr.ydim/spm_hdr.ydim;
    zstretch = hdr.zdim/spm_hdr.zdim;
else
    xstretch = 1;
    ystretch = 1;
    zstretch = 1;
end


if ~isempty(args.spm_file2)
    % load SPM into memory and create the overlay
    spm_file2 = args.spm_file2;
    spm_hdr2 = read_hdr(spm_file2);
    spm_data2 = read_img2(spm_hdr,spm_file2);
    % get rid of the NaNs
    spm_data2(find(spm_data2==NaN))=0;
    spm_scale2 =  SPM_scale_factor;

    % resample the paramter map to fit the anatomical one
    [x,y,z] = meshgrid(1:spm_hdr2.ydim , 1:spm_hdr2.xdim, 1:spm_hdr2.zdim);
    [xi,yi, zi] = meshgrid(1:hdr.ydim , 1:hdr.xdim, 1:hdr.zdim);

    % optional in case the origin is not set in the image headers...
    if args.ignore_origin==1
        spm_hdr2.origin = [0 0 0];
        hdr.origin = [0 0 0];
    end

    x = ( x - spm_hdr2.origin(1) )* spm_hdr2.xsize;
    y = ( y - spm_hdr2.origin(2) )* spm_hdr2.ysize;
    z = ( z - spm_hdr2.origin(3) )* spm_hdr2.zsize;

    xi = ( xi - hdr.origin(1) )* hdr.xsize;
    yi = ( yi - hdr.origin(2) )* hdr.ysize;
    zi = ( zi - hdr.origin(3) )* hdr.zsize;

    if hdr.zdim >1
        spm_dataB = interp3(x,y,z, spm_data2, xi,yi,zi,'nearest');
    else
        spm_dataB = spm_data2;
    end
    spm_dataB(find(isnan(spm_dataB)))=0;

    % threshold the map
    if isempty(args.threshold)
        args.threshold = mean(spm_dataB(:)) * 3;
    end
    inds2 = find(spm_dataB >= args.threshold);
    
    % scale the maps to use the whole colormap
    spm_dataB = spm_dataB * 255 / max(spm_dataB(:));
    %spm_data2(inds) = 0;
 
    if ~isempty(inds2)
        D(inds2) =  512 + spm_dataB(inds2);
    end

    % combine the three images
    msk1 = zeros(size(D));
    msk1(inds)=1;
    msk2 = zeros(size(D));
    msk2(inds2)=1;
    msk = msk1 .* msk2;
    inds3 = find(msk);
    
    if ~isempty(inds3)
        D(inds3) =  800;
        
    end

% 
% figure
% subplot(3,1,1),    hist(spm_dataR(:),100)
% subplot(3,1,2),    hist(spm_dataB(:),100)
% subplot(3,1,3),    hist(D(:),100)
% figure(myfig)

    %configure the colormap:
    set_func_colors2

    xstretch = hdr.xdim/spm_hdr2.xdim;
    ystretch = hdr.ydim/spm_hdr2.ydim;
    zstretch = hdr.zdim/spm_hdr2.zdim;
else
    xstretch = 1;
    ystretch = 1;
    zstretch = 1;
end


if ~isempty(args.tseries_file)
    % load up the time series into memory

    %first, ,make sure the name is OK.  we want just the root of the time
    %series:  ie - 'ravol_'
    filename = args.tseries_file;
    if length(filename)> 3
        suffix = filename(end-3:end);
        if strcmp(suffix,'.img')  % input is an img file

            func_hdr = read_hdr(sprintf('%s.hdr', filename(1:end-4)));
            func_root = filename(1:end-8);

        elseif strcmp(suffix,'.hdr') % uinput is a hdr file

            func_hdr = read_hdr(filename);
            func_root = filename(1:end-8);

        else  % input is either the root, or a sample file without the extension

            files = dir(sprintf('%s*.hdr', filename));
            samplename = files(1).name;
            func_hdr = read_hdr(samplename);
            func_root = samplename(1:end-8);
        end

    else
        % if the filename is only 3 chars, it must be the root!
        files = dir(sprintf('%s*.hdr', filename));
        samplename = files(1).name;
        func_hdr = read_hdr(samplename);
        func_root = samplename(1:end-8);
    end
    func_data = read_img_series(func_root);
end

% determine the first point for the extraction 
if isempty(args.xyz)
    x=ceil(hdr.xdim/2);
    y=ceil(hdr.ydim/2);
    z=ceil(hdr.zdim/2);
else
    x = args.xyz(1);
    y = args.xyz(2);
    z = args.xyz(3);
end


[fig1, fig2, fig3] =  ov(hdr,D,x,y,z,0);

figure(histFig), subplot(2,1,1),hist(anat_data(:),100), title('Anatomical')

if ~isempty(args.spm_file)
    figure(histFig), subplot(2,1,2),hist(spm_data(:),100), title('Stats Map')
end

figure(myfig)

% create the gaussian kernel for the filter (to be used later)
g = make_gaussian(50,4,100);

button=1;
while (button ~= 122)  % until they press Z.  122 is the Z key

    % now get into the interactive sampling loop:
    [fig1, fig2, fig3] =  ov(hdr,D,x,y,z,0);

    fprintf('\n---\ncoords = (%3.2f, %3.2f, %3.2f) mm,  \n(%3d, %3d, %3d) vox , \nAnat val= %d',...
        hdr.xsize*(x-hdr.origin(1)), ...
        hdr.ysize*(y-hdr.origin(2)), ...
        hdr.zsize*(z-hdr.origin(3)), ...
        x,y,z, ...
        anat_data(x,y,z)*anat_scale );

    % figure out what the coordinates correspond to in the SPM image
    if ~isempty(args.spm_file)
        % get the values in the stats map
        [mx, my, mz] = vox2mm(hdr, [x,y,z]);
        [xs, ys, zs] = mm2vox(spm_hdr, [mx, my, mz]);

        fprintf('\nSPM val= %d', spm_data(xs,ys,zs)*spm_scale );
    else
        xs = x;
        ys = y;
        zs = z;
    end

    % figure out what the coordinates correspond to in the SPM2 image
    if ~isempty(args.spm_file2)
        % get the values in the stats map
        [mx, my, mz] = vox2mm(hdr, [x,y,z]);
        [xs, ys, zs] = mm2vox(spm_hdr2, [mx, my, mz]);
        
        fprintf('\nSPM2 val= %d', spm_data2(xs,ys,zs)*spm_scale2 );
    else
        xs = x;
        ys = y;
        zs = z;
    end

    % extend the coordinates to fill a whole ROI
    % (figure out which voxels get extracted)
    if ~isempty(args.anat_file)
        
        % just in case they forgot to set that flag, if they selected a 
        % mask file, it means they are doing a mask ROI
        if ~isempty(args.mask_file)
            args.ROItype='maskFile';
        end

        % limits of the ROI
        roi = args.ROIsize;
        
        xmin = max([1 xs-roi]);
        xmax = min([hdr.xdim xs+roi]);
        
        ymin = max([1 ys-roi]);
        ymax = min([hdr.ydim ys+roi]);
        
        zmin = max([1 zs-roi]);
        zmax = min([hdr.zdim zs+roi]);
        
        % first figure which voxels
        switch args.ROItype
            case 'cube'
                [xx,yy,zz] = ndgrid([xmin:xmax], [ymin:ymax], [zmin:zmax]);
                nlist = length(xx(:));
                fx = reshape(xx,nlist,1);
                fy = reshape(yy,nlist,1);
                fz = reshape(zz,nlist,1);

                func_xyz = [fx fy fz];   % a list of all voxels within the cube

            case 'sphere'
                %nlist = (2*args.ROIsize + 1)^3; % total # of voxels within a cube
                [xx,yy,zz] = ndgrid([xmin:xmax], [ymin:ymax], [zmin:zmax]);
                nlist = length(xx(:));
                fx = reshape(xx,nlist,1);
                fy = reshape(yy,nlist,1);
                fz = reshape(zz,nlist,1);

                cube_xyz = [fx fy fz];   % a list of all voxels within the cube
                dist_cube = sqrt(...
                    (spm_hdr.xsize * (fx - xs)).^2 + ...
                    (spm_hdr.ysize * (fy - ys)).^2 + ...
                    (spm_hdr.zsize * (fz - zs)).^2);    % a list of distances in mm

                sphere_xyz = cube_xyz(dist_cube <= args.ROIsize, :); % a list of voxels within sphere
                num_voxels = size(sphere_xyz,1); % len_list is the # of voxels within sphere

                % keep only those above threshold in the spm_data
                func_xyz =  [];
                for v=1: num_voxels
                    if spm_data(sphere_xyz(v,1), sphere_xyz(v,2), sphere_xyz(v,3)) ...
                            >= args.threshold;
                        func_xyz = [func_xyz; sphere_xyz(v,:)];
                    end
                end
                if ~isempty(args.spm_file2)
                    func_xyz2 =  [];
                    for v=1: size(func_xyz,1)
                        if spm_data2(func_xyz(v,1), func_xyz(v,2), func_xyz(v,3)) ...
                                >= args.threshold;
                            func_xyz2 = [func_xyz2; func_xyz(v,:)];
                        end
                    end
                    func_xyz=func_xyz2;
                end
        
            case 'voxFile'
                if ~isempty(args.voxFile)
                    func_xyz = load(args.voxFile)
                else
                    fprintf('\nERROR: NO VOXEL FILE (args.voxFile) WAS SPECIFIED - ABORT');
                    fprintf('\nI am very disappointed\n');
                end
            case 'maskFile'
                mask_hdr = read_hdr(args.mask);
                mask_data = read_img(args.mask);
                func = find(mask_data >= threshold);
                [fx, fy, fz] = ind2sub(size(mask), func);
                func_xyz = [fx fy fz];
            otherwise
                fprintf('\nError. Alowed ROI types are: cube, sphere, voxFile, maskFile.')
                fprintf('\nDo not let it happen again... Exiting\n')
                return
        end
        
        % fill in the ROI so you know what pixels got extracted
        if ~isempty(func_xyz)
            vx = func_xyz(:,1);
            vy = func_xyz(:,2);
            vz = func_xyz(:,3);

            axes(fig3), hold on, plot(vy*ystretch, vz*zstretch,'gx');
            axes(fig2), hold on, plot(vx*xstretch, vz*zstretch,'gx');
            axes(fig1), hold on, plot(vy*ystretch, vx*xstretch,'gx');% do the extraction:
        else
            fprintf('\nFound no voxels above threshold at this location');
        end
    end

     % and extract the time series in the selected voxels
     if ~isempty(func_xyz) & ~isempty(args.tseries_file)

        tmp = xtract(func_hdr, func_data, vx, vy, vz);

        % filtering stuff:
        % tmp = smoothdata2(tmp, TR, 0.009, 0.3, 3);
        if args.doGfilter
            disp('Gaussian filter ...')
            MeanBefore=mean(tmp);
            tmp = conv(g,tmp);
            tmp = tmp(50:end-50);
            MeanAfter=mean(tmp);
        end

        series_mean = mean(tmp);

        if args.doDetrend
            disp('detrending ...')
            dtmp = mydetrend(tmp');
            load coeffs.mat
            tmp=dtmp;
            tmp = 100 * tmp / series_mean;
        else
            tmp = 100 * (tmp' - series_mean) / series_mean;
        end

        tdata = tmp;
        subplot 224, plot(tdata,'r');axis tight ; hold off; 
        xlabel('scan #'), ylabel('%signal')
        
        if button==3
            % right mouse button means we save data to file
            fprintf('\nsaving:   %s_tdata.dat, and %svoxels.dat',...
                args.output_name,args.output_name)
            str=sprintf('save %s_tdata.dat tdata -ASCII', args.output_name); eval(str);
            str=sprintf('save %s_voxels.dat func_xyz -ASCII', args.output_name); eval(str);
        end
        
        if ~isempty(args.onsets)

            [ev_avg ev_std] = event_avg(tdata,args.onsets,args.window,1);

            subplot 224, plot(ev_avg,'r');axis tight ; hold off;
            dlha = get(gca,'children');
            set(dlha(:),'LineWidth',2);
            hold on
            subplot 224, errorbar([1:length(ev_avg)], ev_avg,...
                ev_std, ev_std,'r');
            axis tight ; hold off;
            hold off
            subplot(224), title (sprintf('ROI at %d %d %d ', xs , ys, zs))
            set(gca, 'Xtick',[0:2:args.window])
            xlabel('scan #'), ylabel('%signal')

            if button==3
            % right mouse button means we save data to file
                tmp = [ev_avg ev_std];
                fprintf('\nsaving:  %s_avg.dat ',args.output_name)
                str=sprintf('save %s_avg.dat tmp -ASCII', args.output_name); eval(str);                
            end
            
            % now display the image of event averages
            load allevents
            figure(Evfig);
            imagesc(allevents); colorbar
            title('Image of all the events in 2D')
            xlabel('Time (scans)'), ylabel('Event number')
            % return focus to other figure
            figure(myfig);           
        end
   
    end


    if args.doFFT
        figure(FFTfig),hold off,
        subplot(211), plot(linspace(-1,1,length(tdata)), abs(fftshift(fft(tdata - mean(tdata)))),'r')
        title('FFT magnitude (mean removed)')
        xlabel('Frequency'), ylabel('Magnitude')
        subplot(212), plot(linspace(-1,1,length(tdata)), angle(fftshift(fft(tdata - mean(tdata)))),'r')
        title('FFT Phase(mean removed)')
        figure(myfig)
        xlabel('Frequency'), ylabel('Phase')        
    end
    
    % Get the next user defined point
    if (args.interact)
        [i j button] = ginput(1);
        i=round(i);j=round(j);
        fig = floor(gca);
        switch(fig)
            case floor(fig1)
                x=j;
                y=i;
            case floor(fig2)
                z=j;
                x=i;
            case floor(fig3)
                y=i;
                z=j;
        end
    end
    % exit the loop by clicking outside or hitting "Z"
    if i<1 | button==122 | j<1
        break
    end
    if ACTIVE==0
        break
    end

end

result = args;
fprintf('\nLater!')
return

