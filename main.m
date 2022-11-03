
clc
close all;
clear;
load TRAININGSET;
totalLetters=size(TRAIN, 2);


% SELECTING THE TEST DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[file,path]=uigetfile({'*.jpg;*.bmp;*.png;*.tif;*.jfif'},'Choose an image');
s=[path,file];
picture=imread(s);



% CALLING PLATE DETECTOR FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%picture = plate_detector(picture);

imshow(picture);
pause(2);

%{
[h,w,~] = size(picture);
targetSize = [round(w/4) round(w/2)];
win = centerCropWindow2d(size(picture),targetSize);
picture = imcrop(picture, win);
figure
subplot(1,2,1)
imshow(picture)
picture=imresize(picture,[300 600]);
subplot(1,2,2)
imshow(picture)
%}

%RGB2GRAY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
picture=rgb2gray(picture);

diff = edge(picture, "sobel", 0.2);
imshow(diff)

% pic1 = [picture(:,1) picture];
% pic2 = [picture, picture(:,end)];
% diff = pic1-pic2;
% imshow(diff)

% THRESHOLDIG and CONVERSION TO A BINARY IMAGE
threshold = graythresh(picture);
picture =~imbinarize(picture,threshold);
subplot(1,2,2)
imshow(picture)



% Removing the small objects and background
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
figure
% picture = bwareaopen(picture,30); % removes all connected components (objects) that have fewer than 30 pixels from the binary image BW
picture = bwareaopen(picture,30); 
subplot(1,4,1)
imshow(picture)
background=bwareaopen(picture,5000); %for some it didnt worked
%background=bwareaopen(picture,3000);
subplot(1,4,2)
imshow(background)
picture2=picture-background;
subplot(1,4,3)
imshow(picture2)
picture2=bwareaopen(picture2,30);
subplot(1,4,4)
imshow(picture2)
%%


% Labeling connected components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
imshow(picture2)
[L,Ne]=bwlabel(picture2);
propied=regionprops(L,'BoundingBox');
hold on
for n=1:size(propied,1)
    rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
end
hold off



% Decision Making
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
final_output=[];
t=[];
for n=1:Ne
    [r,c] = find(L==n);
    Y=picture2(min(r):max(r),min(c):max(c));
    imshow(Y)
    Y=imresize(Y,[42,24]);
    imshow(Y)
    %pause(0.4)
 
    ro=zeros(1,totalLetters);
    for k=1:totalLetters   
        ro(k)=corr2(TRAIN{1,k},Y);
    end
    [MAXRO,pos]=max(ro);
    out=cell2mat(TRAIN(2,pos));  
    if (MAXRO> 0.5) && (out ~= 'i')     
        final_output=[final_output out];
    end
end



% Printing the plate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file = fopen('number_Plate.txt', 'wt');
fprintf(file,'%s\n',final_output);
fclose(file);
winopen('number_Plate.txt')