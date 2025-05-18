% -----------------------------------------------------
% 標準偏差画像作成
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
h = struct();
s = struct();
v = struct();
h_sqrt = struct();

% 画像の読み込み
for i = 1:use_fig_num
    filename = append(use_img, sprintf('%d', i), file_ext);
    A.(sprintf('A%d', i)) = imread(filename);
end

% `AllMask` を最初の画像のサイズに合わせて初期化
image_size = size(A.A1(:,:,1));  % グレースケール画像と仮定
AllMask = double(zeros(image_size, "like", A.A1));

% RGB画像をHSVに変換し、h, s, vを分解
for i = 1:use_fig_num
    Ahsv.(sprintf('Ahsv%d', i)) = rgb2hsv(A.(sprintf('A%d', i)));
    [h.(sprintf('h%d', i)), s.(sprintf('s%d', i)), v.(sprintf('v%d', i))] = ...
        imsplit(Ahsv.(sprintf('Ahsv%d', i)));
end

% 画像マスク処理
for i = 1:use_fig_num
    img_path = fullfile(use_img, sprintf('%d%s', i, file_ext));

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
AA(~BW) = 255;
figure(1000);
imshow(AA);

% マスクと原画像を一緒に表示
figure(1001);
imshowpair(A.A1,AA)

% ----------------------------------------------
% 実験画像解析
% 色相角の平均を出力＆標準偏差画像の出力
% ----------------------------------------------
h_mean = zeros(size(AllMask),"like",AllMask);
h_std  = zeros(size(AllMask),"like",AllMask);

% 色相角の平均を出力
for i = 1:use_fig_num
    h.(sprintf('h%d', i))(~mask_pixels) = 0;
    h_mean = h_mean + h.(sprintf('h%d', i));
end
h_mean = h_mean/10;

% 標準偏差の平均を出力
for i = 1:use_fig_num
    h_sqrt.(sprintf('h%d', i)) = sqrt((360*h.(sprintf('h%d', i)) - 360*h_mean).* ...
        (360*h.(sprintf('h%d', i)) - 360*h_mean));
    h_std = h_std + h_sqrt.(sprintf('h%d', i));
end
h_std_mean = h_std/10;

figure(1002);
imagesc(h_std_mean); % imagesc を使うと値のスケールが適切に調整される
if camera==1
    axis([570 970 360 620]);
    axis off; 
else
    axis([930 1190 550 950]);
    axis off;
end
colorbar; % カラーバーを表示
% clim([0 max(h_sqrt.(sprintf('h%d', i)),[],'all')]);
clim([0 6]);
