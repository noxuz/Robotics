function C = PlaneacionRutaQuad(boundary, ps, ts)
    
    %%------------------------ Inicializacion -------------------------
    % Inicializar matriz q que es cuadrada de 8*m m siendo el numero de
    % tramos
    
    % El numero m de tramos es el numero de waypoints+1
    syms t
    numTramos = length(ps)+1;
    
    % Matriz de sistema de ecuaciones
    q = sym(zeros(8*numTramos,8*numTramos));
    
    % Vector b 
    b = sym(zeros(8*numTramos,1));
    

    
   %% POSICIONES--------------------------------------------------

 
    % Crear vector de posiciones
    posicion = derivative_matrix(1);
        
    % Vector con todos los puntos de posicion 
    checkpoints = [boundary(1);ps;boundary(5)];
    % Vector con todos los pasos de tiempo
    tiempos = [0;ts];
    
    % Llenar las ecuaciones de continuidad de posiciones
    for i = 1:numTramos
        % Llenar en pares la posicion en la matriz q
        q(2*i-1:2*i,(i-1)*8+1:i*8) = [posicion;posicion];      
    end
    
    % Sustituir en las ecuaciones el valor inicial y en el respectivo
    % vector b
    q(1,:) = subs(q(1,:),t,tiempos(1));
    b(1) = checkpoints(1);
    
    % Sustituir en la ultima los valores
    q(2*numTramos,:) = subs(q(2*numTramos,:),t,tiempos(end)-tiempos(end-1)); 
    b(2*numTramos) = checkpoints(end);
    
    % Llenar las ecuaciones de continuidad de posicion junto con el vector
    % b
    for j = 2:2:2*numTramos-1
        q(j,:) = subs(q(j,:),t,tiempos(j/2 + 1)-tiempos(j/2)); % La posicion del polinomio anterior se evalua en el tiempo diferencial (con referencia t=0)
        q(j+1,:) = subs(q(j+1,:),t,0); % El polinomio siguiente se evalua en t=0 porque se ven independientemente
        b(j:j+1) = [checkpoints(j/2 + 1);checkpoints(j/2 + 1)]; % A lo que son iguales lo dicta los waypoints
    end
    
    
    %% Boundaries-----------------------------------------------------
    
    % Matriz usada para creacion de ecuaciones para boundaries
    dparaboundary = derivative_matrix(4);
    % Colocación de los boundaries iniciales
    q(2*numTramos+1:2*numTramos+3,1:8) = subs(dparaboundary(2:end,:),t,tiempos(1));
    % Actualizar vector b
    b(2*numTramos+1:2*numTramos+3) = boundary(2:4);
    
    % Boundaries finales
    q(2*numTramos+4:2*numTramos+6,end-7:end) = subs(dparaboundary(2:end,:),t,tiempos(end)-tiempos(end-1));
    % Actualizar vector b
    b(2*numTramos+4:2*numTramos+6) = boundary(6:end);
    
    
    
    %% CONTINUIDAD HASTA SEXTA DERIVADA--------------------------------------------------------------

    Dhasta6 = derivative_matrix(7);
    Dhasta6 = Dhasta6(2:end,:);
    
    numWaypoints = numTramos-1;
    
    for k = 1:numWaypoints % Por cada waypoint
         q(end-((numTramos-k)*6)+1:end-((numTramos-k)*6)+6,(k-1)*8+1:end-((numWaypoints-k)*8)) = horzcat(subs(Dhasta6,t,tiempos(k+1)-tiempos(k)),-subs(Dhasta6,t,0));
    end
    
    
    %% COSECHAR resultados
    % El ultimo paso es acomodar la salida en matriz
    
    % Producir vector de coeficientes en fila
    Salida = inv(q)*b;
    
    % Inicializar la salida de cosecha
    C = sym(zeros(8,numTramos));
    
    % llenar la salida (osea acomodar en la salida deseada, tambien se podria hacer convirtiendo de indice lineal a matriz)
    for s = 1:numTramos
        C(:,s) = Salida(8*(s-1)+1:8*(s-1)+8);
    end

    % Convertir de symbolic a double precision
    C = double(C);
end
