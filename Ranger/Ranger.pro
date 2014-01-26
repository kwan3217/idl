;Ranger was before the era of leap seconds, and Spice uses an incorrect version of UTC prior to the 
;beginning of the leap second table. "Absurd Accuracy is our Obsession" 
;
;These are instants which have the same *name* as the UTC (actually GMT) times given in the Ranger report,
;but are on a uniform time scale which must be converted. TDT is ahead of TAI by 32.184s, so to get the
;ET of the TAI time with the same name, add 32.184s to the ET of the TDT time. TAI is ahead of GMT by deltaAT. 
;Ranger 7 was launched on mjd 38505, when the following row in tai-utc.dat was valid
;
; 1964 APR  1 =JD 2438486.5  TAI-UTC=   3.3401300 S + (MJD - 38761.) X 0.001296 S
;
;so deltaAT on that day was 3.1379540
;
T=['1964-Jul-28 17:19:56.000 TDT', $
   '1964-Jul-28 17:20:01.000 TDT', $
   '1964-Jul-28 18:00:00.000 TDT', $
   '1964-Jul-28 19:00:00.000 TDT', $
   '1964-Jul-28 20:00:00.000 TDT', $
   '1964-Jul-28 21:00:00.000 TDT', $
   '1964-Jul-28 22:00:00.000 TDT', $
   '1964-Jul-28 23:00:00.000 TDT', $
   '1964-Jul-29 00:00:00.000 TDT', $
   '1964-Jul-29 01:00:00.000 TDT', $
   '1964-Jul-29 02:00:00.000 TDT', $
   '1964-Jul-29 03:00:00.000 TDT', $
   '1964-Jul-29 04:00:00.000 TDT', $
   '1964-Jul-29 05:00:00.000 TDT', $
   '1964-Jul-29 06:00:00.000 TDT', $
   '1964-Jul-29 07:00:00.000 TDT', $
   '1964-Jul-29 08:00:00.000 TDT', $
   '1964-Jul-29 09:00:00.000 TDT', $
   '1964-Jul-29 10:00:00.000 TDT', $
   '1964-Jul-29 10:27:09.000 TDT', $
   '1964-Jul-29 10:27:58.000 TDT', $
   '1964-Jul-29 11:00:00.000 TDT', $
   '1964-Jul-29 12:00:00.000 TDT', $
   '1964-Jul-29 13:00:00.000 TDT', $
   '1964-Jul-29 14:00:00.000 TDT', $
   '1964-Jul-29 15:00:00.000 TDT', $
   '1964-Jul-29 16:00:00.000 TDT', $
   '1964-Jul-29 17:00:00.000 TDT', $
   '1964-Jul-29 18:00:00.000 TDT', $
   '1964-Jul-29 19:00:00.000 TDT', $
   '1964-Jul-29 20:00:00.000 TDT', $
   '1964-Jul-29 21:00:00.000 TDT', $
   '1964-Jul-29 22:00:00.000 TDT', $
   '1964-Jul-29 23:00:00.000 TDT', $
   '1964-Jul-30 00:00:00.000 TDT', $
   '1964-Jul-30 01:00:00.000 TDT', $
   '1964-Jul-30 02:00:00.000 TDT', $
   '1964-Jul-30 03:00:00.000 TDT', $
   '1964-Jul-30 04:00:00.000 TDT', $
   '1964-Jul-30 05:00:00.000 TDT', $
   '1964-Jul-30 06:00:00.000 TDT', $
   '1964-Jul-30 07:00:00.000 TDT', $
   '1964-Jul-30 08:00:00.000 TDT', $
   '1964-Jul-30 09:00:00.000 TDT', $
   '1964-Jul-30 10:00:00.000 TDT', $
   '1964-Jul-30 11:00:00.000 TDT', $
   '1964-Jul-30 12:00:00.000 TDT', $
   '1964-Jul-30 13:00:00.000 TDT', $
   '1964-Jul-30 14:00:00.000 TDT', $
   '1964-Jul-30 15:00:00.000 TDT', $
   '1964-Jul-30 16:00:00.000 TDT', $
   '1964-Jul-30 17:00:00.000 TDT', $
   '1964-Jul-30 18:00:00.000 TDT', $
   '1964-Jul-30 19:00:00.000 TDT', $
   '1964-Jul-30 20:00:00.000 TDT', $
   '1964-Jul-30 21:00:00.000 TDT', $
   '1964-Jul-30 22:00:00.000 TDT', $
   '1964-Jul-30 23:00:00.000 TDT', $
   '1964-Jul-31 00:00:00.000 TDT', $
   '1964-Jul-31 01:00:00.000 TDT', $
   '1964-Jul-31 02:00:00.000 TDT', $
   '1964-Jul-31 03:00:00.000 TDT', $
   '1964-Jul-31 04:00:00.000 TDT', $
   '1964-Jul-31 05:00:00.000 TDT', $
   '1964-Jul-31 06:00:00.000 TDT', $
   '1964-Jul-31 07:00:00.000 TDT', $
   '1964-Jul-31 08:00:00.000 TDT', $
   '1964-Jul-31 09:00:00.000 TDT', $
   '1964-Jul-31 10:00:00.000 TDT', $
   '1964-Jul-31 11:00:00.000 TDT', $
   '1964-Jul-31 12:00:00.000 TDT', $
   '1964-Jul-31 13:00:00.000 TDT', $
   '1964-Jul-31 13:25:48.724 TDT']
