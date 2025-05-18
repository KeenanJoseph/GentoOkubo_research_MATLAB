function [r1_mean,g1_mean,b1_mean] = mean_color_0411_large(A,mask_pixels)
%入力した画像AのROI内のh,s,vを出力
[r,g,b] = imsplit(A);

denominator = nnz(mask_pixels);
% roi_matrix,roi_rowは、extract_ROI.mで求めたROI
% 色相角は0~360[deg.]にした
% 明度と彩度は、％表示にした
rMask_mean = sum(r(mask_pixels),"all")/denominator;
gMask_mean = sum(g(mask_pixels),"all")/denominator;
bMask_mean = sum(b(mask_pixels),"all")/denominator;

r1_mean = rMask_mean;
g1_mean = gMask_mean;
b1_mean = bMask_mean;
end