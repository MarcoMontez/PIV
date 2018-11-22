%run('vlfeat-0.9.21/toolbox/vl_setup')
% vl_version verbose
close all; clear; clc;
format compact
%%
% im1=rgb2gray(imread('bonecos/rgb_image1_0005.png'));
% im2=rgb2gray(imread('bonecos/rgb_image2_0005.png'));

im1=rgb2gray(imread('ourimages/mountain1.png'));
im2=rgb2gray(imread('ourimages/mountain2.png'));


%Get Features
[f1, d1] = vl_sift(single(im1));
[f2, d2] = vl_sift(single(im2));
% f = [X;Y;S;TH], where X,Y is the (fractional) center of the frame, 
%                 S is the scale and TH is the orientation (in radians).
% d = 128-dimensional vector of class UINT8.

%Show Features
figure(1);
imshow(im1); hold on; plot(f1(1,:), f1(2,:), '*'); hold off;
%vl_plotsiftdescriptor(d1, f1); %to visualize key frames and descriptors
figure(2);
imshow(im2); hold on; plot(f1(1,:), f1(2,:), '*'); hold off;

%Match Features
[match, sc] = vl_ubcmatch(d1, d2, 1.8); %increase third parameter to increase threshold
% match contains the indexes in d1,d2 of the paired points
% sc is the squared Euclidean distance between the matches (score), 
%    the lower, the better

%Show matching
figure(3) ; clf ;

%if images are differet size we should extend one of them

% sb = size(im1);
% ss = size(im2);
% 
% im1(1,end+ss(2),1) = 0; %extend image
% im1(1:ss(1), sb(2):sb(2)+ss(2)-1, :) = im2;

imshow(cat(2, im1,im2));

xa = f1(1,match(1,:)) ;
xb = f2(1,match(2,:)) + size(im1,2) ;
ya = f1(2,match(1,:)) ;
yb = f2(2,match(2,:)) ;

hold on ;
h = line([xa ; xb], [ya ; yb]) ;
set(h,'linewidth', 1, 'color', 'b') ;

vl_plotframe(f1(:,match(1,:))) ;
f2(1,:) = f2(1,:) + size(im1,2) ;
vl_plotframe(f2(:,match(2,:))) ;
axis image off ;


