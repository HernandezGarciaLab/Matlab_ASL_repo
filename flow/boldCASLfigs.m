load ('~hernan/data/flow/040121_simplest/BOLD/BOLD.mat')
load ('~hernan/data/flow/040121_simplest/CASL/CASL.mat')


sl=3
window = [0 30]
subplot(231), show(-pact(:,:,sl)', window), title('Active perfusion') , dofontsize(14)
subplot(232), show(-prest(:,:,sl)', window), title('Resting perfusion'), dofontsize(14)
subplot(233), show(prest(:,:,sl)'-pact(:,:,sl)', window), title('Perfusion Difference'), dofontsize(14)

window = [0 6000]
subplot(234), show(BOLD_act(:,:,sl)', window), title('Active BOLD')  ,dofontsize(14)
subplot(235), show(BOLD_rest(:,:,sl)', window), title('Resting BOLD'), dofontsize(14)
window = [0 300]
subplot(236), show(BOLD_act(:,:,sl)'-BOLD_rest(:,:,sl)', window), title('BOLD Difference'), dofontsize(14)

colormap(hot)

print -djpeg BOLD.CASL.difference.png
