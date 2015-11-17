% close all
% clear

numberOfSubjects = 40;
per = zeros(27,40,17,4,4);
truePositivesCell = cell(4,1);
trueNegativesCell = cell(4,1);
c = zeros(27,40,4);

for currentMethod = 1:4
    load(['./out/workspace/complete_MTD' num2str(currentMethod)])
    if currentMethod == 2
        numberOfCombinations = 27;
    else
        numberOfCombinations = 25;
    end
    for currentSubject = 1:numberOfSubjects
        for currentCombination = 1:numberOfCombinations
            if ~isempty(classificationOutput{currentCombination,currentSubject})
                [c(currentCombination,currentSubject,currentMethod),~,~,per(currentCombination,currentSubject,:,:,currentMethod)] = ...
                    confusion(targetsOutput{currentCombination,currentSubject}',...
                    classificationOutput{currentCombination,currentSubject});
            end
        end
    end
    meanPer = squeeze(mean(per,2));
    falseNegatives = squeeze(meanPer(:,:,1,:));
    falsePositives = squeeze(meanPer(:,:,2,:));
    truePositives = squeeze(meanPer(:,:,3,:));
    trueNegatives = squeeze(meanPer(:,:,4,:));
    
    truePositivesCell{currentMethod,1} = round(100*truePositives(:,:,currentMethod),1);
    trueNegativesCell{currentMethod,1} = round(100*trueNegatives(:,:,currentMethod),1);
    notConfusion = ()
end

