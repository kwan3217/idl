function planet::init,lspice_id,lframe_i
  tau=2d*!dpi ; tau manifesto
  self.spice_id=lspice_id
  cspice_gdpool,string(self.spice_id,format='(%"BODY%d_GM")'),0,1,v,found
  if ~found then begin
    ;Check for the x version if given an x99 body id
    bod_pri=self.spice_id/100
    if bod_pri gt 0 then begin
      cspice_gdpool,string(bod_pri,format='(%"BODY%d_GM")'),0,1,v,found
    end
  end
  ;Internally we work in meters and seconds
  self.mu=v[0]*1d9
  cspice_gdpool,string(self.spice_id,format='(%"BODY%d_RADII")'),0,1,v,found
  self.r=v[0]*1d3
  cspice_gdpool,string(self.spice_id,format='(%"BODY%d_J2")'),0,1,v,found
  self.J2=v[0]
  cspice_gdpool,string(self.spice_id,format='(%"BODY%d_PM")'),1,1,v,found
  self.w=v[0]/86400d*tau/360d
  self.frame_i=lframe_i
  return,1
end

function planet::twobody,rv
  return,-self.mu*rv/(vlength(rv)^3)
end

function planet::j2grav,rv
  r=vlength(rv)
  resolve_grid,rv,x=x,y=y,z=z
  coef=-3d*self.J2*self.mu*self.r^2d/(2d*r^5d)
  ax=coef*x*(1d -5d*z^2d/r^2d)
  ay=coef*y*(1d -5d*z^2d/r^2d)
  az=coef*z*(3d -5d*z^2d/r^2d)
  return,compose_grid(ax,ay,az)
end

function planet::wind,rv
  return,crossp_grid([0,0,self.w],rv)
end

function planet::tipm,et
  cspice_tipbod,self.frame_i,self.spice_id,et,tipm
  return,tipm
end

function planet::llr,rv,et
  return,xyz2llr(self->i2rel(rv,et))
end

function planet::i2rel,rv,et
  return,self->tipm(et) ## rv
end

function planet::rel2i,rv,et
  return,transpose(self->tipm(et)) ## rv
end

;Difference between the planetocentric equipotential ("sea level", "geoid",
;"aeroid" etc) surface radius and the spherical planet radius in meters
function planet::equipotential,rv
  message,'Pure virtual function'
end

;Difference between the planetocentric topography radius and the equipotential
;surface in meters, on earth the MSL height of a point on the ground.
function planet::topography,rv
  message,'Pure virtual function'
end

;Atmospheric density in kg/m^3 (water=1000)
function planet::rho,rv
  message,'Pure virtual function'
end

pro planet__define
  struct={planet,spice_id:0L,r:0d,mu:0d,J2:0d,w:0d,frame_i:''}
end