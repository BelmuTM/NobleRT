/***********************************************/
/*       Copyright (C) Noble RT - 2021         */
/*   Belmu | GNU General Public License V3.0   */
/*                                             */
/* By downloading this content you have agreed */
/*     to the license and its terms of use.    */
/***********************************************/

vec3 computeDOF(vec3 color, float depth) {

    vec4 outOfFocusColor = saturate(bokeh(texCoords, colortex0, pixelSize, 5, 30.0));
    return mix(color, outOfFocusColor.rgb, saturate(getCoC(linearizeDepth(depth), linearizeDepth(centerDepthSmooth))));
}