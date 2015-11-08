% Implementação do MTD2 com variação de parâmetros 
% e medida do número de segmentos obtidos por movimento
close all
clear

%% Parâmetros utilizados

% Predeterminados
l = 10e3;

% Combinações a serem testadas
A = [20 30 40];
B = [2 5 8];
C = [2 5 8];
combinations = combvec(A, B, C)';
numberOfCombinations = length(combinations);

%% Base de dados Ninapro

ninaproList = ls('database/ninapro2/S*_E1*');
numberOfSubjects = length(ninaproList);
numberOfClasses = 17;

%% Teste das diferentes combinações
numberOfSegments = zeros(numberOfCombinations,numberOfSubjects,numberOfClasses);
for currentSubject = 1:numberOfSubjects    
    fprintf('currentSubject = %i / %i\n', currentSubject, numberOfSubjects)
    load (['database/ninapro2/' ninaproList(currentSubject,:)])
    for currentCombination = 1:numberOfCombinations
        fprintf('\tcurrentCombination = %i / %i\n', ...
            currentCombination, numberOfCombinations)
        % metodo de segmentacao
        [~, centerLocs] = ...
            seg_mtd2(emg, l, combinations(currentCombination, 1), ...
            combinations(currentCombination,2),combinations(currentCombination,3));
        % identificacao do movimento correspondente a cada segmento
        targetClasses = identifyClasses(centerLocs, stimulus);
        % numero de segmentos obtidos por movimento
        for currentClass = 1:numberOfClasses
            numberOfSegments(currentCombination,currentSubject,currentClass) = ...
                length(find(targetClasses(:,currentClass)));
        end
    end
end
save('./out/workspace/number_MTD2.mat') % salva a workspace atual