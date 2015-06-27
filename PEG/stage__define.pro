function stage::init,a0=a0,v_e=v_e
  self.a0=a0
  self.v_e=v_e
  self.tau=v_e/a0
  return,1
end

function stage::a,t
  return,self.a0/(1d -t/self.tau)
end

function stage::b,n,t
  if(n eq 0) then return,-self.v_e*alog(1-t/self.tau)
  return,self.b(n-1,t)*self.tau-self.v_e*t^double(n)/double(n)
end
  
function stage::c,n,t
  if(n eq 0) then return,self.b(0,t)*t-self.b(1,t)
  return,self.c(n-1,t)*self.tau-self.v_e*t^double(n+1)/double(n*(n+1))
end  

function stage::rocket_t,deltav
  return,self.tau*(1-exp(-deltav/self.v_e))
end

function stage::rocket_deltav,t
  return,-self.v_e*alog(1d -t/self.tau)
end

pro stage::burn,deltat
  self.a0=self.a(deltat)
  self.tau=self.tau-deltat
end

pro stage::getproperty,tau=tau,a0=a0,v_e=v_e
  tau=self.tau
  a0=self.a0
  v_e=self.v_e
end  
  
pro stage__define
  structure={stage,inherits IDL_Object,a0:0d,v_e:0d,tau:0d}
end