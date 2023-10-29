#include "Includes/AcerolaFX_Common.fxh"
#include "Includes/AcerolaFX_TempTex1.fxh"
#include "Includes/AcerolaFX_ColorBlindness.fxh"

uniform uint _ColorBlindMode <
    ui_type = "combo";
    ui_label = "色盲模式";
    ui_tooltip = "模拟哪种色盲模式？";
    ui_items = "绿色盲（红绿）\0"
               "红色盲（红绿）\0"
               "蓝色盲（蓝黄）\0";
> = 0;

uniform float _Severity <
    ui_min = 0.0f; ui_max = 1.0f;
    ui_label = "严重性";
    ui_type = "slider";
    ui_tooltip = "调节色盲的严重程度。";
> = 0.5f;

sampler2D ColorBlindness { Texture = AFXTemp1::AFX_RenderTex1; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
float4 PS_EndPass(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return tex2D(ColorBlindness, uv).rgba; }

float3x3 GetColorBlindnessMatrix(int i) {
    if (_ColorBlindMode == 0)
        return deuteranomalySeverities[i];
    else if (_ColorBlindMode == 1)
        return protanomalySeverities[i];

    return tritanomalySeverities[i];
}

float4 PS_ColorBlindness(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float4 col = saturate(tex2D(Common::AcerolaBuffer, uv));

    int p1 = min(10, floor(_Severity * 10.0f));
    int p2 = min(10, floor((_Severity + 0.1f) * 10.0f));
    float weight = frac(_Severity * 10.0f);

    float3x3 matrix1 = GetColorBlindnessMatrix(p1);
    float3x3 matrix2 = GetColorBlindnessMatrix(p2);

    float3 newCB1 = lerp(matrix1[0], matrix2[0], weight);
    float3 newCB2 = lerp(matrix1[1], matrix2[1], weight);
    float3 newCB3 = lerp(matrix1[2], matrix2[2], weight);

    float3x3 blindness = float3x3(newCB1, newCB2, newCB3);

    float3 cb = saturate(mul(blindness, col.rgb));

    return float4(cb, 1.0f);
}

technique AFX_ColorBlindness < ui_label = "AcerolaFX::色盲[AFX_ColorBlindness]"; ui_tooltip = "(SDR) 模拟色盲效果。"; > {
    pass {
        RenderTarget = AFXTemp1::AFX_RenderTex1;

        VertexShader = PostProcessVS;
        PixelShader = PS_ColorBlindness;
    }

    pass EndPass {
        RenderTarget = Common::AcerolaBufferTex;

        VertexShader = PostProcessVS;
        PixelShader = PS_EndPass;
    }
}