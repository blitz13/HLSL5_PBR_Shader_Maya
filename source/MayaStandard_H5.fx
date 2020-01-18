#ifndef _MAYA_
#define _MAYA_
#endif 

cbuffer UpdatePerFrame : register(b0)
{
    
};

///////////////////////////////////////////////////////////////////////////
// Objects
cbuffer UpdatePerObject : register(b1)
{
    float4x4 wvp : WorldViewProjection < string UIWidget = "None"; >;
    float4x4 world : World < string UIWidget = "None"; >;
};

///////////////////////////////////////////////////////////////////////////
// Lights
cbuffer Updatelights : register(b2)
{
    int light0Type : LIGHTTYPE
	<
		string Object = "Light 0";
		string UIName = "Light 0 Type";
		string UIFieldNames ="None:Default:Spot:Point:Directional:Ambient";
		float UIMin = 0;
		float UIMax = 5;
		float UIStep = 1;
        string UIWidget = "none";
	> = 2;
    
    float3 light0Pos : POSITION
	< 
		string Object = "Light 0";
		string UIName = "Light 0 Position"; 
		string Space = "World";
        string UIWidget = "none";
	> = { 100.0f, 100.0f, 100.0f };

    float3 light0Color : LIGHTCOLOR
	<
		string Object = "Light 0";
		string UIName = "Light 0 Color"; 
		string UIWidget = "none";
	> = { 1.0f, 1.0f, 1.0f };
};

///////////////////////////////////////////////////////////////////////////
// UI
cbuffer UpdateAttributes : register(b3)
{
    float3 BaseColor
    <
        string UIWidget = "ColorPicker";
        string UIName = "Base Color";
    > = { 0.5, 0.5, 0.5 };
};

///////////////////////////////////////////////////////////////////////////
// VERTEX SHASER DATA STRUCT
struct VS_INPUT
{
    float4 position : POSITION;
    float4 normal : NORMAL;
};

struct VS_TO_PS
{
    float4 hPosition : SV_Position;
    float4 diffuse : COLOR;
};

// VERTEX SHADER
VS_TO_PS VS(VS_INPUT IN)
{
    VS_TO_PS OUT;
    OUT.hPosition = mul(IN.position, wvp);
    float3 wsPosition = mul(IN.position, world);
    float3 lightVec = normalize(light0Pos - wsPosition);
    float3 normal = normalize(IN.normal);
    float illum = max(dot(lightVec, normal), 0);
    OUT.diffuse = (illum * float4(light0Color, 1) * float4(BaseColor, 1));
    return OUT;
}

////////////////////////////////////////////////////////////////////////////
// PIXEL SHADER INPUT STRUCT
struct PS_DATA
{
    float4 Color : SV_Target;
};

// PIXEL SHADER
PS_DATA PS(VS_TO_PS IN)
{
    PS_DATA OUT;

    //OUT.Color = float4(BaseColor, 1);
    OUT.Color = IN.diffuse;

    return OUT;
}

///////////////////////////////////////////////////////////////////////////
// TECHNIQUES
technique11 T0
{
    pass P0
    {
        SetVertexShader(CompileShader(vs_5_0, VS()));
        SetPixelShader(CompileShader(ps_5_0, PS()));
        SetHullShader(NULL);
        SetDomainShader(NULL);
        SetGeometryShader(NULL);
    }
}