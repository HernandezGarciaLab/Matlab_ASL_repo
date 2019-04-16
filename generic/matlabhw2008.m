% This assignment consists of a tutorial that will expose you to the 
% key concepts in matlab that you typically use in FMRI time series
% analysis
% 
% this assignment needs the following files in the working directory:
% read_hdr.m, read_img.m, spm_hrf.m, tmp.hdr, tmp.img, SPM_fMRIDesMtx.mat 
% The "mfiles" directory also contains a lot of useful programs for future use.
% Please verify that you have those before beginging the exercise.
%
% Type these in line by line and paste the output below the line. Note how matlab
% behaves. YOU WILL ENCOUNTER ERRORS.  When you do, please indicate what's
% wrong and how to fix it.
%
% whenever you find several question marks (???) it means that you need to fill
% in the blank
%
% What to turn in:
% 
% Fill in the blanks and answer the questions.  Place your answers in a comment (that
% means preceeded by a % ).
% When you are finished, email this file to hernan@umich.edu and put this in the subjecct line:
%   FMRI2008_homework
%
%

% Exercise 0:  Familiarize yourself with navigating the file system and path
%
% When you are in matlab, whatever you do - execute commands, access data
% ...etc.  applies to a specific location in the file system (a.k.a. the
% directory tree).  You can move up and down the directory tree using the
% command "cd" (change directory).  "pwd"  tells you where you are.
% Try these and notice what happens (you don't need to write anything)

cd c:\tmp\

pwd

% You can do the same thing from the user interface (The Matlab Window)
% Can you find how to navigate through the directory tree without these
% commands? (I know you can - you don't have to give me an answer to this)


% Matlab executes a bunch of programs that live in specific locations in the computer.
% Matlab needs to know where those programs are, so it can load them and execute them  
% When you write your own matlab programs, you need to let Matlab know where to find them.
% All of this is done by a list of directories that Matlab keeps stored in its settings.
% this list of directories are called "the path".  You can set the path by clicking 
% "File" | "Preferences"
% in the matlab command window.  In the command line, you can do the same by typing 

addpath(' something ...')

% You can check that the path is set correctly by typing 
path

% Can you find how to do the same things from the user interface?
% The actual exercise:  set the path so that it includes the directory "mfiles" that has been
% provided to you for this exercises.  It contains a number of matlab programs that will be 
% necessary later on...



% Exercise 1:  Variables and their types - A few basics
a = 1

a

% note what happens with the semicolon:  it suppresses the output to the screen
a = 1;

% Matlab treats evrything like a matrix.  Let's make a matrix by hand:
a = [1 2 3 ; 4 5 6 ; 7 8 9; 10 11 12]

% now that we have a matrix, let's get a sense for how the data
% is stored and accessed in the matrix

a(1)

a(1,3)

a(:,2)

a(2,:)

a(:)

a(2:end, :)

% so now you see how you can access the different elements, rows, and columns of a matrix

% Let's try doing things to matrices, i.e. changing their values, and doing operations on them:
% The "whos" command tells you the dimensions of the matrix.  It's very useful when you have errors
% debug

a'

a = [1:3:100]

% transposing a matrix:
whos a

a = a'

whos a

% This is how we do simple operations on the data.  Everything is a matrix in matlab
% so the operations are by default matrix operations!!  watch out for that.  It takes a 
% little getting used to

a = a/10

b = a + 10

c = [1:3]

% this is a Matrix multiplication:
a * b

a * b'

% this is an element by element multiplication (note that "*" is not the same as ".*" )

a .* b

a ./ c

% Let's play with the graphics now:

figure

plot(a)

figure
plot(sin(a))

figure
plot(a, sin(a))

% note all the different menus you get on the figure.  Note all thw ways you can export your figure
% can you find in the menu how to write your figure out as a JPEG file?
% Save it in your directory.

b = 3 * ones(size(a))

c = a .* b;

whos c

figure
plot(c)

% A little review: practice a little more with the operators: 

c = a * b;

whos a b

c = a' * b ;

whos c

c = a * b';

whos c

figure
imagesc(c)

% now let's get rid of stuff
who

clear b c

whos

clear all

whos

close 

close all

% Let's look at how matlab handles text:  a "string" is a bunch of characters.
% matlab treat strings it as a matrix full of characters

string = 'SPM_fMRIDesMtx'

whos string

% this will concatenate two matrices together:

string = [string '.mat']

path_string = pwd

% The sprintf command is a very useful way to create strings from data:
% this will come in handy later in the tutorial ... and in your programming life.
% Here is an example of how to use it:

string = sprintf('Some stuff %s/%s', path_string, string)

% Note what just happened here and  read the documentation on sprintf 
% - if you are a C programmer, you'll note that it works the same way....

help sprintf

string = sprintf('vol_blahblahblah_%04d.img', 45)

% Let's get some data from a file and play with it:
% The following file comes from SPM and it contains information about an analysis
% Before doing this exercise, make sure you have a file called
% SPM_fMRIDesMtx.mat'
% cd to whatever directory that file is.

string = 'SPM_fMRIDesMtx'
load (string)

% Let's look at the variables that were stored in the file:
whos

% xX is a structure.  Matlab  let's you use data structures to store many different kinds of
% data into a single variableThis is useful when you want to organize your
% data so that you can move it around easily.
%
% explore the structure xX.  It contains a bunch of elements.
% structures are useful because they help you lump a bunch of data into a 
% single variable that you can manage more easily.

xX

% let's focus on the matrix X, which is part of the structure xX
% Create a variable to store that matrix:

X = xX.X

figure

% Let's have a look at it, The variable X contains a "desgin matrix" (You'll learn about design matrices soon in class...):

imagesc(X)

%  Let's look at individual regressors. (we're jumping ahead a bit, but you can ask an instructor about what they
%  mean in FMRI analysis

r1 = X(:,1); 

r2 = X(:,2);

figure

plot(r1,'r');

% this command keeps the current plot and let's you add things on top of it:
hold on

plot(r2, 'b');

hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exercise 2 : creating a model for the BOLD signal corresponding to 
% a train of stimuli.  You will have to fill in the blanks at times.

% BUT ....before we start this exercise ... let's go over a important concept:
% Just like in math, a function in matlab is a set of operations that take some input and return some output.  
% In matlab you call a function like this:
%  output = function_name(input1, input2, ....)
% for example:
t = [0:0.1:10];
y = sin(t)
% We'll write our own functions later. (The programs in the mfiles directory are 
% mostly functions ...)

