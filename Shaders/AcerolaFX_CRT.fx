#include "Includes/AcerolaFX_Common.fxh"
#include "Includes/AcerolaFX_TempTex1.fxh"

uniform float _Curvature <
    ui_min = 1.0f; ui_max = 10.0f;
    ui_label = "曲率";
    ui_type = "drag";
    ui_tooltip = "控制屏幕边角的曲率。";
> = 10.0f;

uniform float _VignetteWidth <
    ui_min = 1.0f; ui_max = 100.0f;
    ui_label = "暗角宽度";
    ui_type = "drag";
    ui_tooltip = "调节暗角宽度";
> = 30.0f;

uniform int _LineSize <
    ui_min = 0; ui_max = 4;
    ui_label = "扫描线尺寸";
    ui_type = "slider";
    ui_tooltip = "以 2 ^ x 的方式调节CRT扫描线尺寸。";
> = 0;

uniform float _LineStrength <
    ui_min = 1.0f; ui_max = 5.0f;
    ui_label = "扫描线强度";
    ui_type = "drag";
    ui_tooltip = "调节CRT扫描线强度。";
> = 1.0f;

uniform float _BrightnessAdjust <
    ui_min = -1.0f; ui_max = 1.0f;
    ui_label = "亮度调节";
    ui_type = "drag";
    ui_tooltip = "调节CRT扫描线亮度。";
> = 0.0f;

uniform bool _MaskUI <
    ui_label = "遮蔽UI";
    ui_tooltip = "CRT效果不应用于UI。";
> = true;

sampler2D CRT { Texture = AFXTemp1::AFX_RenderTex1; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
float4 PS_EndPass(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return tex2D(CRT, uv).rgba; }

float4 PS_CRT(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float2 crtUV = uv * 2.0f - 1.0f;
    float2 offset = crtUV.yx / _Curvature;
    crtUV = crtUV + crtUV * offset * offset;
    crtUV = crtUV * 0.5f + 0.5f;

    float4 col = tex2D(Common::AcerolaBuffer, crtUV);
    float4 UI = tex2D(ReShade::BackBuffer, crtUV);

    float3 output = saturate(col.rgb);

    if (crtUV.x <= 0.0f || 1.0f <= crtUV.x || crtUV.y <= 0.0f || 1.0f <= crtUV.y)
        output = 0;

    crtUV = crtUV * 2.0f - 1.0f;
    float2 vignette = _VignetteWidth / float2(BUFFER_WIDTH, BUFFER_HEIGHT);
    vignette = smoothstep(0.0f, vignette, 1.0f - abs(crtUV));
    vignette = saturate(vignette);

    output.g *= (sin(uv.y * (BUFFER_HEIGHT / exp2(_LineSize)) * 2.0f) + 1.0f) * 0.15f * _LineStrength + 1.0f + _BrightnessAdjust;
    output.rb *= (cos(uv.y * (BUFFER_HEIGHT / exp2(_LineSize)) * 2.0f) + 1.0f) * 0.135f * _LineStrength + 1.0f + _BrightnessAdjust; 

    output = saturate(output) * vignette.x * vignette.y;

    return float4(lerp(output.rgb, UI.rgb, UI.a * _MaskUI), col.a);
}

technique AFX_CRT  <ui_label = "AcerolaFX::显像管[AFX_CRT]"; ui_tooltip = "(LDR) 将画面变为显像管电视风格。"; >  {
    pass {
        RenderTarget = AFXTemp1::AFX_RenderTex1;

        VertexShader = PostProcessVS;
        PixelShader = PS_CRT;
    }

    pass End {
        RenderTarget = Common::AcerolaBufferTex;

        VertexShader = PostProcessVS;
        PixelShader = PS_EndPass;
    }
}