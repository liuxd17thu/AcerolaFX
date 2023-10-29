#include "Includes/AcerolaFX_Common.fxh"
#include "Includes/AcerolaFX_TempTex1.fxh"

sampler2D ColorCorrection { Texture = AFXTemp1::AFX_RenderTex1; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
float4 PS_EndPass(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return tex2D(ColorCorrection, uv).rgba; }

#define AFX_COLOR_CORRECT_SHADOW_CLONE(AFX_TECHNIQUE_NAME, AFX_TECHNIQUE_LABEL, AFX_VARIABLE_CATEGORY, AFX_HDR, AFX_EXPOSURE, AFX_TEMPERATURE, AFX_TINT, AFX_CONTRAST, AFX_LINEAR_MIDPOINT, AFX_BRIGHTNESS, AFX_COLOR_FILTER, AFX_FILTER_INTENSITY, AFX_SATURATION, AFX_SHADER_NAME) \
uniform bool AFX_HDR < \
    ui_category = AFX_VARIABLE_CATEGORY; \
    ui_category_closed = true; \
    ui_label = "高动态范围[HDR]"; \
    ui_tooltip = "启用HDR（颜色数值可以超过1）。"; \
> = true; \
\
uniform float AFX_EXPOSURE < \
    ui_category = AFX_VARIABLE_CATEGORY; \
    ui_category_closed = true; \
    ui_min = 0.0f; ui_max = 10.0f; \
    ui_label = "曝光"; \
    ui_type = "drag"; \
    ui_tooltip = "调节相机曝光。"; \
> = 1.0f; \
\
uniform float AFX_TEMPERATURE < \
    ui_category = AFX_VARIABLE_CATEGORY; \
    ui_category_closed = true; \
    ui_min = -1.0f; ui_max = 1.0f; \
    ui_label = "色温"; \
    ui_type = "drag"; \
    ui_tooltip = "调节白平衡色温。"; \
> = 0.0f; \
\
uniform float AFX_TINT < \
    ui_category = AFX_VARIABLE_CATEGORY; \
    ui_category_closed = true; \
    ui_min = -1.0f; ui_max = 1.0f; \
    ui_label = "色调"; \
    ui_type = "drag"; \
    ui_tooltip = "调节白平衡色调。"; \
> = 0.0f; \
\
uniform float3 AFX_CONTRAST < \
    ui_category = AFX_VARIABLE_CATEGORY; \
    ui_category_closed = true; \
    ui_min = 0.0f; ui_max = 5.0f; \
    ui_label = "对比度"; \
    ui_type = "drag"; \
    ui_tooltip = "调节对比度。"; \
> = 1.0f; \
\
uniform float3 AFX_LINEAR_MIDPOINT < \
    ui_category = AFX_VARIABLE_CATEGORY; \
    ui_category_closed = true; \
    ui_min = 0.0f; ui_max = 5.0f; \
    ui_label = "线性中值点"; \
    ui_type = "drag"; \
    ui_tooltip = "调节从黑色到完全饱和过程的中值点，用于对比度。"; \
> = 0.5f; \
\
uniform float3 AFX_BRIGHTNESS < \
    ui_category = AFX_VARIABLE_CATEGORY; \
    ui_category_closed = true; \
    ui_min = -5.0f; ui_max = 5.0f; \
    ui_label = "亮度"; \
    ui_type = "drag"; \
    ui_tooltip = "分颜色通道调节亮度。"; \
> = float3(0.0, 0.0, 0.0); \
\
uniform float3 AFX_COLOR_FILTER < \
    ui_category = AFX_VARIABLE_CATEGORY; \
    ui_category_closed = true; \
    ui_min = 0.0f; ui_max = 1.0f; \
    ui_label = "色彩过滤"; \
    ui_type = "color"; \
    ui_tooltip = "设置色彩过滤（白色对应不改变）。"; \
> = float3(1.0, 1.0, 1.0); \
\
uniform float AFX_FILTER_INTENSITY < \
    ui_category = AFX_VARIABLE_CATEGORY; \
    ui_category_closed = true; \
    ui_min = 0.0f; ui_max = 10.0f; \
    ui_label = "色彩过滤强度 (HDR)"; \
    ui_type = "drag"; \
    ui_tooltip = "调节色彩过滤的强度。"; \
> = 1.0f; \
\
uniform float3 AFX_SATURATION < \
    ui_category = AFX_VARIABLE_CATEGORY; \
    ui_category_closed = true; \
    ui_min = 0.0f; ui_max = 5.0f; \
    ui_label = "饱和度"; \
    ui_type = "drag"; \
    ui_tooltip = "调节饱和度。"; \
> = 1.0f; \
\
float4 AFX_SHADER_NAME(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { \
    float4 col = tex2D(Common::AcerolaBuffer, uv).rgba; \
    float UIMask = 1.0f - col.a; \
\
    float3 output = col.rgb; \
    if (!AFX_HDR) \
        output = saturate(output); \
\
    output *= AFX_EXPOSURE; \
    if (!AFX_HDR) \
        output = saturate(output); \
\
    output = Common::WhiteBalance(output.rgb, AFX_TEMPERATURE, AFX_TINT); \
    output = AFX_HDR ? max(0.0f, output) : saturate(output); \
\
    output = AFX_CONTRAST * (output - AFX_LINEAR_MIDPOINT) + AFX_LINEAR_MIDPOINT + AFX_BRIGHTNESS; \
    output = AFX_HDR ? max(0.0f, output) : saturate(output); \
\
    output *= (AFX_COLOR_FILTER * AFX_FILTER_INTENSITY); \
    if (!AFX_HDR) \
        output = saturate(output); \
\
    output = lerp(Common::Luminance(output), output, AFX_SATURATION); \
    if (!AFX_HDR) \
        output = saturate(output); \
\
    return float4(output, col.a); \
} \
\
technique AFX_TECHNIQUE_NAME < ui_label = AFX_TECHNIQUE_LABEL; ui_tooltip = "(HDR/LDR) 一组色彩修正着色器。"; > { \
    pass ColorCorrect { \
        RenderTarget = AFXTemp1::AFX_RenderTex1; \
\
        VertexShader = PostProcessVS; \
        PixelShader = AFX_SHADER_NAME; \
    } \
\
    pass EndPass { \
        RenderTarget = Common::AcerolaBufferTex; \
\
        VertexShader = PostProcessVS; \
        PixelShader = PS_EndPass; \
    } \
} \