cspice_str2et,t,tdt
delAT=3.1379540d
tai=tdt+32.184d ;ET of named times above as if the tag were TAI instead of TDT
gmt=tai+delAT  ;ET of named times above as if the tag were GMT instead of TDT. As best I can figure, this is the accurate Spice ET for the times intended in the Ranger document
;Demonstrate INCORRECT handling of UTC before beginning of leap-second table
;cspice_timout,gmt,'YYYY-Mon-DD HR:MN:SC.### ::UTC',50,out
;print,out
state=[[-4.8336120E+3,-4.2062476E+3,-1.4413997E+3,7.0601070E+0,-6.8712132E+0,-4.7797460E+0], $
[-4.7982264E+3,-4.2405294E+3,-1.4652728E+3,7.0940173E+0,-6.8414752E+0,-4.7694813E+0], $
[1.4133998E+4,-7.9897407E+3,-6.5075322E+3,6.5614168E+0,7.4185279E-1,-6.6640706E-1], $
[3.3222362E+4,-3.6139479E+3,-7.2726185E+3,4.4486546E+0,1.4096569E+0,2.7990459E-2], $
[4.7538591E+4,1.5599436E+3,-6.8452390E+3,3.5982859E+0,1.4413985E+0,1.8201312E-1], $
[5.9546763E+4,6.6919147E+3,-6.0675792E+3,3.1096832E+0,1.4059146E+0,2.4208696E-1], $
[7.0115787E+4,1.1671274E+4,-5.1384184E+3,2.7807035E+0,1.3600434E+0,2.7090856E-1], $
[7.9670782E+4,1.6485287E+4,-4.1330882E+3,2.5386541E+0,1.3148349E+0,2.8605484E-1], $
[8.8457831E+4,2.1141938E+4,-3.0870670E+3,2.3501867E+0,1.2727788E+0,2.9422427E-1], $
[9.6634863E+4,2.5653528E+4,-2.0193274E+3,2.1975617E+0,1.2342340E+0,2.9846922E-1], $
[1.0431062E+5,3.0032377E+4,-9.4089186E+2,2.0703478E+0,1.1989770E+0,3.0035464E-1], $
[1.1156386E+5,3.4289674E+4,1.4145645E+2,1.9619511E+0,1.1666457E+0,3.0075305E-1], $
[1.1845391E+5,3.8435300E+4,1.2233761E+3,1.8679676E+0,1.1368759E+0,3.0018227E-1], $
[1.2502680E+5,4.2477865E+4,2.3019992E+3,1.7853263E+0,1.1093403E+0,2.9896470E-1], $
[1.3131918E+5,4.6424890E+4,3.3753994E+3,1.7118100E+0,1.0837566E+0,2.9730888E-1], $
[1.3736079E+5,5.0282966E+4,4.4422671E+3,1.6457714E+0,1.0598851E+0,2.9535378E-1], $
[1.4317620E+5,5.4057874E+4,5.5017041E+3,1.5859568E+0,1.0375227E+0,2.9319434E-1], $
[1.4878597E+5,5.7754737E+4,6.5531033E+3,1.5313925E+0,1.0164977E+0,2.9089677E-1], $
[1.5420759E+5,6.1378092E+4,7.5960550E+3,1.4813088E+0,9.9666358E-1,2.8850785E-1], $
[1.5660314E+5,6.2994607E+4,8.0651379E+3,1.4599478E+0,9.8804557E-1,2.8740624E-1], $
[1.5667451E+5,6.3041630E+4,8.0776771E+3,1.4342615E+0,9.7257015E-1,2.8116150E-1], $
[1.5940771E+5,6.4901358E+4,8.6168121E+3,1.4100239E+0,9.6267305E-1,2.7985019E-1], $
[1.6440562E+5,6.8334626E+4,9.6198208E+3,1.3671075E+0,9.4484521E-1,2.7737203E-1], $
[1.6925436E+5,7.1705259E+4,1.0613874E+4,1.3270946E+0,9.2786752E-1,2.7487869E-1], $
[1.7396378E+5,7.5016198E+4,1.1598946E+4,1.2896489E+0,9.1166118E-1,2.7238246E-1], $
[1.7854258E+5,7.8270077E+4,1.2575041E+4,1.2544879E+0,8.9615725E-1,2.6989228E-1], $
[1.8299854E+5,8.1469301E+4,1.3542187E+4,1.2213724E+0,8.8129509E-1,2.6741466E-1], $
[1.8733866E+5,8.4616106E+4,1.4500448E+4,1.1900975E+0,8.6702129E-1,2.6495428E-1], $
[1.9156924E+5,8.7712503E+4,1.5449885E+4,1.1604872E+0,8.5328837E-1,2.6251443E-1], $
[1.9569598E+5,9.0760379E+4,1.6390580E+4,1.1323896E+0,8.4005421E-1,2.6009737E-1], $
[1.9972410E+5,9.3761457E+4,1.7322619E+4,1.1056720E+0,8.2728092E-1,2.5770453E-1], $
[2.0365834E+5,9.6717321E+4,1.8246086E+4,1.0802188E+0,8.1493457E-1,2.5533671E-1], $
[2.0750307E+5,9.9629466E+4,1.9161077E+4,1.0559284E+0,8.0298459E-1,2.5299427E-1], $
[2.1126231E+5,1.0249926E+5,2.0067680E+4,1.0327113E+0,7.9140329E-1,2.5067715E-1], $
[2.1493978E+5,1.0532798E+5,2.0965984E+4,1.0104883E+0,7.8016546E-1,2.4838499E-1], $
[2.1853893E+5,1.0811684E+5,2.1856082E+4,9.8918905E-1,7.6924823E-1,2.4611723E-1], $
[2.2206297E+5,1.1086693E+5,2.2738060E+4,9.6875120E-1,7.5863059E-1,2.4387308E-1], $
[2.2551491E+5,1.1357931E+5,2.3611997E+4,9.4911923E-1,7.4829320E-1,2.4165159E-1], $
[2.2889753E+5,1.1625496E+5,2.4477978E+4,9.3024357E-1,7.3821837E-1,2.3945168E-1], $
[2.3221350E+5,1.1889479E+5,2.5336079E+4,9.1208014E-1,7.2838961E-1,2.3727216E-1], $
[2.3546532E+5,1.2149965E+5,2.6186363E+4,8.9458968E-1,7.1879160E-1,2.3511169E-1], $
[2.3865532E+5,1.2407036E+5,2.7028906E+4,8.7773722E-1,7.0941010E-1,2.3296884E-1], $
[2.4178575E+5,1.2660765E+5,2.7863761E+4,8.6149202E-1,7.0023170E-1,2.3084207E-1], $
[2.4485875E+5,1.2911225E+5,2.8690988E+4,8.4582683E-1,6.9124380E-1,2.2872973E-1], $
[2.4787637E+5,1.3158482E+5,2.9510635E+4,8.3071815E-1,6.8243442E-1,2.2663002E-1], $
[2.5084056E+5,1.3402598E+5,3.0322739E+4,8.1614577E-1,6.7379209E-1,2.2454100E-1], $
[2.5375323E+5,1.3643632E+5,3.1127343E+4,8.0209263E-1,6.6530585E-1,2.2246056E-1], $
[2.5661623E+5,1.3881637E+5,3.1924468E+4,7.8854511E-1,6.5696500E-1,2.2038640E-1], $
[2.5943135E+5,1.4116663E+5,3.2714131E+4,7.7549295E-1,6.4875905E-1,2.1831596E-1], $
[2.6220035E+5,1.4348759E+5,3.3496346E+4,7.6292921E-1,6.4067767E-1,2.1624648E-1], $
[2.6492502E+5,1.4577965E+5,3.4271105E+4,7.5085090E-1,6.3271033E-1,2.1417459E-1], $
[2.6760707E+5,1.4804323E+5,3.5038398E+4,7.3925903E-1,6.2484653E-1,2.1209685E-1], $
[2.7024827E+5,1.5027867E+5,3.5798195E+4,7.2815944E-1,6.1707520E-1,2.1000909E-1], $
[2.7285042E+5,1.5248627E+5,3.6550448E+4,7.1756338E-1,6.0938466E-1,2.0790648E-1], $
[2.7541534E+5,1.5466632E+5,3.7295100E+4,7.0748863E-1,6.0176250E-1,2.0578340E-1], $
[2.7794499E+5,1.5681905E+5,3.8032064E+4,6.9796108E-1,5.9419481E-1,2.0363315E-1], $
[2.8044137E+5,1.5894458E+5,3.8761219E+4,6.8901668E-1,5.8666610E-1,2.0144765E-1], $
[2.8290666E+5,1.6104307E+5,3.9482434E+4,6.8070435E-1,5.7915846E-1,1.9921710E-1], $
[2.8534327E+5,1.6311453E+5,4.0195518E+4,6.7309006E-1,5.7165062E-1,1.9692926E-1], $
[2.8775385E+5,1.6515892E+5,4.0900239E+4,6.6626292E-1,5.6411685E-1,1.9456880E-1], $
[2.9014145E+5,1.6717611E+5,4.1596305E+4,6.6034385E-1,5.5652490E-1,1.9211601E-1], $
[2.9250961E+5,1.6916579E+5,4.2283335E+4,6.5549936E-1,5.4883336E-1,1.8954510E-1], $
[2.9486259E+5,1.7112753E+5,4.2960848E+4,6.5196283E-1,5.4098728E-1,1.8682160E-1], $
[2.9720570E+5,1.7306063E+5,4.3628215E+4,6.5007001E-1,5.3291134E-1,1.8389813E-1], $
[2.9954566E+5,1.7496408E+5,4.4284596E+4,6.5031997E-1,5.2449829E-1,1.8070771E-1], $
[3.0189148E+5,1.7683643E+5,4.4928874E+4,6.5348665E-1,5.1558823E-1,1.7715220E-1], $
[3.0425574E+5,1.7867544E+5,4.5559479E+4,6.6083973E-1,5.0592980E-1,1.7308061E-1], $
[3.0665716E+5,1.8047774E+5,4.6174154E+4,6.7462447E-1,4.9510014E-1,1.6825085E-1], $
[3.0912585E+5,1.8223786E+5,4.6769492E+4,6.9925626E-1,4.8232034E-1,1.6224628E-1], $
[3.1171641E+5,1.8394624E+5,4.7340034E+4,7.4492919E-1,4.6596134E-1,1.5430614E-1], $
[3.1454879E+5,1.8558384E+5,4.7876595E+4,8.4271238E-1,4.4189690E-1,1.4311788E-1], $
[3.1802455E+5,1.8710406E+5,4.8369947E+4,1.1756720E+0,3.9760646E-1,1.3512609E-1], $
[3.2029137E+5,1.8771490E+5,4.8627681E+4,2.0228714E+0,4.3325334E-1,2.8010270E-1]]

