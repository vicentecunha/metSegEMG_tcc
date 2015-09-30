%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           	%
% MTD1 - método iterativo utilizando thresholding para detecção de centros de	%
% 	 segmentos de comprimento constante                                   		%
%                                                                           	%
% Argumentos:                                                               	%
%   x - matriz column-wise com os canais do sinal a ser segmentado           	%
%   l - comprimento desejado para os segmentos                              	%
%   q - razão de atualização entre iterações para valor de threshold        	%
%   r_target - razão mínima esperada entre número de segmentos e comprimento	%
%		total de sinal                                                      	%
%   T_lim - valor de limite inferior para threshold                         	%
%                                                                           	%
% Retorno:                                                                      %
%   x_seg - cell array com os canais segmentados                                %
%                                                                           	%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x_seg = seg_mtd1(x, l, q, r_target, T_lim)

	% Obtém comprimento do sinal e número de canais
    [L, numberOfChannels] = size(x);

    % Soma dos canais
    x_sum = zeros(L,1);
    for currentChannel = 1:numberOfChannels
        x_sum = x_sum + x(:,currentChannel);
    end

	% Valor inicial de threshold corresponde ao máximo do sinal
    T_k = max(x_sum); 

	% Processo iterativo
    targetReached = false;
	while ~targetReached
	
		% Calcula threshold desta iteração
        T_k = q*T_k; 
        
		% Verifica se limite de valor de threshold foi atingido
        if T_k < T_lim
            warning('Threshold limit reached. Stopping iterations.')
            break
        end
            
        % Identifica candidatos a centros de segmentos
        [centerValues, centerLocs] = findpeaks(x_sum, ...
           'MinPeakHeight', T_k, 'MinPeakDistance',l);
        
        % Determina o encerramento do processo iterativo
         targetReached = (length(centerLocs)/L > r_target);
		 
	end
    
    % Eliminação de centros que estão muito aos extremos do sinal
    if(centerLocs(1) < l/2)
        centerLocs(1) = [];
        centerValues(1) = [];
    end
    if(L - centerLocs(end) < l/2)
        centerLocs(end) = [];
        centerValues(end) = [];
    end
    
    % Segmentação dos canais
    x_seg = cell(length(centerLocs),numberOfChannels);
    for currentChannel = 1:numberOfChannels
        for currentSegment = 1:length(centerLocs)
            x_seg{currentSegment,currentChannel} = ...
                x(centerLocs - l/2: centerLocs+l/2-1,currentChannel);
        end
    end
	
end