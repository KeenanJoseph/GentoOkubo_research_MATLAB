% -----------------------------------------------------
% 逆ガンマ補正
% 2024/04/08
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
camera = 1; % 実験用カメラの時
% camera = 0; % スマホのカメラの時

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
    % 逆ガンマ補正
    % 既定：sRGB
    % adobe-rgb-1998：約2.2乗
    A.(sprintf('A%d', i)) = rgb2lin(imread(filename),OutputType="double");
    % A.(sprintf('A%d', i)) = rgb2lin(imread(filename),OutputType="double",ColorSpace="adobe-rgb-1998");
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

mask_pixels = double(ones(image_size, "like", A.A1));
pixel_num = nnz(mask_pixels)

figure(1000);
imshow(A.A1);

% % マスク表示
% BW = repmat(mask_pixels,[1 1 3]);
% figA = A.A1;
% AA = zeros(size(figA),"like",figA);
% AA(BW) = A.A1(BW);
% AA(~BW) = 0;
% figure(1000);
% imshow(AA);

% ----------------------------------------------
% 実験画像解析
% 色相角の平均を出力＆標準偏差画像の出力
% ----------------------------------------------
r_mean = zeros(size(AllMask),"like",AllMask);
r_std  = zeros(size(AllMask),"like",AllMask);
g_mean = zeros(size(AllMask),"like",AllMask);
g_std  = zeros(size(AllMask),"like",AllMask);
b_mean = zeros(size(AllMask),"like",AllMask);
b_std  = zeros(size(AllMask),"like",AllMask);
h_mean = zeros(size(AllMask),"like",AllMask);
h_std  = zeros(size(AllMask),"like",AllMask);

% R,G,Bと色相角の平均を出力
for i = 1:use_fig_num
    r.(sprintf('r%d', i))(~mask_pixels) = 0;
    r_mean = r_mean + r.(sprintf('r%d', i));

    g.(sprintf('g%d', i))(~mask_pixels) = 0;
    g_mean = g_mean + g.(sprintf('g%d', i));
    
    b.(sprintf('b%d', i))(~mask_pixels) = 0;
    b_mean = b_mean + b.(sprintf('b%d', i));

    h.(sprintf('h%d', i))(~mask_pixels) = 0;
    h_mean = h_mean + h.(sprintf('h%d', i));
end
r_mean = r_mean/use_fig_num;
g_mean = g_mean/use_fig_num;
b_mean = b_mean/use_fig_num;
h_mean = h_mean/use_fig_num;

% 標準偏差の平均を出力
for i = 1:use_fig_num
    r_sqrt.(sprintf('r%d', i)) = (255*r.(sprintf('r%d', i)) - 255*r_mean).* ...
        (255*r.(sprintf('r%d', i)) - 255*r_mean);
    r_std = r_std + r_sqrt.(sprintf('r%d', i));

    g_sqrt.(sprintf('g%d', i)) = (255*g.(sprintf('g%d', i)) - 255*g_mean).* ...
        (255*g.(sprintf('g%d', i)) - 255*g_mean);
    g_std = g_std + g_sqrt.(sprintf('g%d', i));

    b_sqrt.(sprintf('b%d', i)) = (255*b.(sprintf('b%d', i)) - 255*b_mean).* ...
        (255*b.(sprintf('b%d', i)) - 255*b_mean);
    b_std = b_std + b_sqrt.(sprintf('b%d', i));

    h_sqrt.(sprintf('h%d', i)) = (360*h.(sprintf('h%d', i)) - 360*h_mean).* ...
        (360*h.(sprintf('h%d', i)) - 360*h_mean);
    h_std = h_std + h_sqrt.(sprintf('h%d', i));
end
r_std_mean = sqrt(r_std/use_fig_num);
g_std_mean = sqrt(g_std/use_fig_num);
b_std_mean = sqrt(b_std/use_fig_num);
h_std_mean = sqrt(h_std/use_fig_num);

figure(1002);
if camera == 1
    imagesc(r_std_mean);
else
    imagesc(imrotate(r_std_mean,90)); % imagesc を使うと値のスケールが適切に調整される
    axis equal;
    axis tight;
end
colorbar; % カラーバーを表示
% clim([0 max(r_sqrt.(sprintf('r%d', i)),[],'all')]);
clim([0 20]);

figure(1003);
if camera == 1
    imagesc(g_std_mean);
else
    imagesc(imrotate(g_std_mean,90)); % imagesc を使うと値のスケールが適切に調整される
    axis equal;
    axis tight;
end
colorbar; % カラーバーを表示
% clim([0 max(g_sqrt.(sprintf('g%d', i)),[],'all')]);
clim([0 20]);

figure(1004);
if camera == 1
    imagesc(b_std_mean);
else
    imagesc(imrotate(b_std_mean,90)); % imagesc を使うと値のスケールが適切に調整される
    axis equal;
    axis tight;
end
colorbar; % カラーバーを表示
% clim([0 max(b_sqrt.(sprintf('b%d', i)),[],'all')]);
clim([0 20]);

figure(1005);
if camera == 1
    imagesc(h_std_mean);
else
    imagesc(imrotate(h_std_mean,90)); % imagesc を使うと値のスケールが適切に調整される
    axis equal;
    axis tight;
end
colorbar; % カラーバーを表示
% clim([0 max(h_sqrt.(sprintf('h%d', i)),[],'all')]);
clim([0 20]);
