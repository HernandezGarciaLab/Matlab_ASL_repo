# Matlab_ASL_repo
Code for analyzing perfusion FMRI data collected with ASL 
Dear users,

This is a Matlab library for many things related to ASL and funcitonal MRI. It also includes reconstruction libraries for spiral data generated at the UM FMRI laboratory by my stack of spirals sequence.

The bulk of you probably want to just process the ASL data that you collected at the lab, so here is the first thing you need to do: step 1: download the software step 2: include all the directories in your path step 3: know where your data are, as well as the acquisition parameters for the pulse sequence. step 4: from the Matlab command line, type : fasl03 . This will start the GUI.

There are several kinds of experiments that you may be processing.

#1 - you collected PCASL data with the stack of spirals sequence and now you want to calculate perfusion images and put them into MNI space.

-select the P-file name in the "input data file" box
-fill out the acquisition parameters below. When in doubt, just leave the defaults.
-check the box that says "stack of spirals reconstruction"
-check the following boxes in "Time series Preprocessing"
  .realignment
  .smoothing
  .subtraction
  .spatial normalization
-check the box that says "quantify CBF"

Under "spatial Transformations" you will need to select images to -coregister to structural: this is usually the anatomical T1 SPGR -Normalise to Template : this is your T1 template from SPM

VERY important: make you sure that you use SPM (or something else) to set the origins on these images. You may also need to do that on the "mean_sub.img" and "SpinDensity.img" that FASL will generate.
when you are all done filling in the blanks, then hit "GO! at the botton of the F-ASL window.

#2 - you collected PCASL data with the General Electric sequence and now you want to calculate perfusion images and put them into MNI space (as in #1).

#3 - you collected an ASL based with the stack of spirals sequence and now you want to calculate your activation maps in MNI space.
 
