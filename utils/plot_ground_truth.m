resultFolder = pwd;
gt_unique = dlmread(fullfile(resultFolder, 'gt_unique.txt'));
gt_enlarged = dlmread(fullfile(resultFolder, 'gt_enlarged.txt'));

h1 = figure;
% imshow(gt_unique)
imagesc(gt_unique), colormap gray, ylabel('test images'), xlabel('memory images')
set(gca,'xaxisLocation','top')
saveas(h1, 'gt_unique.jpg')

h2 = figure;
% imshow(gt_enlarged)
imagesc(gt_enlarged), colormap gray, ylabel('test images'), xlabel('memory images')
set(gca,'xaxisLocation','top')
saveas(h2, 'gt_enlarged.jpg')

