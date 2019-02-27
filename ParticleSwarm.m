%                  Abraham Rodríguez Vázquez 
%
% Implementación de algoritmo Particle Swarm Optimization (PSO)
% Parámetros:
%   *Grafo: Matríz simétrica como representación del grafo de rutas.
% Salidas:
%   *Ruta: Combinación que minimiza la función de costo, representa
%          la ruta con la distancia total más corta entre nodos.

function rutaOptima = ParticleSwarm(grafo)

% Obtener el número de nodos, que viene representado por 
% la longitud de una dimensión de la matríz grafo
numNodos = length(grafo);

% Hiperparámetros
numParticulas = 20;
iteraciones = 100000;
omega = 0.5;
phi_p = 0.3;
phi_g = 0.7;

% Inicializar enjambre de partículas aleatoriamente;
enjambre = zeros(numParticulas,numNodos);
for i = 1:numParticulas
    enjambre(i,:) = randperm(numNodos);
end

% Inicializar velocidades de cada particula
vel = zeros(numParticulas,1);

% Inicializar la mejor particula local
mejor_local = randperm(numNodos);

% Inicializar la mejor particula global
mejor_global = randperm(numNodos);

% Comienzo del algoritmo
for i = 1:iteraciones
    
    % Obtener ganancias aleatorias dentro del rango [-1 1] esto hace posible
    % obtener distancias negativas en el calculo de la velocidad
    r_p = -1 + 2*rand();
    r_g = -1 + 2*rand();

    % Iterar por cada particula independiente
    for p = 1:numParticulas
        % Computar velocidad, i.e. magnitud con la que se actualizará la particula
        vel(p) = omega*vel(p) + ...
                 phi_p*r_p*calcular_distancia(mejor_local,enjambre(p,:)) + ...
                 phi_g*r_g*calcular_distancia(mejor_global,enjambre(p,:));
        
        % Mantener valores de velocidad entre 2 y numNodos
        vel(p) = min(vel(p),numNodos);
        vel(p) = max(vel(p),2);
        vel(p) = round(vel(p));

        % Obtener la nueva posición de la particula, es decir
        % sumar la velocidad obtenida a su posición.
        enjambre(p,:) = actualizar_particula(enjambre(p,:),vel(p));

        % Actualizar la mejor particula del enjambre
        if costo(enjambre(p,:)) < costo(mejor_local)
            mejor_local = enjambre(p,:);
        end

        % Actualizar la mejor partícula global
        if costo(mejor_local) < costo(mejor_global)
            mejor_global = mejor_local;
        end
    
    end

end

% Devolver como solución la partícula la mejor partícula encontrada
rutaOptima = mejor_global;


%------------------------- Funciones auxiliares ---------------------------------
    
% Funcion para calcular el costo de un estado, i.e. la distancia total
function energia = costo(estado)

    % Inicializar acumulador
    energia = 0; 

    % Se suma el valor de las distancias en el grafo menos la última con el primero
    for l = 1:numNodos-1
        energia = energia + grafo(estado(l),estado(l+1)); 
    end

    % Sumar la distancia del último con el primero
    energia = energia + grafo(estado(end),estado(1));

end

% Funcion para calcular la distancia entre dos partículas
function distancia = calcular_distancia(particula_1,particula_2)
    
    % Comparar logicamente la igualdad entre cada elemento 
    comparar = particula_1 == particula_2;
    % La distancia se toma como el número de elementos no iguales
    distancia = sum(comparar);

end

% Función para sumar la velocidad a la posición de la partícula
function particulaMovida = actualizar_particula(particula,velocidad)
 
    % Se intercambian valores de entre posiciones aleatorias de la particula sin
    % repetir, ni de forma combinatoria, e.g. intercambiar la posicion 4ta
    % por la 3ra es lo mismo que intercambiar la 3ra por la 4ta.
    posiciones_aleatorias = randperm(numNodos,velocidad);

    % Iinicializar particula movida
    particulaMovida = particula;
    
    % Realizar la actualizacion, i.e. intercambiar posiciones aleatorias
    for n = 1:velocidad-1
        particulaMovida(posiciones_aleatorias(n)) = particula(posiciones_aleatorias(n+1));
        particulaMovida(posiciones_aleatorias(n+1)) = particula(posiciones_aleatorias(n));
        particula = particulaMovida;
    end

    % Excentar del caso particular cuando se intercambian 2 valores,
    % no se intercambia el último con el primero.
    if velocidad ~= 2
        % Intercambiar las posiciones dadas por el último y primer valor
        particulaMovida(posiciones_aleatorias(end)) = particula(posiciones_aleatorias(1));
        particulaMovida(posiciones_aleatorias(1)) = particula(posiciones_aleatorias(end));
    end
end

end
