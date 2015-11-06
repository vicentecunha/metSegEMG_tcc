% Implementa��o do MTD1 com varia��o de par�metros 
% e medida do n�mero de segmentos obtidos por movimento
close all
clear

%% Par�metros utilizados

% Predeterminados
l = 10e3;
r_target = 5.6e-5;

% Combina��es a serem testadas
q = [0.8 0.85 0.9 0.95];
T_lim = [0.05 0.1 0.15 0.2];
combinations = combvec(q, T_lim)';
numberOfCombinations = length(combinations);

%% Base de dados Ninapro

ninaproList = ls('database/ninapro2/S*_E1*');
numberOfSubjects = length(ninaproList);
numberOfChannels = 12;

%% Implementa��o com treinamento interno a cada volunt�rio

numberOfCharacteristics = 3;
predictorsCellArray = cell(numberOfCombinations, numberOfSubjects);
targetsCellArray = cell(numberOfCombinations, numberOfSubjects);
internalClassificationCellArray = cell(numberOfCombinations, numberOfSubjects);
centerLocsCellArray = cell(numberOfCombinations, numberOfSubjects);

for currentSubject = 1:numberOfSubjects
    
    fprintf('currentSubject = %i / %i\n', currentSubject, numberOfSubjects)
    
    % Carrega o volunt�rio atual
    load (['database/ninapro2/' ninaproList(currentSubject,:)])
    
    % Teste das diferentes combina��es
    for currentCombination = 1:numberOfCombinations
        
        fprintf('\tcurrentCombination = %i / %i\n', ...
            currentCombination, numberOfCombinations)
        
        [x_seg, centerLocsCellArray{currentCombination, currentSubject}] = ...
            seg_mtd1(emg, l, combinations(currentCombination,1), r_target, ...
            combinations(currentCombination,2));
        
        % Alvos para treinamento da rede neural
        targetsCellArray{currentCombination, currentSubject} = ...
            identifyClasses(centerLocsCellArray{currentCombination,currentSubject},stimulus);
        
        % Entradas da rede neural
        numberOfSegments = length(centerLocsCellArray{currentCombination,currentSubject});
        
        predictorsCellArray{currentCombination, currentSubject} = ...
            zeros(numberOfSegments, numberOfCharacteristics*numberOfChannels);
        
        for currentSegment = 1:numberOfSegments         
            for currentChannel = 1:numberOfChannels
                % RMS
                predictorsCellArray{currentCombination, currentSubject} ...
                    (currentSegment, currentChannel) = ...
                    rms(x_seg{currentSegment, currentChannel}); 
                % Vari�ncia
                predictorsCellArray{currentCombination, currentSubject} ...
                    (currentSegment, currentChannel + numberOfChannels) = ...
                    var(x_seg{currentSegment, currentChannel});
                % Frequ�ncia mediana
                predictorsCellArray{currentCombination, currentSubject} ...
                    (currentSegment, currentChannel + 2*numberOfChannels) = ...
                    medfreq(x_seg{currentSegment, currentChannel});
            end
        end
        
        % Treinamento de rede neural e resultados de classifica��o
        internalTrainedNet = ...
            train(patternnet(10,'trainscg'), ...
            predictorsCellArray{currentCombination, currentSubject}', ...
            targetsCellArray{currentCombination, currentSubject}');
        
        internalClassificationCellArray{currentCombination, currentSubject} = ...
            internalTrainedNet(predictorsCellArray{currentCombination,currentSubject}');
        
        % Plot da matriz de confus�o
        plotconfusion(targetsCellArray{currentCombination, currentSubject}', ...
            internalClassificationCellArray{currentCombination, currentSubject}, ...
            ['Current Subject: ' num2str(currentSubject) ...
            ' Current Combination: ' num2str(currentCombination)]);
        savefig(['./out/confusion/S' num2str(currentSubject) ...
            '_C' num2str(currentCombination) '_MTD1.fig'])
    end
end
save('./out/workspace/MTD1.mat') % salva a workspace atual

%% Implementa��o com treinamento global

globalPredictorsCellArray = cell(numberOfCombinations, 1);
globalTargetsCellArry = cell(numberOfCombinations, 1);
globalClassificationCellArray = cell(numberOfCombinations, 1);

for currentCombination = 1:numberOfCombinations
    
    fprintf('\tcurrentCombination = %i / %i\n', ...
            currentCombination, numberOfCombinations)
    
    % Concatena��o de todos os volunt�rios
    globalPredictorsCellArray{currentCombination, 1} = ...
        predictorsCellArray{currentCombination,1};    
    globalTargetsCellArry{currentCombination, 1} = ...
        targetsCellArray{currentCombination, 1};
    
    for currentSubject = 2:numberOfSubjects        
         globalPredictorsCellArray{currentCombination, 1} = ...
             cat(1, globalPredictorsCellArray{currentCombination, 1}, ...
             predictorsCellArray{currentCombination,currentSubject});
         globalTargetsCellArry{currentCombination, 1} = ...
             cat(1, globalTargetsCellArry{currentCombination, 1}, ...
             targetsCellArray{currentCombination,currentSubject});
    end
    
    % Treinamento de rede neural e resultados de classifica��o
    globalTrainedNet = ...
        train(patternnet(10,'trainscg'), ...
        globalPredictorsCellArray{currentCombination, 1}', ...
        globalTargetsCellArry{currentCombination, 1}');
    globalClassificationCellArray{currentCombination, 1} = ...
        globalTrainedNet(globalPredictorsCellArray{currentCombination, 1}');

    % Plot da matriz de confus�o
    plotconfusion(globalTargetsCellArry{currentCombination, 1}', ...
        globalClassificationCellArray{currentCombination, 1}, ...
        ['Current Combination: ' num2str(currentCombination)]);
    savefig(['./out/confusion/C' num2str(currentCombination) '_global_MTD1.fig'])
    
end
save('./out/workspace/MTD1.mat') % salva a workspace atual
