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
numberOfClasses = 17;

%% Teste das diferentes combina��es
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

%% Plot de resultados
% m�dia do n�mero de segmentos para todos os volunt�rios
segmentsNumberMean = squeeze(mean(numberOfSegments,2));
lines = {'-';'--';':';'-';'--';':';'-';'--';':';'-';'--';':';'-';'--';':';'-'};
markers={'+';'o';'*';'.';'x';'s';'d';'^';'v';'>';'<';'p';'h';'+';'o';'*'};
figure(), hold on
for currentCombination = 1:numberOfCombinations
    plot(segmentsNumberMean(currentCombination,:)', ...
        [markers{currentCombination} lines{currentCombination}]);
end