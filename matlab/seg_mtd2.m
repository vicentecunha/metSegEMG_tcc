function [x_seg, finalCenterLocs] = seg_mtd2(x, l, A, B, C)
%   MTD2 - metodo nao iterativo utilizando thresholding para deteccao de
% 	centros de segmentos de comprimento constante                           
%                                                                           
% Argumentos: (para mais detalhes, refira a descricao do MTD2)                                                              
%   x - matriz cujas colunas sao canais do sinal a ser segmentado           
%   l - comprimento desejado para os segmentos
%       (deve ser inteiro maior que zero)                             
%   A - coeficiente utilizado para decisao de metodo de calculo de threshold
%       (deve ser maior ou igual a 1)
%   B - multiplo da media aritmetica do sinal x para obtencao de threshold
%       (deve ser maior ou igual a 1)	
%   C - fracao do valor maximo do sinal x para calculo de threshold	
%       (deve ser maior ou igual a 1)
%                                                                           
% Retorno:                                                                   
%   x_seg - cell array com os canais segmentados
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
    % Calculo do threshold
    maxValue = 1; % sinais normalizados
    meanValue = mean(x_norm(:,currentChannel));
    if maxValue > (A*meanValue)
        T = B*meanValue;
    else
        T = maxValue/C;
    end   
    % Identifica centros de segmentos
    [~, centerLocsCell{1,currentChannel}] = ...
        findpeaks(double(x_norm(:,currentChannel)), ...
        'MinPeakHeight', T, 'MinPeakDistance',l);
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