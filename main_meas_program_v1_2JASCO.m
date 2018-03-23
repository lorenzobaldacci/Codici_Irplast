%il programma controlla i due motori del carosello tramite arduino e
%acquisice le misure sullo ftir JASCO controllando mouse e tastiera

%aggiungo i percorsi per i programmi e i file
addpath('C:\Users\Administrator\Documents\MATLAB')
addpath('C:\Users\Administrator\Documents\LorenzoTDS')
%% creo l'oggetto arduino e mi collego alla scheda tramite seriale
if exist('a','var') && isa(a,'arduino') && isvalid(a),
    % nothing to do    
else
    a=arduino('COM13');
end
%% servo motors
%specifico qual'è il pin di controllo del servo, di solito ci sono tre cavi
%pin nel servo, uno di Vcc (rosso), uno di Ground (marrone) e l'altro di controllo
servo_pin = 7;
%inserisco gli angoli a cui far arrivare il servo. il servo si muove sempre
%entro un range fissato, per esempio 180 gradi, e mantiene costanti
%l'origine e gli assi del sistema di riferimento
servo_angle = [35,35:10:135,138];
%attivo il motore
a.servoAttach(servo_pin);
pause(1)
a.servoStatus(servo_pin);

%specifico quali sono i pin dello stepper. ogni stepper ha il suo numero di
%pin, accendendoli e spegnendoli nell'ordine corretto il motore compie dei
%passi. bisogna sempre che l'ordine acceso/spento sia quello corretto
%altrimenti il motore si rompe
st_pin = [8 9 10 11];

%specifico l'angolo che deve compiere lo stepper. a differenza del servo lo
%stepper ruota senza ricordarsi gli assi del sistema di riferimento, quindi
%la rotaizone è sempre relativa al punto in cui si trova lo stepper prima
%dell'istruzione
st_angle = 45*104/20; %angolo con rapporto moltiplicativo in base alle ruote dentate
dt = 0.0001; %delay di acceso/spento in secondi, non ridurre al di sotto di 0.0001
diR = 1; %direzione di rotazione. 1 = la ruota grande si muove in senso antiorario rispetto all'asse uscente dallo stepper. 0=senso orario
pause(1)

%sets sample names
sampName = ['PR.2'; 'P.05'; 'P.07'; 'P.08'; 'PR.3'; 'P.09'; 'P.10'; 'P.06']; %puo' arrivare fino a nove
%%
% start session
for i0 = 1:9 %numero di samples, puo' arrivare fino a nove
    
    %inizializzo il servo, facendogli fare tutto lo span di angoli che
    %chiedo in avanti e indietro
    
    %in avanti
    for i2 = servo_angle(1):servo_angle(end) %il ciclo for serve per far andare piano il servo
        servo_rot = i2;  
        servoWrite(a,servo_pin,servo_rot); %da un impulso al servo
        pause(0.015)
        val=servoRead(a,servo_pin);
    end
    pause(1)
    
    %indietro
    for i2 = 0:servo_angle(end)-servo_angle(1)
        servo_rot = i2;
        servoWrite(a,servo_pin,servo_angle(end)-servo_rot); 
        pause(0.015)
        val=servoRead(a,servo_pin);
    end
    pause(1)
    %fine inizializzazione servo
    
    %cominciano le misure
    if i0==1 || i0==5 %se devo misurare i reference allora non faccio ruotare il campione e uso questa subroutine
        pause(1)
        servoDetach(a,servo_pin); %stacco il servo mentre misura così si raffredda
        pause(1)
        filename=[sampName(i0,:)];
        measureJasco(1,1,filename);
        pause(1)
        a.servoAttach(servo_pin); %riattacco il servo, pronto per la misura successiva
        pause(1)
    else %se invece sono su una finestra con il campione montato uso questa subroutine
        for i1 = 1:length(servo_angle)-1
            %ruoto piano il campione, come per l'inizializzazione, ma
            %stavolta dall'angolo attuale al successivo. anche per la prima
            %misura, ed è per questo che il primo valore nell'array servo
            %angle e' ripetuto due volte
            for i2 = servo_angle(i1):servo_angle(i1+1)
                servo_rot = i2;
                servoWrite(a,servo_pin,servo_rot); 
                pause(0.015)
                val=servoRead(a,servo_pin);
            end
            pause(1)
            servoDetach(a,servo_pin); %stacco il servo durante la misura
            pause(1)
            pol_angle=round(1.74757*(servo_angle(i1+1)-servo_angle(1))); %calcolo l'angolo di inclinazione del campione rispetto alla posizione iniziale
            filename=[sampName(i0,:),'.A',num2str(pol_angle)]; %definisco il nome del file in cui salvo la misura
            measureJasco(1,1,filename); %misuro e poi sposto il mouse su salva con nome, digito il nome e premo invio. potrebbe essere necessario aggiungere la procedura di esportazione in csv
            pause(1)
            a.servoAttach(servo_pin); %riattacco il servo
            pause(1)
        end
        pause(1)
        %quando ho misurato l'ultimo angolo del campione riporto il
        %campione (e il servo) alla posizione iniziale. e' importante per
        %evitare che il servo faccia scatti alla successiva
        %inizializzazione
        for i3 = 0:servo_angle(end)-servo_angle(1)
        servoWrite(a,servo_pin,servo_angle(end)-i3); 
        pause(0.015)
        val=servoRead(a,servo_pin);
        end
    end

pause(1)
% detach servo from pin #7
servoDetach(a,servo_pin); %stacco il servo prima di attivare lo stepper
pause(1)
% return the status of servo on pin #7
servoStatus(a,servo_pin);

%distinguo diversi casi di rotazione in modo da caricare sette campioni ma
%acquisire due reference
switch i0
    case 4
        diR=0;
        move_stepper28BYJ48(a,st_pin(1),st_pin(2),st_pin(3),st_pin(4),diR,3*st_angle,dt); %lo stepper riporta la finestra senza campione in posizione di misura
        pause(1)
        diR=1;
    case 5
        move_stepper28BYJ48(a,st_pin(1),st_pin(2),st_pin(3),st_pin(4),diR,4*st_angle,dt); %lo stepper porta la finestra con il quarto campione in posizione di misura
        pause(1)
    otherwise
        move_stepper28BYJ48(a,st_pin(1),st_pin(2),st_pin(3),st_pin(4),diR,st_angle,dt); %lo stepper porta smeplicemente la finestra successiva in posizione di misura
        pause(1)
end
disp('ok');
a.servoAttach(servo_pin); %riattacco il servo, pronto per l'inizializzazione successiva
pause(1)
end
servoDetach(a,servo_pin); %stacco il servo
%% close session
delete(a) %cancello l'oggetto arduino