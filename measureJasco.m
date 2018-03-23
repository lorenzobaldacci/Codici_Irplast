function rec = measureJasco(wavenumRes,averageNum,filename)
    pause(0.1)
    %muovo il mouse sul pulsante misura e clicco
    robot =  java.awt.Robot;
    ScreenDimensions = get(0,'screensize');
    robot.mouseMove(ScreenDimensions(3)/4.5, ScreenDimensions(4)-20);
    pause(0.6)
    robot.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);
    robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK);
    pause(0.6)
    %aspetto che la misura finisca
    switch wavenumRes
        case 0.5
            pause(20*averageNum)
        case 0.1
            pause(30*averageNum)
        case 0.07
            pause(40*averageNum)
        otherwise
            pause(0.5)
    end
    %muovo il mouse su salva con nome e clicco
    robot.mouseMove(ScreenDimensions(3)/4.5, ScreenDimensions(4)-20);
    pause(0.6)
    robot.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);
    robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK);
    pause(0.6)
    robot.mouseMove(ScreenDimensions(3)/4.5, ScreenDimensions(4)-20);
    pause(0.6)
    robot.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);
    robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK);
    pause(0.6)
    %digito il nome del file da salvare
    for i0=1:length(filename)
        if uint8(filename(i0))==46
            robot.keyPress(java.awt.event.KeyEvent.VK_PERIOD);
            robot.keyRelease(java.awt.event.KeyEvent.VK_PERIOD);
        else
            eval(['robot.keyPress(java.awt.event.KeyEvent.VK_',filename(i0),')']);
            eval(['robot.keyRelease(java.awt.event.KeyEvent.VK_',filename(i0),')']);
        end
    end
    %salvo
    robot.keyPress(java.awt.event.KeyEvent.VK_ENTER);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ENTER);
    rec = 1;
end