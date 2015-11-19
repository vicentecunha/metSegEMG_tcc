% clear

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

combinations = cell(4,1);
corr_coefs = cell(4,3);

q = [0.75 0.8 0.85 0.9 0.95];
T_lim = [0.05 0.1 0.15 0.2 0.25];
combinations{1,1} = combvec(q, T_lim)';

A = [20 30 40];
B = [2 5 8];
C = [2 5 8];
combinations{2,1} = combvec(A, B, C)';

B = 0.05:0.05:0.25;
C = -0.05:-0.05:-0.25;
combinations{3,1} = combvec(B, C)';

combinations{4,1} = (0.01:0.01:0.25)';
chosenIndex = zeros(4,1);

%% CALCULOS
for currentMethod = 1:4
    load(['./out/workspace/complete_MTD' num2str(currentMethod)])
    
    segMean{currentMethod,1} = squeeze(mean(numberOfSegPerClass,2));
    segMode{currentMethod,1} = squeeze(mode(numberOfSegPerClass,2));
    segMeanMean{currentMethod,1} = squeeze(mean(segMean{currentMethod,1},2));
    segModeMode{currentMethod,1} = squeeze(mode(segMode{currentMethod,1},2));
    concat{currentMethod,1} = [segMeanMean{currentMethod,1} segModeMode{currentMethod,1}];
    
    switch(currentMethod)
        case 1
            numberOfCombinations = 25;
            numberOfParams = 2;
        case 2
            numberOfCombinations = 27;
            numberOfParams = 3;
        case 3
            numberOfCombinations = 25;
            numberOfParams = 2;
        case 4
            numberOfCombinations = 25;
            numberOfParams = 1;
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
    for currentParam = 1:numberOfParams
        corr_coefs{currentMethod, currentParam} = ...
            corrcoef(combinations{currentMethod,1}(:,currentParam),segMeanMean{currentMethod,1});
    end
    
    [chosenMin(currentMethod),chosenIndex(currentMethod)] = min(abs(segMeanMean{currentMethod,1} - 6));
end

r(cellfun('isempty',r)) = {zeros(17,2)};
p(cellfun('isempty',p)) = {zeros(17,2)};
f(cellfun('isempty',f)) = {zeros(17,2)};
rMean = r;
pMean = p;
fMean = f;

fClass = cell(4,1);
fClassNoShit = cell(4,1);
fClassShit = cell(4,1);
fClassFinal = cell(4,17);
fMeansClass= cell(4,1);
for currentMethod = 1:4
    
    switch currentMethod
        case 1
            selectedIndex = 11;
        case 2
            selectedIndex = 18;
        case 3
            selectedIndex = 7;
        case 4
            selectedIndex = 21;
    end
    
    fMat = cell2mat(f(selectedIndex,:,:));
    fClass{currentMethod,1} = sortrows(fMat(:,:,currentMethod),2);
    fClassNoShit{currentMethod,1} = fClass{currentMethod,1}(:,1:2:end);
    fClassShit{currentMethod,1} = fClass{currentMethod,1}(:,2);
    
    fMeansClass{currentMethod} = mean(fClassNoShit{currentMethod,1},2);
end
fMeansClass = cell2mat(fMeansClass');

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

%% PLOT
plot(fMeansClass(:,1),'--+'), hold on,
plot(fMeansClass(:,2),'--o'),
plot(fMeansClass(:,3),'--x'),
plot(fMeansClass(:,4),'--s'), hold off
title('Valor F médio por classe de movimento. Base de dados: NinaPro')
xlabel('Classe de Movimento')
ylabel('Valor F Médio')
ylim([0.45 1])
grid on

% for currentMethod = 1:4
%     if currentMethod == 2
%         numberOfCombinations = 27;
%     else
%         numberOfCombinations = 25;
%     end
%     h = figure()
%     [ax, h1, h2] = plotyy(1:numberOfCombinations,concat{currentMethod,1},1:numberOfCombinations,...
%        fMeanMean(1:numberOfCombinations,currentMethod),'bar','plot');
%     title(['Método de Segmentação: MTD' num2str(currentMethod) '; Base de Dados: NinaPro'])
%     xlabel('Índice da Combinação de Parâmetros')
%     ylabel(ax(1),'Número de Segmentos Obtidos por Classe')
%     ylabel(ax(2),'Valor F Médio')
%     set(ax(1),'YLim',[0 10])
%     set(ax(1),'YTick',0:1:10)
%     set(ax(2),'YLim',[0 1])
%     set(ax(2),'YTick',0:0.1:1)
%     set(ax,'xlim',[0,numberOfCombinations+1]);
%     set(ax(2),'XTick',1:1:numberOfCombinations)
%     set(ax(2),'Xgrid','on')
%     set(ax(2),'Ygrid','off')
% end
