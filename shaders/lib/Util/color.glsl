/*
  Author: Belmu (https://github.com/BelmuTM/)
  */

// I AM NOT THE AUTHOR OF THE TONE MAPPING ALGORITHMS BELOW
// Most sources are: Github, ShaderToy, or Discord.

float blendOverlay(float base, float blend) {
    return base < 0.5f ? (2.0f * base * blend) : (1.0f - 2.0f * (1.0f - base ) * (1.0f - blend));
}

vec3 blendOverlay(vec3 base, vec3 blend) {
    return vec3(blendOverlay(base.r, blend.r), blendOverlay(base.g, blend.g), blendOverlay(base.b, blend.b));
}

vec3 blendOverlay(vec3 base, vec3 blend, float opacity) {
	return blendOverlay(base, blend) * opacity + base * (1.0f - opacity);
}

vec4 lumaBasedReinhard(vec4 color) {
    float lum = luma(color.rgb);
	float white = 2.0f;
	float toneMappedLuma = lum * (1.0f + lum / (white * white)) / (1.0f + lum);
	color *= toneMappedLuma / lum;
	return color;
}

vec4 uncharted2(vec4 color) {
	float A = 0.15f;
	float B = 0.50f;
	float C = 0.10f;
	float D = 0.20f;
	float E = 0.02f;
	float F = 0.30f;
	float W = 11.2f;

	color = ((color * (A * color + C * B) + D * E) / (color * (A * color + B) + D * F)) - E / F;
	float white = ((W * (A * W + C * B) + D * E) / (W * (A * W + B) + D * F)) - E / F;
	color /= white;

	return color;
}

vec3 filmic(vec3 x) {
    vec3 X = max(vec3(0.0f), x - 0.004f);
    vec3 result = (X * (6.2f * X + 0.5f)) / (X * (6.2f * X + 1.7f) + 0.06f);
    return pow(result, vec3(2.2f));
}

// Uchimura 2017, "HDR theory and practice"
// Math: https://www.desmos.com/calculator/gslcdxvipg
// Source: https://www.slideshare.net/nikuque/hdr-theory-and-practicce-jp

vec3 uchimura(vec3 x, float P, float a, float m, float l, float c, float b) {
    float l0 = ((P - m) * l) / a;
    float L0 = m - m / a;
    float L1 = m + (1.0f - m) / a;
    float S0 = m + l0;
    float S1 = m + a * l0;
    float C2 = (a * P) / (P - S1);
    float CP = -C2 / P;

    vec3 w0 = vec3(1.0f - smoothstep(0.0f, m, x));
    vec3 w2 = vec3(step(m + l0, x));
    vec3 w1 = vec3(1.0f - w0 - w2);

    vec3 T = vec3(m * pow(x / m, vec3(c)) + b);
    vec3 S = vec3(P - (P - S1) * exp(CP * (x - S0)));
    vec3 L = vec3(m + a * (x - m));

    return T * w0 + L * w1 + S * w2;
}

vec3 uchimura(vec3 x) {
    const float P = 1.0f;  // max display brightness
    const float a = 1.0f;  // contrast
    const float m = 0.22f; // linear section start
    const float l = 0.4f;  // linear section length
    const float c = 1.33f; // black
    const float b = 0.0f;  // pedestal

    return uchimura(x, P, a, m, l, c, b);
}

vec3 lottes(vec3 x) {
    const vec3 a = vec3(1.6f);
    const vec3 d = vec3(0.977f);
    const vec3 hdrMax = vec3(8.0f);
    const vec3 midIn = vec3(0.18f);
    const vec3 midOut = vec3(0.267f);

    const vec3 b =
      (-pow(midIn, a) + pow(hdrMax, a) * midOut) /
      ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);
    const vec3 c =
      (pow(hdrMax, a * d) * pow(midIn, a) - pow(hdrMax, a) * pow(midIn, a * d) * midOut) /
      ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);

    return pow(x, a) / (pow(x, a * d) * b + c);
}

// Originally made by Richard Burgess-Dawson
// Modified by JustTech#2594
vec3 burgess(vec3 color) {
    vec3 maxColor = color * min(vec3(1.0f), 1.0f - exp(-1.0f / 0.004f * color)) * 0.8f;
    vec3 retColor = (maxColor * (6.2f * maxColor + 0.5f)) / (maxColor * (6.2f * maxColor + 1.7f) + 0.06f);
    return retColor;
}

vec3 vibranceSaturation(vec3 color, float vibrance, float saturation) {
    float lum = luma(color);
    float mn = min(min(color.r, color.g), color.b);
    float mx = max(max(color.r, color.g), color.b);
    float sat = (1.0f - saturate(mx - mn)) * saturate(1.0f - mx) * lum * 5.0f;
    vec3 light = vec3((mn + mx) / 2.0f);

    color = mix(color, mix(light, color, vibrance), sat);
    color = mix(color, light, (1.0f - light) * (1.0f - vibrance) / 2.0f * abs(vibrance));
    color = mix(vec3(lum), color, saturation);
    return color;
}

vec3 brightnessContrast(vec3 color, float contrast, float brightness) {
    return (color - 0.5f) * contrast + 0.5f + brightness;
}
