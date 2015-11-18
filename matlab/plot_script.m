clear

numberOfSubjects = 10;
segMode = cell(4,1);
segMean = cell(4,1);
segMeanMean = cell(4,1);
segModeMode = cell(4,1);
concat = cell(4,1);
per = zeros(27,numberOfSubjects,17,4,4);
r = cell(27,numberOfSubjects,4);
p = cell(27,numberOfSubjects,4);
f = cell(27,numberOfSubjects,4);

for currentMethod = 1:4
    load(['./out/workspace/complete_MTD' num2str(currentMethod) '_IEE'])
    
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
                p{currentCombination,currentSubject,currentMethod} = [stats.precision unique(targetLabels)];
                f{currentCombination,currentSubject,currentMethod} = [stats.Fscore unique(targetLabels)];
                
                for row = 1:17
                    if row > length(r{currentCombination,currentSubject,currentMethod}(:,1))
                        r{currentCombination,currentSubject,currentMethod} = ...
                            [r{currentCombination,currentSubject,currentMethod}; 0 row];
                        p{currentCombination,currentSubject,currentMethod} = ...
                            [p{currentCombination,currentSubject,currentMethod}; 0 row];
                        f{currentCombination,currentSubject,currentMethod} = ...
                            [f{currentCombination,currentSubject,currentMethod}; 0 row];
                    end
                    if r{currentCombination,currentSubject,currentMethod}(row,2) ~= row
                        r{currentCombination,currentSubject,currentMethod} = ...
                            [0 row; r{currentCombination,currentSubject,currentMethod}];
                        r{currentCombination,currentSubject,currentMethod} = ...
                            sortrows(r{currentCombination,currentSubject,currentMethod},2);
                    end
                    if p{currentCombination,currentSubject,currentMethod}(row,2) ~= row
                        p{currentCombination,currentSubject,currentMethod} = ...
                            [0 row; p{currentCombination,currentSubject,currentMethod}];
                        p{currentCombination,currentSubject,currentMethod} = ...
                            sortrows(p{currentCombination,currentSubject,currentMethod},2);
                    end
                    if f{currentCombination,currentSubject,currentMethod}(row,2) ~= row
                        f{currentCombination,currentSubject,currentMethod} = ...
                            [0 row; f{currentCombination,currentSubject,currentMethod}];
                        f{currentCombination,currentSubject,currentMethod} = ...
                            sortrows(f{currentCombination,currentSubject,currentMethod},2);
                    end
                    if isnan(p{currentCombination,currentSubject,currentMethod}(row,1))
                        p{currentCombination,currentSubject,currentMethod}(row,1) = 0;
                    end
                end
                
            end
        end
    end
   
end

r(cellfun('isempty',r)) = {zeros(17,2)};
p(cellfun('isempty',p)) = {zeros(17,2)};
f(cellfun('isempty',f)) = {zeros(17,2)};
rMean = r;
pMean = p;
fMean = f;
for currentCombination = 1:27
    for currentSubject = 1:numberOfSubjects
        for currentMethod = 1:4
            rMean{currentCombination,currentSubject,currentMethod} = ...
                mean(r{currentCombination,currentSubject,currentMethod}(:,1));
            pMean{currentCombination,currentSubject,currentMethod} = ...
                mean(p{currentCombination,currentSubject,currentMethod}(:,1));
            fMean{currentCombination,currentSubject,currentMethod} = ...
                mean(f{currentCombination,currentSubject,currentMethod}(:,1));
        end
    end
end
rMean = cell2mat(rMean);
rMeanMean = squeeze(mean(rMean,2));
pMean = cell2mat(pMean);
pMeanMean = squeeze(mean(pMean,2));
fMean = cell2mat(fMean);
fMeanMean = squeeze(mean(fMean,2));

for currentMethod = 1:4
    if currentMethod == 2
        numberOfCombinations = 27;
    else
        numberOfCombinations = 25;
    end
    h = figure()
    [ax, h1, h2] = plotyy(1:numberOfCombinations,concat{currentMethod,1},1:numberOfCombinations,...
       fMeanMean(1:numberOfCombinations,currentMethod),'bar','plot');
    title(['Método de Segmentação: MTD' num2str(currentMethod) '; Base de Dados: IEE'])
    xlabel('Índice da Combinação de Parâmetros')
    ylabel(ax(1),'Número de Segmentos Obtidos por Classe')
    ylabel(ax(2),'Valor F Médio')
    set(ax(1),'YLim',[0 10])
    set(ax(1),'YTick',0:1:10)
    set(ax(2),'YLim',[0 1])
    set(ax(2),'YTick',0:0.1:1)
    set(ax,'xlim',[0,26]);
    set(ax(2),'XTick',1:1:25)
    set(ax(2),'Xgrid','on')
    set(ax(2),'Ygrid','off')
end
