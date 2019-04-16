function f = img(y,c)% Syntax f = img(y,c). Use to display grayscale image w/ WinLev Sliders.
% "y" is the real or cmplx array to be displayed in 256-grayscale.
% "c" is an optional argument to choose type of display:
%		c=1 to display abs(y)
%		c=2 to display real(y)
%		c=3 to display imag(y) (i.e. imaginary part)
%		c=4 to display phase(y)
%		c=5 to display magnitude-weighted phase(y)
%		c not specified, <1, or >5 will display abs(y)
% Scales 2D argument up or down to have max of 'Gsteps - 1'.
% Gsteps is the # of graylevels selected for colormap(gray).
% Note, this function doesn't really return any value to LHS of f=img(y).

% TLChenevert 11/19/95
% TLC 3/97: Show transpose of array and lable image.
% TLC 4/97: Dont transpose.
clf; % Clears current figure
global LC WC dummy_2d typ fname;
%clear dummy_2d;
if nargin < 2, c = 1; end
if c == 1
	y1 = abs(y);
	typ = 'Abs; ';
	
elseif c == 2
	y1 = real(y);
	typ = 'Real; ';
	
elseif c == 3
	y1 = imag(y);  % y must be complex for this option
	typ = 'Imag; ';

elseif c == 4
	y1 = 180*angle(y)/pi; % y must be complex for this option
	typ = 'Phase; ';

elseif c == 5
	y1 = abs(y) .* angle(y); % y must be complex for this option
	typ = 'Mag*Phase; ';
	
else
	y1 = abs(y);
	typ = 'Abs; ';
end

Gstep = 256;

% Dummy array scaled & shifted to be 0->Gstep.
mx1 = max(max(y1));
mn1 = min(min(y1));
dummy_2d = (y1 - mn1)*(Gstep-1)/(mx1 - mn1);
mmax = max(max(dummy_2d));
mmin = min(min(dummy_2d));
Lmin = mmin;
Lmax = mmax;
Ldef = (Lmax + Lmin)/2;
Wmin = 0;
Wmax = mmax - mmin;
Wdef = Wmax;

image((dummy_2d - Ldef + (Wdef/2))*(Gstep-1)/Wdef);
title(fname);
colormap(gray(Gstep));
% Now interact via slider
hh = gca;
fig = gcf;
lev = ['global LC WC dummy_2d typ fname;' ...
	'NW = ceil(get(WC,''Value''));' ...
	'NL = ceil(get(LC,''Value''));' ...
   'image((dummy_2d - NL + (NW/2))*255/NW);' ...
   'title([typ,fname]);' ...
   'axis image;'];
	%'title([typ,fname,''Lev='' int2str(NL) '' Win='' int2str(NW)]);'];	
win = ['global LC WC dummy_2d typ fname;' ...
	'NW = ceil(get(WC,''Value''));' ...
	'NL = ceil(get(LC,''Value''));' ...
   'image((dummy_2d - NL + (NW/2))*255/NW);' ...
   'title([typ,fname]);' ...
   'axis image;'];
   %'title([typ,fname,'' Lev='' int2str(NL) '' Win='' int2str(NW)]);'];
%global LC WC dummy_2d;
LC = uicontrol(fig,'Style','slider','Units', 'normalized','Position',[0.95 0.10 0.02 0.25],...
	'Min',Lmin,'Max',Lmax,  ...
	'Value',Ldef,'CallBack',lev,'visible','on');		
WC = uicontrol(fig,'Style','slider','Units', 'normalized','Position',[0.75 0.00 0.25 0.03],...
	'Min',Wmin,'Max',Wmax,  ...
	'Value',Wdef,'CallBack',win,'visible','on');

%clear dummy_2d;
