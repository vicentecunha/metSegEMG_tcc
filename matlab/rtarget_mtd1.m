%%
%   Determinação de r_target para MTD1
%%

%% Base de dados Ninapro

ninaproList = ls('database/ninapro2/S*_E1*');
numberOfSubjects = length(ninaproList);
numberOfSegments = 102; % 17 movimentos * 6 repetições

%% Obtenção de r_target da database

r_target = zeros(numberOfSubjects, 1);

for currentSubject = 1:numberOfSubjects

    fprintf('currentSubject = %i\n',currentSubject)
    
    % Carrega o voluntário atual
    load (['database/ninapro2/' ninaproList(currentSubject,:)])
    
    % r_target para este voluntário
    r_target(currentSubject) = numberOfSegments/length(emg);
    
end

min_r_target = min(r_target)
max_r_target = max(r_target)