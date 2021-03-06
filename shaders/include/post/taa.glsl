/***********************************************/
/*        Copyright (C) NobleRT - 2022         */
/*   Belmu | GNU General Public License V3.0   */
/*                                             */
/* By downloading this content you have agreed */
/*     to the license and its terms of use.    */
/***********************************************/

/*
    AABB Clipping from "Temporal Reprojection Anti-Aliasing in INSIDE"
    http://s3.amazonaws.com/arena-attachments/655504/c5c71c5507f0f8bf344252958254fb7d.pdf?1468341463
*/

vec3 clipAABB(vec3 prevColor, vec3 minColor, vec3 maxColor) {
    vec3 pClip = 0.5 * (maxColor + minColor); // Center
    vec3 eClip = 0.5 * (maxColor - minColor); // Size

    vec3 vClip  = prevColor - pClip;
    float denom = maxOf(abs(vClip / eClip));

    return denom > 1.0 ? pClip + vClip / denom : prevColor;
}

vec3 neighbourhoodClipping(sampler2D currTex, vec3 prevColor) {
    vec3 minColor = vec3(1e9), maxColor = vec3(-1e9);

    for(int x = -TAA_NEIGHBORHOOD_RADIUS; x <= TAA_NEIGHBORHOOD_RADIUS; x++) {
        for(int y = -TAA_NEIGHBORHOOD_RADIUS; y <= TAA_NEIGHBORHOOD_RADIUS; y++) {
            vec3 color = linearToYCoCg(texelFetch(currTex, ivec2(gl_FragCoord.xy) + ivec2(x, y), 0).rgb);
            minColor = min(minColor, color); 
            maxColor = max(maxColor, color); 
        }
    }
    return clipAABB(prevColor, minColor, maxColor);
}

// Thanks LVutner for the help with TAA (buffer management)
// https://github.com/LVutner
vec3 temporalAntiAliasing(Material currMat, sampler2D currTex, sampler2D prevTex) {
    vec3 currPos = vec3(texCoords, currMat.depth0);
    vec3 prevPos = currPos - getVelocity(currPos);

    vec3 currColor = linearToYCoCg(texelFetch(currTex, ivec2(gl_FragCoord.xy), 0).rgb);
    vec3 prevColor = linearToYCoCg(texture(prevTex, prevPos.xy).rgb);
         prevColor = neighbourhoodClipping(currTex, prevColor);

    float weight = float(clamp01(prevPos.xy) == prevPos.xy) * TAA_STRENGTH;

    // Offcenter rejection from Zombye#7365 (Spectrum - https://github.com/zombye/spectrum)
    vec2 pixelCenterDist = 1.0 - abs(2.0 * fract(prevPos.xy * viewSize) - 1.0);
         weight         *= sqrt(pixelCenterDist.x * pixelCenterDist.y) * TAA_OFFCENTER_REJECTION + (1.0 - TAA_OFFCENTER_REJECTION);

    return yCoCgToLinear(mix(currColor, prevColor, clamp01(weight))); 
}
