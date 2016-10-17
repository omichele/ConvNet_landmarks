% 47.2185143,-1.5487041,16.5z    dataset optimal google map coord
% Fourc points in Nantes
% 47.2227703,-1.554485
% 47.2151752,-1.5529525
% 47.2170097,-1.5417094
% 47.2215955,-1.5433481
% 47.2189471,-1.5475662     5th point to be added on the existent map

lat = [47.2227703   47.2151752   47.2170097   47.2215955];
lon = [-1.554485    -1.5529525    -1.5417094   -1.5433481];

lat = [47.2227703   47.2151752   47.2170097   47.2215955    47.2215955];
lon = [-1.554485    -1.5529525    -1.5417094   -1.5433481   -1.5433481];

% example points europe
% lat = [48.8708   51.5188   41.9260   40.4312   52.523   37.982];
% lon = [2.4131    -0.1300    12.4951   -3.6788    13.415   23.715];

plot(lon, lat, '.r', 'MarkerSize', 20)      % print the points and at the same time set the size of the plot so plot_google_map knows what to display
plot_google_map


%% example geoshow
h = geoshow(lat, lon, 'DisplayType', 'Point')

load korea


figure;
worldmap(map, refvec)

geoshow(gca,map,refvec,'DisplayType','texturemap');
demcmap(map)


%% example geoshow 2

states = geoshape(shaperead('usastatehi', 'UseGeoCoords', true));


figure
ax = usamap('conus');
oceanColor = [.5 .7 .9];
setm(ax, 'FFaceColor', oceanColor)
geoshow(states)
title({ ...
    'Conterminous USA State Boundaries', ...
    'Polygon Geographic Vector Data'})


placenames = gpxread('boston_placenames');


route = gpxread('sample_route.gpx');


stateName = 'Massachusetts';
ma = states(strcmp(states.Name, stateName));

figure
ax = usamap('ma');
setm(ax, 'FFaceColor', oceanColor)
geoshow(states)
geoshow(ma, 'LineWidth', 1.5, 'FaceColor', [.5 .8 .6])
geoshow(placenames);
geoshow(route.Latitude, route.Longitude);
title({'Massachusetts and Surrounding Region', 'Placenames and Route'})


lat = [route.Latitude placenames.Latitude];
lon = [route.Longitude placenames.Longitude];
latlim = [min(lat) max(lat)];
lonlim = [min(lon) max(lon)];
[latlim, lonlim] = bufgeoquad(latlim, lonlim, .05, .05);

figure
ax = usamap(latlim, lonlim);
setm(ax, 'FFaceColor', oceanColor)
geoshow(states)
geoshow(placenames)
geoshow(route.Latitude, route.Longitude)
title('Closeup of Placenames and Route')


filename = 'boston_ovr.jpg';
RGB = imread(filename);
R = worldfileread(getworldfilename(filename), 'geographic', size(RGB));


figure
ax = usamap(RGB, R);
setm(ax, ...
    'MLabelLocation',.05, 'PLabelLocation',.05, ...
    'MLabelRound',-2, 'PLabelRound',-2)
geoshow(RGB, R)
title('Boston Overview')


lat = [route.Latitude  placenames.Latitude  R.LatitudeLimits];
lon = [route.Longitude placenames.Longitude R.LongitudeLimits];
latlim = [min(lat) max(lat)];
lonlim = [min(lon) max(lon)];


figure
ax = usamap(latlim, lonlim);
setm(ax, 'GColor','k', ...
    'PLabelLocation',.05, 'PLineLocation',.05)
geoshow(RGB, R)
geoshow(states.Latitude, states.Longitude, 'LineWidth', 2, 'Color', 'y')
geoshow(placenames)
geoshow(route.Latitude, route.Longitude)
title('Boston Overview and Geographic Vector Data')



latlim = [min(ma.Latitude),  max(ma.Latitude)];
lonlim = [min(ma.Longitude), max(ma.Longitude)];
[latlim, lonlim] = bufgeoquad(latlim, lonlim, .05, .05);


figure
ax = usamap(latlim, lonlim);
setm(ax, 'FFaceColor', oceanColor)
geoshow(states)
geoshow(ma, 'LineWidth', 1.5, 'FaceColor', [.5 .8 .6])
geoshow(RGB, R)
geoshow(placenames)
geoshow(route.Latitude, route.Longitude)
titleText = 'Massachusetts and Surrounding Region';
title(titleText)


xLoc = -127800;
yLoc = 5014700;
scaleruler('Units', 'mi', 'RulerStyle', 'patches',  ...
    'XLoc', xLoc, 'YLoc', yLoc);
title({titleText, 'with Scale Ruler'})


northArrowLat =  42.5;
northArrowLon = -70.25;
northarrow('Latitude', northArrowLat, 'Longitude', northArrowLon);
title({titleText, 'with Scale Ruler and North Arrow'})


h2 = axes('Position', [.15 .6 .2 .2], 'Visible', 'off');
usamap({'PA','ME'})
plabel off; mlabel off
setm(h2, 'FFaceColor', 'w');
geoshow(states, 'FaceColor', [.9 .6 .7], 'Parent', h2)
plotm(latlim([1 2 2 1 1]), lonlim([2 2 1 1 2]), ...
    'Color', 'red', 'LineWidth', 2)
title(ax, {titleText, 'with Scale Ruler, North Arrow, and Inset Map'})