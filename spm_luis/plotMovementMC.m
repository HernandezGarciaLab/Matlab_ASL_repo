% 
% A simple script to plot movement parameters take from 
% the AIR realignment preprocessing.
%
% function results=plotMovement(varargin)
%
% Robert C. Welsh, V0.5 Aug 1, 2002
% Univ of Michigan, Dept of Radiology
%
% V 0.6 - fileName can now be an array.
%
% V 0.7 - add optional title to the plot, else use
%         the directory of the first file name
%         given.
%
% Inputs: 
% 
%   varargin
%
%   If the number of inputs == 2, we assume
%   the the first is the list of files names and the
%   second is the title to show on the top plot.
%
%   If the number of inputs == 1, then we check to 
%   see if the input is a string array, if so we
%   assume this is a list of file names, 
%
%   else, we check to see if the single string is an 
%   existing file, if so we plot that, else 
%   it is a title and we use that to show and then we use
%   spm_get to get the file names to plot.
%
% 
%   Now this can break if the files don't exist!
%

function results=plotMovementMC(varargin)

theTitle = '';

% How many arguements? ==2, means first is file names, second is
% title.

if nargin == 2
  fileName = varargin{1};
  theTitle = varargin{2};
else
  if nargin == 1
    if size(varargin{1},1) > 1
      fileName = varargin{1};
      theTitle = '';
    else
      if exist(varargin{1}) == 2
	fileName = varargin{1};
	theTitle = '';
      else
	theTitle = varargin{1};
      end
    end
  end
end

% Did file names get passed?

if exist('fileName') ~= 1
  fileName=spm_get([0 Inf],'real*.dat','Pick relign.dat file(s)','./',0);
end

% Did they want to bug out?

if size(fileName,1) == 0
  fprintf('Aborting...\n');
  return
end

% Let's check to see that each file passed is really a file.

badFile = 0;

for iFile = 1:size(fileName,1)
  if exist(fileName(iFile,:)) ~= 2
    badFile = 1;
  end
end

% Bad file name?

if badFile == 1
  fprintf('Sorry, on of the files doesn''t exist. Aborting.\n');
  return
end

% Ok, now let's figure out the title to display.

if length(theTitle) < 1
  [fd ff] = fileparts(fileName(1,:));
  if length(fd) < 1
    fd = pwd;
  end
  theTitle = fd;
end

% Read in the data and concatenate.

realignData = [];
for iFile = 1:size(fileName,1)
  x=load(fileName(iFile,:));
  realignData = [realignData;x];
end

x=realignData;

colorTable = [1 0 0; 0 1 0; 0 0 1];

% Whatever figure is there we'll use that.

clf;

% Labes to put on axes.

xlabel = ['Image #';...
	  'Image #'];
ylabel = ['Rotation(degrees)';...
          'Translation(mm)  '];
	  
mcScale = [180/pi 180/pi 180/pi 1 1 1];

% Now plot it all.

for ip = 1:2
  sb= subplot(2,1,ip);
  for ic=1:3
    sp=plot(x(:,ic+(ip-1)*3)*mcScale(ic+(ip-1)*3));
    set(sp,'Color',colorTable(ic,:));
    set(sp,'LineWidth',3);
    hold on
  end
  set(sb,'FontWeight','bold');
  set(get(sb,'xlabel'),'string',xlabel(ip,:));
  set(get(sb,'ylabel'),'string',ylabel(ip,:));
  set(get(sb,'xlabel'),'fontweight','bold');
  set(get(sb,'ylabel'),'fontweight','bold');
  if ip==1    
    title(theTitle);
  end
end

% Return the list to the user.

results=x;

%
% All done 
% 
