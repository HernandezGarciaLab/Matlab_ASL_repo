
%% Build the Design Matrix

%% experiment date:  10.26.09
TR = 4;
doASLmod=1;
exp_duration = 1144;
% 150 * TR;
% add three seconds for instructions on each trial
%shifts = [1:5]*3;

onsets{1} = [
	13
	66
	303
	380
	681
	1046 ] -7;

durations{1} = [
	48
	96
	72
	48
	72
	96];

onsets{2} = [
	167
	468
	604
	758
	870
	958 ] -7 ;

durations{2} = [
	96
	96
	72
	72
	48
	48] ;

onsets{3} = [
	8
	61
	162
	263
	298
	375
	428
	463
	564
	599
	676
	753
	830
	865
	918
	953
	1006
	1041] - 7 ;

durations{3} = ones(size(onsets{3}))*5;


X = buildDesMat(TR, exp_duration, onsets, durations, doASLmod);