close all
clear

numberOfSubjects = 40;
per = zeros(27,40,17,4,2);

for currentMethod = 1:2
    load(['./out/workspace/complete_MTD' num2str(currentMethod)])
    if currentMethod == 2
        numberOfCombinations = 27;
    else
        numberOfCombinations = 25;
    end
    for currentSubject = 1:numberOfSubjects
        for currentCombination = 1:numberOfCombinations
            if ~isempty(classificationOutput{currentCombination,currentSubject})
                [~,~,~,per(currentCombination,currentSubject,:,:,currentMethod)] = ...
                    confusion(targetsOutput{currentCombination,currentSubject}',...
                    classificationOutput{currentCombination,currentSubject});
            end
        end
    end
    meanPer = squeeze(mean(per,2));
    falseNegatives = squeeze(meanPer(:,:,1,:));
    falsePositives = squeeze(meanPer(:,:,2,:));
    truePositives = squeeze(meanPer(:,:,3,:));
    trueNegatives = squeeze(meanPer(:,:,3,:));
end
