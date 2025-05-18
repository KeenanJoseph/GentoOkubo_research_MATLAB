function [h1_mean,s1_mean,v1_mean] = mean_color_0130_large_Gamma(A,AMask_slide)
%入力した画像AのROI内のh,s,vを出力
A_hsv = rgb2hsv(A);
[hh,ss,vv] = imsplit(A_hsv);

denominator = nnz(AMask_slide);
% roi_matrix,roi_rowは、extract_ROI.mで求めたROI
% 色相角は0~360[deg.]にした
% 明度と彩度は、％表示にした
hMask_mean = 360*sum(hh(AMask_slide),"all")/denominator;
sMask_mean = 100*sum(ss(AMask_slide),"all")/denominator;
vMask_mean = 100*sum(vv(AMask_slide),"all")/denominator;

h1_mean = hMask_mean;
s1_mean = sMask_mean;
v1_mean = vMask_mean;
end