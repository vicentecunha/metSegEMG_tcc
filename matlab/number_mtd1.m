% Implementacao do MTD1 com variacao de parametros 
% e medida do numero de segmentos obtidos por movimento
close all
clear

%% Parametros utilizados
% Predeterminados
l = 10e3;
r_target = 5.6e-5;
% Combinacoes a serem testadas
q = [0.8 0.85 0.9 0.95];
T_lim = [0.05 0.1 0.15 0.2];
combinations = combvec(q, T_lim)';
numberOfCombinations = length(combinations);

%% Base de dados Ninapro

ninaproList = ls('database/ninapro2/S*_E1*');
numberOfSubjects = length(ninaproList);
numberOfClasses = 17;

%% Teste das diferentes combinacoes
numberOfSegments = zeros(numberOfCombinations,numberOfSubjects,numberOfClasses);
for currentSubject = 1:numberOfSubjects    
    fprintf('currentSubject = %i / %i\n', currentSubject, numberOfSubjects)
    load (['database/ninapro2/' ninaproList(currentSubject,:)])
    for currentCombination = 1:numberOfCombinations
        fprintf('\tcurrentCombination = %i / %i\n', ...
            currentCombination, numberOfCombinations)
        % metodo de segmentacao
        [~, centerLocs] = ...
            seg_mtd1(emg, l, combinations(currentCombination, 1), ...
            r_target, combinations(currentCombination, 2));
        % identificacao do movimento correspondente a cada segmento
        targetClasses = identifyClasses(centerLocs, stimulus);
        % numero de segmentos obtidos por movimento
        for currentClass = 1:numberOfClasses
            numberOfSegments(currentCombination,currentSubject,currentClass) = ...
                length(find(targetClasses(:,currentClass)));
        end
    end
end
save('./out/workspace/number_MTD1.mat') % salva a workspace atual