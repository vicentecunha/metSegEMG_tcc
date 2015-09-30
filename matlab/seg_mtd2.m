%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        		%    
% MTD2 - método não iterativo utilizando thresholding para detecção de 			%
% 	centros de segmentos de comprimento constante                           	%
%                                                                           	%
% Argumentos:                                                               	%
%   x - matriz column-wise com os canais do sinal a ser segmentado           	%
%   l - comprimento desejado para os segmentos                              	%
%   A - coeficiente utilizado para decisão de método de cálculo de threshold	%
%   B - múltiplo da média aritmética do sinal x para obtenção de threshold		%
%   C - fração do valor máximo do sinal x para cálculo de threshold				%
%                                                                           	%
% Retorno:                                                                      %
%   x_seg - cell array com os canais segmentados                                %
%                                                                           	%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x_seg = seg_mtd2(x, l, A, B, C)

	% Obtém comprimento do sinal e número de canais
    [L, numberOfChannels] = size(x);

    % Soma dos canais
    x_sum = zeros(L,1);
    for currentChannel = 1:numberOfChannels
        x_sum = x_sum + x(:,currentChannel);
    end

	% Cálculo do threshold
    if(max(x_sum) > A*mean(x_sum))
		T = B*mean(x_sum);
	else
		T = max(x_sum)/C;
    end
	
	% Identifica centros de segmentos
    [centerValues, centerLocs] = findpeaks(x_sum, ...
        'MinPeakHeight', T, 'MinPeakDistance',l);
    
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