% Implementacao do MTD3 com variacao de parametros 
% e medida do numero de segmentos obtidos por movimento
close all
clear

%% Parametros utilizados
l_min = 7.5e3;
l_max = 12.5e3;
step = 100;
W = 5e3;

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
    B = [0.5 0.1 0.15 0.2];
    C = [-0.5 -0.1 -0.15 -0.2];
    combinations = combvec(B, C)';
    numberOfCombinations = length(combinations);    
    for currentCombination = 1:numberOfCombinations
        % metodo de segmentacao
        [x_seg, centerLocs] = ...
            seg_mtd3(S.emg, l_min, l_max, step, W, ...
            combinations(currentCombination,1), combinations(currentCombination,2));
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
save('./out/workspace/numbers/number_MTD3.mat') % salva a workspace atual