% OK, let's begin our exercise now...

% Our resolution will be 100 points per second.
points = 100;

% create the HRF using SPM's function "spm_hrf.m". Let's read about it
% first.

help spm_hrf

% note that all the paramaters you enter must be in units of seconds
% TR stands for "repetition time".  It is the time it takes to collect a 
% single image and it determines how finely the FMRI data are sampled in
% time.  Typical TRs are about 2 seconds.

% Now use the function to create a single response
% Fill in the blank  (the ???? , that is):

hrf = spm_hrf( ??? );

subplot 311, plot(hrf),title('Response to a single stimulus')

% now do it again in units of 1/100 of a second, ie = TR = 1/100, 
% or 1/points

hrf = spm_hrf( ??? );

subplot 311, plot(hrf),title('Response to a single stimulus')


% create a set of stimuli occurring at random times 
% in the time series.  First make an array of zeros,
% then put ones where you want to have stimuli occur

stim=zeros(50*points,1);

stim( 5*points:13*points:end ) =1;

subplot 312, plot(stim),title('A set of stimuli at randomized times')


% convolve the input and the HRF and clip out the end (empty)
% first note what the convolution operation does 

help conv
% (ask an instructor if you want to know more):

resp = conv(stim, hrf);

% Note the size s of the inputs and the outputs to the function:

whos resp stim hrf

% clip the end of the response function and plot it

resp = resp(1:length(stim));

subplot 313, plot(resp),title('Response to the set of stimuli')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Problem 3 : reading in a time series of images from a single file and 
% displaying the images
%
% Start out by making sure that your path includes the directory where you
% placed the *.m files that go with this course
%
% Welcome to the Analyze format: the data and the header information are in separate files.
% You have been given a time series of images in a pair of Analyze format (AVW) files.
% tmp.hdr contains information about the dimensions of the data, and tmp.img contains
% the actual data. can you locate them?  YOu'll need to navigate to the directory
% where they are in order to access the data
%
% Take a little time to familiarize yourself with the the header information.  
% My program puts all the header information in a structure with many fields, 

