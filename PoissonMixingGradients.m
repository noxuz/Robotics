function I = PoissonMixingGradients
    
% read images 
target= im2double(imread('target_2.jpg')); 
source= im2double(imread('source_2.jpg')); 
mask=imread('mask_2.bmp');

row_offset=130;
col_offset=10; 

source_scale=0.6;

source =imresize(source,source_scale);
mask =imresize(mask,source_scale);


% YOUR CODE STARTS HERE

% N: Number of pixels in the mask
N=sum(mask(:)); 

% enumerating pixels in the mask
mask_id = zeros(size(mask));
mask_id(mask) = 1:N;   
    
% neighborhood size for each pixel in the mask
[ir,ic] = find(mask);

Np = zeros(N,1); 

for ib=1:N
    
    i = ir(ib);
    j = ic(ib);
    
    % No se utiliza en realidad

    % Obtener el numero de vecinos de cada pixel de la mascara
    % incluyendo el offset de columnas y filas
    Np(ib)=  double((row_offset+i> 1))+ ...
             double((col_offset+j> 1))+ ...
             double((row_offset+i< size(target,1))) + ...
             double((col_offset+j< size(target,2)));

end


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



% output intialization
I = target; 


for color=1:3 % solve for each colorchannel

    % compute b for each color
    b=zeros(N,1);
    
    for ib=1:N
    
    i = ir(ib);
    j = ic(ib);
    
            
      if (i>1) 
          %      acumulador + boundarie condition + centro kernel + lado
          % correspondiente del kernel, el (1-mask(i-1,j)) detecta
          % automaticamente si se trata de un pixel en el boundarie,
          % se suma el mismo pixel central unicamente las veces que hay pixeles
          % vecinos del kernel para promediar adecuadamente
          b(ib) = b(ib) + target(row_offset+i-1,col_offset+j,color)*(1-mask(i-1,j));
                  % Condicional para el gradiente para el target y source
                  if abs(target(row_offset+i,col_offset+j,color)-target(row_offset+i-1,col_offset+j,color))>= abs(source(i,j,color)-source(i-1,j,color))
                        b(ib) = b(ib) + target(row_offset+i,col_offset+j,color)-target(row_offset+i-1,col_offset+j,color);
                  else
                        b(ib) = b(ib) + source(i,j,color)-source(i-1,j,color);
                  end
      end

      if (i<size(mask,1))
          b(ib)=b(ib)+  target(row_offset+i+1,col_offset+j,color)*(1-mask(i+1,j));
                  if abs(target(row_offset+i,col_offset+j,color)-target(row_offset+i+1,col_offset+j,color)) >= abs(source(i,j,color)-source(i+1,j,color))
                       b(ib) = b(ib) + target(row_offset+i,col_offset+j,color)-target(row_offset+i+1,col_offset+j,color);
                  else
                       b(ib) = b(ib) + source(i,j,color)-source(i+1,j,color);
                  end
      end

      if (j>1)
          b(ib)= b(ib) +  target(row_offset+i,col_offset+j-1,color)*(1-mask(i,j-1));
                  if abs(target(row_offset+i,col_offset+j,color)-target(row_offset+i,col_offset+j-1,color))  >= abs(source(i,j,color)-source(i,j-1,color))
                       b(ib) = b(ib) + target(row_offset+i,col_offset+j,color)-target(row_offset+i,col_offset+j-1,color);
                  else
                       b(ib) = b(ib) + source(i,j,color)-source(i,j-1,color);
                  end
      end


      if (j<size(mask,2))
          b(ib)= b(ib)+ target(row_offset+i,col_offset+j+1,color)*(1-mask(i,j+1));
                  if abs(target(row_offset+i,col_offset+j,color)-target(row_offset+i,col_offset+j+1,color)) >= abs(source(i,j,color)-source(i,j+1,color)) 
                       b(ib) = b(ib) + target(row_offset+i,col_offset+j,color)-target(row_offset+i,col_offset+j+1,color);
                  else 
                       b(ib) = b(ib) + source(i,j,color)-source(i,j+1,color);
                  end
      end     


 

    end

    
     % solve linear system A*x = b;
    % your CODE begins here

    x = A \ b;

    % your CODE ends here



    
    % impaint target image
    % solamente se sobreponen los pixeles que se calcularon
    
     for ib=1:N
           I(row_offset+ir(ib),col_offset+ic(ib),color) = x(ib);
     end
    


% YOUR CODE ENDS HERE

figure(1), imshow(target);
figure(2), imshow(I);
figure(3), imshow(source);


end
