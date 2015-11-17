% Determinacao de r_target para MTD1

%% Base de dados Ninapro

ninaproList = ls('database/ninapro2/S*_E1*');
numberOfSubjects = length(ninaproList);
numberOfSegments = 102; % 17 movimentos * 6 repeticoes

%% Obtencao de r_target da database

r_target = zeros(numberOfSubjects, 1);

for currentSubject = 1:numberOfSubjects

    fprintf('currentSubject = %i\n',currentSubject)
    
    % Carrega o voluntario atual
    load (['database/ninapro2/' ninaproList(currentSubject,:)])
    
    % r_target para este voluntario
    r_target(currentSubject) = numberOfSegments/length(emg);
    
end

min_r_target(1) = min(r_target);

%% Base de dados IEE

ieeList = ls('database/IEE/*.mat');
numberOfSubjects = length(ieeList(:,1));
numberOfSegments = 102; % 17 movimentos * 6 repeticoes

%% Obtencao de r_target da database

r_target = zeros(numberOfSubjects, 1);

for currentSubject = 1:numberOfSubjects

    fprintf('currentSubject = %i\n',currentSubject)
    
    % Carrega o voluntario atual
    load (['database/IEE/' ieeList(currentSubject,:)])
    
    % r_target para este voluntario
    r_target(currentSubject) = numberOfSegments/length(emg);
    
end

min_r_target(2) = min(r_target);