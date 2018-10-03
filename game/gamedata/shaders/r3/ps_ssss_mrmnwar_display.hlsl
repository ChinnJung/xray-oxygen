#include "common.h"

uniform float4 ssss_params;
uniform	Texture2D s_sunshafts;

float4 blendSoftLight(float4 a, float4 b)
{
	float4 c = 2 * a * b + a * a * (1 - 2 * b);
	float4 d = sqrt(a) * (2 * b - 1) + 2 * a * (1 - b);
	
	return (b < 0.5) ? c : d;
}

float4 main(p_screen I) : SV_Target
{
	float4 	cScreen 	= s_image.Load(int3(I.tc0.xy * screen_res.xy, 0), 0);
	float4 	cSunShafts 	= s_sunshafts.Load(int3(I.tc0.xy * screen_res.xy, 0), 0);
	
	float 	fShaftsMask = saturate(1.00001f - cSunShafts.w) * ssss_params.y * 2;
	
	// normalize suncolor
	float4 	sunColor 	= float4(normalize(L_sun_color.xyz), 1);
	
	float4 	outColor 	= cScreen + cSunShafts.xyzz * ssss_params.x * sunColor * (1 - cScreen);
			outColor 	= blendSoftLight(outColor, sunColor * fShaftsMask * 0.5f + 0.5f);
	
	return outColor;
}

