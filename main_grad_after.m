%%
close all; clear; clc;
format compact

%% Load Images and find Background module
img_folder = 'um';
[imgs, imgsd, bgdepth, bggray] = backgroundmodule(img_folder);
%%
% Bg subtraction for depth (try with gray too)
%for i=length(d)/2,
minimum_pixels = 3000;
se = strel('disk',6);
su = strel('disk',4);


for i=1:size(imgs,3),
%     i=10;
    imdiff=abs(imgsd(:,:,i)-bgdepth)>.2;
    %
%     figure()
%     imagesc(imgsd(:,:,i));
    
    %20cm margin for kinnect error. But wait! Kinnect doesn't work in black
    %objects (might say something's moving when it's not), also for contours
    %and transitions
    
    %imdiff=abs(imgs(:,:,i)-bggray)>.20;
    imgdiffiltered=imopen(imdiff,se); %%erosion and dilation

    closed_image = imclose(imgdiffiltered, su);

    connected = bwlabel(closed_image); %8-connected
    %vamos experimentar aumentar o raio do disco sem "quebrar" o prof
    
    %filtro de ru�do por volume (n� de pixeis por classe)
    nclasses = max(connected(:));
    
    
    
    for k=1:nclasses,
        [class_x, class_y] = find(connected==k);
        if( size(class_x,1) <= minimum_pixels),
            connected(class_x, class_y) = 0;
        end
        clear class_x;
        clear class_y;
    end
    
    %re-ordenar classes
    connected2 = bwlabel(connected);
    
    figure()
    imagesc(connected2);
    
    img_copy=imgsd(:,:,i);
    for x=1:size(connected2,1)
        for y=1:size(connected,2)
            if connected2(x,y)==0
               img_copy(x,y)=20;
            end
        end
    end
    
%     figure()
%     imagesc(img_copy);
%     
    [Gmag, Gdir] = imgradient(img_copy,'prewitt');
% 
%     figure()
%     imshowpair(Gmag, Gdir, 'montage');
    
    for x=1:size(connected2,1)
        for y=1:size(connected,2)
            if Gmag(x,y)>2 || img_copy(x,y)==20
               Gmag(x,y)=0;
            else
                Gmag(x,y)=1;
            end
        end
    end
    
%     figure()
%     imagesc(Gmag);
    
     connected3 = bwlabel(Gmag); %8-connected
    %vamos experimentar aumentar o raio do disco sem "quebrar" o prof
    
    figure()
    imagesc(connected3);
%     title('Gradient edge removed')
    %filtro de ru�do por volume (n� de pixeis por classe)
     nclasses = max(connected3(:));
%     
%     
    %Elimina os conjuntos menores que minimum_pixels     
     for k=1:nclasses,
        [class_x, class_y] = find(connected3==k);
        if( size(class_x,1) <= minimum_pixels),
            for x=1:length(class_x)
                connected3(class_x(x), class_y(x)) = 0;
            end
        end
     end
    
    
   %Calcular x,y,z
    %Reordenar classes
    connected3 = bwlabel(connected3);
    nclasses = max(connected3(:));
    
    classes={};
    for k=1:nclasses,
        [class_x, class_y] = find(connected3==k);
        classe=zeros(1,length(class_x));
        for j=1:length(class_x)  
             classe(j)=imgsd(class_x(j),class_y(j),i);
        end
        %Retira os valores de z=0;
        classe(classe==0)=[];
        %Guarda o array numa cell, porque uma cell pode conter arrays de
        %tamanhos diferentes
        classes{k}=classe;
        classes_z(k,1)=max(classe);
        classes_z(k,2)=min(classe);
        classes_x(k,1)=max(class_x);
        classes_x(k,2)=min(class_x);
        classes_y(k,1)=max(class_y);
        classes_y(k,2)=min(class_y);
        
    end
        classes_z
        classes_x
        classes_y
    
    maxValue_x=classes_x(1,1);  
    minValue_x=classes_x(1,2);
    maxValue_y=classes_y(1,1);
    minValue_y=classes_y(1,2);
    
    figure()
    imagesc(connected3);
    
    figure()
    hold all
    imagesc(connected3);
    line([minValue_y maxValue_y],[minValue_x minValue_x],'Color','red')
    line([minValue_y maxValue_y],[maxValue_x maxValue_x],'Color','red')
    line([minValue_y minValue_y],[minValue_x maxValue_x],'Color','red')
    line([maxValue_y maxValue_y],[minValue_x maxValue_x],'Color','red')
    %Inverte a imagem
    camroll(180)
    hold off
%     title('Gradient filtered image')     
    %%
end

%%