selenostate=[[-3.6696648E+4,8.3380871E+3,5.7618991E+3,1.1519648E+0,-2.9167374E-1,-2.2064369E-1], $
[-3.2528503E+4,7.2804507E+3,4.9632370E+3,1.1642382E+0,-2.9598789E-1,-2.2312202E-1], $
[-2.8309192E+4,6.2061829E+3,4.1548527E+3,1.1806607E+0,-3.0096588E-1,-2.2607587E-1], $
[-2.4020153E+4,5.1122044E+3,3.3346352E+3,1.2034764E+0,-3.0703081E-1,-2.2974786E-1], $
[-1.9631390E+4,3.9933515E+3,2.4993193E+3,1.2370998E+0,-3.1496184E-1,-2.3455447E-1], $
[-1.5088464E+4,2.8403666E+3,1.6435937E+3,1.2917239E+0,-3.2638830E-1,-2.4125647E-1], $
[-1.0271567E+4,1.6345024E+3,7.5841539E+2,1.3984170E+0,-3.4543671E-1,-2.5116643E-1], $
[-4.7793061E+3,3.2947533E+2,-1.6529600E+2,1.7402440E+0,-3.8462794E-1,-2.5783979E-1], $
[-1.6351617E+3,-2.6943836E+2,-5.1570976E+2,2.5912449E+0,-3.4676184E-1,-1.1228365E-1]]

