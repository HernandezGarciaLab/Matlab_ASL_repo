function h=abline(b,m,varargin)
% FORMAT h = abline(b,m,...)
% Plots y=a*x+b in dotted line
%
% ...  Other graphics options
%
% Like Splus' abline
%
% To plot a horizontal line at y:    abline('h',y)   
% To plot a vertical line at x:      abline('v',x)   
%
% @(#)abline.m	1.4 02/02/13

if (nargin==2) & isstr(b)
  b = lower(b);
else

  if (nargin<1)
    b = 0;
  end
  if (nargin<2)
    m = 0;
  end
  
end

XX=get(gca,'Xlim');
YY=get(gca,'Ylim');

if isstr(b) & (b=='h')

  g=line(XX,[m m],'LineStyle',':',varargin{:});

elseif isstr(b) & (b=='v')

  g=line([m m],YY,'LineStyle',':',varargin{:});

else

  g=line(XX,m*XX+b,'LineStyle',':',varargin{:});

end

if (nargout>0)
  h=g;
end
