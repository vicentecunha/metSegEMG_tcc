% Implementacao do MTD2 com variacao de parametros 
% e resultados para calssificacao utilizando RNA
close all
clear

%% Parametros utilizados
l = 10e3;

%% Seleção da base de dados (manter uma opção comentada)
% Base de dados Ninapro
% database = 'ninapro';
% path = 'database/ninapro2/';
% subjectList = ls([path 'S*_E1*']);
% numberOfSubjects = 40;

% Base de dados IEE
database = 'iee';
path = 'database/IEE/';
subjectList = ls([path '*.mat']);
numberOfSubjects = 10;

%% Implementação
numberOfClasses = 17;
numberOfCombinations = 27;
numberOfChannels = 12;
classificationOutput = cell(numberOfCombinations, numberOfSubjects);
targetsOutput = cell(numberOfCombinations, numberOfSubjects);
predictorsOutput = cell(numberOfCombinations, numberOfSubjects);

parfor_progress(numberOfSubjects);
parfor currentSubject = 1:numberOfSubjects
    parfor_progress; % exibe progresso do parfor
    S = load ([path subjectList(currentSubject,:)]);
    L = length(S.emg);
    
    % Combinacoes a serem testadas
    A = [20 30 40];
    B = [2 5 8];
    C = [2 5 8];
    combinations = combvec(A, B, C)';

    for currentCombination = 1:numberOfCombinations
        % metodo de segmentacao
        [x_seg, centerLocs] = ...
            seg_mtd2(S.emg, l, combinations(currentCombination,1), ...
            combinations(currentCombination,2), combinations(currentCombination,3));
        % identificacao do movimento correspondente a cada segmento
        if strcmp(database, 'ninapro')
            targetClasses = identifyClasses(centerLocs, database, S.stimulus);
        else
            targetClasses = identifyClasses(centerLocs, database, L);
        end        
        targetsOutput{currentCombination, currentSubject} = targetClasses;
        
       % Divisao de grupos para treinamento
        numberOfSegments = length(centerLocs);
        numberOfTrainPerClass = sum(targetClasses,1);
        numberOfTrainPerClass(numberOfTrainPerClass == 2) = ...
            numberOfTrainPerClass(numberOfTrainPerClass == 2) - 1;
        numberOfTrainPerClass(numberOfTrainPerClass > 2) = ...
            numberOfTrainPerClass(numberOfTrainPerClass > 2) - 2;
        
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
end
save('./out/workspace/numbers/complete_MTD2_IEE.mat') % salva a workspace atual
numberOfSegPerClass = zeros(numberOfCombinations,numberOfSubjects,numberOfClasses);
for currentSubject = 1:numberOfSubjects
    for currentCombination = 1:numberOfCombinations
        numberOfSegPerClass(currentCombination,currentSubject,:) = ...
            sum(targetsOutput{currentCombination,currentSubject});
    end
end
save('./out/workspace/complete_MTD2_IEE.mat') % salva a workspace atual