help,state
all_elorb=[]
for i=0,(size(state,/dim))[1]-1 do begin
  this_state=state[*,i]
;  print,this_state
  mu=398601.38d
  re=6378.165d
  this_elorb=elorb(this_state[0:2],this_state[3:5],re,mu)
  this_elorb.tp+=gmt[i]
  all_elorb=[all_elorb,this_elorb]
  ;help,this_elorb
;  print,string(format='(%"SMA %15.7e  ECC %15.7e")',this_elorb.a,this_elorb.e)  
;  print,string(format='(%"INC %15.7e  LAN %15.7e  APF %15.7e")',this_elorb.i*!radeg,this_elorb.an*!radeg,this_elorb.ap*!radeg)  
end
plot,gmt-gmt[0],all_elorb.rp-all_elorb[0].rp,/ynoz
seleno_elorb=[]
n=(size(selenostate,/dim))[1]
selenogmt=gmt[n_elements(gmt)-n:n_elements(gmt)-1]
cspice_etcal,selenogmt[0],cal
print,cal
geogmt=gmt ;gmt[0:n_elements(gmt)-n]
cspice_etcal,geogmt[-1],cal
print,cal
geo_elorb=all_elorb ;[0:n_elements(gmt)-n]
for i=0,n-1 do begin
  this_state=selenostate[*,i]
