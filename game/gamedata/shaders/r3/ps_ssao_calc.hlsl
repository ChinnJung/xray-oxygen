#include "common.h"

#ifndef ISAMPLE
#define ISAMPLE 0
#endif

uniform	Texture2D	s_half_depth;

#include "ps_ssao.hlsl"
#ifdef	USE_HBAO
#include "ps_ssao_hbao.hlsl"
#endif	//	USE_HBAO

struct	_input
{
	float4	tc0		: TEXCOORD0;	// tc.xy, tc.w = tonemap scale
	float2	tcJ		: TEXCOORD1;	// jitter coords
	float4	pos2d	: SV_Position;
};

float4 main ( _input I 
#ifdef	MSAA_OPTIMIZATION	
	,uint	iSample	: SV_SAMPLEINDEX
#endif	//	MSAA_OPTIMIZATION	
) : SV_Target0
{
	gbuffer_data gbd0 = gbuffer_load_data( GLD_P(I.tc0.xy + 0.5f * screen_res.zw, I.pos2d * 2, ISAMPLE) );
	gbuffer_data gbd1 = gbuffer_load_data( GLD_P(I.tc0.xy - 0.5f * screen_res.zw, I.pos2d * 2, ISAMPLE) );
	gbuffer_data gbd2 = gbuffer_load_data( GLD_P(I.tc0.xy + 0.5f * float2(+screen_res.z, -screen_res.w), I.pos2d * 2, ISAMPLE) );
	gbuffer_data gbd3 = gbuffer_load_data( GLD_P(I.tc0.xy + 0.5f * float2(-screen_res.z, +screen_res.w), I.pos2d * 2, ISAMPLE) );

	//float3 avgN = (gbd0.N +  gbd1.N +  gbd2.N + gbd3.N) * 0.25f;
	
	// check if they are on the plane
	//float dx = gbd2.P.z - gbd1.P.z;
	//float dy = gbd3.P.z - gbd1.P.z;

	//float tx = (gbd0.P.z - gbd3.P.z) - dx;
	//float ty = (gbd0.P.z - gbd2.P.z) - dy;

	//float diff = 0.0f;
	//if (abs(tx * ty) > 0.005f) diff = 1.0f;

	gbuffer_data gbd = gbd0;
	if (gbd1.P.z < gbd.P.z) gbd = gbd1;	
	if (gbd2.P.z < gbd.P.z) gbd = gbd2;	
	if (gbd3.P.z < gbd.P.z) gbd = gbd3;

	float4	P = float4( gbd0.P, gbd0.mtl );	// position.(mtl or sun)
	float4	N = float4( gbd0.N, gbd0.hemi );		// normal.hemi

#ifndef USE_HBAO
	float occ = calc_ssao( CS_P(P, N, I.tc0, I.tcJ, I.pos2d, ISAMPLE) );
#else
	//	Is not supported now
	float occ = 1.0f;//hbao_calc(P, N, I.tc0, I.pos2d);
#endif

	return  float4(occ, occ, occ, occ);
}
