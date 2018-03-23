addpath('C:\Users\Administrator\Documents\MATLAB')
addpath('C:\Users\Administrator\Documents\LorenzoTDS')
%% create arduino object and connect to board
if exist('a','var') && isa(a,'arduino') && isvalid(a),
    % nothing to do    
else
    a=arduino('COM13');
end
%% servo motors
servo_pin = 7;
servo_angle = [35,35:10:135,138];
a.servoAttach(servo_pin);
st_pin = [8 9 10 11];
st_angle = 45*104/20;
dt = 0.0001;
diR = 1;
pause(2)
% return the status of servo on pin #9
a.servoStatus(servo_pin); 

%creates tcp/ip object to communicate with TDS
ip = '127.0.0.1';
retlen = 3000;
fmt = 'float64';
setmode = 8;
tcpObj = tcpip(ip, 8001, 'InputBufferSize', retlen*8, 'ByteOrder', 'littleEndian');
set(tcpObj, 'ByteOrder', 'littleEndian');

%sets sample names
sampName = ['PR.2'; 'P.05'; 'P.07'; 'P.08'; 'PR.3'; 'P.09'; 'P.10'; 'P.06']; %puo' arrivare fino a nove
%%
% start session
for i0 = 1:8 %numero di samples, puo' arrivare fino a nove
    
    %servo initialize
    for i2 = servo_angle(1):servo_angle(end)
        servo_rot = i2;  
        servoWrite(a,servo_pin,servo_rot); 
        pause(0.015)
        % reads angle from servo on pin #7
        val=servoRead(a,servo_pin);
    end
    pause(1)
    
    for i2 = 0:servo_angle(end)-servo_angle(1)
        servo_rot = i2;
        servoWrite(a,servo_pin,servo_angle(end)-servo_rot); 
        pause(0.015)
        % reads angle from servo on pin #7
        val=servoRead(a,servo_pin);
    end
    pause(1)
    %end servo initialize
    if i0==1 || i0==5
        pause(1)
        servoDetach(a,servo_pin);
        pause(1)
        filename=[sampName(i0,:)];
        measureTDS(tcpObj,retlen,fmt,setmode,filename);
        pause(1)
        a.servoAttach(servo_pin);
        pause(1)
    else
        for i1 = 1:length(servo_angle)-1
            for i2 = servo_angle(i1):servo_angle(i1+1)
                servo_rot = i2;
                servoWrite(a,servo_pin,servo_rot); 
                pause(0.015)
                % reads angle from servo on pin #7
                val=servoRead(a,servo_pin);
            end
            pause(1)
            servoDetach(a,servo_pin);
            pause(1)
            pol_angle=round(1.74757*(servo_angle(i1+1)-25));
            filename=[sampName(i0,:),'.A',num2str(pol_angle)];
            measureTDS(tcpObj,retlen,fmt,setmode,filename);
            pause(1)
            a.servoAttach(servo_pin);
            pause(1)
        end
        pause(1)
        for i3 = 0:servo_angle(end)-servo_angle(1)
        servoWrite(a,servo_pin,servo_angle(end)-i3); 
        pause(0.015)
        % reads angle from servo on pin #7
        val=servoRead(a,servo_pin);
        end
    end

pause(1)
% detach servo from pin #7
servoDetach(a,servo_pin);
pause(1)
% return the status of servo on pin #7
servoStatus(a,servo_pin);
switch i0
    case 4
        diR=0;
        move_stepper28BYJ48(a,st_pin(1),st_pin(2),st_pin(3),st_pin(4),diR,3*st_angle,dt);
        pause(1)
        diR=1;
    case 5
        move_stepper28BYJ48(a,st_pin(1),st_pin(2),st_pin(3),st_pin(4),diR,4*st_angle,dt);
        pause(1)
    otherwise
        move_stepper28BYJ48(a,st_pin(1),st_pin(2),st_pin(3),st_pin(4),diR,st_angle,dt);
        pause(1)
end
disp('ok');
a.servoAttach(servo_pin);
pause(1)
end
servoDetach(a,servo_pin);
%% close session
delete(a)
delete(tcpObj)
% Copyright 2013 The MathWorks, Inc.