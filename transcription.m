clear all;
close all;

[x, Fs] = audioread("piano.wav");
L = length(x);

%I will divide the signal in 70 parts and make an fft on each part
%it works well with few seconds signals.
size = round(L/70);
window = hamming(size);

freq = [];
time = [];

%a make an FFT on each part and store the most powerful frequency of each
%one of them as well as the corresponding time.
for i = 1 : size : L-size
    FFTX = fft(x(i:i+size));
    [Y, I] = max(abs(FFTX));
    f = 0:Fs/size:Fs/2;
    note = f(I);
    freq = [freq note];
    time = [time i*1/Fs];
end

%This for loop replace previous note by current note if it is one harmonic
%of it
for i = 2:length(freq)
    if(freq(i-1)>2*(freq(i)-3) && freq(i-1)<2*(freq(i)+3))
        
        freq(i-1) = freq(i);
        continue
    end
    if(freq(i-1)>0.5*(freq(i)-3) && freq(i-1)<0.5*(freq(i)+3))
        
        freq(i-1) = freq(i);
    end
end

%This for loop replace next note by current note if it is one harmonic
%of it
for i = 1:length(freq)-1
    if(freq(i+1)>2*(freq(i)-3) && freq(i+1)<2*(freq(i)+3))
        freq(i+1) = freq(i);
        continue
    end
    if(freq(i+1)>0.5*(freq(i)-3) && freq(i+1)<0.5*(freq(i)+3))
        freq(i) = freq(i+1);
    end
end


figure(1);


plot(time, freq, 'o');
xlabel('time (s)')
ylabel('Frequency (Hz)')

%we build an array containing each of the 88 piano notes
first_freq = 27.5;
r = 1.05946309435929;
piano_freq = zeros(1,88);
piano_freq(1) = first_freq;
for i = 2:88
    piano_freq(i) = r*piano_freq(i-1);
end

%using the piano notes we build centers of each interval
quantization_tab = zeros(1, 88);
quantization_tab(1) = first_freq;
for i = 2:88
   quantization_tab(i) = (piano_freq(i-1)+piano_freq(i))/2; 
end

%we associate each analysed frequency to a single piano key
for i = 1:length(freq)
    for j = 1:87
        if(freq(i)<quantization_tab(j+1) && freq(i)>quantization_tab(j))
            freq(i) = j+1;
        end
    end
end

figure(2);
plot(time, freq, 'o');
xlabel('time (s)')
ylabel('piano key number')
