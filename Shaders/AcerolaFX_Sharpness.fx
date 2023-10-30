#include "Includes/AcerolaFX_Sharpness.fxh"

#ifndef AFX_SHARPNESS_CLONE_COUNT
    #define AFX_SHARPNESS_CLONE_COUNT 0
#endif

uniform int _Filter <
    ui_category = "锐度1 设置";
    ui_category_closed = true;
    ui_type = "combo";
    ui_label = "过滤类型";
    ui_items = "基础\0"
               "自适应\0";
    ui_tooltip = "使用何种锐化滤波器。";
> = 0;

uniform float _Sharpness <
    ui_category = "锐度1 设置";
    ui_category_closed = true;
    ui_min = -1.0f; ui_max = 1.0f;
    ui_label = "锐度";
    ui_type = "drag";
    ui_tooltip = "调节锐化强度。";
> = 0.0f;

uniform float _SharpnessFalloff <
    ui_category = "锐度1 设置";
    ui_category_closed = true;
    ui_min = 0.0f; ui_max = 0.01f;
    ui_label = "锐度淡出";
    ui_type = "slider";
    ui_tooltip = "调节锐度随深度减弱的比率。";
> = 0.0f;

uniform float _Offset <
    ui_category = "锐度1 设置";
    ui_category_closed = true;
    ui_min = 0.0f; ui_max = 1000.0f;
    ui_label = "淡出偏置";
    ui_type = "slider";
    ui_tooltip = "锐度开始淡出的深度偏置。";
> = 0.0f;

float4 PS_AdaptiveSharpness(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float4 col = saturate(tex2D(Common::AcerolaBuffer, uv));

    float3 output = 0;
    if (_Filter == 0) Basic(uv, _Sharpness, output);
    if (_Filter == 1) Adaptive(uv, _Sharpness, output);
    
    if (_SharpnessFalloff > 0.0f) {
        float depth = ReShade::GetLinearizedDepth(uv);
        float viewDistance = depth * 1000;

        float falloffFactor = 0.0f;

        falloffFactor = (_SharpnessFalloff / log(2)) * max(0.0f, viewDistance - _Offset);
        falloffFactor = exp2(-falloffFactor);

        output = lerp(col.rgb, output, saturate(falloffFactor));
    }

    return float4(output, col.a);
}

technique AFX_AdaptiveSharpness <ui_label = "AcerolaFX::锐度[AFX_AdaptiveSharpness]"; ui_tooltip = "(LDR) 增加边缘之间的对比度，提供细节更精致的错觉。"; > {
    pass Sharpen {
        RenderTarget = AFXTemp1::AFX_RenderTex1;

        VertexShader = PostProcessVS;
        PixelShader = PS_AdaptiveSharpness;
    }

    pass EndPass {
        RenderTarget = Common::AcerolaBufferTex;

        VertexShader = PostProcessVS;
        PixelShader = PS_EndPass;
    }
}

#if AFX_SHARPNESS_CLONE_COUNT > 0
AFX_SHARPNESS_SHADOW_CLONE(AFX_SHARPNESS2, "AcerolaFX::锐度2[AFX_SHARPNESS2]", "锐度2 设置", _Filter2, _Sharpness2, _SharpnessFalloff2, _SharpnessOffset2, PS_Sharpness2)
#endif

#if AFX_SHARPNESS_CLONE_COUNT > 1
AFX_SHARPNESS_SHADOW_CLONE(AFX_SHARPNESS3, "AcerolaFX::锐度3[AFX_SHARPNESS3]", "锐度3 设置", _Filter3, _Sharpness3, _SharpnessFalloff3, _SharpnessOffset3, PS_Sharpness3)
#endif

#if AFX_SHARPNESS_CLONE_COUNT > 2
AFX_SHARPNESS_SHADOW_CLONE(AFX_SHARPNESS4, "AcerolaFX::锐度4[AFX_SHARPNESS4]", "锐度4 设置", _Filter4, _Sharpness4, _SharpnessFalloff4, _SharpnessOffset4, PS_Sharpness4)
#endif

#if AFX_SHARPNESS_CLONE_COUNT > 3
AFX_SHARPNESS_SHADOW_CLONE(AFX_SHARPNESS5, "AcerolaFX::锐度5[AFX_SHARPNESS5]", "锐度5 设置", _Filter5, _Sharpness5, _SharpnessFalloff5, _SharpnessOffset5, PS_Sharpness5)
#endif

#if AFX_SHARPNESS_CLONE_COUNT > 4
AFX_SHARPNESS_SHADOW_CLONE(AFX_SHARPNESS6, "AcerolaFX::锐度6[AFX_SHARPNESS6]", "锐度6 设置", _Filter6, _Sharpness6, _SharpnessFalloff6, _SharpnessOffset6, PS_Sharpness6)
#endif

#if AFX_SHARPNESS_CLONE_COUNT > 5
AFX_SHARPNESS_SHADOW_CLONE(AFX_SHARPNESS7, "AcerolaFX::锐度7[AFX_SHARPNESS7]", "锐度7 设置", _Filter7, _Sharpness7, _SharpnessFalloff7, _SharpnessOffset7, PS_Sharpness7)
#endif

#if AFX_SHARPNESS_CLONE_COUNT > 6
AFX_SHARPNESS_SHADOW_CLONE(AFX_SHARPNESS8, "AcerolaFX::锐度8[AFX_SHARPNESS8]", "锐度8 设置", _Filter8, _Sharpness8, _SharpnessFalloff8, _SharpnessOffset8, PS_Sharpness8)
#endif

#if AFX_SHARPNESS_CLONE_COUNT > 7
AFX_SHARPNESS_SHADOW_CLONE(AFX_SHARPNESS9, "AcerolaFX::锐度9[AFX_SHARPNESS9]", "锐度9 设置", _Filter9, _Sharpness9, _SharpnessFalloff9, _SharpnessOffset9, PS_Sharpness9)
#endif

#if AFX_SHARPNESS_CLONE_COUNT > 8
AFX_SHARPNESS_SHADOW_CLONE(AFX_SHARPNESS10, "AcerolaFX::锐度10[AFX_SHARPNESS10]", "锐度10 设置", _Filter10, _Sharpness10, _SharpnessFalloff10, _SharpnessOffset10, PS_Sharpness10)
#endif