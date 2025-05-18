% -----------------------------------------------------
% ROI 標準偏差画像作成、
% 2024/04/02
% 実験条件
% 同軸照明（LEDライト）：LFV3-35SW(A)
% 実験用カメラ：Basler ace・acA2440-35ucMED
% 覆い：黒色のポリスチレンボード
% Exposure Value：420000
% Width：1000、Height：1000
% 保存する画像の形式：TIFF
% -----------------------------------------------------
close all
clear

set(0,'defaultAxesFontSize',24);
set(0,'defaultAxesFontName','times');
set(0,'defaultTextFontSize',24);
set(0,'defaultTextFontName','times');
set(0,'DefaultFigureColormap', jet);

%%
% config
% 実験用カメラかスマホのカメラか
% camera = 1; % 実験用カメラの時
camera = 0; % スマホのカメラの時

% 画像ディレクトリの設定
if camera == 1
    A2 = '.\camera\EG';
    file_ext = '.tiff';
else
    A2 = '.\smartphone\EG';
    file_ext = '.png';
end

% 使用する画像番号
% img_num = '0';
% img_num = '20';
% img_num = '40';
% img_num = '60';
% img_num = '80';
img_num = '100';
use_img = append(A2, img_num, '\');

% 画像枚数
use_fig_num = 10;

%%
% ----------------------------------------------
% 実験画像解析
% マスク作成
% ----------------------------------------------
% 画像を保存する構造体
A = struct();
Ahsv = struct();
r = struct();
g = struct();
b = struct();
h = struct();
s = struct();
v = struct();
r_sqrt = struct();
g_sqrt = struct();
b_sqrt = struct();
h_sqrt = struct();

% 画像の読み込み
for i = 1:use_fig_num
    filename = append(use_img, sprintf('%d', i), file_ext);
    A.(sprintf('A%d', i)) = im2double(imread(filename));
    % A.(sprintf('A%d', i)) = rgb2lin(imread(filename),OutputType="double");
    % A.(sprintf('A%d', i)) = rgb2lin(imread(filename),OutputType="double", ...
    %     ColorSpace="adobe-rgb-1998");
end

% `AllMask` を最初の画像のサイズに合わせて初期化
image_size = size(A.A1(:,:,1));  % グレースケール画像と仮定
AllMask = double(zeros(image_size, "like", A.A1));

% RGB画像から、r, g, bを分解
for i = 1:use_fig_num
    [r.(sprintf('r%d', i)), g.(sprintf('g%d', i)), b.(sprintf('b%d', i))] = ...
        imsplit(A.(sprintf('A%d', i)));
end

% RGB画像をHSVに変換し、h, s, vを分解
for i = 1:use_fig_num
    Ahsv.(sprintf('Ahsv%d', i)) = rgb2hsv(A.(sprintf('A%d', i)));
    [h.(sprintf('h%d', i)), s.(sprintf('s%d', i)), v.(sprintf('v%d', i))] = ...
        imsplit(Ahsv.(sprintf('Ahsv%d', i)));
end

% 画像マスク処理
for i = 1:use_fig_num
    AMask = double(ones(image_size, "like", A.A1));

    % 不要領域のマスキング
    if camera == 1
        % バルク屈折率感度測定
        AMask(1:360, :) = 0;
        AMask(620:1400, :) = 0;
        AMask(:, 1:570) = 0;
        AMask(:, 970:1400) = 0;
        % リファレンス
        % AMask(1:920, :) = 0;
        % AMask(1120:1400, :) = 0;
        % AMask(:, 1:720) = 0;
        % AMask(:, 920:1400) = 0;
    else
        % バルク屈折率感度測定
        AMask(:, 1:930) = 0;
        AMask(:, 1190:1920) = 0;
        AMask(1:550, :) = 0;
        AMask(950:1440, :) = 0;
        % リファレンス
        % AMask(:, 1:350) = 0;
        % AMask(:, 550:1920) = 0;
        % AMask(1:730, :) = 0;
        % AMask(930:1440, :) = 0;
    end
    AllMask = AllMask + AMask;
end
mask_pixels = (AllMask == use_fig_num);
pixel_num = nnz(mask_pixels)

% マスク表示
BW = repmat(mask_pixels,[1 1 3]);
figA = A.A1;
AA = zeros(size(figA),"like",figA);
AA(BW) = A.A1(BW);
AA(~BW) = 0;
figure(1000);
imshow(AA);

[rAA,gAA,bAA] = imsplit(AA);
% 赤成分だけのカラー画像
redImage = cat(3, rAA, zeros(size(rAA), 'like', rAA), zeros(size(rAA), 'like', rAA));
figure(2000);
imshow(redImage);
title('赤成分');

% 緑成分だけのカラー画像
greenImage = cat(3, zeros(size(gAA), 'like', gAA), gAA, zeros(size(gAA), 'like', gAA));
figure(2001);
imshow(greenImage);
title('緑成分');

% 青成分だけのカラー画像
blueImage = cat(3, zeros(size(bAA), 'like', bAA), zeros(size(bAA), 'like', bAA), bAA);
figure(2002);
imshow(blueImage);
title('青成分');

% ----------------------------------------------
% 実験画像解析
% 色相角の平均を出力＆標準偏差画像の出力
% ----------------------------------------------
r1_mean=0;
g1_mean=0;
b1_mean=0;
h1_mean=0;
s1_mean=0;
v1_mean=0;
% 画像10枚分を解析するので、zeros(10,3)
Resultrgb_mean = zeros(use_fig_num,3);
Resultrgb_std  = zeros(use_fig_num,3);
Resulthsv_mean = zeros(use_fig_num,3);
Resulthsv_std  = zeros(use_fig_num,3);

for i=1:use_fig_num
    if camera==1
        img_path = append(use_img,"\",num2str(i),".tiff");
    else
        img_path = append(use_img,"\",num2str(i),".png");
    end
    imgA = imread(img_path);
    if strcmp(img_num,'0')|strcmp(img_num,'20')|strcmp(img_num,'40')
        [h1_mean,s1_mean,v1_mean] = mean_color_0130_small(imgA,mask_pixels); % EG0~40
    else
        [h1_mean,s1_mean,v1_mean] = mean_color_0130_large(imgA,mask_pixels); % EG60~100
        [r1_mean,g1_mean,b1_mean] = mean_color_0411_large(imgA,mask_pixels);
        % [h1_mean,s1_mean,v1_mean] = mean_color_0130_large_Gamma(imgA,mask_pixels); % EG60~100
        % [r1_mean,g1_mean,b1_mean] = mean_color_0411_large_Gamma(imgA,mask_pixels);
    end
    Resulthsv_mean(i,1) = h1_mean;
    Resulthsv_mean(i,2) = s1_mean;
    Resulthsv_mean(i,3) = v1_mean;
    Resulthsv_std(i,1)  = h1_mean;
    Resulthsv_std(i,2)  = s1_mean;
    Resulthsv_std(i,3)  = v1_mean;
    Result1mean = [h1_mean,s1_mean,v1_mean];
    Resultrgb_mean(i,1) = r1_mean;
    Resultrgb_mean(i,2) = g1_mean;
    Resultrgb_mean(i,3) = b1_mean;
    Resultrgb_std(i,1)  = r1_mean;
    Resultrgb_std(i,2)  = g1_mean;
    Resultrgb_std(i,3)  = b1_mean;
    Result1rgbmean = [r1_mean,g1_mean,b1_mean]
end

h_mean = sum(Resulthsv_mean(:,1))/use_fig_num;
s_mean = sum(Resulthsv_mean(:,2))/use_fig_num;
v_mean = sum(Resulthsv_mean(:,3))/use_fig_num;
h_std  = std(Resulthsv_std(:,1),0,"all");
s_std  = std(Resulthsv_std(:,2),0,"all");
v_std  = std(Resulthsv_std(:,3),0,"all");
r_mean = sum(Resultrgb_mean(:,1))/use_fig_num;
g_mean = sum(Resultrgb_mean(:,2))/use_fig_num;
b_mean = sum(Resultrgb_mean(:,3))/use_fig_num;
r_std  = std(Resultrgb_std(:,1),0,"all");
g_std  = std(Resultrgb_std(:,2),0,"all");
b_std  = std(Resultrgb_std(:,3),0,"all");

% 出力
Result10hsvmean = [h_mean,s_mean,v_mean]
Result10hsvstd  = [h_std,s_std,v_std]
Result10rgbmean = [r_mean,g_mean,b_mean]
Result10rgbstd  = [r_std,g_std,b_std]

Ahsv1 = rgb2hsv(AA);
[h1,s1,v1] = imsplit(Ahsv1);
[r1,g1,b1] = imsplit(AA);

%%
% ----------------------------------------------
% HSV画像のヒストグラム
% ----------------------------------------------

% 色相角のヒストグラム
figure(1005);
imhist(h1)
axis([0 1 0 20000])
hold on;
if h_mean>=360
    h_max=h_mean-360;
else
    h_max=h_mean;
end
stem(h_max/360,100000,'ro','LineWidth',2)
legend('Hue','Mean','Location','northwest')
hold off;

% 彩度のヒストグラム
figure(1006);
imhist(s1);
hold on;
stem(s_mean/100,100000,'ro','LineWidth',2)
legend('Saturation','Mean','Location','northwest')
hold off;
axis([0 1 0 20000]);

% 明度のヒストグラム
figure(1007);
imhist(v1)
hold on;
stem(v_mean/100,100000,'ro','LineWidth',2)
legend('Value','Mean','Location','northwest')
hold off;
axis([0 1 0 20000]);

% ----------------------------------------------
% RGB画像のヒストグラム
% ----------------------------------------------

% Rのヒストグラム
figure(1008);
imhist(r1)
hold on;
stem(r_mean/255,100000,'ro','LineWidth',2)
legend('R','Mean','Location','northwest')
hold off;
axis([0 1 0 6000])

% Gのヒストグラム
figure(1009);
imhist(g1);
hold on;
stem(g_mean/255,100000,'ro','LineWidth',2)
legend('G','Mean','Location','northwest')
hold off;
axis([0 1 0 6000]);

% Bのヒストグラム
figure(1010);
imhist(b1)
hold on;
stem(b_mean/255,100000,'ro','LineWidth',2)
legend('B','Mean','Location','northwest')
hold off;
axis([0 1 0 6000]);