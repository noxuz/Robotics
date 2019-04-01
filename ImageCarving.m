function Icarved = ImageCarving(N)

% N: number of vertical seams you have to remove

% Leer imagen original y guardar para futural visualizacion
I = im2double(imread('waterfall.png'));

% Inicializar imagen de salida
Icarved = I; 

% Vector uusado para crear la matriz path
Caminos = [-1 0 1];

% Altura de la imagen, constante utilizada frecuentemente
numFilas = size(I,1);

% Inicio del algoritmo, repetir N veces para eliminar N seams verticales
for iIter = 1:N

%----------------------- 0: Prepare --------------------------
    % Convertir imagen de la iteracion actual a escala de grises
    Igris = rgb2gray(Icarved);

    % Obtener gradientes en x y de la imagen a escala de grises
    Gx = imfilter(Igris,.5*[-1 0 1],'replicate');
    Gy = imfilter(Igris,.5*[-1 0 1]','replicate');

    % Obtener matriz de energia, que es el valor absoluto del gradiente de cada pixel
    Energia = abs(Gx) +  abs(Gy);

%----------------------- 1: Inicializar --------------------------
    % Inicializar matriz de zeros de energia cumulativa del path
    Value = zeros(size(Igris)); 
    % Inicializar primera fila con los valores de Energia
    Value(1,:) = Energia(1,:);

    % Inicializar matriz de path
    Path = zeros(size(Igris));

%----------------------- 2: Propagation --------------------------
    % Iterar por cada fila desde la segunda
    for i = 2:numFilas
        
        % Iterar por todos los pixeles de la fila
        for j = 1:size(Igris,2)
            % Encontrar los vecinos del pixel en cuestion respetando rangos
            if j == 1
                Vecinos = [Inf Value(i-1,j) Value(i-1,j+1)];
            elseif j == size(Igris,2)
                Vecinos = [Value(i-1,j-1) Value(i-1,j) Inf];
            else
                Vecinos = [Value(i-1,j-1) Value(i-1,j) Value(i-1,j+1)];
            end

            % Encontrar el pixel vecino con menor valor
            [Minimo,IndiceMin] = min(Vecinos);

            % Anadir este valor minimo a la ebergia del pixel actual value en el pixel actual
            Value(i,j) = Energia(i,j) + Minimo;

            % Actualizar matriz de path
            Path(i,j) = Caminos(IndiceMin);
            
        end
        
    end

%----------------------- 3: Path resolving --------------------------
     % Encontrar el path de energia minima con la ultima fila de la matriz value
    [~,IndicePath] = min(Value(end,:));  

    % Reconstruir el path de costo minimo con coordenadas [y x]
    Caminito = zeros(numFilas,2);
    Caminito(:,1) = 1:numFilas;
    Caminito(end,2) = IndicePath;

    for c = numFilas-1:-1:1
        Caminito(c,2) = IndicePath + Path(c+1,IndicePath);
        % Actualizar caminito
        IndicePath = IndicePath + Path(c+1,IndicePath);
    end

% Eliminar los pixeles de la seam obtenida y resizear la imagen

% Convertir a indices lineales
% IndicesLin = sub2ind(size(Igris),Caminito(:,1),Caminito(:,2));   
% Icarved(IndicesLin) = 1;

    % Actualizar cada fila de Icarved
    Icarved_temporal = zeros(numFilas,size(Igris,2)-1,3);
    for k = 1:numFilas
        Icarved_temporal(k,:,:) = [Icarved(k,1:Caminito(k,2)-1,:) Icarved(k,(Caminito(k,2)+1):end,:)];
    end
   
    Icarved = Icarved_temporal;

end

% Mostrar imagenes de salida Icarved y original
figure(1),imshow(I);
figure(2),imshow(Icarved);

end
