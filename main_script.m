% ------------------------------------------------------------------------------
% Function : minimal load dataset script
% Project  : Astrobee ISS Datasets
% Author   : suyoungkang
% Version  : V01  28AUG2015 Initial version.
% Comment  : https://astrobee-iss-dataset.github.io/
% Status   : accepted at RA-L 2024
% ------------------------------------------------------------------------------

clc;
close all;
clear variables; %clear classes;

addpath('quaternion');
addpath('readyaml');
addpath('colladaParser');

% set dataset folder
datasetPath = './Astrobee-ISS-Datasets/ff_return_journey_forward';
disp(' ');
disp([' > dataset_load_test [', datasetPath, ']']);

assert(exist(datasetPath, 'dir') > 0, ...
  ' > Dataset folder does not exist, Please set datasetPath.');

% load dataset
dataset = dataset_load(datasetPath);

% plot dataset
dataset_plot(dataset);
