#include "Includes/AcerolaFX_Common.fxh"
#include "Includes/AcerolaFX_TempTex1.fxh"

#ifndef AFX_CHROMA_KEY_TEXTURE
    #define AFX_CHROMA_KEY_TEXTURE "watercolor.png"
#endif

#ifndef AFX_CHROMA_TEX_WIDTH
#define AFX_CHROMA_TEX_WIDTH 1024
#endif

#ifndef AFX_CHROMA_TEX_HEIGHT
#define AFX_CHROMA_TEX_HEIGHT 512
#endif

uniform float3 _KeyColor <
    ui_type = "color";
    ui_label = "键控颜色";
> = 0.0f;

uniform int _Behavior <
    ui_type = "combo";
    ui_label = "键控行为";
    ui_tooltip = "要对色键做什么？";
    ui_items = "实色\0"
               "渐变\0"
               "纹理\0";
> = 0;

uniform float3 _ReplaceColor <
    ui_type = "color";
    ui_label = "替换颜色";
    ui_spacing = 5;
> = 0.0f;

uniform float3 _Gradient1 <
    ui_category = "渐变设置";
    ui_category_closed = true;
    ui_type = "color";
    ui_label = "渐变颜色1";
> = 0.0f;

uniform float3 _Gradient2 <
    ui_category = "渐变设置";
    ui_category_closed = true;
    ui_type = "color";
    ui_label = "渐变颜色2";
> = 0.0f;

uniform float2 _TextureTile <
    ui_category = "纹理设置";
    ui_category_closed = true;
    ui_type = "drag";
    ui_label = "平铺率";
> = 1.0f;

uniform float2 _TextureOffset <
    ui_category = "纹理设置";
    ui_category_closed = true;
    ui_type = "drag";
    ui_label = "偏移";
> = 0.0f;

texture2D AFX_ChromaKeyTex < source = AFX_CHROMA_KEY_TEXTURE; > { Width = AFX_CHROMA_TEX_WIDTH; Height = AFX_CHROMA_TEX_HEIGHT; };
sampler2D ChromaKeyTexture { Texture = AFX_ChromaKeyTex; AddressU = REPEAT; AddressV = REPEAT; };

sampler2D ChromaKey { Texture = AFXTemp1::AFX_RenderTex1; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
float4 PS_EndPass(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return tex2D(ChromaKey, uv).rgba; }

float4 PS_ChromaKey(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float4 col = saturate(tex2D(Common::AcerolaBuffer, uv).rgba);

    if (all(col.rgb == _KeyColor)) {
        if (_Behavior == 0)
            return float4(_ReplaceColor, col.a);

        if (_Behavior == 1) {
            float3 output = lerp(_Gradient1, _Gradient2, uv.x);

            return float4(output, col.a);
        }

        if (_Behavior == 2) {
            return tex2D(ChromaKeyTexture, (uv * _TextureTile) + _TextureOffset);
        }
    }

    return col;
}

technique AFX_ChromaKey < ui_label_zh = "AcerolaFX::色键抠像"; ui_tooltip = "将指定颜色替换为其他内容。\n译注：这个不是绿幕，而是用来处理已经绿幕抠过的图像。"; > {
    pass {
        RenderTarget = AFXTemp1::AFX_RenderTex1;

        VertexShader = PostProcessVS;
        PixelShader = PS_ChromaKey;
    }

    pass EndPass {
        RenderTarget = Common::AcerolaBufferTex;

        VertexShader = PostProcessVS;
        PixelShader = PS_EndPass;
    }
}