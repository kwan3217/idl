;Scattering phase function of air molecules. Mie or Rayleigh phase function would go here
function air_phase,theta
  return,1d
end

;
function dust_phase,theta
  return,1d
end

function dust_mix,alt

end

;given wavelength in m, return wavenumber in /cm
function wavenumber,lambda
  return,0.01d/lambda
end

function sigma_air,lambda
  ;Rayleigh cross section
  vbar=wavenumber(lambda)
  return,0d
end

function sigma_dust,lambda

end

function albedo_dust,lambda

end

function dust_n,alt

end

function air_n,alt

end

pro martian_sky,alt,vsun,vcam
  defsysv,'!red',607d-9,1
  defsysv,'!green',555d-9,1
  defsysv,'!blue',467d-9,1
  defsysv,'!tau',2*!dpi,1
  
end