#include "Includes/AcerolaFX_Common.fxh"
#include "Includes/AcerolaFX_TempTex1.fxh"

uniform float3 _FogColor <
    ui_min = 0.0f; ui_max = 1.0f;
    ui_label = "雾颜色";
    ui_type = "color";
    ui_tooltip = "设置雾颜色。";
> = float3(1.0f, 1.0f, 1.0f);

uniform int _FogMode <
    ui_type = "combo";
    ui_label = "雾因子模式";
    ui_items = "E指数\0"
                "2指数\0";
> = 1;

uniform float _Density <
    ui_min = 0.0f; ui_max = 0.05f;
    ui_label = "雾气密度";
    ui_type = "slider";
    ui_tooltip = "调节雾气密度。";
> = 0.0f;

uniform float _Offset <
    ui_min = 0.0f; ui_max = 1000.0f;
    ui_label = "雾气偏置";
    ui_type = "slider";
    ui_tooltip = "雾气开始出现的距离位置偏置。";
> = 0.0f;

uniform bool _SampleSky <
    ui_label = "采样天空";
    ui_tooltip = "是否对天空盒应用雾气。";
> = true;

uniform float _ZProjection <
    ui_category_closed = true;
    ui_category = "高级设置";
    ui_min = 0.0f; ui_max = 5000.0f;
    ui_label = "相机Z轴投影";
    ui_type = "slider";
    ui_tooltip = "调节相机Z轴投影（相机截锥体的深度）。";
> = 1000.0f;

sampler2D Fog { Texture = AFXTemp1::AFX_RenderTex1; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
float4 PS_EndPass(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return tex2D(Fog, uv).rgba; }

float4 PS_DistanceFog(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float4 col = tex2D(Common::AcerolaBuffer, uv).rgba;

    float depth = ReShade::GetLinearizedDepth(uv);
    float viewDistance = depth * _ZProjection;

    float fogFactor = 0.0f;
    
    if (_FogMode == 0) {
        fogFactor = (_Density / log(2)) * max(0.0f, viewDistance - _Offset);
        fogFactor = exp2(-fogFactor);
    } else {
        fogFactor = (_Density / sqrt(log(2))) * max(0.0f, viewDistance - _Offset);
        fogFactor = exp2(-fogFactor * fogFactor);
    }

    if (depth > 0.99f && !_SampleSky)
        fogFactor = 1.0f;

    float3 fogOutput = lerp(_FogColor, col.rgb, saturate(fogFactor));

    return float4(fogOutput, col.a);
}

technique AFX_Fog <ui_label_zh = "AcerolaFX::雾气"; ui_tooltip = "(LDR) 对远处像素应用颜色以夸大距离感。"; >  {
    pass {
        RenderTarget = AFXTemp1::AFX_RenderTex1;

        VertexShader = PostProcessVS;
        PixelShader = PS_DistanceFog;
    }

    pass End {
        RenderTarget = Common::AcerolaBufferTex;

        VertexShader = PostProcessVS;
        PixelShader = PS_EndPass;
    }
}