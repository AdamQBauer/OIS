function [I, RasterSeeds]=CalcManySeeds(WL)

% Creates a seed (RasterSeeds) for each pixel location in a white light image of the brain. 
% User is asked to click on the anterior and posterior landmarks of WL in order to register 
% the calculated seeds in mouse space.

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

image(WL);
axis image;

nVx=size(WL,1);
nVy=nVx;

disp('Click Anterior Midline Suture Landmark');
[x, y]=ginput(1);
x=round(x);
y=round(y);

OF(1)=x;
OF(2)=y;

disp('Click Lambda');
[x, y]=ginput(1);
x=round(x);
y=round(y);

T(1)=x;
T(2)=y;

Xdim=linspace(-4,-0.25,61);
Ydim=linspace(-5,4,145);

[X, Y]=meshgrid(Xdim, Ydim);
X1=reshape(X,[],1);
Y1=reshape(Y,[],1);
Seeds.L(:,:)=[X1 Y1];

Xdim=linspace(4,0.25,61);
Ydim=linspace(-5,4,145);

[X, Y]=meshgrid(Xdim, Ydim);
X1=reshape(X,[],1);
Y1=reshape(Y,[],1);
Seeds.R(:,:)=[X1 Y1];

L.bregma=[0 0];
L.tent=[0 -3.9];
L.of=[0 3.525];

adist=norm(L.of-L.tent);
idist=norm(OF-T);

aa=atan2(L.of(1)-L.tent(1),L.of(2)-L.tent(2));
ia=atan2(OF(1)-T(1),OF(2)-T(2));
da=ia-aa;

pixmm=idist/adist;
R=[cos(da) -sin(da) ; sin(da) cos(da)];

I.bregma=pixmm*(L.bregma*R);
I.tent=pixmm*(L.tent*R);
I.OF=pixmm*(L.of*R);

t=T-I.tent;

I.bregma=I.bregma+t;
I.tent=I.tent+t;
I.OF=I.OF+t;

Numseeds=size(Seeds.L,1);

for f=1:Numseeds
    I.Seeds.R(f,:)=round(pixmm*Seeds.R(f,:)*R+I.bregma);
    I.Seeds.L(f,:)=round(pixmm*Seeds.L(f,:)*R+I.bregma);
end

RasterSeeds=zeros(2*Numseeds,2);

for f=1:Numseeds
    RasterSeeds(2*f-1,1)=I.Seeds.R(f,1);
    RasterSeeds(2*f-1,2)=I.Seeds.R(f,2);
    RasterSeeds(2*f,1)=I.Seeds.L(f,1);
    RasterSeeds(2*f,2)=I.Seeds.L(f,2);
end

end





