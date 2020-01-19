#ifndef _MAYA_
#define _MAYA_
#endif 

cbuffer UpdatePerFrame : register(b0)
{
    float4x4 viewInv    : ViewInverse < string UIWidget = "None"; >;
};

///////////////////////////////////////////////////////////////////////////
// Objects
cbuffer UpdatePerObject : register(b1)
{
    float4x4 wvp        : WorldViewProjection   < string UIWidget = "None"; >;
    float4x4 worldIT    : WorldInverseTranspose < string UIWidget = "None"; >;
    float4x4 world      : World                 < string UIWidget = "None"; >;
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
	> = 3;
    
    float4 light0Pos : POSITION
	< 
		string Object = "Light 0";
		string UIName = "Light 0 Position"; 
		string Space = "World";
        string UIWidget = "none";
	> = { 100.0f, 100.0f, 100.0f, 0.0};

    float4 light0Color : LIGHTCOLOR
	<
		string Object = "Light 0";
		string UIName = "Light 0 Color"; 
		string UIWidget = "none";
	> = { 1.0f, 1.0f, 1.0f, 0.0f };
};

///////////////////////////////////////////////////////////////////////////
// UI
cbuffer UpdateAttributes : register(b3)
{
    //float3 BaseColor
    //<
    //    string UIWidget = "ColorPicker";
    //    string UIName = "Base Color";
    //> = { 0.5, 0.5, 0.5 };
};

Texture2D NormalMap
<
    string ResourceName = "";
    string UIWidget = "FilePicker";
    string UIName = "Normal Map";
    string ResourceType = "2D";
>;

Texture2D DiffuseMap
<
    string ResourceName = "";
    string UIWidget = "FilePicker";
    string UIName = "Diffuse Map";
    string ResourceType = "2D";
>;

// SAMPLER
SamplerState SamplerAnisoWrap
{
    Filter = ANISOTROPIC;
    AddressU = Wrap;
    AddressV = Wrap;

};

///////////////////////////////////////////////////////////////////////////
// VERTEX SHASER DATA STRUCT
struct VS_INPUT
{
    float4 position : POSITION;
    float2 texCoord : TEXCOORD0;
    float3 normal : NORMAL;
    float3 binormal : BINORMAL;
    float3 tangent : TANGENT;
    
};

struct VS_TO_PS
{
    float4 hPosition : SV_Position;
    float2 texCoord : TEXCOORD0;
    float3 lightVec : TEXCOORD1;
    float3 worldNormal : TEXCOORD2;
    float3 worldTangent : TEXCOORD3;
    float3 worldBinormal : TEXCOORD4;
};

// VERTEX SHADER
VS_TO_PS VS(VS_INPUT IN, uniform float4 lightPosition)
{
    VS_TO_PS OUT;
    
    float3 wsPosition = mul(IN.position, world);
    
    OUT.worldNormal = mul(float4(IN.normal, 1), worldIT).xyz;
    OUT.worldBinormal = mul(float4(IN.binormal, 1), worldIT).xyz;
    OUT.worldTangent = mul(float4(IN.tangent, 1), worldIT).xyz;
    
    OUT.lightVec = float3(lightPosition.xyz) - wsPosition;
    OUT.texCoord.xy = IN.texCoord;
    OUT.hPosition = mul(IN.position, wvp);
    
    return OUT;
}

////////////////////////////////////////////////////////////////////////////

// PIXEL SHADER
float4 PS(VS_TO_PS IN, uniform float4 lightColor) : SV_Target
{
    float4 OUT;
    
    float4 difMapColor = DiffuseMap.Sample(SamplerAnisoWrap, IN.texCoord);
    
    float3 normal = NormalMap.Sample(SamplerAnisoWrap, IN.texCoord).xyz * 2.0 - 1.0;
    normal = float3(normal.xy * -1, normal.z);
    
    float3 wNormal = normalize(IN.worldNormal);
    float3 wBinormal = normalize(IN.worldBinormal);
    float3 wTangent = normalize(IN.worldTangent);
    
    float3 nNormals = (normal.z * wNormal) + (normal.y * wBinormal) + (normal.x * -wTangent);
    nNormals = normalize(nNormals);
    
    float3 nLightVec = normalize(IN.lightVec);
    
    float4 difLight = saturate(dot(nNormals, nLightVec) * lightColor);
    
    OUT = pow(difMapColor, 2.233333333) * difLight;
    
    return OUT;
}

///////////////////////////////////////////////////////////////////////////
// TECHNIQUES
technique11 T0
{
    pass P0
    {
        SetVertexShader(CompileShader(vs_5_0, VS(light0Pos)));
        SetPixelShader(CompileShader(ps_5_0, PS(light0Color)));
        SetHullShader(NULL);
        SetDomainShader(NULL);
        SetGeometryShader(NULL);
    }
}