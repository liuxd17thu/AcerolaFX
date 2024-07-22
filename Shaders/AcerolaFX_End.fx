#include "Includes/AcerolaFX_Common.fxh"

uniform bool _MaskUI <
    ui_label = "遮蔽UI";
    ui_tooltip = "遮蔽UI，如果启用了抖动或者CRT，则需要禁用这个。";
> = true;

float4 PS_End(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float4 originalCol = tex2D(ReShade::BackBuffer, uv);

    return float4(lerp(tex2D(Common::AcerolaBuffer, uv).rgb, originalCol.rgb, originalCol.a * _MaskUI), originalCol.a);
}

technique AcerolaFXEnd <ui_label_zh = "========AcerolaFX::结束"; ui_tooltip = "(需求！) 将它置于所有AcerolaFX着色器之后。";> {
    pass {
        VertexShader = PostProcessVS;
        PixelShader = PS_End;
    }
}