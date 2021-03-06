
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This program simulates the symbal error rate of new modulation scheme 
%of M symbals by averaging the number of errors in N tests. The theoretical
%values for other schmes are also caculated using derived expressions and a
%visual comparison is made on a graph of symbal error rate (SER) against 
%signal to noise ratio (SNR) in dB to check the validity of the simulation.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%declare parameters for SNR, N, M, and number of loops L
SNR_db = [0:30];
N=1e5;
M=16;
L=5;

power_inter_db=-30:10:10;
power_inter=sqrt(10.^(power_inter_db./10));
L=length(power_inter);

%convert SNR db to SNR
sig_energy = 10.^(SNR_db/10);
l = length(sig_energy);

SER_SIM = zeros(1,l);%declare a matrix for SER
SER_I_SIM=zeros(L,l);

%generate array of original signal
sig_ind=transpose(0:L:L*(M-1));
mag2=transpose(0:(M-1));% magnitude used to make spiral constellations 
original_signal=exp(-1j*2*pi/M*(sig_ind)).*mag2;

mag1 = sqrt((original_signal'*original_signal)./(2*M*(sig_energy)));%magnitude using to scale the noise power

%plot the new modulation scheme
x1=transpose(real(original_signal));
y1=transpose(imag(original_signal));

figure(1);
scatter(x1,y1,'r');
title('Constellation of signals');
xlabel('real');
ylabel('imaginary');
grid on;

for SIM_index=1:L
    P_inter=power_inter(1,SIM_index);
tran_signal = zeros(N,1);

for index=1:l
    %transmitted signals are selected randomly from the original signals
    tran_signal_index = randi(M,N,1);
    
    for row=1:N
        tran_signal(row,1)=original_signal(tran_signal_index(row,1),1);
    end
  
    %generate white gaussian noise and scale its power & fading channel
    noise =(randn(N,1)+1j*randn(N,1))*mag1(index);
    h = (randn(N,1)+1j*randn(N,1))./sqrt(2);
    interference=P_inter*(randn(N,1)+1j*randn(N,1))./sqrt(2);
    
    %received signal = transmitted signal * fading channel + noise
    receive_sig =h.*tran_signal+noise+interference;
   
    %detected signals are generated by mapping each of transmitted signals to the
    %nearest signal after channel
    Eucld_dist=zeros(N,M);
    
    for k = 1: M
        Eucld_dist(:,k) = abs(receive_sig - h.*original_signal(k,1) );
    end
    [~, indices ]       = min(Eucld_dist,[],2) ;
    number_of_errors    = (indices~=tran_signal_index);
    SER_SIM(index)          = mean(number_of_errors);
end
    SER_I_SIM(SIM_index,:)=SER_SIM;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot a graph of SER against SNR for both simulation result and all
%theoreetical expressions 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2);
semilogy(SNR_db,SER_I_SIM);
legend('Interference power -30dB','Interference power -20dB','Interference power -10dB','Interference power 0dB','Interference power 10dB','location','southwest');
str=sprintf('SER against SNR when M=%d',M);
title(str);
xlabel('SNR/db');
ylabel('SER');
grid on

