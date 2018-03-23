function rec = measureTDS(tcpObj,retlen,fmt,setmode,filename)
    fopen(tcpObj);
    command = ['SETMODE ',setmode];
    fwrite(tcpObj,command);
    fclose(tcpObj);
    fopen(tcpObj);
    command = 'START';
    fwrite(tcpObj,command);
    pause(4)
    switch setmode
        case 0
            pause(1)
        case 1
            pause(2)
        case 2
            pause(5)
        case 3
            pause (10)
        case 4
            pause(15)
        case 5
            pause(25)
        case 6
            pause(55)
        case 7
            pause(105)
        case 8
            pause(205)
        case 9
            pause(505)
        case 10
            pause(1005)
    end
    fclose(tcpObj);
    fopen(tcpObj);
    command = 'STOP';
    fwrite(tcpObj,command);
    fclose(tcpObj);
    fopen(tcpObj);
    command = 'GETTIMEAXIS'; 
    fwrite(tcpObj, command);
    t = fread(tcpObj, retlen, fmt);
    fclose(tcpObj);
    fopen(tcpObj);
    command = 'GETLATESTPULSE'; 
    fwrite(tcpObj, command);
    E = fread(tcpObj, retlen, fmt);
    fclose(tcpObj);
    %delete(tcpObj);
    rec = [t E];
    save([filename,'.txt'],'rec','-ascii')
end