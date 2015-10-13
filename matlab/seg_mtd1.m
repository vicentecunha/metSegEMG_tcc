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
%   T_lim - valor de limite inferior para threshold
%       (deve ser maior que zero)                        
%                                                                           
% Retorno:                                                                     
%   x_seg - cell array com canais segmentados
%   centerLocs - posicoes centrais dos segmentos
%%                                                                           

function [x_seg, centerLocs] = seg_mtd1(x, l, q, r_target, T_lim)

%% Preprocessamento

	% Obtem comprimento do sinal e numero de canais
    [L, numberOfChannels] = size(x);
    
    % Retificacao de sinal
    x_ret = abs(x);
     
 	% Suavizacao utilizando media movel
    x_smooth = reshape(smooth(x_ret, 32), L, numberOfChannels);
	
%% Metodo 

    % Cell array para armazenar posicoes dos segmentos identificados
    centerLocsCell = cell(1,numberOfChannels);

    for currentChannel = 1:numberOfChannels 
        
        % Processo iterativo 
        targetReached = false;
        T_k = max(x_smooth(:,currentChannel));
        while ~targetReached            
            % Calcula threshold desta iteracao
            T_k = q*T_k; 

            % Verifica se o limite de valor de threshold foi atingido
            if T_k < T_lim
                break
            end

            % Identifica candidatos a centros de segmentos
            [~, centerLocsCell{1,currentChannel}] = ...
                findpeaks(double(x_smooth(:,currentChannel)), ...
                'MinPeakHeight', T_k, 'MinPeakDistance',l);

            % Determina o encerramento do processo iterativo
             targetReached = ...
                 (length(centerLocsCell{1,currentChannel})/L > r_target);            
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
    idx = kmeans(centerLocsArray,numberOfSegments);
    
    % Media dos clusters
    centerLocsMean = zeros(numberOfSegments,1);
    for currentCluster = 1:numberOfSegments
        centerLocsMean(currentCluster) = ...
            mean(centerLocsArray(idx == currentCluster));
    end
    centerLocs = sort(round(centerLocsMean));
    
    % Segmentacao
    x_seg = cell(numberOfSegments,numberOfChannels);
    for currentChannel = 1:numberOfChannels
        for currentSegment = 1:numberOfSegments
            if mod(l,2) == 0 % se l for par
                x_seg{currentSegment,currentChannel} = ...
                    x(centerLocs(currentSegment)-l/2: ...
                    centerLocs(currentSegment)+l/2 - 1, currentChannel);
            else % se l for impar
                x_seg{currentSegment,currentChannel} = ...
                    x(centerLocs(currentSegment)-(l+1)/2: ...
                    centerLocs(currentSegment)+(l+1)/2 - 1, currentChannel);
            end
        end
    end

end