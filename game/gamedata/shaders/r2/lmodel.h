#ifndef	LMODEL_H
#define LMODEL_H

#include "common.h"

//////////////////////////////////////////////////////////////////////////////////////////
// Lighting formulas			// 
float4 	plight_infinity(float m, float3 pnt, float3 normal, float3 light_direction)
{
  float3 N		= normal;					// normal 
  float3 V 		= -normalize(pnt);		// vector2eye
  float3 L 		= -light_direction;			// vector2light
  float3 H		= normalize	(L+V);			// half-angle-vector 
  
  return tex3D(s_material, float3(dot(L,N), dot(H,N), m));
}

float4 plight_local(float m, float3 pnt, float3 normal, float3 light_position, float light_range_rsq, out float rsqr)  
{
	float3 N		= normal;										// normal 
	float3 L2P 	= pnt - light_position;                         	// light2point 
	float3 V 		= -normalize	(pnt);							// vector2eye
	float3 L 		= -normalize	((float3)L2P);					// vector2light
	float3 H		= normalize	(L+V);								// half-angle-vector
		   rsqr		= dot		(L2P,L2P);							// distance 2 light (squared)
	float  att 		= saturate	(1 - rsqr*light_range_rsq);			// q-linear attenuate
	
	float4 light	= tex3D(s_material, float3( dot(L,N), dot(H,N), m ) ); 
	
	return float4(att * light.xxx,0) + att*float4(light.www * (Ldynamic_color.xyz * Ldynamic_color.xyz),light.w);
}

float4 blendp(float4 value, float4 tcp)    		
{
	#ifndef FP16_BLEND  
		value 	+= (float4)tex2Dproj 	(s_accumulator, tcp); 	// emulate blend
	#endif
	return 	value	;
}

float4 blend(float4 value, float2 tc)			
{
	#ifndef FP16_BLEND  
		value 	+= (float4)tex2D 	(s_accumulator, tc); 	// emulate blend
	#endif
	return 	value	;
}

#endif
