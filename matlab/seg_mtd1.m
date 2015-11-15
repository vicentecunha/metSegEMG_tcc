function [x_seg, finalCenterLocs] = seg_mtd1(x, l, q, r_target, T_lim)
%   MTD1 - metodo iterativo utilizando thresholding para deteccao de
%   centros de segmentos de comprimento constante                                   	
%                                                                           
% Argumentos: (para mais detalhes, refira a descricao do MTD1)
%   x - matriz cujas colunas sao canais do sinal a ser segmentado           
%   l - comprimento desejado para os segmentos                          
%   q - razao de atualizacao entre iteracoes para valor de threshold     
%   r_target - razao minima esperada entre numero de segmentos e comprimento
%       total de sinal               
%   T_lim - fracao do maximo do sinal para limite inferior de threshold                   
%                                                                           
% Retorno:                                                                     
%   x_seg - cell array com canais segmentados
%   finalCenterLocs - posicoes centrais dos segmentos
 
%% Preprocessamento

[L, numberOfChannels] = size(x); % comprimento do sinal e numero de canais
x_ret = abs(x); % retificacao
x_norm = zeros(L, numberOfChannels); % normalizacao
for currentChannel = 1:numberOfChannels
    x_norm(:,currentChannel) = ...
        x_ret(:,currentChannel)./max(x_ret(:,currentChannel));
end

%% Metodo

centerLocsCell = cell(1,numberOfChannels);
for currentChannel = 1:numberOfChannels 
    T_k = 1; % canais normalizados, seus valores maximos sempre sao 1
    targetReached = false;
    while ~targetReached % processo iterativo
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

%% Clustering

centerLocsArray = sort(cell2mat(centerLocsCell'));
[~, labscore] = dbscan(centerLocsArray,2000,3);
numberOfSegments = max(labscore);
finalCenterLocs = zeros(numberOfSegments,1); % medias internas aos clusters
for currentCluster = 1:numberOfSegments 
    finalCenterLocs(currentCluster) = ...
        round(mean(centerLocsArray(labscore == currentCluster)));
end

%% Segmentacao

x_seg = cell(numberOfSegments, numberOfChannels);
for currentChannel = 1:numberOfChannels
    for currentSegment = 1:numberOfSegments
        switch mod(l,2)
            case 0 % se l for par
                if(finalCenterLocs(currentSegment)-l/2)<1
                    % segmento muito a esquerda
                    x_seg{currentSegment,currentChannel} = ...
                        x(1:finalCenterLocs(currentSegment)+(l/2)-1, ...
                        currentChannel);
                else if(finalCenterLocs(currentSegment)+(l/2)-1)>L
                        % segmento muito a direita
                        x_seg{currentSegment,currentChannel} = ...
                            x(finalCenterLocs(currentSegment)-l/2:L, ...
                            currentChannel);
                    else
                        x_seg{currentSegment,currentChannel} = ...
                            x(finalCenterLocs(currentSegment)-l/2: ...
                            finalCenterLocs(currentSegment)+(l/2)-1, ...
                            currentChannel);
                    end
                end
            case 1 % se l for impar
                if(finalCenterLocs(currentSegment) - (l-1)/2)<1
                    % segmento muito a esquerda
                    x_seg{currentSegment,currentChannel} = ...
                        x(1:finalCenterLocs(currentSegment) + (l-1)/2, ...
                        currentChannel);
                else if(finalCenterLocs(currentSegment) + (l-1)/2)>L
                        % segmento muito a direita
                        x_seg{currentSegment,currentChannel} = ...
                            x(finalCenterLocs(currentSegment) - (l-1)/2:L, ...
                            currentChannel);
                    else
                        x_seg{currentSegment,currentChannel} = ...
                            x(finalCenterLocs(currentSegment) - (l-1)/2: ...
                            finalCenterLocs(currentSegment) + (l-1)/2, ...
                            currentChannel);
                    end
                end
        end
    end
end
end