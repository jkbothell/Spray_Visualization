clear, clc

% Read in original image
image = imread('x=0_y=4.6_Ql=0.099_Qg=329_000213.tif');
image = im2double(image); %convert to double
figure, imshow(image)

% Image with increased contrast to utalize full grayscale
image_full_contrast = imadjust(image);
imwrite(image_full_contrast, 'full_contrast.tif')

% Find gradient
gmag = imgradient(image_full_contrast);
maximum = max(max(gmag));
gmag_adjusted = gmag.*(1/maximum);
imwrite(gmag_adjusted, 'gradient.tif')

% Canny edge detector
lower_threshold = edge(image_full_contrast, 'canny', 0.08);
upper_threshold = edge(image_full_contrast, 'canny', 0.2);

% Morphology with canny edge detector
siz = size(image_full_contrast);
connectivity = zeros(siz(1),siz(2),30);
connectivity(:,:,1) = upper_threshold;
for k = 1:30
    for i = 1:siz(1)
        for j = 1:siz(2)
            if connectivity(i,j,k) > 0
                connectivity(i-1:i+1, j-1:j+1,k+1) = lower_threshold(i-1:i+1, j-1:j+1);
            end
        end
    end
end

figure, imshow(connectivity(:,:,30))
lines = connectivity(:,:,30);
lines(lines<1) = NaN;
imwrite(lines, 'canny_edges.tif')

% filling in regions with liquid 
lines(image_full_contrast<0.55) = 1;

% filling in phase boundaries
fill_phase = lines;
a = zeros(siz);
a(image_full_contrast>0.85) = 1;
fill_phase(image_full_contrast>0.85) = 1;

% filling further
fill_phase(isnan(fill_phase)) = 0;
BW = imfill(fill_phase, 'holes');

% opening image
se = strel('disk', 2);
J = imopen(BW, se);

% eliminate background from image
segmented = image_full_contrast;
added = ones(siz);
segmented = (segmented.*-1)+added;
segmented(J<.001) = 0;
imwrite(segmented, 'segmented.tif')

% eliminate background without inverting
segmented_forward = image_full_contrast;
segmented_forward(J<.001) = 0;

% simple threshold
thresholded = image_full_contrast;
added = ones(siz);
thresholded = (thresholded.*-1)+added;
thresholded(thresholded<0.45) = NaN;
figure, imshow(thresholded)
imwrite(thresholded, 'thresholded.tif')

% inverted full contrast image
inverted = image_full_contrast;
added = ones(siz);
inverted = (inverted.*-1)+added;
figure, imshow(inverted)
imwrite(inverted, 'inverted.tif')

% coloring image blue and yellow
figure, contourf(segmented, 'edgecolor', 'none');
set(gca,'position', [0 0 1 1], 'XTick', [], 'YTick', [])
saveas(gcf, 'parula', 'tif')

% coloring image orange
figure, contourf(segmented, 'edgecolor', 'none');
colormap(autumn)
set(gca,'position', [0 0 1 1], 'XTick', [], 'YTick', [])
saveas(gcf, 'autumn', 'tif')

% coloring image pink
figure, contourf(segmented, 'edgecolor', 'none');
colormap(pink)
set(gca,'position', [0 0 1 1], 'XTick', [], 'YTick', [])
saveas(gcf, 'pink', 'tif')





