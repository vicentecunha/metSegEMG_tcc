%%
%   Variação de parâmetros para MTD1
%
%   Classificação de movimentos utilizando rede neural artificial para
%   diferentes parâmetros no método de segmentação MTD1
%%
close all
clear
%% Base de dados Ninapro

ninaproList = ls('database/ninapro2/S*_E1*');
numberOfSubjects = length(ninaproList);
numberOfChannels = 12;

%% Parâmetros

% Predeterminados
l = 10e3;
r_target = 5.6e-5;

% Possibilidades de combinação a serem testadas
q = [0.8 0.85 0.9 0.95];
T_lim = [0.05 0.1 0.15 0.2];

combinations = combvec(q, T_lim)';
numberOfCombinations = length(combinations);

%% Implementação com treinamento interno a cada voluntário

numberOfCharacteristics = 3; % características utilizadas pela rede neural
internalClassificationCellArray = cell(numberOfCombinations, numberOfSubjects);
predictorsCellArray = cell(numberOfCombinations, numberOfSubjects);
targetsCellArray = cell(numberOfCombinations, numberOfSubjects);
centerLocsCellArray = cell(numberOfCombinations, numberOfSubjects);

for currentSubject = 1:numberOfSubjects
    
    fprintf('currentSubject = %i / %i\n', currentSubject, numberOfSubjects)
    
    % Carrega o voluntário atual
    load (['database/ninapro2/' ninaproList(currentSubject,:)])
    
    % Teste das diferentes combinações
    for currentCombination = 1:numberOfCombinations
        
        fprintf('\tcurrentCombination = %i / %i\n', ...
            currentCombination, numberOfCombinations)
        
        [x_seg, centerLocsCellArray{currentCombination, currentSubject}] = ...
            seg_mtd1(emg, l, combinations(currentCombination,1), r_target, ...
            combinations(currentCombination,2));
        
        % Alvos para treinamento da rede neural
        targetsCellArray{currentCombination, currentSubject} = ...
            identifyClasses(centerLocsCellArray{currentCombination,currentSubject}, stimulus);
        
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
                % Variância
                predictorsCellArray{currentCombination, currentSubject} ...
                    (currentSegment, currentChannel + numberOfChannels) = ...
                    var(x_seg{currentSegment, currentChannel});
                % Frequência mediana
                predictorsCellArray{currentCombination, currentSubject} ...
                    (currentSegment, currentChannel + 2*numberOfChannels) = ...
                    medfreq(x_seg{currentSegment, currentChannel});
            end
        end
        
        % Treinamento de rede neural e resultados de classificação
        internalTrainedNet = ...
            train(patternnet(10,'trainscg'), ...
            predictorsCellArray{currentCombination, currentSubject}', ...
            targetsCellArray{currentCombination, currentSubject}');
        
        internalClassificationCellArray{currentCombination, currentSubject} = ...
            internalTrainedNet(predictorsCellArray{currentCombination,currentSubject}');
        
        plotconfusion(targetsCellArray{currentCombination, currentSubject}', ...
            internalClassificationCellArray{currentCombination, currentSubject}, ...
            ['Current Subject: ' num2str(currentSubject) ...
            ' Current Combination: ' num2str(currentCombination)]);
        
        % Salva plot da matriz de confusão
        savefig(['./out/confusion/S' num2str(currentSubject) ...
            '_C' num2str(currentCombination) '_MTD1.fig'])
    end
end

%% Salva a workspace atual
save('./out/workspace/MTD1.mat')

%% Implementação com treinamento global

globalClassificationCellArray = cell(numberOfCombinations, 1);
globalPredictorsCellArray = cell(numberOfCombinations, 1);
globalTargetsCellArry = cell(numberOfCombinations, 1);

for currentCombination = 1:numberOfCombinations
    
    fprintf('\tcurrentCombination = %i / %i\n', ...
            currentCombination, numberOfCombinations)
    
    % Concatenação de todos os voluntários
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
    
    % Treinamento de rede neural e resultados de classificação
    globalTrainedNet = ...
        train(patternnet(10,'trainscg'), ...
        globalPredictorsCellArray{currentCombination, 1}', ...
        globalTargetsCellArry{currentCombination, 1}');
    
    globalClassificationCellArray{currentCombination, 1} = ...
        globalTrainedNet(globalPredictorsCellArray{currentCombination, 1}');
    
    plotconfusion(globalTargetsCellArry{currentCombination, 1}', ...
        globalClassificationCellArray{currentCombination, 1}, ...
        ['Current Combination: ' num2str(currentCombination)]);
    
    % Salva plot da matriz de confusão
    savefig(['./out/confusion/S' num2str(currentSubject) '_global_MTD1.fig'])
    
end



