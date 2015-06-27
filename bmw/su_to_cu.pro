;Convert standard units to canonical units
;input
;  x - measurement to convert, may be scalar or any size or shape of vector
;  a - length of canonical distance unit in standard units. Standard length unit is implied by this. 
;  mu - gravitational constant in standard distance and time units. Standard length unit same as 
;       above, standard time unit implied by this.
;  LL - power of length dimension used in x
;  TT - power of time dimension used in x
;  /inverse - convert x from canonical units back to standard units
;return
;  a scalar or array the same size as x, in canonical units (or standard if /inv was set)
;Example
; An object orbiting Earth has a position of <1131340,-2282343,6672423> m 
; and a speed of <-5643.05,4303.33,2428.79> m/s. Convert this to canonical units
; Earth radius used as distance unit length: 6378137m
; Earth gravitational constant: 398600.4415d9 m,s
; print,su_to_cu([1131340d,-2282343d,6672423d],6378137d,398600.4415d9,1,0)
;      0.17737781     -0.35783850       1.0461398
; print,su_to_cu([-5643.05d,4303.33d,2428.79d],6378137d,398600.4415d9,1,-1)
;     -0.71382529      0.54435559      0.30723310
; We are going to solve the Kepler problem over a time of 40min=2400s. How many canonical time units?
; print,su_to_cu(2400d,6378137d,398600.4415d9,0,1)
;       2.9746739
; The answer is r_t=<-0.6616125, 0.6840739,-0.6206809> and
;               v_t=< 0.4667380,-0.2424455,-0.7732126>. What is this in SI units?
; print,su_to_cu([-0.6616125d, 0.6840739d,-0.6206809d],6378137d,398600.4415d9,1,0,/inv)
;      -4219855.2       4363117.1      -3958787.8
; print,su_to_cu([ 0.4667380d,-0.2424455d,-0.7732126d],6378137d,398600.4415d9,1,-1,/inv)
;       3689.7346      -1916.6203      -6112.5284
function su_to_cu,x,a,mu,LL,TT,inverse=inverse
;To convert:  Standard Unit to       Canonical Unit          Multiply by
;Distance     m                      DU                      1/a
;Time         s                      TU                      sqrt(mu/a^3)
;For derived units, raise the base unit for each dimension to the power of the dimension needed, then multiply. For example
;Speed        m/s                    DU/TU (LL=1,TT=-1)      1/a*sqrt(a^3/mu)
;For inverse conversion, divide instead of multiply
  DU=(1d/a[0])^LL
  TU=sqrt(mu[0]/a[0]^3)^TT
  DUTU=DU*TU
  if keyword_set(inverse) then DUTU=1d/DUTU
  return,x*DUTU
end