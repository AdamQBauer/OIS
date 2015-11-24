function mousecat_xform(subjname,filedate,suffix,outname,files)

% appends good data runs that have already been affine transformed (runs are
% in atlas space.
% filedate: YYMMDD
% subjname: any alphanumberic convention is ok, e.g. "Mouse1"
% suffix: filename run number, e.g. "fc1"

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

name.subj = subjname; clear subjname
name.date = filedate; clear filedate
name.suffix = suffix; clear suffix
name.base= [name.date,'-',name.subj,'-',name.suffix];

    if exist([name.base,'-',outname],'file') %checks to see if the raw data were already processed
        disp([name.base,'-',outname,' Already concatenated'])
        return
    else

load([name.date, '-', name.subj,'-', 'LandmarksandMask.mat'], 'xform_WL', 'xform_isbrain', 'I','seedcenter');

datahb2=[];
ff=0;
for m=files
    ff=ff+1;
    load([name.base,num2str(m),'-datahb.mat'], 'xform_datahb')
    datahb2=cat(4,datahb2,xform_datahb);
end

[refseeds]=GetReferenceSeeds;
xform_datahb=datahb2; clear datahb2

save([name.base,'-',outname],'xform_datahb','xform_WL','refseeds', 'xform_isbrain', 'I','files', '-v7.3');

    end
    
end