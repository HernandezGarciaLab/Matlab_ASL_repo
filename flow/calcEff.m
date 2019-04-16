function calcEff(pfile)

sprec1(pfile,'com', 'N');
vname = dir('vol*.nii');
aslsub(vname(1).name);
lightbox('mean_phaseDiff')
figure
lightbox('mean_magDiff');

return