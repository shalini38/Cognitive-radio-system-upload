
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This program simulates the symbal error rate of quadrate amplitude modulation 
%(QAM) of M symbals by averaging the number of errors in N tests. The theoretical
%value is also caculated using derived expressions and a visual comparison 
%is made on a graph of symbal error rate (SER) against signal to noise ratio 
%(SNR) in dB to check the validity of the simulation.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%declare parameters for SNR, N, and M
SNR_db = [0:30];
N=1e5;
M=4;

power_inter_db=-30:10:10;
power_inter=sqrt(10.^(power_inter_db./10));
L=length(power_inter);

sig_energy = 10.^(SNR_db/10);%convert SNR db to SNR
l = length(sig_energy);

original_signal = transpose(qammod(0:M-1,M));%generate array of original signal
mag = sqrt((original_signal'*original_signal)./(2*M*(sig_energy)));%magnitude using to scale the noise power


SER_I_SIM=zeros(L,l);
SER_SIM = zeros(1,l);%declare a matrix for SER


for SIM_index=1:L
    P_inter=power_inter(1,SIM_index);
    
tran_signal = zeros(N,1);

for index = 1:l
    %transmitted signals are selected randomly from the original signals
    tran_signal_index = randi(M,N,1);
    tran_signal=qammod(tran_signal_index-1,M);
     
    %generate white gaussian noise n scale its power & fading channel h
    %with unity power
    noise= (randn(N,1)+1j.*randn(N,1)).*mag(1,index);
    h=(randn(N,1)+1j.*randn(N,1))./sqrt(2);
    interference=P_inter*(randn(N,1)+1j*randn(N,1))./sqrt(2);
    
    %received signal = transmitted signal * fading channel + noise
    receive_sig = tran_signal.*h+noise+interference;
   
    %detected signals are generated by mapping each of transmitted signals 
    %to the nearest signal after channel
    Eucld_dist=zeros(N,M);
    
    for k = 1: M
        Eucld_dist(:,k) = abs(receive_sig - h.*original_signal(k,1));
    end
    [~, indices ] = min(Eucld_dist,[],2) ;
    number_of_errors = (indices~=tran_signal_index);
    SER_SIM(index) = mean(number_of_errors);
    
end
     SER_I_SIM(SIM_index,:)=SER_SIM;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot a graph of SER against SNR for both simulation result and
%theoreetical expressions 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
semilogy(SNR_db,SER_I_SIM);
legend('Interference power -30dB','Interference power -20dB','Interference power -10dB','Interference power 0dB','Interference power 10dB','location','southwest');
str=sprintf('(QAM) SER against SNR when M=%d',M);
title(str);
xlabel('SNR/db');
ylabel('SER');
grid on;
