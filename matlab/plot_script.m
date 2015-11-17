close all
clear

numberOfSubjects = 40;
segMode = cell(4,1);
segMean = cell(4,1);
segMeanMean = cell(4,1);
segModeMode = cell(4,1);
concat = cell(4,1);
per = zeros(27,40,17,4,4);
r = cell(27,40,4);

for currentMethod = 1:4
    load(['./out/workspace/complete_MTD' num2str(currentMethod)])
    
    segMean{currentMethod,1} = squeeze(mean(numberOfSegPerClass,2));
    segMode{currentMethod,1} = squeeze(mode(numberOfSegPerClass,2));
    segMeanMean{currentMethod,1} = squeeze(mean(segMean{currentMethod,1},2));
    segModeMode{currentMethod,1} = squeeze(mode(segMode{currentMethod,1},2));
    concat{currentMethod,1} = [segMeanMean{currentMethod,1} segModeMode{currentMethod,1}];
    
    if currentMethod == 2
        numberOfCombinations = 27;
    else
        numberOfCombinations = 25;
    end
    
    for currentSubject = 1:numberOfSubjects
        for currentCombination = 1:numberOfCombinations
            if ~isempty(classificationOutput{currentCombination,currentSubject})
                
                [numberOfSegments,numberOfClasses] = size(targetsOutput{currentCombination,currentSubject});
                targetLabels = zeros(numberOfSegments,1);
                outLabels = zeros(numberOfSegments,1);
                for currentClass = 1:numberOfClasses
                    for currentSegment = 1:numberOfSegments
                        if(targetsOutput{currentCombination,currentSubject}(currentSegment,currentClass))
                            targetLabels(currentSegment) = currentClass;
                            [~, outLabels(currentSegment)] = max(classificationOutput{currentCombination,currentSubject}(:,currentSegment));
                        end
                    end
                end

                stats = confusionmatStats(confusionmat(targetLabels,outLabels));
                r{currentCombination,currentSubject,currentMethod} = [stats.recall unique(targetLabels)];
                
                for row = 1:17
                    if row > length(r{currentCombination,currentSubject,currentMethod}(:,1))
                        r{currentCombination,currentSubject,currentMethod} = ...
                            [r{currentCombination,currentSubject,currentMethod}; 0 row];
                    end
                    if r{currentCombination,currentSubject,currentMethod}(row,2) ~= row
                        r{currentCombination,currentSubject,currentMethod} = ...
                            [0 row; r{currentCombination,currentSubject,currentMethod}];
                        r{currentCombination,currentSubject,currentMethod} = ...
                            sortrows(r{currentCombination,currentSubject,currentMethod},2);
                    end
                end
                
            end
        end
    end
   
end

r(cellfun('isempty',r)) = {zeros(17,2)};
rMean = r;
for currentCombination = 1:27
    for currentSubject = 1:numberOfSubjects
        for currentMethod = 1:4
            rMean{currentCombination,currentSubject,currentMethod} = ...
                mean(r{currentCombination,currentSubject,currentMethod}(:,1));
        end
    end
end
rMean = cell2mat(rMean);
rMeanMean = squeeze(mean(rMean,2));

for currentMethod = 1:4
    if currentMethod == 2
        numberOfCombinations = 27;
    else
        numberOfCombinations = 25;
    end
    figure()
    plotyy(1:numberOfCombinations,concat{currentMethod,1},1:numberOfCombinations,...
        rMeanMean(1:numberOfCombinations,currentMethod),'bar','plot')
end
