function f = indind(et,etimes1,etimes2)
% usage .. indind(et,etimes1,etimes2)

out = zeros(size(et));
for lp = 1:length(etimes1)
  out = out+(et < etimes1(lp)).*(et > etimes2(lp));
end
f = find(out);
