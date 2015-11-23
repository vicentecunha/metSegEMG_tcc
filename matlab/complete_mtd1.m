% Implementacao dos metodos de segmentacao com variacao de parametros
% e resultados para calssificacao utilizando RNA
close all
clear

%% Selecao da base de dados (manter uma opcao comentada)
% Base de dados Ninapro
% database = 'ninapro';
% path = 'database/ninapro2/';
% subjectList = ls([path 'S*_E1*']);
% numberOfSubjects = 40;
% r_target = 5.6e-5;

% Base de dados IEE
database = 'iee';
path = 'database/IEE/';
subjectList = ls([path '*.mat']);
numberOfSubjects = 10;
r_target = 6.1e-5;

%% Selecao do metodo a ser utilizado e combinacoes a serem testadas
methodToTest = 1;
switch methodToTest
    case 1
        l = 10e3;
        q = [0.75 0.8 0.85 0.9 0.95];
        T_lim = [0.05 0.1 0.15 0.2 0.25];
        combinations = combvec(q, T_lim)';
        combArg1 = combinations(:,1);
        combArg2 = combinations(:,2);
    case 2
        l = 10e3;
        A = [60 80 100];
        B = [2 5 8];
        C = [2 5 8];
        combinations = combvec(A, B, C)';
        combArg1 = combinations(:,1);
        combArg2 = combinations(:,2);
        combArg3 = combinations(:,3);
    case 3
        l_min = 7.5e3;
        l_max = 12.5e3;
        step = 100;
        W = 5e3;
        B = 0.05:0.05:0.25;
        C = -0.05:-0.05:-0.25;
        combinations = combvec(B, C)';
        combArg1 = combinations(:,1);
        combArg2 = combinations(:,2);
    case 4
        l_min = 7.5e3;
        l_max = 12.5e3;
        step = 100;
        W = 5e3;
        
        combinations = (0.01:0.01:0.25)';
end

%% Implementacao
numberOfClasses = 17;
numberOfCombinations = 25;
numberOfChannels = 12;
classificationOutput = cell(numberOfCombinations, numberOfSubjects);
targetsOutput = cell(numberOfCombinations, numberOfSubjects);
predictorsOutput = cell(numberOfCombinations, numberOfSubjects);

parfor_progress(numberOfSubjects);
for currentSubject = 1:numberOfSubjects
    parfor_progress; % exibe progresso do parfor
    S = load ([path subjectList(currentSubject,:)]);
    L = length(S.emg);
    x = S.emg;
    stimulus = S.stimulus;
    
    parfor currentCombination = 1:numberOfCombinations
        % metodo de segmentacao
        switch methodToTest
            case 1
                [x_seg, centerLocs] = ...
                    seg_mtd1(x, l, combArg1(currentCombination), r_target, ...
                    combArg2(currentCombination));
            case 2
                [x_seg, centerLocs] = ...
                    seg_mtd2(x, l, combArg1(currentCombination), ...
                    combArg2(currentCombination), combArg3(currentCombination));
            case 3
                [x_seg, centerLocs] = ...
                    seg_mtd3(x, l_min, l_max, step, W, ...
                    combArg1(currentCombination), combArg2(currentCombination));
            case 4
                [x_seg, centerLocs] = ...
                    seg_mtd4(x, l_min, l_max, step, W, T(currentCombination));
        end
        % identificacao do movimento correspondente a cada segmento
        if strcmp(database, 'ninapro')
            targetClasses = identifyClasses(centerLocs, database, stimulus);
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
save(['./out/workspace/MTD' num2str(methodToTest) '_' database '.mat'])
