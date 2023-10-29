#include "Includes/AcerolaFX_Common.fxh"
#include "Includes/AcerolaFX_TempTex1.fxh"

uniform float _Alpha <
    ui_min = 0.0f; ui_max = 1.0f;
    ui_label = "透明度";
    ui_type = "slider";
    ui_tooltip = "将全局透明度设置为……";
> = 0.0f;

sampler2D Alpha { Texture = AFXTemp1::AFX_RenderTex1; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
float4 PS_EndPass(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return tex2D(Alpha, uv).rgba; }

float4 PS_Alpha(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    return float4(tex2D(ReShade::BackBuffer, uv).rgb, _Alpha);
}

technique AFX_Alpha < ui_label = "AcerolaFX::透明度[AFX_Alpha]"; ui_tooltip = "设置后备缓冲区的全局透明度通道，以绕过UI遮蔽。"; > {
    pass {
        VertexShader = PostProcessVS;
        PixelShader = PS_Alpha;
    }
}