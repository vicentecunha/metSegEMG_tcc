% Implementacao do MTD2 com variacao de parametros 
% e medida do numero de segmentos obtidos por movimento
close all
clear

%% Parametros utilizados
l = 10e3;

%% Base de dados Ninapro

ninaproList = ls('database/ninapro2/S*_E1*');
numberOfSubjects = length(ninaproList);
numberOfClasses = 17;

%% Teste das diferentes combinacoes
numberOfSegments = zeros(numberOfCombinations,numberOfSubjects,numberOfClasses);
parfor_progress(numberOfSubjects);
parfor currentSubject = 1:numberOfSubjects
    S = load (['database/ninapro2/' ninaproList(currentSubject,:)]);
    % Combinacoes a serem testadas
    A = [20 30 40];
    B = [2 5 8];
    C = [2 5 8];
    combinations = combvec(A, B, C)';
    numberOfCombinations = length(combinations);
    for currentCombination = 1:numberOfCombinations
        % metodo de segmentacao
        [x_seg, centerLocs] = ...
            seg_mtd2(S.emg, l, combinations(currentCombination,1), ...
            combinations(currentCombination,2), combinations(currentCombination,3));
        % identificacao do movimento correspondente a cada segmento
        targetClasses = identifyClasses(centerLocs, S.stimulus);
        % numero de segmentos obtidos por movimento
        for currentClass = 1:numberOfClasses
            numberOfSegments(currentCombination,currentSubject,currentClass) = ...
                length(find(targetClasses(:,currentClass)));
        end
    end
    S = []; % libera espaco da memoria
    parfor_progress; % exibe progresso do parfor
end
meanNumberOfSegments = squeeze(mean(numberOfSegments,2));
save('./out/workspace/numbers/number_MTD2.mat') % salva a workspace atual