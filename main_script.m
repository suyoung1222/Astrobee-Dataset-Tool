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

% set draw option
set_body = 0; % 0: navcam, 1: IMU, 2:body

% set dataset folder
datasetPath = './Astrobee-ISS-Datasets/ff_return_journey_up';
disp(' ');
disp([' > dataset_load_test [', datasetPath, ']']);

assert(exist(datasetPath, 'dir') > 0, ...
  ' > Dataset folder does not exist, Please set datasetPath.');

% load dataset
imu_raw = readmatrix([datasetPath,'/imu.txt'], 'Delimiter',  ' ');
imu_filtered = readmatrix([datasetPath,'/imu_filtered.txt'], 'Delimiter',  ' ');
gt_trajectory = readmatrix([datasetPath,'/groundtruth.txt'], 'Delimiter',  ' ');
% astroloc_trajectory = readmatrix();
description = readyaml([datasetPath,'/description.yaml']);
if (description.robot == 'bumblebee')
    Tcam_to_body = [0 0 1 0.1177; 1 0 0 -0.0422; 0 1 0 -0.0826];
    Timu_to_body = [0 -1 0 0.0386; 1 0 0 0.0247; 0 0 1 -0.01016];
elseif(description.robot == 'queenbee') % TODO: Update the value from astrobee original github
    Tcam_to_body = [0 0 1 0.1177; 1 0 0 -0.0422; 0 1 0 -0.0826];
    Timu_to_body = [0 -1 0 0.0386; 1 0 0 0.0247; 0 0 1 -0.01016];
end

%% read description
description = readyaml([datasetPath,'/description.yaml']);
disp("==============Dataset Description==============");
disp(['     robot name [', description.robot, ']']);
disp(['     recorded date [', description.recorded_date, ']']);
disp(['     flying area [', description.flying_area, ']']);
disp(['     category [', description.category, ']']);
disp(['     comment [', description.comment, ']']);

%% plot sensor configuration
figure();
sensor_plot(Tcam_to_body, Timu_to_body);
title("Sensor Configurations");
f = FigureRotator();
%% plot IMU state
imu_raw_time = ( imu_raw(:, 1) - imu_raw(1, 1) );
imu_filtered_time = ( imu_filtered(:, 1) - imu_filtered(1, 1) );

figure;
sgtitle("Raw IMU Measurements (Biased) : IMU frame");
subplot(3, 2, 1);
plot(imu_raw(:, 2)); 
xlabel("t"); ylabel("omega x [rad/s]");

subplot(3, 2, 3);
plot(imu_raw(:, 3));
xlabel("t"); ylabel("omega y [rad/s]");

subplot(3, 2, 5);
plot(imu_raw(:, 4));
xlabel("t"); ylabel("omega z [rad/s]");

subplot(3, 2, 2);
plot(imu_raw(:, 5));
xlabel("t"); ylabel("ax [m/s^2]");

subplot(3, 2, 4);
plot(imu_raw(:, 6));
xlabel("t"); ylabel("ay [m/s^2]");

subplot(3, 2, 6);
plot(imu_raw(:, 7));
xlabel("t"); ylabel("az [m/s^2]");

figure;
sgtitle("Filtered IMU Measurements (Unbiased) : Body Frame");
subplot(3, 2, 1);
plot(imu_filtered_time, imu_filtered(:, 2)); 
xlabel("t"); ylabel("omega x [rad/s]");

subplot(3, 2, 3);
plot(imu_filtered_time, imu_filtered(:, 3));
xlabel("t"); ylabel("omega y [rad/s]");

subplot(3, 2, 5);
plot(imu_filtered_time, imu_filtered(:, 4));
xlabel("t"); ylabel("omega z [rad/s]");

subplot(3, 2, 2);
plot(imu_filtered_time, imu_filtered(:, 5));
xlabel("t"); ylabel("ax [m/s^2]");

subplot(3, 2, 4);
plot(imu_filtered_time, imu_filtered(:, 6));
xlabel("t"); ylabel("ay [m/s^2]");

subplot(3, 2, 6);
plot(imu_filtered_time, imu_filtered(:, 7));
xlabel("t"); ylabel("az [m/s^2]");


%% plot groundtruth trajectory
tstamp = gt_trajectory(:, 1);
numPose = length(tstamp);
p_gc_astro = gt_trajectory(:, 2:4);
q_gc_astro = [gt_trajectory(:, 8), gt_trajectory(:, 5:7)];
R_gc_astro = zeros(3, 3, numPose);
for k = 1:numPose
    R_gc_astro(:, :, k) = quat2rotm(q_gc_astro(k, :));
end

figure(10);
for k = 1:numPose
    figure(10); cla;

    % draw moving trajectory
    plot3(p_gc_astro(:, 1), p_gc_astro(:, 2), p_gc_astro(:, 3), 'm', 'LineWidth', 2); hold on; grid on; axis equal;

    % draw camera body and frame
    Rgc_astro_current = R_gc_astro(:, :, k);
    pgc_astro_current = p_gc_astro(k, :);
    plot_camera_frame(Rgc_astro_current, pgc_astro_current', 0.5, 'k'); hold off;
    refresh; pause(0.01); 
end

figure(20);
for k = 1:100:numPose
    plot3(p_gc_astro(:, 1), p_gc_astro(:, 2), p_gc_astro(:, 3), 'm', 'LineWidth', 2); hold on; grid on; axis equal;
    Rgc_astro_current = R_gc_astro(:, :, k);
    pgc_astro_current = p_gc_astro(k, :);
    plot_camera_frame(Rgc_astro_current, pgc_astro_current', 0.5, 'k');
    plot_inertial_frame(1);
    view(90, -90);
end
f = FigureRotator();

%% Functions
function sensor_plot(Tbc, Tbi)

    % plot body
    q_plotPose(zeros(3, 1), [1;0;0;0], 'body', 0.03);
    hold on;
    
    % plot sensors
    for i = 1:2
        if i == 1
            sensor_name = 'navcam';
            p_BS_B = Tbc(1:3, 4);
            C_BS = Tbc(1:3, 1:3);
        else
            sensor_name = 'imu';
            p_BS_B = Tbi(1:3, 4);
            C_BS = Tbi(1:3, 1:3);
        end
        q_SB = q_C2q(C_BS);
        q_plotPose(p_BS_B, q_SB, sensor_name, 0.015);
        plot3([0, p_BS_B(1)], [0, p_BS_B(2)], [0, p_BS_B(3)], 'k');
        axis equal; view(-90, 180);
    
    end
end