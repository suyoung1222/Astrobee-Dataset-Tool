addpath('astrobee_media');
datasetPath = './Astrobee-ISS-Datasets/CAD/';
disp(' ');
disp([' > dataset_load_test [', datasetPath, ']']);

%fname = 'virtualCity';         %model credit: esri CityEngine (http://www.esri.com/software/cityengine)
fname = [datasetPath,'model.urdf']; 
robot = importrobot(fname);
show(robot);