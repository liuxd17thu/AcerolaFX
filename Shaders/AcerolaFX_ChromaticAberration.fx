#include "Includes/AcerolaFX_Common.fxh"
#include "Includes/AcerolaFX_TempTex1.fxh"

uniform bool _DebugMask <
    ui_label = "调试遮罩";
    ui_tooltip = "显示色差强度遮罩。";
> = false;

uniform float2 _FocalOffset <
    ui_min = -1.0f; ui_max = 1.0f;
    ui_label = "焦点位置";
    ui_type = "drag";
    ui_tooltip = "焦点坐标相对于屏幕中心的坐标偏移。";
> = 0.0f;

uniform float2 _Radius <
    ui_min = 0f; ui_max = 5.0f;
    ui_label = "对焦半径";
    ui_type = "drag";
    ui_tooltip = "调节屏幕中央的对焦半径。";
> = 1.0f;

uniform float _Hardness <
    ui_min = 0f; ui_max = 10.0f;
    ui_label = "硬度";
    ui_type = "drag";
    ui_tooltip = "调节强度从屏幕中央向外变化的平滑度。";
> = 1.0f;

uniform float _Intensity <
    ui_min = 0f; ui_max = 10.0f;
    ui_label = "强度";
    ui_type = "drag";
    ui_tooltip = "调节色彩偏移的强度。";
> = 1.0f;

uniform float3 _ColorOffsets <
    ui_min = -1.0f; ui_max = 1.0f;
    ui_label = "色彩偏移";
    ui_type = "drag";
    ui_tooltip = "调节每个颜色通道偏移的程度。";
> = 0.0f;

sampler2D ChromaticAberration { Texture = AFXTemp1::AFX_RenderTex1; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
float4 PS_EndPass(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return tex2D(ChromaticAberration, uv).rgba; }

float4 PS_ChromaticAberration(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float2 texelSize = float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);

    float2 pos = uv - 0.5f;
    pos -= _FocalOffset;
    pos *= _Radius;
    pos += 0.5f;

    float2 direction = pos - 0.5f;
    float intensity = saturate(pow(abs(length(pos - 0.5f)), _Hardness));
    intensity *= _Intensity;
    if (_DebugMask)
        return intensity;

    float4 col = 1.0f;
    float2 redUV = uv + (direction * _ColorOffsets.r) * intensity;
    float2 blueUV = uv + (direction * _ColorOffsets.b) * intensity;
    float2 greenUV = uv + (direction * _ColorOffsets.g) * intensity;

    col.r = tex2D(Common::AcerolaBufferLinear, redUV).r;
    col.g = tex2D(Common::AcerolaBufferLinear, blueUV).g;
    col.b = tex2D(Common::AcerolaBufferLinear, greenUV).b;

    return col;
}

technique AFX_ChromaticAberration < ui_label_zh = "AcerolaFX::色差"; ui_tooltip = "移动色彩通道，模拟色差效果。"; > {
    pass {
        RenderTarget = AFXTemp1::AFX_RenderTex1;

        VertexShader = PostProcessVS;
        PixelShader = PS_ChromaticAberration;
    }

    pass EndPass {
        RenderTarget = Common::AcerolaBufferTex;

        VertexShader = PostProcessVS;
        PixelShader = PS_EndPass;
    }
}