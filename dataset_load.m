% ------------------------------------------------------------------------------
% Function : load dataset
% Project  : IJRR MAV Datasets
% Author   : www.asl.ethz.ch
% Version  : V01  28AUG2015 Initial version.
% Comment  :
% Status   : under review
% ------------------------------------------------------------------------------


function dataset = dataset_load(datasetPath)

dataset = [];



%% scan for bodys

disp('');
disp(' >> scanning dataset...');
datasetFolderContent = dir(datasetPath);
NFolderRobot = length(datasetFolderContent);
for iFolderRobot = 1:NFolderRobot
    switch datasetFolderContent(iFolderRobot).name
        case 'description.yaml'
            description = readyaml([datasetPath,'/description.yaml']);
            dataset.robot = description.robot;
            dataset.recordedDate = description.recorded_date;
            dataset.flyingArea = description.flying_area;
            dataset.category = description.category;
            dataset.comment = description.comment;

        case 'gray.zip'
            if exist([datasetPath,'/gray'], 'dir')
                disp("gray folder exists, pass unzip.");
            else
                disp("gray folder does not exists, processing unzip");
                unzip([datasetPath,'/gray.zip'], [datasetPath,'/gray']);
            end

        case 'gray_raw.zip'
            if exist([datasetPath,'/gray'], 'dir')
                disp("gray_raw folder exists, pass unzip.");
            else
                disp("gray_raw folder does not exists, processing unzip");
                unzip([datasetPath,'/gray_raw.zip'], [datasetPath,'/gray_raw']);
            end

        case 'distorted_calib.txt'
            dataset.dist_calib = readmatrix([datasetPath,'/distorted_calib.txt'], 'Delimiter',  ' ');

        case 'undistorted_calib.txt'
            dataset.rect_calib = readmatrix([datasetPath,'/undistorted_calib.txt'], 'Delimiter',  ' ');

        case 'imu.txt'
            dataset.imu_raw = readmatrix([datasetPath,'/imu.txt'], 'Delimiter',  ' ');

        case 'imu_filtered.txt'
            dataset.imu_filtered = readmatrix([datasetPath,'/imu_filtered.txt'], 'Delimiter',  ' ');

        

        
        otherwise
            disp('other value')


    end 
end

%% Astrobee information
if (dataset.robot == 'bumblebee')
    dataset.Rcam_to_body = [0 0 1; 1 0 0; 0 1 0];
    dataset.pcam_to_body = [0.1177; -0.0422; -0.0826];
    dataset.Rimu_to_body = [0 -1 0; 1 0 0; 0 0 1];
    dataset.pimu_to_body = [0.0386; 0.0247; -0.01016];
else if(dataset.robot == 'queenbee') % TODO: Update the value from astrobee original github
    dataset.Rcam_to_body = [0 0 1; 1 0 0; 0 1 0];
    dataset.pcam_to_body = [0.1177; -0.0422; -0.0826];
    dataset.Rimu_to_body = [0 -1 0; 1 0 0; 0 0 1];
    dataset.pimu_to_body = [0.0386; 0.0247; -0.01016];
end

assert(~isempty(dataset_load.body));

end