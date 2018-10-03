#include "common.h"
#include "ogse_config.h"
#include "ogse_functions.h"

float4 main(p_screen I) : SV_Target
{
	float4 depth;
	depth.x = s_position.Load(int3((I.tc0.xy + float2(0, 1.0f) * screen_res.zw) * screen_res.xy, 0), 0).z;
	depth.y = s_position.Load(int3((I.tc0.xy + float2(1, 0.65f) * screen_res.zw) * screen_res.xy, 0), 0).z;
	depth.z = s_position.Load(int3((I.tc0.xy + float2(-1, 0.65f) * screen_res.zw) * screen_res.xy, 0), 0).z;

	float4 sceneDepth;
	sceneDepth.x = normalize_depth(depth.x)*is_not_sky(depth.x);
	sceneDepth.y = normalize_depth(depth.y)*is_not_sky(depth.y);
	sceneDepth.z = normalize_depth(depth.z)*is_not_sky(depth.z);

	sceneDepth.w = (sceneDepth.x + sceneDepth.y + sceneDepth.z) * 0.333f;
	
	depth.w = saturate(1 - sceneDepth.w*1000);
	
	float4 Color = float4(depth.w, depth.w, depth.w, sceneDepth.w);	
	return Color;
}
