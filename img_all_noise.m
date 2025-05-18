% ----------------------------------------------
% 標準偏差画像の生成
% 画像全体のノイズの載り方を調査
% ----------------------------------------------
close all
clear

set(0,'defaultAxesFontSize',24);
set(0,'defaultAxesFontName','times');
set(0,'defaultTextFontSize',24);
set(0,'defaultTextFontName','times');
set(0,'DefaultFigureColormap', jet);

%% 
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

figure(2000);
imshow(A.(sprintf('A%d', 1)))

% RGB画像をHSVに変換し、h, s, vを分解
for i = 1:use_fig_num
    Ahsv.(sprintf('Ahsv%d', i)) = rgb2hsv(A.(sprintf('A%d', i)));
    [h.(sprintf('h%d', i)), s.(sprintf('s%d', i)), v.(sprintf('v%d', i))] = ...
        imsplit(Ahsv.(sprintf('Ahsv%d', i)));
end

h_mean = zeros(size(h.(sprintf('h%d', 1))),"like",h.(sprintf('h%d', 1)));
for i = 1:use_fig_num
    h_mean = h_mean + h.(sprintf('h%d', i));
end
h_mean = h_mean/use_fig_num;

for i = 1:use_fig_num
    h_sqrt.(sprintf('h%d', i)) = sqrt((360*h.(sprintf('h%d', i)) - 360*h_mean).* ...
        (360*h.(sprintf('h%d', i)) - 360*h_mean));
    figure(i);
    % histogram(h_sqrt.(sprintf('h%d', i)),1)
    imagesc(h_sqrt.(sprintf('h%d', i))); % imagesc を使うと値のスケールが適切に調整される
    % colormap jet; % カラーマップを設定
    colorbar; % カラーバーを表示
    % axis image; % アスペクト比を保持
    % clim([0 max(h_sqrt.(sprintf('h%d', i)),[],'all')]);
    clim([0 80]);
end

for i = 1:use_fig_num
    figure(i+100)
    histogram(h_sqrt.(sprintf('h%d', i)))
    xlim([-1 80])
    ylim([0 250000])
end
