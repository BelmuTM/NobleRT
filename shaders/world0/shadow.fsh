#version 400 compatibility
#include "/include/extensions.glsl"

/***********************************************/
/*       Copyright (C) Noble RT - 2021         */
/*   Belmu | GNU General Public License V3.0   */
/*                                             */
/* By downloading this content you have agreed */
/*     to the license and its terms of use.    */
/***********************************************/

varying vec2 texCoords;
varying vec4 color;
uniform sampler2D colortex0;

void main() {
    gl_FragData[0] = texture(colortex0, texCoords) * color;
}