;  print,this_state
  mu=4900.759d
  re=1738.09d
  this_elorb=elorb(this_state[0:2],this_state[3:5],re,mu)
  this_elorb.tp+=selenogmt[i]
  seleno_elorb=[seleno_elorb,this_elorb]
  help,this_elorb
;  print,string(format='(%"SMA %15.7e  ECC %15.7e")',this_elorb.a,this_elorb.e)  
;  print,string(format='(%"INC %15.7e  LAN %15.7e  APF %15.7e")',this_elorb.i*!radeg,this_elorb.an*!radeg,this_elorb.ap*!radeg)  
end
;plot,selenogmt-gmt[0],all_elorb.e,/ynoz
dt=60d
geo_t_short=[dindgen((geogmt[-1]-geogmt[0])/dt+1)*dt+geogmt[0],geogmt[-1]]
geo_elorb_short=make_array(value=geo_elorb[0],n_elements(geo_t_short))
geo_elorb_short.p=interpol(geo_elorb.p,geogmt,geo_t_short)
geo_elorb_short.a=interpol(geo_elorb.a,geogmt,geo_t_short)
geo_elorb_short.e=interpol(geo_elorb.e,geogmt,geo_t_short)
geo_elorb_short.i=interpol(geo_elorb.i,geogmt,geo_t_short)
geo_elorb_short.an=interpol(geo_elorb.an,geogmt,geo_t_short)
geo_elorb_short.ap=interpol(geo_elorb.ap,geogmt,geo_t_short)
geo_elorb_short.ta=interpol(geo_elorb.ta,geogmt,geo_t_short)
geo_elorb_short.tp=interpol(geo_elorb.tp,geogmt,geo_t_short)
geo_elorb_short.rp=interpol(geo_elorb.rp,geogmt,geo_t_short)
geo_elorb_short.mm=interpol(geo_elorb.mm,geogmt,geo_t_short)
geo_elorb_short.N=interpol(geo_elorb.n,geogmt,geo_t_short)
geo_elorb_short.T=interpol(geo_elorb.t,geogmt,geo_t_short)

