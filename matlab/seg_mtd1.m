%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% MTD1 - método iterativo utilizando thresholding para detecção de centros    %
% 	de segmentos de comprimento constante                                     %
%                                                                             %
% Argumentos:                                                                 %
%   x - matriz column-wise com os sinais a serem segmentados                  %
%   l - comprimento desejado para os segmentos                                %
%   q - razão de atualização entre iterações para valor de threshold          %
%   r_target - razão mínima esperada entre número de segmentos e comprimento  %
%		total de sinal                                                        %
%   T_lim - valor de limite inferior para threshold                           %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x_seg = seg_mtd1(x, l, q, r_target, T_lim)

	% Máximo dos canais é o valor inicial de threshold
    T0 = max(x); 
	
	% Obtém comprimento do sinal e número de canais
    [L, numberOfChannels] = size(x);
	
	% Array utilizado para armazenar o número de candidatos a centro de
	% 	segmentos identificados por canal
	numberOfCandidates = zeros(1, numberOfChannels); 
	
	% Cell array utilizado para armazenar as localizações de candidatos
	%	a centro de segmentos identificados por canal
	locsOfCandidates = cell(1, numberOfChannels);
	
    % Plot dos centros identificados
    figure(1)
    
	% Identificação de candidatos a centro para cada um dos canais
    for currentChannel = 1:numberOfChannels 

		% Threshold inicial
		T_k = T0(currentChannel); 
        		
		% Processo iterativo
        targetReached = false;
		while ~targetReached

			% Calcula threshold desta iteração
            T_k = q*T_k; 
            
			% Verifica se limite de valor de threshold foi atingido
            if T_k < T_lim
                warning(['Threshold limit reached on channel ', ...
                    num2str(currentChannel), '. Stopping iterations.'])
                break
            end
                
            % Identifica candidatos para centros de segmentos
            [centerValues, centerLocs] = findpeaks(x(:,currentChannel), ...
               'MinPeakHeight', T_k, 'MinPeakDistance',l);
            
            % Determina o encerramento do processo iterativo
             targetReached = (length(centerLocs)/L > r_target);
			 
		end
		
		% Armazena o número de candidatos identificados para este canal
		numberOfCandidates(currentChannel) = (length(centerLocs));

        % Armazena os locais dos candidatos identificados para este canal
        locsOfCandidates{currentChannel} = centerLocs;
        
        % Plot dos centros identificados
        subplot(5,2,currentChannel), plot(x(:,currentChannel)), hold on, ...
            plot(centerLocs,centerValues,'r*'), hold off
        
    end
end