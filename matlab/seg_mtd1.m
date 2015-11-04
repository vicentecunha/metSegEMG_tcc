%%
%   MTD1 - metodo iterativo utilizando thresholding para deteccao de
%   centros de segmentos de comprimento constante                                   	
%                                                                           
% Argumentos: (para mais detalhes, refira a descricao do MTD1)
%   x - matriz cujas colunas sao canais do sinal a ser segmentado           
%   l - comprimento desejado para os segmentos
%       (deve ser inteiro maior que zero)                             
%   q - razao de atualizacao entre iteracoes para valor de threshold
%       (deve ser entre 0 e 1)       
%   r_target - razao minima esperada entre numero de segmentos e comprimento
%       total de sinal
%       (deve ser maior que zero)                       
%   T_lim - fracao do maximo do sinal para limite inferior de threshold
%       (deve ser entre 0 e 1)                        
%                                                                           
% Retorno:                                                                     
%   x_seg - cell array com canais segmentados
%   centerLocs - posicoes centrais dos segmentos
%%                                                                        

function [x_seg, centerLocs] = seg_mtd1(x, l, q, r_target, T_lim)
%% Preprocessamento

% Obtem comprimento do sinal e numero de canais
[L, numberOfChannels] = size(x);

% Retificacao
x_ret = abs(x);

% Normalizacao
x_norm = zeros(L, numberOfChannels);
for currentChannel = 1:numberOfChannels
    x_norm(:,currentChannel) = ...
        x_ret(:,currentChannel)./max(x_ret(:,currentChannel));
end

%% Metodo

% Cell array para armazenar posicoes dos segmentos identificados
centerLocsCell = cell(1,numberOfChannels);

for currentChannel = 1:numberOfChannels
    
    % Processo iterativo
    T_k = 1; % canais normalizados, seus valores maximos sempre sao 1
    targetReached = false;
    while ~targetReached
        
        T_k = q*T_k; % calcula threshold desta iteracao
        if T_k < T_lim % verifica se o limite de valor de threshold foi atingido
            break
        end
        
        % Identifica candidatos a centros de segmentos
        [~, centerLocsCell{1,currentChannel}] = ...
            findpeaks(double(x_norm(:,currentChannel)), ...
            'MinPeakHeight', T_k, 'MinPeakDistance',l);
        
        % Determina o encerramento do processo iterativo
        targetReached = (length(centerLocsCell{1,currentChannel})/L >= r_target);
    end
    
end

%% Segmentacao do sinal

% Maximo numero de segmentos detectados
numberOfSegments = 0;
for currentChannel = 1:numberOfChannels
    currentChannelNumberOfSegments = length(centerLocsCell{1,currentChannel});
    if  currentChannelNumberOfSegments > numberOfSegments
        numberOfSegments = currentChannelNumberOfSegments;
    end
end

% Clustering dos centros de segmentos detectados
centerLocsArray = cell2mat(centerLocsCell');
[~,C] = kmeans(centerLocsArray,numberOfSegments);
centerLocs = sort(round(C));

% Segmentacao
x_seg = cell(numberOfSegments,numberOfChannels);
for currentChannel = 1:numberOfChannels
    for currentSegment = 1:numberOfSegments
        if mod(l,2) == 0 % se l for par
            if (centerLocs(currentSegment)-l/2) < 1 % segmento muito a esquerda
                x_seg{currentSegment,currentChannel} = ...
                    x(1:centerLocs(currentSegment)+l/2 - 1, currentChannel);
            else if (centerLocs(currentSegment)+l/2 - 1) > L % segmento muito a direita
                    x_seg{currentSegment,currentChannel} = ...
                        x(centerLocs(currentSegment)-l/2:L, currentChannel);
                else
                    x_seg{currentSegment,currentChannel} = ...
                        x(centerLocs(currentSegment)-l/2: ...
                        centerLocs(currentSegment)+l/2 - 1, currentChannel);
                end
            end
        else % se l for impar
            if (centerLocs(currentSegment)-(l+1)/2) < 1 % segmento muito a esquerda
                x_seg{currentSegment,currentChannel} = ...
                    x(1:centerLocs(currentSegment)+l/2 - 1, currentChannel);
            else if (centerLocs(currentSegment)+(l+1)/2 - 1) > L % segmento muito a direita
                    x_seg{currentSegment,currentChannel} = ...
                        x(centerLocs(currentSegment)-l/2:L, currentChannel);
                else
                    x_seg{currentSegment,currentChannel} = ...
                        x(centerLocs(currentSegment)-(l+1)/2: ...
                        centerLocs(currentSegment)+(l+1)/2 - 1, currentChannel);
                end
            end
        end
    end
end

end