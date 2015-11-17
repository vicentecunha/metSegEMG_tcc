close all
clear

numberOfSubjects = 40;
segMode = cell(4,1);
segMean = cell(4,1);

for currentMethod = 1:4
    load(['./out/workspace/complete_MTD' num2str(currentMethod)])
    segMean{currentMethod,1} = round(squeeze(mean(numberOfSegPerClass,2)),1);
    segMode{currentMethod,1} = squeeze(mode(numberOfSegPerClass,2)),1;
end
