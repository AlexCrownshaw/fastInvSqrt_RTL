#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>


float fixed_to_float(int fixed_point_value, int fract_width) 
{
    /* Convert fixed-point to IEEE754 single precision [float = fix / (2^fract_width)] */
    return (float)fixed_point_value / (1 << fract_width);
}


float inv_sqrt(float x) 
{
    /* Comput inverse square root */
    return 1.0f / sqrtf(x);
}


// 
uint32_t ieee754_to_int(float f) 
{
    /* Cast as IEEE754 single precision and return 32-bit integer value */
    union {
        float f;
        uint32_t i;
    } u;
    u.f = f;

    return u.i;
}

// The DPI-C compatible function
uint32_t compute_inv_sqrt(int fixed_point_value, int fract_width) {
    float float_value = fixed_to_float(fixed_point_value, fract_width);
    
    float inv_sqrt_result = inv_sqrt(float_value);
    
    return ieee754_to_int(inv_sqrt_result);
}
