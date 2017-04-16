classdef Scrambler
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Default
        LFSR
    end
    
    methods
        function obj = Scrambler()
            Default  = [0, 1, 1, 0, 0];%, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1];%randi([0 1],1,59);
            obj.LFSR = Default;
        end
        
        function o = scramble(obj, signalToScramble)
            for i = 1:signalToScramble.getSize()
                disp("LFSR"); disp(obj.LFSR);
                %x = xor(obj.LFSR(1,1), xor(obj.LFSR(1,40), obj.LFSR(1,59)));
                x = xor(obj.LFSR(1,1), xor(obj.LFSR(1,3), obj.LFSR(1,5)));
                x = xor(signalToScramble.getBit(i), x);
                signalToScramble.setBitV(i, x);
                obj.LFSR = circshift(obj.LFSR, 1, 1);
                obj.LFSR(1,1) = signalToScramble.getBit(i);
                o = signalToScramble;
            end
            end
                
    end
    
end
