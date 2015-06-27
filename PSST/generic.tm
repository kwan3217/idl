Observe the order of the kernels, specifically the text kernels. The
last kernel wins, so we can put down a background kernel to take care
of background things, then layer more specific data on top of it. For 
instance, Gravity.tpc is in the background, it has the gravity fields
(mu and J2, out to J4 in some instances) of a whole bunch of objects,
but it is of uncertain pedigree. We layer de-421-masses.tpc on top of
it to get the specific mu used for DE421 for each body. We layer the 
Mars gravity model on top of that to get a specific high-quality J2 
for Mars.

\begindata

PATH_VALUES = ( '../icy/data/generic_kernels/lsk',
                '../icy/data/generic_kernels/spk',
                '../icy/data/generic_kernels/pck',
                '../icy/data/phx/fk')

PATH_SYMBOLS = ('LSK',
                'SPK',
                'PCK',
                'FK')

KERNELS_TO_LOAD = ('$LSK/naif0009.tls',
                   '$SPK/planets/de421.bsp',
                   '$PCK/Gravity.tpc',
                   '$PCK/de-421-masses.tpc',
                   '$PCK/pck00010.tpc',
                   '$PCK/mars_jgmro.tpc',
                   '$FK/phx.tf'
                   )

