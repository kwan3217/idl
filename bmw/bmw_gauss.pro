function FindTTrialCore,A,SS,X,Y
  return,(x^3)*ss+A*sqrt(Y);
end

function FindTTrial,A,r1,r2,Z
  SS=bmw_SS(Z);
  CC=bmw_CC(Z);
  if CC eq 0 then return,!values.d_infinity
  Y=r1+r2-A*(1-Z*SS)/sqrt(CC);
  X=sqrt(Y/CC);
  return,FindTTrialCore(A,SS,X,Y);
end

function FindZLo,A,r1,r2
  eps=1e-9
  ;Find the Z which results in a Y of exactly zero, by bisection
  Zhi=0;
  Y=1d;
  Zlo=-1d;

  while (Y gt 0) do begin
    Zlo*=2d;
    Y=r1+r2-A*(1-Zlo*bmw_SS(Zlo))/sqrt(bmw_CC(Zlo));
  end
  
  repeat begin
    Z=(Zlo+Zhi)/2d
    Y=r1+r2-A*(1-Z*bmw_SS(Z))/sqrt(bmw_CC(Z));
    if Y*Zlo gt 0 then begin
      Zlo=Z
    end else begin
      Zhi=Z
    end
  end until abs(Zlo-Zhi) lt eps

  return,Z+1e-5;
end

function FindZLo2,A,r1,r2,T
  ;Find the Z which results in a TTrial of less than T
  Z=-1;
  TTrial=FindTTrial(A,r1,r2,Z)-T;
  while (TTrial gt 0) do begin
    Z*=2;
    TTrial=FindTTrial(A,r1,r2,Z)-T;
  end
  return,Z;
end

pro bmw_gauss,rv1_,rv2_,t_,type_,l_DU=l_DU,mu=mu,eps=eps,vv1=vv1,vv2=vv2
  if n_elements(eps) eq 0 then eps=1d-9
  tau=2*!dpi
  if keyword_set(l_DU) then begin
    rv1=su_to_cu(rv1_,l_DU,mu,1,0)
    rv2=su_to_cu(rv2_,l_DU,mu,1,0)
    t=su_to_cu(t_,l_DU,mu,0,1)
  end else begin
    rv1=rv1_
    rv2=rv2_
    t=t_
  end

  if(n_elements(type_) eq 0 || type_ eq 0) then type=-1 else type=type_  
  if(type lt 0) then begin
    pole=crossp_grid(rv1,rv2)
    if(pole[2]) gt 0 then begin
      ;prograde is short way
      type=(-type-1)*2+1
    end else begin
      ;prograde is long way way
      type=(-type-1)*2+2
    end
  end

  if(t lt 0) then message,"Time to intercept is negative. Time travel is not allowed in this universe!"
  r1=vlength(rv1)
  r2=vlength(rv2);
  r1dr2=dotp(rv1,rv2);
  DeltaNu=vangle(rv1,rv2);
  Revs=(Type-1)/2d;
  ;short-way and long-way are reversed for odd-numbers of complete revs
  if ((Revs mod 2) eq 1) xor ((Type mod 2) eq 1) then begin
    ;Short way
    DM=1d
  end else begin
    ;Long way
    DM=-1d
    DeltaNu=tau-DeltaNu
  end
  if Revs gt 0 then begin
    minA=r1/2d
    minT=Revs*sqrt(tau*minA^3)
    if (minT gt T) then message,"Can't do it! Minimum trip time for "+string(Revs)+" revs is "+string(minT)+"TU, more than requested "+string(T)+"TU"
  end
  A=DM*sqrt(r1*r2*(1+cos(DeltaNu)))
  if(Revs lt 1) then begin
    ;less than one rev
    if Type eq 1 then begin
      Zlo=FindZLo(A,r1,r2);
    end else begin
      Zlo=FindZLo2(A,r1,r2,T);
    end
    Zhi=tau^2;
  end else begin
    ;more than one rev
    ;Use Zeno's method
    Zlo=((2*Revs+1)*tau/2d)^2; Z that gives the lowest TIME, not necessarily lowest Z
    ;Zbound is the value of Z which gives an infinite T
    if (Type mod 2) eq 1 then begin
      Zbound=(Revs*tau)^2;
    end else begin
      Zbound=((Revs+1)*tau)^2;
    end
    Zhi=(Zbound+Zlo)/2d; //Z that gives the highest TIME, not necessarily highest Z
    repeat begin
      Thi=FindTTrial(A,r1,r2,Zhi);
      Zhi=(Zbound+Zhi)/2; //Split the difference between current Zhi and bound
    end until Thi ge T
  end

  ;Solve it by bisection
  tnlo=FindTTrial(A,r1,r2,Zlo)
  tnhi=FindTTrial(A,r1,r2,Zhi)
  repeat begin
    Z=(Zlo+Zhi)/2d
    tn=FindTTrial(A,r1,r2,Z)
    if (t-tn)*tnlo gt 0 then begin
      Zlo=Z
    end else begin
      Zhi=Z
    end
  end until abs(Zlo-Zhi) le eps
    
  S=(bmw_SS(Z));
  C=(bmw_CC(Z));
  Y=r1+r2-A*(1d -Z*S)/sqrt(C);
  f=1d -Y/r1;
  g=A*sqrt(Y);
  gdot=1d -Y/r2;
  vv1=(rv2-rv1*f)/g;
  vv2=(rv2*gdot-rv1)/g;
  if keyword_set(L_DU) then begin
    vv1=su_to_cu(vv1,l_DU,mu,1,-1,/inv)
    vv2=su_to_cu(vv2,l_DU,mu,1,-1,/inv)
  end
end