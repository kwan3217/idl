Linear Kalman Filter IDL code
Chris Jeppesen - 7 Jun 2011
jeppesen@lasp.colorado.edu

kv_example.pro - Check this one first. This is an example which drives kalman_filter and kalman_smooth
                 and makes a bunch of plots to help visualize what the filter is doing.
                 
kf_inv.pro - helper function. A version of inv() which doesn't crash when passed a scalar,
             returns 1/x if passed a scalar x, otherwise matches invert().
kf_t.pro - helper function. A version of transpose() which doesn't crash when passed a scalar,
             returns x if passed a scalar x, otherwise matches transpose().
kalman_filter.pro - vanilla implementation of linear Kalman filter. No clever tricks to avoid
                    numerical problems, just a straight implementation of the five lines.
kalman_smooth.pro - vanilla implementation of the Fixed Lag Kalman Smoother.
kalman_velocity.pro - Implements the cart on rails process model and filters an entire time series at once
kf_blank_state.pro - Function used internally to set up the filter state. You shouldn't have to worry about it.
                                 
              