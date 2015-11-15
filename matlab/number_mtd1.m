% Implementacao do MTD1 com variacao de parametros 
% e medida do numero de segmentos obtidos por movimento
close all
clear

%% Parametros utilizados
% Predeterminados
l = 10e3;
r_target = 5.6e-5;

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
    q = [0.8 0.85 0.9 0.95];
    T_lim = [0.05 0.1 0.15 0.2];
    combinations = combvec(q, T_lim)';
    numberOfCombinations = length(combinations);
    for currentCombination = 1:numberOfCombinations
        % metodo de segmentacao
        [x_seg, centerLocs] = ...
            seg_mtd1(S.emg, l, combinations(currentCombination,1), r_target, ...
            combinations(currentCombination,2));
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
save('./out/workspace/numbers/number_MTD1.mat') % salva a workspace atual
