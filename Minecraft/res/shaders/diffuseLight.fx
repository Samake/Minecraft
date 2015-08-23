//************************************
// Authors: Sam@ke
//************************************
#include "mta-helper.fx"

sampler MainSampler = sampler_state
{
    Texture = (gTexture0);
};


struct VertexShaderInput
{
	float3 Position : POSITION0;
	float4 Color : COLOR0;
	float2 TexCoord : TEXCOORD0;
};


struct VertexShaderOutput
{
	float4 Position : POSITION0;
	float4 Color : COLOR0;
	float2 TexCoord : TEXCOORD0;
};


VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
    VertexShaderOutput output;
	

    output.Position = MTACalcScreenPosition(input.Position);
	output.Color = MTACalcGTABuildingDiffuse(input.Color);
	output.TexCoord = input.TexCoord;
	
    return output;
}


float4 PixelShaderFunction(VertexShaderOutput input) : COLOR0
{	
	float4 mainColor = tex2D(MainSampler, input.TexCoord);
	float4 mtaDiffuseLight = mainColor * input.Color;
	mtaDiffuseLight.rgb *= 1.3;
	
	return mtaDiffuseLight;
}


technique DiffuseLight
{
    pass Pass0
    {
		AlphaBlendEnable = True;
        AlphaRef = 1;
        VertexShader = compile vs_3_0 VertexShaderFunction();
        PixelShader = compile ps_3_0 PixelShaderFunction();
    }
}


// Fallback
technique Fallback
{
    pass P0
    {
        // Just draw normally
    }
}