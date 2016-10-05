%% Input the images
c1 = double(imread('c1.png'));
c2 = double(imread('c2.png'));
c3 = double(imread('c3.png'));
c4 = double(imread('c4.png'));
f4 = double(imread('f4.png'));
f3 = double(imread('f3.png'));
f2 = double(imread('f2.png'));
f1 = double(imread('f1.png')); f1 = imopen(f1, strel('disk', 3));

%% Scale the depth image to match the colour image
[f1, corrI11, corrI12, corrI13, corrI14, corrI15] = scaleFence(c1, f1);
[f2, corrI21, corrI22, corrI23, corrI24, corrI25] = scaleFence(c2, f2);
[f3, corrI31, corrI32, corrI33, corrI34, corrI35] = scaleFence(c3, f3);
[f4, corrI41, corrI42, corrI43, corrI44, corrI45] = scaleFence(c4, f4);

%% Finding out reference points to make Homography matrix
xy1 = refPoints(f1);
xy2 = refPoints(f2);
xy3 = refPoints(f3);
xy4 = refPoints(f4);

%% Use DLT algorithm by making Homography matrix
% to rectify rotation and skewing effects
[C1, F1] = homoDLT(c1, f1, xy1);
[C2, F2] = homoDLT(c2, f2, xy2);
[C3, F3] = homoDLT(c3, f3, xy3);
[C4, F4] = homoDLT(c4, f4, xy4);

%% Find Translation between 1st and other fences, to align fences
% so as to use Loopy Belief to interpolate 
R = size(C1,1); C = size(C1,2);

% [rShift12, cShift12, corr12] = findTranslF(F1, F2);
% [rShift13, cShift13, corr13] = findTranslF(F1, F3);
% [rShift14, cShift14, corr14] = findTranslF(F1, F4);
% row_shifts = [rShift12 rShift13 rShift14];
% col_shifts = [cShift12 cShift13 cShift14];
% clear rShift12 rShift13 rShift14 cShift12 cShift13 cShift14

[rShift12_f, cShift12_f, corr12R_f, corr12C_f] = findTranslF_fast(F1, F2);
[rShift13_f, cShift13_f, corr13R_f, corr13C_f] = findTranslF_fast(F1, F3);
[rShift14_f, cShift14_f, corr14R_f, corr14C_f] = findTranslF_fast(F1, F4);
row_shifts = [rShift12_f rShift13_f rShift14_f];
col_shifts = [cShift12_f cShift13_f cShift14_f];
clear rShift12_f cShift12_f rShift13_f cShift13_f rShift14_f cShift14_f

%% FENCE ALIGNMENT: Shifting Colour & Fence Images with Translations found to align fences
C234 = zeros(size(C1,1), size(C1,2), size(C1,3), 3);
C234(:,:,:,1) = C2; C234(:,:,:,2) = C3; C234(:,:,:,3) = C4;
F234 = zeros(size(F1,1), size(F1,2), 3);
F234(:,:,1) = F2; F234(:,:,2) = F3; F234(:,:,3) = F4;
newC234 = C234;
newF234 = F234;
for k=1:3
    rShift = row_shifts(k);
    cShift = col_shifts(k);
    newC = zeros(size(C1));
    newF = zeros(size(F1));
    oldC = C234(:,:,:,k);
    oldF = F234(:,:,k);
    if(rShift>=0 && cShift>=0)
        newC(rShift+1:end, cShift+1:end, :) = oldC(1:end-rShift, 1:end-cShift, :);
        newF(rShift+1:end, cShift+1:end) = oldF(1:end-rShift, 1:end-cShift);
    else if(rShift<0 && cShift>=0)
            newC(1:end+rShift, cShift+1:end, :) = oldC(-rShift+1:end, 1:end-cShift, :);
            newF(1:end+rShift, cShift+1:end) = oldF(-rShift+1:end, 1:end-cShift);
        else if(rShift>=0 && cShift<0)
                newC(rShift+1:end, 1:end+cShift, :) = oldC(1:end-rShift, -cShift+1:end, :);
                newF(rShift+1:end, 1:end+cShift) = oldF(1:end-rShift, -cShift+1:end);
            else newC(1:end+rShift, 1:end+cShift, :) = oldC(-rShift+1:end, -cShift+1:end, :);
                newC(1:end+rShift, 1:end+cShift, :) = oldC(-rShift+1:end, -cShift+1:end, :);
                newF(1:end+rShift, 1:end+cShift) = oldF(-rShift+1:end, -cShift+1:end);
            end
        end
    end
    newC234(:,:,:,k) = newC;
    newF234(:,:,k) = newF;
end

figure, subplot(231), imshow(uint8(.4*C1 + .7*C2)), title('C2 superimposed on C1', 'fontsize', 16), ...
    subplot(232), imshow(uint8(.4*C1 + .6*C3)), title('C3 superimposed on C1', 'fontsize', 16), ...
    subplot(233), imshow(uint8(.4*C1 + .6*C4)), title('C4 superimposed on C1', 'fontsize', 16), ...
    subplot(234), imshow(uint8(.4*C1 + .6*newC234(:,:,:,1))), title('Translated C2 superimposed on C1', 'fontsize', 16), ...
    subplot(235), imshow(uint8(.4*C1 + .6*newC234(:,:,:,2))), title('Translated C3 superimposed on C1', 'fontsize', 16), ...
    subplot(236), imshow(uint8(.4*C1 + .6*newC234(:,:,:,3))), title('Translated C4 superimposed on C1', 'fontsize', 16), 

Y_Obs = zeros(4, 300, 300);
Y_Obs(1,:,:) = rgb2gray(uint8(C1(1:300,125:424,:)));
Y_Obs(2,:,:) = rgb2gray(uint8(newC234(1:300,125:424,:,1)));
Y_Obs(3,:,:) = rgb2gray(uint8(newC234(1:300,125:424,:,2)));
Y_Obs(4,:,:) = rgb2gray(uint8(newC234(1:300,125:424,:,3)));
fence = zeros(4, 300, 300);
fence(1,:,:) = F1(1:300,125:424)>0;
fence(2,:,:) = newF234(1:300,125:424,1)>0;
fence(3,:,:) = newF234(1:300,125:424,2)>0;
fence(4,:,:) = newF234(1:300,125:424,3)>0;

clear C234 F234 rShift cShift newC newF oldC oldF k

%% Find row_shift & col_shift in new 300x300 images

[rShift12, cShift12, varT12] = findTranslCol(squeeze(Y_Obs(1,:,:)), squeeze(fence(1,:,:)), squeeze(Y_Obs(2,:,:)), squeeze(fence(2,:,:)));
[rShift13, cShift13, varT13] = findTranslCol(squeeze(Y_Obs(1,:,:)), squeeze(fence(1,:,:)), squeeze(Y_Obs(3,:,:)), squeeze(fence(3,:,:)));
[rShift14, cShift14, varT14] = findTranslCol(squeeze(Y_Obs(1,:,:)), squeeze(fence(1,:,:)), squeeze(Y_Obs(4,:,:)), squeeze(fence(4,:,:)));
row_shifts = [rShift12 rShift13 rShift14];
col_shifts = [cShift12 cShift13 cShift14];
clear rShift12 rShift13 rShift14 cShift12 cShift13 cShift14

%% In-Paint using Loopy Belief
[image, defenced_image] = LBP2_ed4(row_shifts,col_shifts,Y_Obs,1-fence);