seleno_t_short=[dindgen((selenogmt[-1]-selenogmt[0])/dt+1)*dt+selenogmt[0],selenogmt[-1]]
seleno_elorb_short=make_array(value=seleno_elorb[0],n_elements(seleno_t_short))
seleno_elorb_short.p=interpol(seleno_elorb.p,selenogmt,seleno_t_short)
seleno_elorb_short.a=interpol(seleno_elorb.a,selenogmt,seleno_t_short)
seleno_elorb_short.e=interpol(seleno_elorb.e,selenogmt,seleno_t_short)
seleno_elorb_short.i=interpol(seleno_elorb.i,selenogmt,seleno_t_short)
seleno_elorb_short.an=interpol(seleno_elorb.an,selenogmt,seleno_t_short)
seleno_elorb_short.ap=interpol(seleno_elorb.ap,selenogmt,seleno_t_short)
seleno_elorb_short.ta=interpol(seleno_elorb.ta,selenogmt,seleno_t_short)
seleno_elorb_short.tp=interpol(seleno_elorb.tp,selenogmt,seleno_t_short)
seleno_elorb_short.rp=interpol(seleno_elorb.rp,selenogmt,seleno_t_short)
seleno_elorb_short.mm=interpol(seleno_elorb.mm,selenogmt,seleno_t_short)
seleno_elorb_short.N=interpol(seleno_elorb.n,selenogmt,seleno_t_short)
seleno_elorb_short.T=interpol(seleno_elorb.t,selenogmt,seleno_t_short)

print,geo_t_short[-1]
print,seleno_t_short[0]
openw,ouf,'geo.csv',/get
for i=0,n_elements(geo_elorb_short)-1 do begin
 printf,ouf,format='(%"%23.15e;%23.15e;%23.15e;%23.15e;%23.15e;%23.15e;%23.15e")',geo_t_short[i],geo_elorb_short[i].e,geo_elorb_short[i].i,geo_elorb_short[i].ap,geo_elorb_short[i].an,geo_elorb_short[i].a,geo_elorb_short[i].tp
end
free_lun,ouf
openw,ouf,'seleno.csv',/get
for i=0,n_elements(seleno_elorb_short)-1 do begin
  printf,ouf,format='(%"%23.15e;%23.15e;%23.15e;%23.15e;%23.15e;%23.15e;%23.15e")',seleno_t_short[i],seleno_elorb_short[i].e,seleno_elorb_short[i].i,seleno_elorb_short[i].ap,seleno_elorb_short[i].an,seleno_elorb_short[i].a,seleno_elorb_short[i].tp
end
free_lun,ouf

;dt=1d
;geo_t_short=dindgen((geogmt[-1]-geogmt[0])/dt)*dt+geogmt[0]
;cspice_spkezr,'-1007',geo_t_short[0:-2],'J2000','NONE','399',short_state,ltime

end