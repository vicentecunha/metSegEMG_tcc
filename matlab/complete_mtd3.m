% Implementacao do MTD3 com variacao de parametros 
% e resultados para calssificacao utilizando RNA
close all
clear

%% Parametros utilizados
l_min = 7.5e3;
l_max = 12.5e3;
step = 100;
W = 5e3;

%% Base de dados Ninapro
ninaproList = ls('database/ninapro2/S*_E1*');
numberOfSubjects = 40;
numberOfClasses = 17;
numberOfCombinations = 25;
numberOfChannels = 12;
classificationOutput = cell(numberOfCombinations, numberOfSubjects);
targetsOutput = cell(numberOfCombinations, numberOfSubjects);
predictorsOutput = cell(numberOfCombinations, numberOfSubjects);

parfor_progress(numberOfSubjects);
parfor currentSubject = 1:numberOfSubjects
    S = load (['database/ninapro2/' ninaproList(currentSubject,:)]);
    
    % Combinacoes a serem testadas
    B = 0.05:0.05:0.25;
    C = -0.05:-0.05:-0.025;
    combinations = combvec(B, C)';

    for currentCombination = 1:numberOfCombinations
        % metodo de segmentacao
        [x_seg, centerLocs] = ...
            seg_mtd3(S.emg, l_min, l_max, step, W, ...
            combinations(currentCombination,1), combinations(currentCombination,2));
        % identificacao do movimento correspondente a cada segmento
        targetClasses = identifyClasses(centerLocs, S.stimulus);
        targetsOutput{currentCombination, currentSubject} = targetClasses;
        
        % Divisao de dados para treinamento
        numberOfSegments = length(targetClasses);
        numberOfTrainPerClass = round(0.7*sum(targetClasses));
        trainIndFlags = false(numberOfSegments,1);
        valIndFlags = false(numberOfSegments,1);
        testIndFlags = false(numberOfSegments,1);
        for currentClass = 1:numberOfClasses
            counter = 0;
            for currentSegment = 1:numberOfSegments
                if targetClasses(currentSegment,currentClass)
                    if counter < numberOfTrainPerClass(currentClass)
                        trainIndFlags(currentSegment) = true;
                    else if counter == numberOfTrainPerClass(currentClass)
                            valIndFlags(currentSegment) = true;
                        else if counter > numberOfTrainPerClass(currentClass)
                                testIndFlags(currentSegment) = true;
                            end
                        end
                    end
                    counter = counter + 1;
                end
            end
        end
        trainInd = find(trainIndFlags);
        valInd = find(valIndFlags);
        testInd = find(testIndFlags);
        
        % Preditores da RNA
        predictors = zeros(numberOfSegments, 3*numberOfChannels);
        for currentSegment = 1:numberOfSegments
            for currentChannel = 1:numberOfChannels
                % RMS
                predictors(currentSegment, currentChannel + 0*numberOfChannels) = ...
                    rms(x_seg{currentSegment, currentChannel});
                % Variancia
                predictors(currentSegment, currentChannel + 1*numberOfChannels) = ...
                    var(x_seg{currentSegment, currentChannel});
                % Frequencia mediana
                predictors(currentSegment, currentChannel + 2*numberOfChannels) = ...
                    medfreq(x_seg{currentSegment, currentChannel});
            end
        end
        predictorsOutput{currentCombination, currentSubject} = predictors; 
        
        % Treinamento de rede neural
        net = patternnet(40,'trainscg');
        net.divideFcn = 'divideind';
        net.divideParam.trainInd = trainInd;
        net.divideParam.valInd = valInd;
        net.divideParam.testInd = testInd;
        trainedNet = train(net, predictors', targetClasses');
        classificationOutput{currentCombination, currentSubject} = ...
            trainedNet(predictors'); % resultados de classificacao
    end
    S = []; % libera espaco da memoria
    parfor_progress; % exibe progresso do parfor
end
save('./out/workspace/numbers/complete_MTD3.mat') % salva a workspace atual
numberOfSegPerClass = zeros(numberOfCombinations,numberOfSubjects,numberOfClasses);
for currentSubject = 1:numberOfSubjects
    for currentCombination = 1:numberOfCombinations
        numberOfSegPerClass(currentCombination,currentSubject,:) = ...
            sum(targetsOutput{currentCombination,currentSubject});
    end
end
meanNumberOfSeg = squeeze(mean(numberOfSegPerClass,2));
save('./out/workspace/complete_MTD3.mat') % salva a workspace atual