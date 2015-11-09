% Implementação do MTD3 com variação de parâmetros 
% e medida do número de segmentos obtidos por movimento
close all
clear

%% Parâmetros utilizados

% Predeterminados
l_min = 7.5e3;
l_max = 12.5e3;
step = 100;
W = 5e3;

% Combinações a serem testadas
B = [0.5 0.1 0.15 0.2];
C = [-0.5 -0.1 -0.15 -0.2];
combinations = combvec(B, C)';
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
            seg_mtd3(emg,l_min,l_max,step,W,combinations(currentCombination, 1), ...
            combinations(currentCombination, 2));
        % identificacao do movimento correspondente a cada segmento
        targetClasses = identifyClasses(centerLocs, stimulus);
        % numero de segmentos obtidos por movimento
        for currentClass = 1:numberOfClasses
            numberOfSegments(currentCombination,currentSubject,currentClass) = ...
                length(find(targetClasses(:,currentClass)));
        end
    end
end
save('./out/workspace/number_MTD3.mat') % salva a workspace atual