%              Abraham Rodriguez Vazquez
%
% Implementación del algoritmo ''Harris Corners Detection''
% de computer vision para encontrar puntos de
% seguimiento en una imagen

% Leer imagen de carpeta local
img = imread('peppers.png');
img_gray = double(rgb2gray(img));

% Aplicar un filtro gaussiano para suavizar la imagen
img_gray_smooth = gauss_blur(img_gray);

% Computar gradientes en dirección X y Y
[I_x,I_y] = grad2d(img_gray_smooth);

% Obtener versiones suavizadas de los gradientes
A = gauss_blur(I_x.^2);
B = gauss_blur(I_y.^2);
C = gauss_blur(I_x.*I_y);

I_xx = A;
I_yy = B;
I_xy = C;

% Constante empírica
k = 0.06;

% Compotar el score de cada pixel
R = (A.*B-C.^2) - k*(A+B).^2;

% Suprimir no máximos en un radio de r
% y límite thresh
r = 5;
thresh = 10000;
hc = nmsup(R,r,thresh);

% Mostrar Harris Corners en la imagen original
figure()
imshow(img)
hold on;
plot(hc(:,1), hc(:,2), 'rx')
hold off;

% Función para realizar non maximun suppression
function loc = nmsup(R,r,thresh)
    % Obtener dimensiones de matriz de scores 
    [nr,nc] = size(R);
    loc = zeros(1,2);
    
    % Aplicar threshold a imagen
    menores = R<thresh;
    R(menores) = 0;
    
    % Ordenar por score los pixeles
    [sorteada,indices] = sort(R(:),'descend');
    sorteada = nonzeros(sorteada);

    % Aplicar non maximun suppression
    for i = 1:length(sorteada)
       
        [origeni,origenj] = ind2sub([nr,nc],indices(i));

           % Hacer 0 los pixeles vecinos
           if R(indices(i)) ~= 0
                for c = origenj-r:origenj+r % Cada columna
                    for d = origeni-r:origeni+r % Cada fila
                          if c == origenj && d == origeni
                              continue;
                          else  
                             if c > 0 && c < nc+1 && d > 0 && d < nr+1
                               R(d,c) = 0; % Apagar ese pitsel
                             end
                          end
                    end
                end
                
           end
        

    end

    % Cosechar los pixeles sobrevivientes 
     [sorteada2,indices2] = sort(R(:),'descend'); % Recapacita quate

        sorteada2 = nonzeros(sorteada2);
        % Obtener ubicación de los pixeles sobrevivientes
        for l = 1:length(sorteada2)
            [origeni,origenj] = ind2sub([nr,nc],indices2(l));
            loc(l,:) = [origenj origeni];
        end
    
end
 
% Función para calcular el gradiente de la imagen
function [I_x,I_y] = grad2d(img)
    % Kernel para obtener el gradiente en la direccion X
	dx_filter = [1/2 0 -1/2];
    % Aplicar convolución de la imagen con el kernel del filtro
	I_x = conv2(img,dx_filter,'same');

    % Obtener gradiente en direccion Y 
	I_y = conv2(img,dx_filter','same');
end

% Funcion para suavizar una imagen mediante gaussian blur
function smooth = gauss_blur(img)
    x =  -2:2;
    sigma = 1;
    % Crear kernel del filtro gaussian blur
    gauss_filter = 1/(sqrt(2*pi)*sigma)*exp(-x.^2/(2*sigma));

    % Convolucionar la imagen con el kernel para obtener la imagen suavizada
    smooth_x = conv2(img,gauss_filter,'same');
    smooth = conv2(smooth_x,gauss_filter','same');
end
