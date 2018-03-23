function y = move_stepper28BYJ48(a,p1,p2,p3,p4,diR,angle,dt)
pinMode(a,p1,'output');
pinMode(a,p2,'output');
pinMode(a,p3,'output');
pinMode(a,p4,'output');
step_num_per_rev = 64;
gear_ratio = 64;
step_num_tot = step_num_per_rev*gear_ratio;
num_phas = 8;
step_num_360=step_num_per_rev*num_phas;
step_num=round(step_num_360*angle/360);
lo = 0;
hi = 1;
tic
if diR == 1
    rotation = 'forward';
    digitalWrite(a,p1,lo);
    digitalWrite(a,p2,lo);
    digitalWrite(a,p3,lo);
    digitalWrite(a,p4,lo);
    for i1 = 1:step_num
        %step1
        digitalWrite(a,p1,lo);
        digitalWrite(a,p4,hi);
        pause(dt)
        %step2
        digitalWrite(a,p3,hi);
        pause(dt)
        %step3
        digitalWrite(a,p4,lo);
        pause(dt)
        %step4
        digitalWrite(a,p2,hi);
        pause(dt)
        %step5
        digitalWrite(a,p3,lo);
        pause(dt)
        %step6
        digitalWrite(a,p1,hi);
        pause(dt)
        %step7
        digitalWrite(a,p2,lo);
        pause(dt)
        %step8
        digitalWrite(a,p4,hi);
        pause(dt)
    end
else
    rotation = 'backward';
    digitalWrite(a,p1,lo);
    digitalWrite(a,p2,lo);
    digitalWrite(a,p3,lo);
    digitalWrite(a,p4,lo);
    for i1 = 1:step_num
        %step8
        digitalWrite(a,p1,hi);
        digitalWrite(a,p4,hi);
        pause(dt)
        %step7
        digitalWrite(a,p4,lo);
        pause(dt)
        %step6
        digitalWrite(a,p2,hi);
        pause(dt)
        %step5
        digitalWrite(a,p1,lo);
        pause(dt)
        %step4
        digitalWrite(a,p3,hi);
        pause(dt)
        %step3
        digitalWrite(a,p2,lo);
        pause(dt)
        %step2
        digitalWrite(a,p4,hi);
        pause(dt)
        %step1
        digitalWrite(a,p3,lo);
        pause(dt)
    end
    time = toc;
    
    y = ['moved ',rotation,' by ',num2str(angle),' degrees in ',num2str(time),' s'];
end
