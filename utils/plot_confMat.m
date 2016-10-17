resultFolder = pwd;
results = dlmread(fullfile(resultFolder, 'confusionMat.txt'));

h = figure;
imagesc(results), colormap default, ylabel('test images'), xlabel('memory images')
set(gca,'xaxisLocation','top')
saveas(h, 'confusionMat.jpg')

% the visualization of imshow is slightly different
figure
imshow(results)

% VIsualization when the non-zero elements are put to 1.
figure
imshow(full(spones(results)))