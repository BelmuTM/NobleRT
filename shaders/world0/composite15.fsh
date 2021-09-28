/***********************************************/
/*       Copyright (C) Noble RT - 2021         */
/*   Belmu | GNU General Public License V3.0   */
/*                                             */
/* By downloading this content you have agreed */
/*     to the license and its terms of use.    */
/***********************************************/

#version 150
#extension GL_ARB_shader_texture_lod : enable

varying vec2 texCoords;

#include "/settings.glsl"
#include "/common.glsl"
#include "/lib/util/blur.glsl"
#include "/lib/post/taa.glsl"
#include "/lib/post/exposure.glsl"

/*
const int colortex3Format = RGB16F;
const bool colortex3Clear = false;
const bool colortex7Clear = false;
*/

void main() {
    vec4 Result = texture(colortex0, texCoords);

    #if TAA == 1
        Result.rgb = saturate(computeTAA(colortex0, colortex3));
    #endif

    /*DRAWBUFFERS:037*/
    gl_FragData[0] = Result;
    gl_FragData[1] = Result;
    gl_FragData[2] = vec4(computeAverageLuminance(colortex7));
}
