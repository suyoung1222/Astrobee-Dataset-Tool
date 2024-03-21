% Define translation vector
translation = [0.1157+0.002, -0.0422, -0.0826];

% Define quaternion
quat = [0.500, 0.500, 0.500, 0.500];
rot = quat2rotm(quat);

% Create a rigid3d object
rigidBody = rigid3d(rot, translation);

% Convert rigid3d object to struct
rigid3DStruct = struct(rigidBody);