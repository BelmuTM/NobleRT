/***********************************************/
/*       Copyright (C) Noble RT - 2021         */
/*   Belmu | GNU General Public License V3.0   */
/*                                             */
/* By downloading this content you have agreed */
/*     to the license and its terms of use.    */
/***********************************************/

vec3 computeAberration(vec3 color) {
     vec2 dist = texCoords - vec2(0.5);
     vec2 offset = (1.0 - (dist * dist)) * ABERRATION_STRENGTH * pixelSize;

     return vec3(
          texture(colortex0, texCoords - offset).r,
          texture(colortex0, texCoords).g,
          texture(colortex0, texCoords + offset).b
     );
}