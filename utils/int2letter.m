function [ outChars ] = int2letter( inNum )
%INT2LETTER Convert a number ot letter in alphabet
%   Examples:
%   int2letter(1)  = 'a'
%   int2letter(26)  = 'z'
%   int2letter(26*2)  = 'az'
%   int2letter(26*2+1)  = 'ba'
%   int2letter(26*26+1)  = 'za'
%   int2letter(26*27)  = 'zz'
%   int2letter(26*27+1)  = 'aaa'
%   int2letter(26^3+26^2+26) = 'zzz'
%
    letters = 'abcdefghijklmnopqrstuvwxyz';
    n = numel(letters);
    q = floor(inNum/n);
    r = rem(inNum,n);
    % adjust for 0 base
    if r == 0
        r = n;
        q = q-1;
    end
    if q > 0
        outChars = [int2letter(q) letters(r)] ;
    else
        outChars = letters(r);
    end
end

