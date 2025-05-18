function [h1_mean,s1_mean,v1_mean] = mean_color_0130_pre(Ahsv,AMask_slide)
%入力した画像AのROI内のh,s,vを出力
[h,s,v] = imsplit(Ahsv);

denominator = nnz(AMask_slide);
h_selected = h(AMask_slide); % ROI 部分の h 成分を抽出
h_selected(h_selected <= 0.2 & h_selected > 0) = h_selected(h_selected <= 0.2 & h_selected > 0) + 1;

% roi_matrix,roi_rowは、extract_ROI.mで求めたROI
% 色相角は0~360[deg.]にした
% 明度と彩度は、％表示にした
hMask_mean = 360*sum(h_selected,"all")/denominator;
sMask_mean = 100*sum(s(AMask_slide),"all")/denominator;
vMask_mean = 100*sum(v(AMask_slide),"all")/denominator;

% if hMask_mean > 360
%     hMask_mean=hMask_mean-360;
% end

h1_mean = hMask_mean;
s1_mean = sMask_mean;
v1_mean = vMask_mean;
end