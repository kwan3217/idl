pro msl_aero,aero_alpha,aero_mach,aero_cl,aero_cd,aero_ld
    aero_alpha=[0,  2,  4,  6,  11, 16]*!dtor;
    aero_mach=[ $
     0.4, 0.6, 0.8, 0.9, 1.0, $
     1.2, 1.5, 2.0, 3.0, 4.0, $
     5.0, 6.3, 8.8, 9.8,10.8, $
    11.8,12.8,13.9,15.0,16.0, $
    17.0,18.1,19.2,20.3,21.3, $
    22.4,23.4,24.5,25.5,26.4, $
    27.2,28.0,30.0];

    aero_cl=[ $
    [0, -0.0362,  -0.0729,  -0.1051,  -0.1894,  -0.2672], $
    [0, -0.0382,  -0.0764,  -0.1096,  -0.1955,  -0.2758], $
    [0, -0.0407,  -0.0785,  -0.1172,  -0.2071,  -0.2904], $
    [0, -0.0428,  -0.0850,  -0.1237,  -0.2182,  -0.3066], $
    [0, -0.0519,  -0.0976,  -0.1394,  -0.2389,  -0.3439], $
    [0, -0.0594,  -0.1057,  -0.1480,  -0.2596,  -0.3732], $
    [0, -0.0579,  -0.1062,  -0.1495,  -0.2712,  -0.3955], $
    [0, -0.0503,  -0.1017,  -0.1495,  -0.2692,  -0.3793], $
    [0, -0.0498,  -0.1017,  -0.1500,  -0.2687,  -0.3773], $
    [0, -0.0503,  -0.1027,  -0.1510,  -0.2702,  -0.3732], $
    [0, -0.0503,  -0.1017,  -0.1515,  -0.2712,  -0.3707], $
    [0, -0.0508,  -0.1042,  -0.1535,  -0.2717,  -0.3682], $
    [0, -0.0529,  -0.1062,  -0.1571,  -0.2717,  -0.3621], $
    [0, -0.0524,  -0.1077,  -0.1581,  -0.2717,  -0.3626], $
    [0, -0.0534,  -0.1077,  -0.1586,  -0.2722,  -0.3631], $
    [0, -0.0529,  -0.1093,  -0.1596,  -0.2727,  -0.3621], $
    [0, -0.0539,  -0.1103,  -0.1601,  -0.2722,  -0.3636], $
    [0, -0.0544,  -0.1093,  -0.1611,  -0.2722,  -0.3636], $
    [0, -0.0554,  -0.1113,  -0.1606,  -0.2727,  -0.3641], $
    [0, -0.0569,  -0.1123,  -0.1611,  -0.2717,  -0.3641], $
    [0, -0.0564,  -0.1123,  -0.1611,  -0.2722,  -0.3641], $
    [0, -0.0579,  -0.1118,  -0.1596,  -0.2712,  -0.3636], $
    [0, -0.0569,  -0.1113,  -0.1596,  -0.2717,  -0.3631], $
    [0, -0.0564,  -0.1118,  -0.1586,  -0.2712,  -0.3631], $
    [0, -0.0554,  -0.1093,  -0.1591,  -0.2702,  -0.3626], $
    [0, -0.0544,  -0.1088,  -0.1581,  -0.2717,  -0.3631], $
    [0, -0.0544,  -0.1082,  -0.1586,  -0.2707,  -0.3631], $
    [0, -0.0544,  -0.1082,  -0.1571,  -0.2702,  -0.3621], $
    [0, -0.0534,  -0.1077,  -0.1571,  -0.2702,  -0.3621], $
    [0, -0.0534,  -0.1082,  -0.1566,  -0.2692,  -0.3606], $
    [0, -0.0534,  -0.1082,  -0.1566,  -0.2687,  -0.3616], $
    [0, -0.0544,  -0.1072,  -0.1561,  -0.2692,  -0.3601], $
    [0, -0.0529,  -0.1047,  -0.1530,  -0.2646,  -0.3601]  $
    ];

    aero_cd=[ $
    [1.0441,  1.0464, 1.0453, 1.0398, 1.0311, 1.0112], $
    [1.0943,  1.0949, 1.0903, 1.0926, 1.0779, 1.0562], $ 
    [1.1618,  1.1633, 1.1569, 1.1601, 1.1532, 1.1237], $
    [1.2146,  1.2152, 1.2261, 1.2241, 1.2129, 1.1834], $
    [1.3020,  1.3069, 1.3248, 1.3236, 1.3124, 1.3046], $
    [1.4136,  1.4263, 1.4260, 1.4248, 1.4214, 1.4041], $
    [1.5356,  1.5457, 1.5454, 1.5408, 1.5313, 1.5114], $
    [1.5702,  1.5691, 1.5662, 1.5546, 1.5183, 1.4621], $
    [1.5763,  1.5751, 1.5714, 1.5616, 1.5174, 1.4499], $
    [1.5849,  1.5838, 1.5774, 1.5685, 1.5218, 1.4439], $
    [1.5962,  1.5950, 1.5869, 1.5771, 1.5261, 1.4404], $
    [1.6074,  1.6045, 1.5982, 1.5875, 1.5330, 1.4352], $
    [1.6273,  1.6253, 1.6155, 1.6040, 1.5373, 1.4335], $
    [1.6351,  1.6331, 1.6259, 1.6143, 1.5391, 1.4378], $
    [1.6420,  1.6409, 1.6321, 1.6187, 1.5443, 1.4387], $
    [1.6481,  1.6469, 1.6397, 1.6247, 1.5477, 1.4413], $
    [1.6541,  1.6521, 1.6458, 1.6299, 1.5486, 1.4430], $
    [1.6619,  1.6582, 1.6518, 1.6342, 1.5520, 1.4456], $
    [1.6732,  1.6712, 1.6587, 1.6420, 1.5555, 1.4499], $
    [1.6853,  1.6824, 1.6717, 1.6472, 1.5590, 1.4534], $
    [1.6965,  1.6937, 1.6769, 1.6515, 1.5624, 1.4551], $
    [1.7078,  1.7015, 1.6830, 1.6533, 1.5633, 1.4586], $
    [1.7182,  1.7092, 1.6856, 1.6567, 1.5667, 1.4603], $
    [1.7260,  1.7136, 1.6890, 1.6602, 1.5693, 1.4595], $
    [1.7277,  1.7153, 1.6908, 1.6611, 1.5702, 1.4612], $
    [1.7277,  1.7170, 1.6916, 1.6645, 1.5719, 1.4612], $
    [1.7268,  1.7179, 1.6942, 1.6645, 1.5702, 1.4629], $
    [1.7260,  1.7170, 1.6951, 1.6654, 1.5719, 1.4612], $
    [1.7268,  1.7179, 1.6960, 1.6663, 1.5711, 1.4612], $
    [1.7260,  1.7170, 1.6934, 1.6645, 1.5711, 1.4612], $
    [1.7260,  1.7170, 1.6925, 1.6645, 1.5711, 1.4603], $
    [1.7242,  1.7136, 1.6925, 1.6628, 1.5711, 1.4585], $
    [1.7026,  1.6954, 1.7011, 1.6619, 1.5702, 1.4500] $
    ];
    aero_ld=aero_cl/aero_cd 
end