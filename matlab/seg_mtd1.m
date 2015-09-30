%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           	%
% MTD1 - m�todo iterativo utilizando thresholding para detec��o de centros de	%
% 	 segmentos de comprimento constante                                   		%
%                                                                           	%
% Argumentos:                                                               	%
%   x - matriz column-wise com os canais do sinal a ser segmentado           	%
%   l - comprimento desejado para os segmentos                              	%
%   q - raz�o de atualiza��o entre itera��es para valor de threshold        	%
%   r_target - raz�o m�nima esperada entre n�mero de segmentos e comprimento	%
%		total de sinal                                                      	%
%   T_lim - valor de limite inferior para threshold                         	%
%                                                                           	%
%                                                                               %
% Retorno:                                                                      %
%   x_seg - cell array com os canais segmentados                                %
%                                                                           	%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x_seg = seg_mtd1(x, l, q, r_target, T_lim)

	% Obt�m comprimento do sinal e n�mero de canais
    [L, numberOfChannels] = size(x);

    % Soma dos canais
    x_sum = zeros(L,1);
    for currentChannel = 1:numberOfChannels
        x_sum = x_sum + x(:,currentChannel);
    end

	% Valor inicial de threshold corresponde ao m�ximo do sinal
    T_k = max(x_sum); 

	% Processo iterativo
    targetReached = false;
	while ~targetReached
	
		% Calcula threshold desta itera��o
        T_k = q*T_k; 
        
		% Verifica se limite de valor de threshold foi atingido
        if T_k < T_lim
            warning('Threshold limit reached. Stopping iterations.')
            break
        end
            
        % Identifica centros de segmentos
        [centerValues, centerLocs] = findpeaks(x_sum, ...
           'MinPeakHeight', T_k, 'MinPeakDistance',l);
        
        % Determina o encerramento do processo iterativo
         targetReached = (length(centerLocs)/L > r_target);
		 
	end
    
    % Elimina��o de centros que est�o muito aos extremos do sinal
    if(centerLocs(1) < l/2)
        centerLocs(1) = [];
        centerValues(1) = [];
    end
    if(L - centerLocs(end) < l/2)
        centerLocs(end) = [];
        centerValues(end) = [];
    end
    
    % Segmenta��o dos canais
    x_seg = cell(length(centerLocs),numberOfChannels);
    for currentChannel = 1:numberOfChannels
        for currentSegment = 1:length(centerLocs)
            x_seg{currentSegment,currentChannel} = ...
                x(centerLocs - l/2: centerLocs+l/2-1,currentChannel);
        end
    end
	
end