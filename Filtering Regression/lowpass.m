function [fdata]=lowpass(data,omegaHz,frate)

% lowpass() low-pass filters data, preserving phase information. Syntax:
% 
% [fdata]=lowpass(data,omegaHz,framerate)
% 
% data can be an array of any size, as long as time is the last dimension.
% If data is a struct, then every field is filtered. omegaHz is the cut-off
% frequency of the filter (in Hz). framerate is the framerate of your data
% (in Hz). 
%
% (c) 2009 Washington University in St. Louis
% All Right Reserved
%
% Licensed under the Apache License, Version 2.0 (the "License");
% You may not use this file except in compliance with the License.
% A copy of the License is available is with the distribution and can also
% be found at:
%
% http://www.apache.org/licenses/LICENSE-2.0
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE, OR THAT THE USE OF THE SOFTWARD WILL NOT INFRINGE ANY PATENT
% COPYRIGHT, TRADEMARK, OR OTHER PROPRIETARY RIGHTS ARE DISCLAIMED. IN NO
% EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
% OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
% STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
% ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

if isstruct(data)
    N=fieldnames(data);
    
    for f=1:size(N,1)
        fname=N{f};
        fdata.(fname)=lowpass(data.(fname),omegaHz,frate);
    end
else
    % Reshape to Stuff x Time
    [data2 Sin Sout]=datacondition(data,1);

    % Initialize
    fdata=zeros(Sout);
    
    % Convert Hz Frequency to a Fraction of the Nyquist Frequency
    omegaNy=omegaHz*(2/frate);
    
    % Make Filter
    [b,a] = butter(5,omegaNy);
    
    % Filter every time trace (w/ phase preservation)
    for n=1:Sout(1)
        fdata(n,:)=filtfilt(b,a,squeeze(data2(n,:)));
    end
    
    fdata=reshape(fdata,Sin);
end

end