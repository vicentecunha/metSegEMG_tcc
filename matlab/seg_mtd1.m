%%
% MTD1 - m�todo iterativo utilizando thresholding para detec��o de centros
% de segmentos de comprimento constante
%
%   Argumentos:
%   x - matriz column-wise com os sinais a serem segmentados
%   l - comprimento desejado para os segmentos
%   q - raz�o de atualiza��o entre itera��es para valor de threshold
%   r_target - ..
%   T_lim - valor de limite inferior para Threshold

function x_seg = seg_mtd1(x, l, q, r_target, T_lim)
    % Valor inicial de threshold corresponde aos m�ximos dos sinais
    T0 = max(x);
    % Obt�m n�mero de canais
    [L, num_canais] = size(x);
        
    % Realiza segmenta��o para cada um dos canais
    for current_channel = 1:num_canais
        % Threshold inicial
        T_k = T0(current_channel);
        
        % Vari�vel l�gica para determinar o final do m�todo iterativo
        target_reached = false;
        while ~target_reached
            % Calcula threshold desta itera��o
            T_k = q*T_k;
            % Limite de valor de threshold atingido
            if T_k < T_lim
                break;
            end
                
            % Identifica os poss�veis candidatos para centros de segmentos
            [~, centers_locs_current_channel] = findpeaks(x(:,current_channel), ...
               'MinPeakHeight', T_k, 'MinPeakDistance',l);
           
            % Verifica��o do n�mero de candidatos a centro identificados
            if(length(centers_locs_current_channel) > N)
                error('N�mero de poss�veis centros identificados maior que o N fornecido.')
            end
            
            % Determina o encerramento do processo iterativo
             target_reached = (length(centers_locs_current_channel)/L > N);
        end
        
        % Armazena os centros de segmentos para o canal atual
        index = zeros(length(centers_locs_current_channel),1);
        index(:) = current_channel;
        centers_locs = [centers_locs; index centers_locs_current_channel];
    end
end