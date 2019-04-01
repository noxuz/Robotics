function I = TextureFlattening
    
% read image and mask
target = im2double(imread('bean.jpg')); 
mask = imread('mask_bean.bmp');

% edge detection
Edges = edge(rgb2gray(target),'canny',0.1);

N=sum(mask(:));  % N: Number of unknown pixels == variables

% enumerating pixels in the mask
mask_id = zeros(size(mask));
mask_id(mask) = 1:N;   
    
% neighborhood size for each pixel in the mask
[ir,ic] = find(mask);

% compute matrix A

% your CODE begins here


% Inicializar matriz sparse cuadrada de longitd igual al numero de pixeles
% en la mascara e inicializar los valores de los kernel
A = 4*speye(N); 

% Iterar por cada fila (cada pixel) para ir llenando la matriz sparse
% con los vecinos izquierdos y derechos
for p = 1:N
     
    % Condicional para saber si se está fuera del boundarie
    % de la mascara el pixel vecino izquierdo
    if mask(ir(p),ic(p)-1)
        % Colocar valor en la matriz sparse para el vecino izquierdo
        A(p,mask_id(ir(p),ic(p)-1)) = -1;
    end
    
    % Para pixel derecho
    if mask(ir(p),ic(p)+1)
        % Colocar valor en la matriz sparse para el vecino derecho
        A(p,mask_id(ir(p),ic(p)+1)) = -1;
    end

    % Pixel vecino superior
    if mask(ir(p)-1,ic(p))
        % Colocar valor en la matriz sparse para el vecino superior
        A(p,p-1) = -1;
    end

    % Pixel vecino inferior
    if mask(ir(p)+1,ic(p))
        % Colocar valor en la matriz sparse para el vecino inferior
        A(p,p+1) = -1;
    end
    
end


% your CODE ends here

% Inicializacion de output

I = target;

for color=1:3 % solve for each colorchannel

    % compute b for each color
    b = zeros(N,1);
    
    for ib = 1:N
    
    i = ir(ib);
    j = ic(ib);
    
      % De cajon se colocan las condiciones de frontera, y el gradiente
      % se añade unicamente si el pixel es un edge en el pixel
      % central o vecino
      if (i>1) 
          b(ib) = b(ib) + target(i-1,j,color)*(1-mask(i-1,j));
          if Edges(i,j) || Edges(i-1,j)
             b(ib) = b(ib) + target(i,j,color)-target(i-1,j,color);  
          end
      end

      if (i<size(mask,1))        
          b(ib) = b(ib) + target(i+1,j,color)*(1-mask(i+1,j));
          if Edges(i,j) || Edges(i+1,j)
             b(ib) = b(ib) + target(i,j,color)-target(i+1,j,color);
          end
      end

      if (j>1)
          b(ib) = b(ib) + target(i,j-1,color)*(1-mask(i,j-1));
          if Edges(i,j) || Edges(i,j-1)
            b(ib) = b(ib) + target(i,j,color)-target(i,j-1,color);
          end
      end


      if (j<size(mask,2))
          b(ib) = b(ib) + target(i,j+1,color)*(1-mask(i,j+1));
          if Edges(i,j) || Edges(i,j+1)
             b(ib) = b(ib) + target(i,j,color)-target(i,j+1,color); 
          end
      end     

    end


    % solve linear system A*x = b;
    x = A \ b;
    
    % impaint target image
    % solamente se sobreponen los pixeles que se calcularon 
     for ib = 1:N
           I(ir(ib),ic(ib),color) = x(ib);
     end
    
end

% Plotear todas las imagenes
figure(1);
imshow(target);
figure(2);
imshow(mask);
figure(3);
imshow(Edges);
figure(4);
imshow(I);

end
