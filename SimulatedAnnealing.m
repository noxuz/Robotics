%               Abraham Rodríguez Vázquez 
%
% Implementación de algoritmo de templado simulado
% Parámetros:
%   *Grafo: Representación del grafo como matriz simétrica
%   *T: Número entre 1 y 4 para elegir de entre las funciones de temperatura
% Salidas:
%   *ruta: Combinación que minimiza la función objetivo, en este caso la ruta más corta
function ruta = TempleSimulado(grafo,T)

% Número de iteraciones globales
iter_max = 100000;

% Número de iteraciones locales
iter_local = 30;

% Obtener número de nodos, longitud de un lado de la matriz cuadrada
numNodos = length(grafo); 

% Inicialización
C = randperm(numNodos); % Estado inicial aleatorio

% Definir función de temperatura a usar.
switch T
   case 1
        temperatura = @(t) 1/(1+t);
   case 2
        A = 10; % Constante a estimar
        temperatura = @(t) A/(log(1+t));
   case 3  
        k = 0.9; % Constante a estimar
        T_0 = 100; % Temperatura inicial
        temperatura = @(t) k*T_0*(t-1);
   case 4
        T_0 = 100; % Temperatura inicial
        T_f = .001; % Temperatura Final
        temperatura = @(t) T_0*((T_f/T_0)^(t/iter_max));
end

% Iteraciones globales
for t = 1:iter_max


    % Iteraciones locales
    for n = 1:iter_local
        
        % Mutar aleatoriamente al estado actual intercambiando
        % dos posiciones aleatorias entre sí
        posiciones_Aleatorias = randperm(numNodos,2); % Obtener dos posiciones exclusivas aleatorias
        C_nueva = C; % Inicializar la nueva
        C_nueva(posiciones_Aleatorias(1)) = C(posiciones_Aleatorias(2)); % Realizar el swap
        C_nueva(posiciones_Aleatorias(2)) = C(posiciones_Aleatorias(1));

        % Calcular la diferencia de energia entre los dos estados
        delta_energia = E(C_nueva)-E(C);

        q = min(1,exp(-delta_energia/temperatura(t))); % Probabilidad de avanzar en el templado.
        p = rand(); % Factor estocástico del templado.

        % Se elige el nuevo estado en función en función de la temperatura actual
        % y de la probabilidad aleatoria p.
        if p < q
            C = C_nueva;
        end
        
    end

end

   
 
    % Función auxiliar para calcular la energia
    % se suman las distancias entre cada nodo del estado
    function energia = E(estado)
    energia = 0; % Inicializar energia.

        % Se suma el valor de las distancias en el grafo menos la última con el primero
        for l = 1:numNodos-1
            energia = energia + grafo(estado(l),estado(l+1)); 
        end

        % Sumar la distancia del último con el primero
        energia = energia + grafo(estado(end),estado(1));
    end


end
