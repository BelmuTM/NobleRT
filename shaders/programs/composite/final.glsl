/***********************************************/
/*       Copyright (C) Noble RT - 2021         */
/*   Belmu | GNU General Public License V3.0   */
/*                                             */
/* By downloading this content you have agreed */
/*     to the license and its terms of use.    */
/***********************************************/

#include "/settings.glsl"
#include "/common.glsl"
#include "/lib/util/blur.glsl"
#include "/lib/post/aberration.glsl"
#include "/lib/post/bloom.glsl"
#include "/lib/post/dof.glsl"
#include "/lib/post/exposure.glsl"

vec2 underwaterDistortionCoords(vec2 coords) {
    const float scale = 27.5;
    float speed = frameTimeCounter * WATER_DISTORTION_SPEED;
    float offsetX = coords.x * scale + speed;
    float offsetY = coords.y * scale + speed;

    vec2 distorted = coords + vec2(
        WATER_DISTORTION_AMPLITUDE * cos(offsetX + offsetY) * 0.01 * cos(offsetY),
        WATER_DISTORTION_AMPLITUDE * sin(offsetX - offsetY) * 0.01 * sin(offsetY)
    );

    return saturate(distorted) != distorted ? coords : distorted;
} 

void main() {
    vec2 tempCoords = texCoords;
    #if UNDERWATER_DISTORTION == 1
        if(isEyeInWater == 1) tempCoords = underwaterDistortionCoords(tempCoords);
    #endif

    vec4 Result = texture(colortex0, tempCoords);
    float depth = texture(depthtex0, tempCoords).r;

    // Chromatic Aberration
    #if CHROMATIC_ABERRATION == 1
        Result.rgb = computeAberration(Result.rgb);
    #endif

    // Depth of Field
    #if DOF == 1
        Result.rgb = computeDOF(Result.rgb, depth);
    #endif

    // Bloom
    #if BLOOM == 1
        // I wasn't supposed to use magic numbers like this in Noble :Sadge:
        Result.rgb += saturate(readBloom() * 0.1 * saturate(BLOOM_STRENGTH + clamp(rainStrength, 0.0, 0.5)));
    #endif

    // Vignette
    #if VIGNETTE == 1
        vec2 coords = texCoords * (1.0 - texCoords.yx);
        Result.rgb *= pow(coords.x * coords.y * VIGNETTE_STRENGTH, 0.15);
    #endif
    
    // Tonemapping
    Result.rgb *= computeExposure(texture(colortex7, texCoords).r);

    #if TONEMAPPING == 0
        Result.rgb = whitePreservingReinhard(Result.rgb); // Reinhard
    #elif TONEMAPPING == 1
        Result.rgb = uncharted2(Result.rgb); // Uncharted 2
    #elif TONEMAPPING == 2
        Result.rgb = burgess(Result.rgb); // Burgess
    #elif TONEMAPPING == 3
        Result.rgb = ACESFitted(Result.rgb); // ACES
    #endif

    Result.rgb = vibrance_saturation(Result.rgb, VIBRANCE, SATURATION);
    Result.rgb = adjustContrast(Result.rgb, CONTRAST) + BRIGHTNESS;

    Result.rgb += bayer2(gl_FragCoord.xy) * (1.0 / 255.0); // Removes color banding from the screen
    #if TONEMAPPING != 2
        Result = linearToSRGB(Result);
    #endif

    /*DRAWBUFFERS:0*/
    gl_FragData[0] = Result;
}