help read_hdr

hdr = read_hdr('tmp.hdr')

% these are the most important ones (but there are many others also important)
% Let's stick them into their own variables

xdim = hdr.xdim;
ydim = hdr.ydim;
zdim = hdr.zdim;
tdim = hdr.tdim;

% Reading the contents of a binary file with matlab.
% Let's open the file containing the actual data
% and read it into memory.  The header info is very important!

% Note .  matlab can store and read data using it's own format as .mat files
% However, often data is not stored in .mat files, so you need to open and read the files
% manually using fopen , fread and fclose.  Analyze images are a very useful example of that.
% so let's first learn how to read them ...  Look up the documentation in 
% a few useful commands.

help fopen

help fread 

help fclose

pF = fopen('tmp.img','rb','ieee-be');


timeseries = fread(pF, [xdim*ydim*zdim*tdim], 'short')'; 

fclose(pF);

whos timeseries

% As you can see from the results of the whos command,
% when you read the data, it comes in as a long string of numbers. ie - all the rows of pixels
% have been concatenated sequentially over each slice and over each time point. 
% (That's just the way computers store information in the disk.)
%
% We'll have to reorganize the data a little bit in order to do the kinds of operations 
% we want to do to the time series.  Luckily Matlab has a bunch of built in functions that let you
% reshape matrices at will with a single command!

% Let's make sure that the file contains a time series.  Here is an example of the use of "if"
% notice the syntax of the " if .... end " code

if tdim >=2

    % we'll take the time series that is all concatenated in a VERY long row and 
    % break it up into a 2D matrix, where each row contains one image from the time series
    % recall the lecture from friday?

    timeseries = reshape(timeseries, xdim*ydim*zdim, tdim);

    timeseries = timeseries';

end


whos timeseries

% Let's try to extract a time course from the pixel at coordinates 28,10,25
% we first need to figure where that pixel is stored in each row of the matrix:
% the sub2ind ("subscript to index") command does just that for you .  Read
% carefully how it works:

help sub2ind

% Fill in the blanks here - essentially tell it the dimensions of the 3D matrix that got
% stretched out into the single row:

index = sub2ind([???], 28, 10, 25)

% Now that we know where that pixel is in each row of the matrix, extracting the time series is 
% simple.  Let's have a look at it:

figure
plot(timeseries(:,index ))
title('time series at pixel 28,10,25')

% Let's now display an image out of the time series.  Begin by extracting that image into
% a variable the we can play with:

oneFrame = timeseries( 5,:);

whos oneFrame

%  As you can tell, the image is all stretched out into a single row,  let's
% reorganize it into a 3D matrix (a volume) that we easily manipulate.  there is
% also a very nice matlab command for that purpose:

help reshape 

% Fill in the blanks here.  What are the dimensions of the matrix we want?

oneFrame = reshape(oneFrame, ???? );

whos oneFrame

figure
imagesc(squeeze(oneFrame(:,:,20)))
colormap(gray)

% Let's make a little movie to display the slices.
% Note the use of a for loop and the syntax of it:

for slice=1:zdim
    imagesc(squeeze(oneFrame(:,:,slice)))
    % why did I use the squeeze command in that line?  what does it do?

    % Fill in the blanks the appropriate format code.  
    % Remember how to use the sprintf command?
    title(sprintf('slice number : ????', slice))
    pause(0.1)
    drawnow
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 3B : writing  a function and calling it.  Your job is to 
% create a function in matlab in a separate file and call it from the
% command prompt

% Here is the actual function.  Note the declaration, and the syntax.
% You should always put HELP information in the documentation

% copy and paste all the text from "function" to "return" into a separate
% .m file.   Save it as "orthogonal.m"
% 
% Note that there are some blanks for you to fill before the function
% will work!!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = orthogonal(root, x, y, z)
%
% function result = orthogonal(root, x, y, z)
%
% this function takes a file in analyze format and 
% displays orthogonal sections thru the planes intersecting
% at x,y,z. 
%
% it also displays the time course at the pixel defined by 
% x,y,z
% 
% input parameters:
%          root:  the name of the image file you want without the .img
%          x, y, z : the coordinates of the point at which the three planes
%          intersect.

%figure out the whole name of the header and image files
% and read them.  Note the use of strcat
h = read_hdr(strcat(root,'.hdr'));
raw = read_img(h, (strcat(root,'.img') ));

d = raw(1,:);
d = reshape(d,h.xdim,h.ydim,h.zdim);

colormap(gray)

% display the orthogonal sections
subplot 221, imagesc(squeeze(d(:,:,z))')
hold on
plot(x,y,'+')

subplot 222, imagesc(squeeze(d(:,y,:))')
hold on
plot(x,z,'+')

subplot 223, imagesc(squeeze(d(x,:,:))')
hold on
plot(y,z,'+')

% Fill in the blanks below.  We want to display the time course
% at pixel x,y,z.

subplot 224
pixel = sub2ind(???);
plot(????)
    
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% so that was the function.  Let's use it now:

% when you call matlab help, it's just showing you the comments that
% immediately follow the function declaration, so you can taylor it however you see fit:

help orthogonal

% now use the function to display the contents of tmp.img.  
% --- Make sure that the function is saved in a directory in your path,
% like the "mfles" directory.

orthogonal(???? ,32,32,14)


% Exercise 4:
% Let's write a rough functional connectivity analysis tool.  The objective is to make a map of the 
% correlation coefficient between a pixel of interest and every other pixel in the image
% This is useful because it indicates what pixels belong to a specific network.  "Neurons that are
% wired together fire together".  Hence, their time courses should be correlated

% make sure that you include the mfiles directory in your path:
% this should already be the case, otherwise, use this (fill in the blank)
addpath ???

% start out by using one of the given files to read in the time course into a matrix
% called "rawimgs".  Check out "help read_img"

[rawimgs,hdr] = read_img('tmp.img');

% figure out the position of the pixel of interest in each row and extract its timecourse

seed_pixel = sub2ind([hdr.xdim, hdr.ydim, hdr.zdim], 32, 32, 10)

% recall how to extract a column?
seed = rawimgs( ??? );

numpix = size(rawimgs,2);

% we'll make a map and call it conmap.  start out by creating the map
% of the same directions but filled in with zeros:

conmap = zeros(1,size(rawimgs,2));

warning off

% we'll use a built-in matlab function to compute the correlation coefficient:
help corrcoef

% We will repeat the same operation for every pixel, so a for loop will be helpful here.
% in this for loop, the slowest thing to do is to print output to the screen and make the graphics, 
% if it takes too long, you can remove that code by "commenting it out" - that is,
% put the % sign in front of a line and matlab will ignore that line

for pix=1:size(conmap,2)
	% this is where we compute the correlation
	tmp = corrcoef(seed , rawimgs(:,pix));

	% we only want one element of that output :
	conmap(pix) = tmp(1,2); 

	% this is jsut there to let you know how it's going
	% notice the use of fprintf .  It's the same syntax as sprintf
	fprintf('\r Progress .... %0.2f percent', 100*pix/numpix);

	% every 1000 pixels, plot the time courses for fun
	if (mod(pix,1000) == 0 )
		hold off
		plot(seed)
		hold on
		plot(rawimgs(:,pix),'r');
		title(['correlation coefficient = ' num2str(conmap(pix)) ] )
		drawnow
	end
end

% Let's now write out the connectivity map to an analyze format file pair:
% the output image only has one "frame" or "time point"
% so the header needs to reflect that

hdr.tdim = 1;

% we can use one of the provided functions in the 
write_img('conmap_ints.img',conmap,hdr);

% we want to write the data as decimal point numbers or "floats"
hdr.datatype = 16;
write_img('conmap_floats.img',conmap,hdr);

% Exercise 5: Now use the orthogonal function from the previous exercise
% to look at the images you created:
% conmap_ints and conmap_floats.  What is the difference?  What's going on?

orthogonal( ??? )
orthogonal( ??? )

