% plot timing
time = yaml.ReadYaml('timing.yaml');

figure
plot(cell2mat(time.time_per_loop))

h = figure;
plot(cell2mat(time.time_per_loop_only_processing)), ylabel('Time (s)'), xlabel('Number of Locations')

saveas(h, 'timing.jpg');