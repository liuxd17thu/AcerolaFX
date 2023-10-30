#include "Includes/AcerolaFX_Common.fxh"
#include "Includes/AcerolaFX_TempTex1.fxh"

#ifndef AFX_ZOOM_COUNT
 #define AFX_ZOOM_COUNT 0
#endif

uniform float _Zoom <
    ui_min = 0.0f; ui_max = 5.0f;
    ui_label = "缩放";
    ui_type = "drag";
    ui_tooltip = "减小以放大拉近，增加以缩小拉远。";
> = 1.0f;

uniform float2 _Offset <
    ui_min = -1.0f; ui_max = 1.0f;
    ui_label = "偏移";
    ui_type = "drag";
    ui_tooltip = "缩放相对于屏幕中央的位置偏移。";
> = 0.0f;

uniform bool _PointFilter <
    ui_label = "点过滤";
    ui_tooltip = "模糊或者锐利？";
> = true;

uniform int _SampleMode <
    ui_type = "combo";
    ui_label = "样本模式";
    ui_tooltip = "缩小拉远时，边界以外位置如何处理？";
    ui_items = "钳位\0"
               "镜像\0"
               "绕回\0"
               "重复\0"
               "边界\0";
> = 0;

texture2D AFX_ZoomTex < pooled = true; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; }; 
sampler2D Zoom { Texture = AFXTemp1::AFX_RenderTex1; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
float4 PS_EndPass(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return tex2D(Zoom, uv).rgba; }


float4 PS_Zoom(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float2 zoomUV = uv * 2 - 1;
    zoomUV += float2(-_Offset.x, _Offset.y) * 2;
    zoomUV *= _Zoom;
    zoomUV = zoomUV / 2 + 0.5f;
    
    if (_SampleMode == 0) {
        if (_PointFilter)
            return tex2D(Common::AcerolaBuffer, zoomUV);
        else
            return tex2D(Common::AcerolaBufferLinear, zoomUV);
    } else if (_SampleMode == 1) {
        if (_PointFilter)
            return tex2D(Common::AcerolaBufferMirror, zoomUV);
        else
            return tex2D(Common::AcerolaBufferMirrorLinear, zoomUV);
    } else if (_SampleMode == 2) {
        if (_PointFilter)
            return tex2D(Common::AcerolaBufferWrap, zoomUV);
        else
            return tex2D(Common::AcerolaBufferWrapLinear, zoomUV);
    } else if (_SampleMode == 3) {
        if (_PointFilter)
            return tex2D(Common::AcerolaBufferRepeat, zoomUV);
        else
            return tex2D(Common::AcerolaBufferRepeatLinear, zoomUV);
    } else {
        if (_PointFilter)
            return tex2D(Common::AcerolaBufferBorder, zoomUV);
        else
            return tex2D(Common::AcerolaBufferBorderLinear, zoomUV);

    }
}

technique AFX_Zoom < ui_label = "AcerolaFX::缩放[AFX_Zoom]"; ui_tooltip = "(LDR) 调节图像的缩放修正。"; > {
    pass {
        RenderTarget = AFXTemp1::AFX_RenderTex1;

        VertexShader = PostProcessVS;
        PixelShader = PS_Zoom;
    }

    pass EndPass {
        RenderTarget = Common::AcerolaBufferTex;

        VertexShader = PostProcessVS;
        PixelShader = PS_EndPass;
    }
}

#define AFX_ZOOM_SHADOW_CLONE(AFX_TECHNIQUE_NAME, AFX_TECHNIQUE_LABEL, AFX_VARIABLE_CATEGORY, AFX_ZOOM, AFX_OFFSET, AFX_POINT_FILTER, AFX_SAMPLE_MODE, AFX_SHADER_NAME) \
uniform float AFX_ZOOM < \
    ui_category = AFX_VARIABLE_CATEGORY; \
    ui_min = 0.0f; ui_max = 5.0f; \
    ui_label = "缩放"; \
    ui_type = "drag"; \
    ui_tooltip = "减小以放大拉近，增加以缩小拉远。"; \
> = 1.0f; \
\
uniform float2 AFX_OFFSET < \
    ui_category = AFX_VARIABLE_CATEGORY; \
    ui_min = -1.0f; ui_max = 1.0f; \
    ui_label = "偏移"; \
    ui_type = "drag"; \
    ui_tooltip = "缩放相对于屏幕中央的位置偏移。"; \
> = 0.0f; \
\
uniform bool AFX_POINT_FILTER < \
    ui_category = AFX_VARIABLE_CATEGORY; \
    ui_label = "点过滤"; \
    ui_tooltip = "模糊或者锐利？"; \
> = true; \
\
uniform int AFX_SAMPLE_MODE < \
    ui_category = AFX_VARIABLE_CATEGORY; \
    ui_type = "combo"; \
    ui_label = "样本模式"; \
    ui_tooltip = "缩小拉远时，边界以外位置如何处理？"; \
    ui_items = "钳位\0" \
               "镜像\0" \
               "绕回\0" \
               "重复\0" \
               "边界\0"; \
> = 0; \
\
float4 AFX_SHADER_NAME(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { \
    float2 zoomUV = uv * 2 - 1; \
    zoomUV += float2(-AFX_OFFSET.x, AFX_OFFSET.y) * 2; \
    zoomUV *= AFX_ZOOM; \
    zoomUV = zoomUV / 2 + 0.5f; \
\
    if (AFX_SAMPLE_MODE == 0) { \
        if (AFX_POINT_FILTER) \
            return tex2D(Common::AcerolaBuffer, zoomUV); \
        else \
            return tex2D(Common::AcerolaBufferLinear, zoomUV); \
    } else if (AFX_SAMPLE_MODE == 1) { \
        if (AFX_POINT_FILTER) \
            return tex2D(Common::AcerolaBufferMirror, zoomUV); \
        else \
            return tex2D(Common::AcerolaBufferMirrorLinear, zoomUV); \
    } else if (AFX_SAMPLE_MODE == 2) { \
        if (AFX_POINT_FILTER) \
            return tex2D(Common::AcerolaBufferWrap, zoomUV); \
        else \
            return tex2D(Common::AcerolaBufferWrapLinear, zoomUV); \
    } else if (AFX_SAMPLE_MODE == 3) { \
        if (AFX_POINT_FILTER) \
            return tex2D(Common::AcerolaBufferRepeat, zoomUV); \
        else \
            return tex2D(Common::AcerolaBufferRepeatLinear, zoomUV); \
    } else { \
        if (AFX_POINT_FILTER) \
            return tex2D(Common::AcerolaBufferBorder, zoomUV); \
        else \
            return tex2D(Common::AcerolaBufferBorderLinear, zoomUV); \
\
    } \
} \
\
technique AFX_TECHNIQUE_NAME < ui_label = AFX_TECHNIQUE_LABEL; ui_tooltip = "(LDR) 调节图像的缩放修正。"; > { \
    pass { \
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

#if AFX_ZOOM_COUNT > 0
    AFX_ZOOM_SHADOW_CLONE(AFX_Zoom2, "AcerolaFX::缩放2[AFX_Zoom2]", "缩放2 设置", _Zoom2, _ZoomOffset2, _ZoomPointFilter2, _ZoomSampleMode2, PS_Zoom2)
#endif

#if AFX_ZOOM_COUNT > 1
    AFX_ZOOM_SHADOW_CLONE(AFX_Zoom3, "AcerolaFX::缩放3[AFX_Zoom3]", "缩放3 设置", _Zoom3, _ZoomOffset3, _ZoomPointFilter3, _ZoomSampleMode3, PS_Zoom3)
#endif

#if AFX_ZOOM_COUNT > 2
    AFX_ZOOM_SHADOW_CLONE(AFX_Zoom4, "AcerolaFX::缩放4[AFX_Zoom4]", "缩放4 设置", _Zoom4, _ZoomOffset4, _ZoomPointFilter4, _ZoomSampleMode4, PS_Zoom4)
#endif

#if AFX_ZOOM_COUNT > 3
    AFX_ZOOM_SHADOW_CLONE(AFX_Zoom5, "AcerolaFX::缩放5[AFX_Zoom5]", "缩放5 设置", _Zoom5, _ZoomOffset5, _ZoomPointFilter5, _ZoomSampleMode5, PS_Zoom5)
#endif

#if AFX_ZOOM_COUNT > 4
    AFX_ZOOM_SHADOW_CLONE(AFX_Zoom6, "AcerolaFX::缩放6[AFX_Zoom6]", "缩放6 设置", _Zoom6, _ZoomOffset6, _ZoomPointFilter6, _ZoomSampleMode6, PS_Zoom6)
#endif

#if AFX_ZOOM_COUNT > 5
    AFX_ZOOM_SHADOW_CLONE(AFX_Zoom7, "AcerolaFX::缩放7[AFX_Zoom7]", "缩放7 设置", _Zoom7, _ZoomOffset7, _ZoomPointFilter7, _ZoomSampleMode7, PS_Zoom7)
#endif

#if AFX_ZOOM_COUNT > 6
    AFX_ZOOM_SHADOW_CLONE(AFX_Zoom8, "AcerolaFX::缩放8[AFX_Zoom8]", "缩放8 设置", _Zoom8, _ZoomOffset8, _ZoomPointFilter8, _ZoomSampleMode8, PS_Zoom8)
#endif