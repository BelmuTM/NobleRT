/***********************************************/
/*        Copyright (C) NobleRT - 2022         */
/*   Belmu | GNU General Public License V3.0   */
/*                                             */
/* By downloading this content you have agreed */
/*     to the license and its terms of use.    */
/***********************************************/

/*
	SOURCES / CREDITS:
	Capt Tatsu: https://www.curseforge.com/minecraft/customization/bsl-shaders
	SixSeven:   https://www.curseforge.com/minecraft/customization/voyager-shader-2-0
*/

#if BLOOM == 1
	const vec2 bloomOffsets[] = vec2[](
		vec2(0.0      , 0.0   ),
		vec2(0.0      , 0.26  ),
		vec2(0.135    , 0.26  ),
		vec2(0.2075   , 0.26  ),
		vec2(0.135    , 0.3325),
		vec2(0.160625 , 0.3325),
		vec2(0.1784375, 0.3325)
	);

	vec3 bloomTile(int LOD) {
		float scale   = exp2(LOD); 
		vec2 coords   = (texCoords - bloomOffsets[LOD - 2]) * scale;
		vec2 texScale = pixelSize * scale;

		vec3 bloom = vec3(0.0);

		if(any(greaterThanEqual(abs(coords - 0.5), texScale + 0.5))) return bloom;

        for(int x = -BLOOM_STEPS; x <= BLOOM_STEPS; x++) {
            for(int y = -BLOOM_STEPS; y <= BLOOM_STEPS; y++) {
                float weight = gaussianDistrib2D(vec2(x, y), BLOOM_SIGMA);
                bloom  		+= textureLod(colortex4, coords + vec2(x, y) * texScale, LOD).rgb * weight;
            }
        }
		return bloom;
	}

	vec3 getBloomTile(int LOD) {
		return textureBicubic(colortex3, texCoords / exp2(LOD) + bloomOffsets[LOD - 2]).rgb;
	}

	void writeBloom(inout vec3 bloom) {
		bloom  = bloomTile(2);
		bloom += bloomTile(3);
		bloom += bloomTile(4);
		bloom += bloomTile(5);
		bloom += bloomTile(6);
		bloom += bloomTile(7);
		bloom += bloomTile(8);
	}

	vec3 readBloom() {
    	vec3 bloom  = getBloomTile(2);
	     	 bloom += getBloomTile(3);
	     	 bloom += getBloomTile(4);
	     	 bloom += getBloomTile(5);
	     	 bloom += getBloomTile(6);
	     	 bloom += getBloomTile(7);
	     	 bloom += getBloomTile(8);
    	return bloom * rcp(7.0);
	}
#endif
