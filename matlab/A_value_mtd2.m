% Determinacao de A para MTD2

%% Base de dados Ninapro
ninaproList = ls('database/ninapro2/S*_E1*');
numberOfSubjects = length(ninaproList);
numberOfChannels = 12; % 17 movimentos * 6 repeticoes
A_value = zeros(numberOfSubjects, numberOfChannels);
for currentSubject = 1:numberOfSubjects
    fprintf('currentSubject = %i\n',currentSubject)
    load (['database/ninapro2/' ninaproList(currentSubject,:)])
    [L, ~] = size(emg); % comprimento do sinal e numero de canais
    x_ret = abs(emg); % retificacao
    x_norm = zeros(L, numberOfChannels); % normalizacao
    for currentChannel = 1:numberOfChannels
        x_norm(:,currentChannel) = ...
            x_ret(:,currentChannel)./max(x_ret(:,currentChannel));
    end
    % Razao entre valor maximo e medio para canais deste voluntario
    A_value(currentSubject,:) = 1./mean(x_norm);
end
% mediana de razoes para todos os voluntarios e canais
med_Avalue(1) = median(median(A_value));

%% Base de dados IEE
ieeList = ls('database/IEE/*.mat');
numberOfSubjects = length(ieeList(:,1));
numberOfChannels = 12; % 17 movimentos * 6 repeticoes
A_value = zeros(numberOfSubjects, numberOfChannels);
for currentSubject = 1:numberOfSubjects
    fprintf('currentSubject = %i\n',currentSubject)
    load (['database/ninapro2/' ninaproList(currentSubject,:)])
    [L, ~] = size(emg); % comprimento do sinal e numero de canais
    x_ret = abs(emg); % retificacao
    x_norm = zeros(L, numberOfChannels); % normalizacao
    for currentChannel = 1:numberOfChannels
        x_norm(:,currentChannel) = ...
            x_ret(:,currentChannel)./max(x_ret(:,currentChannel));
    end
    % Razao entre valor maximo e medio para canais deste voluntario
    A_value(currentSubject,:) = 1./mean(x_norm);
end
% mediana de razoes para todos os voluntarios e canais
med_Avalue(2) = median(median(A_value));

% Resultados:
%   med_Avalue(1) = 73.8127 [NinaPro]
%   med_Avalue(2) = 83.3154 [IEE]