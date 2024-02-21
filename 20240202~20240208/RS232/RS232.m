clear
clc

device = bluetooth("CTL2",1,"Timeout",2);
resend_lim = 5;
cor = 0;
resend = 0;
error = [];
tic
for i = 0:255
    write(device,i,'unit8');
    fprintf("Send:%d",i)

    rx = read(device,1,'unit8');

    if rx == i
        cor = cor + 1;
        fprintf("--Receive:%d\n",rx)
    else
        for rs = 1:resend_lim  
            resend = resend + 1;
            write(device,i,'uint8');        
            rx = read(device,1,'uint8');
            pause(0.04);
            if (rx==i)
                cor = cor + 1;
                break
            end
        end
        fprintf("--Receive:%d\n",rx);
    end
    pause(0.04)

    if i~=rx
        error = [error i];
    end
end 
acc = cor/2.56;
fprintf("Correct Number:%d (in total 256)\n Accuarcy:%d%\n", cor, acc);
toc