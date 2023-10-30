#include "Includes/AcerolaFX_Common.fxh"

float4 PS_Start(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    return tex2D(ReShade::BackBuffer, uv);
}

technique AcerolaFXStart <ui_label = "========AcerolaFX::开始[AcerolaFXStart]"; ui_tooltip = "(需求！) 将它置于所有AcerolaFX着色器之前。\n另外，直到 AcerolaFX::结束 为止，中间插入的非AcerolaFX着色器都无法生效。";> {
    pass {
        RenderTarget = Common::AcerolaBufferTex;

        VertexShader = PostProcessVS;
        PixelShader = PS_Start;
    }
}