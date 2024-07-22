#include "Includes/AcerolaFX_Common.fxh"
#include "Includes/AcerolaFX_TempTex1.fxh"

uniform float3 _VignetteColor <
    ui_type = "color";
    ui_label = "暗角颜色";
> = 0.0f;

uniform float2 _VignetteSize <
    ui_min = 0.0f; ui_max = 5.0f;
    ui_label = "暗角尺寸";
    ui_type = "drag";
    ui_tooltip = "暗角的二维尺寸。";
> = 1.0f;

uniform float2 _VignetteOffset <
    ui_min = -1.0f; ui_max = 1.0f;
    ui_label = "暗角偏移";
    ui_type = "drag";
    ui_tooltip = "暗角效果位置相对屏幕中央的偏移。";
> = 0.0f;

uniform float _Intensity <
    ui_min = 0f; ui_max = 5.0f;
    ui_label = "强度";
    ui_type = "slider";
    ui_tooltip = "调节暗角的强度。";
> = 1.0f;

uniform float _Roundness <
    ui_min = 0f; ui_max = 10.0f;
    ui_label = "圆度";
    ui_type = "slider";
    ui_tooltip = "调节暗角整体的形状，数值由低到高大致为星形->圆/椭圆->矩形。";
> = 1.0f;

uniform float _Smoothness <
    ui_min = 0.01f; ui_max = 2.0f;
    ui_label = "平滑度";
    ui_type = "slider";
    ui_tooltip = "调节强度从屏幕中央向外的变化平滑程度。";
> = 1.0f;

sampler2D Vignette { Texture = AFXTemp1::AFX_RenderTex1; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
float4 PS_EndPass(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return tex2D(Vignette, uv).rgba; }

float4 PS_Vignette(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float4 col = tex2D(Common::AcerolaBuffer, uv).rgba;
    float2 texelSize = float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);

    float2 pos = uv - 0.5f;
    pos *= _VignetteSize;
    pos += 0.5f;

    float2 d = abs(pos - (float2(0.5f, 0.5f) + _VignetteOffset)) * _Intensity;
    d = pow(saturate(d), _Roundness);
    float vfactor = pow(saturate(1.0f - dot(d, d)), _Smoothness);

    return float4(lerp(_VignetteColor, col.rgb, vfactor), 1.0f);
}

technique AFX_Vignette < ui_label_zh = "AcerolaFX::暗角"; ui_tooltip = "对图像应用类似电影的渐变暗角效果。"; > {
    pass {
        RenderTarget = AFXTemp1::AFX_RenderTex1;

        VertexShader = PostProcessVS;
        PixelShader = PS_Vignette;
    }

    pass EndPass {
        RenderTarget = Common::AcerolaBufferTex;

        VertexShader = PostProcessVS;
        PixelShader = PS_EndPass;
    }
}