#include "Includes/AcerolaFX_Common.fxh"
#include "Includes/AcerolaFX_TempTex1.fxh"
#include "Includes/AcerolaFX_Downscales.fxh"

#ifndef AFX_SAMPLE_SKY
    #define AFX_SAMPLE_SKY 0
#endif

#ifndef AFX_DEBUG_BLOOM
    #define AFX_DEBUG_BLOOM 0
#endif

#ifndef AFX_NUM_DOWNSCALES
    #define AFX_NUM_DOWNSCALES 0
#endif

uniform float _Threshold <
    ui_min = 0.0f; ui_max = 10.0f;
    ui_label = "阈值";
    ui_type = "drag";
    ui_tooltip = "控制触发泛光的亮度下限值。";
> = 0.8f;

uniform float _SoftThreshold <
    ui_min = 0.0f; ui_max = 1.0f;
    ui_label = "阈值柔化";
    ui_type = "drag";
    ui_tooltip = "调节泛光阈值曲线的肩部。";
> = 0.75f;

uniform float _Intensity <
    ui_min = 0.0f; ui_max = 10.0f;
    ui_label = "强度";
    ui_type = "drag";
    ui_tooltip = "调节泛光强度";
> = 1.0f;

uniform bool _UseKarisAvg <
    ui_category = "高级设置";
    ui_category_closed = true;
    ui_label = "使用Karis均值";
    ui_tooltip = "抑制非常明亮的HDR值以避免光斑及像素闪烁。";
> = true;

uniform float _LuminanceBias <
    ui_category = "高级设置";
    ui_category_closed = true;
    ui_min = 0.0f; ui_max = 2.0f;
    ui_label = "亮度偏置";
    ui_type = "drag";
    ui_tooltip = "Karis均值的亮度偏置。";
> = 1.0f;

uniform float _DownSampleDelta <
    ui_category = "高级设置";
    ui_category_closed = true;
    ui_min = 0.01f; ui_max = 2.0f;
    ui_label = "降采样偏移";
    ui_type = "drag";
    ui_tooltip = "调节降采样后备缓冲区时的采样偏移。";
> = 1.0f;

uniform float _UpSampleDelta <
    ui_category = "高级设置";
    ui_category_closed = true;
    ui_min = 0.01f; ui_max = 2.0f;
    ui_label = "升采样偏移";
    ui_type = "drag";
    ui_tooltip = "调节升采样先前已降采样的后备缓冲区时的采样偏移。";
> = 0.5f;

uniform int _BlendMode <
    ui_category = "色彩修正";
    ui_category_closed = true;
    ui_type = "combo";
    ui_label = "泛光混合模式";
    ui_tooltip = "调节泛光图层与图像混合的方式。";
    ui_items = "加法\0"
               "滤色\0"
               "线性减淡\0";
> = 0;

uniform float _ExposureCorrect <
    ui_category = "色彩修正";
    ui_category_closed = true;
    ui_min = 0.0f; ui_max = 10.0f;
    ui_label = "曝光";
    ui_type = "drag";
    ui_tooltip = "调节相机曝光。";
> = 1.0f;

uniform float _Temperature <
    ui_category = "色彩修正";
    ui_category_closed = true;
    ui_min = -1.0f; ui_max = 1.0f;
    ui_label = "色温";
    ui_type = "drag";
    ui_tooltip = "调节白平衡色温。";
> = 0.0f;

uniform float _Tint <
    ui_category = "色彩修正";
    ui_category_closed = true;
    ui_min = -1.0f; ui_max = 1.0f;
    ui_label = "色调";
    ui_type = "drag";
    ui_tooltip = "调节白平衡色调。";
> = 0.0f;

uniform float _Contrast <
    ui_category = "色彩修正";
    ui_category_closed = true;
    ui_min = 0.0f; ui_max = 5.0f;
    ui_label = "对比度";
    ui_type = "drag";
    ui_tooltip = "调节对比度。";
> = 1.0f;

uniform float3 _Brightness <
    ui_category = "色彩修正";
    ui_category_closed = true;
    ui_min = -5.0f; ui_max = 5.0f;
    ui_label = "亮度";
    ui_type = "drag";
    ui_tooltip = "分颜色通道调节亮度。";
> = float3(0.0, 0.0, 0.0);

uniform float3 _ColorFilter <
    ui_category = "色彩修正";
    ui_category_closed = true;
    ui_min = 0.0f; ui_max = 1.0f;
    ui_label = "色彩过滤";
    ui_type = "color";
    ui_tooltip = "设置色彩过滤（白色对应不改变）。";
> = float3(1.0, 1.0, 1.0);

uniform float _FilterIntensity <
    ui_category = "色彩修正";
    ui_category_closed = true;
    ui_min = 0.0f; ui_max = 10.0f;
    ui_label = "色彩过滤强度 (HDR)";
    ui_type = "drag";
    ui_tooltip = "调节色彩过滤的强度。";
> = 1.0f;

uniform float _Saturation <
    ui_category = "色彩修正";
    ui_category_closed = true;
    ui_min = 0.0f; ui_max = 5.0f;
    ui_label = "饱和度";
    ui_type = "drag";
    ui_tooltip = "调节饱和度。";
> = 1.0f;

float Brightness(float3 c) {
    return max(c.r, max(c.g, c.b));
}

float3 SampleBox(sampler2D texSampler, float2 uv, float2 texelSize, float delta) {
    float4 o = texelSize.xyxy * float2(-delta, delta).xxyy;
    float4 s1 = tex2D(texSampler, uv + o.xy);
    float4 s2 = tex2D(texSampler, uv + o.zy);
    float4 s3 = tex2D(texSampler, uv + o.xw);
    float4 s4 = tex2D(texSampler, uv + o.zw);

    float s1w = rcp(Brightness(s1.rgb) + _LuminanceBias);
    float s2w = rcp(Brightness(s2.rgb) + _LuminanceBias);
    float s3w = rcp(Brightness(s3.rgb) + _LuminanceBias);
    float s4w = rcp(Brightness(s4.rgb) + _LuminanceBias);

    float4 s = 0.0f;
    if (_UseKarisAvg) {
        s = s1 * s1w + s2 * s2w + s3 * s3w + s4 * s4w;
        
        return s.rgb * rcp(s1w + s2w + s3w + s4w);
    }
    else {
        s = s1 + s2 + s3 + s4;
        
        return s.rgb * 0.25f;
    }
}

float3 Prefilter(float3 col) {
    float brightness = Common::Luminance(col);
    float knee = _Threshold * _SoftThreshold;
    float soft = brightness - _Threshold + knee;
    soft = clamp(soft, 0, 2 * knee);
    soft = soft * soft / (4 * knee * 0.00001);
    float contribution = max(soft, brightness - _Threshold);
    contribution /= max(contribution, 0.00001);

    return col * contribution;
}

sampler2D Bloom { Texture = AFXTemp1::AFX_RenderTex1; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
float4 PS_EndPass(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return tex2D(Bloom, uv).rgba; }

float4 PS_Prefilter(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float2 texelSize = float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);
    float UIMask = (tex2D(ReShade::BackBuffer, uv).a > 0.0f) ? 0.0f : 1.0f;

    #if AFX_SAMPLE_SKY
    bool SkyMask = true;
    #else
    bool SkyMask = ReShade::GetLinearizedDepth(uv) < 0.98f;

    bool leftDepth = ReShade::GetLinearizedDepth(uv + texelSize * float2(-1, 0)) < 1.0f;
    bool rightDepth = ReShade::GetLinearizedDepth(uv + texelSize * float2(1, 0)) < 1.0f;
    bool upDepth = ReShade::GetLinearizedDepth(uv + texelSize * float2(0, -1)) < 1.0f;
    bool downDepth = ReShade::GetLinearizedDepth(uv + texelSize * float2(0, 1)) < 1.0f;

    SkyMask *= leftDepth * rightDepth * upDepth * downDepth;
    #endif

    float4 output = float4(Prefilter(pow(abs(SampleBox(Common::AcerolaBuffer, uv, texelSize, 1.0f)), 2.2f).rgb) * UIMask * SkyMask, 1.0f);
    
    return output;
}

float4 Scale(float4 pos : SV_POSITION, float2 uv : TEXCOORD, sampler2D buffer, int sizeFactor, float sampleDelta) {
    float2 texelSize = float2(1.0f / (BUFFER_WIDTH / sizeFactor), 1.0f / (BUFFER_HEIGHT / sizeFactor));

    return float4(SampleBox(buffer, uv, texelSize, sampleDelta), 1.0f);
}

#if AFX_NUM_DOWNSCALES > 1
float4 PS_Down1(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_TARGET { return Scale(position, uv, DownScale::Half, 2, _DownSampleDelta); }
#if AFX_NUM_DOWNSCALES > 2
float4 PS_Down2(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_TARGET { return Scale(position, uv, DownScale::Quarter, 4, _DownSampleDelta); }
#if AFX_NUM_DOWNSCALES > 3
float4 PS_Down3(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_TARGET { return Scale(position, uv, DownScale::Eighth, 8, _DownSampleDelta); }
#if AFX_NUM_DOWNSCALES > 4
float4 PS_Down4(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_TARGET { return Scale(position, uv, DownScale::Sixteenth, 16, _DownSampleDelta); }
#if AFX_NUM_DOWNSCALES > 5
float4 PS_Down5(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_TARGET { return Scale(position, uv, DownScale::ThirtySecondth, 32, _DownSampleDelta); }
#if AFX_NUM_DOWNSCALES > 6
float4 PS_Down6(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_TARGET { return Scale(position, uv, DownScale::SixtyFourth, 64, _DownSampleDelta); }
#if AFX_NUM_DOWNSCALES > 7
float4 PS_Down7(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_TARGET { return Scale(position, uv, DownScale::OneTwentyEighth, 128, _DownSampleDelta); }
float4 PS_Up1(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_TARGET { return Scale(position, uv, DownScale::TwoFiftySixth, 256, _UpSampleDelta); }
#endif
float4 PS_Up2(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_TARGET { return Scale(position, uv, DownScale::OneTwentyEighth, 128, _UpSampleDelta); }
#endif
float4 PS_Up3(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_TARGET { return Scale(position, uv, DownScale::SixtyFourth, 64, _UpSampleDelta); }
#endif
float4 PS_Up4(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_TARGET { return Scale(position, uv, DownScale::ThirtySecondth, 32, _UpSampleDelta); }
#endif
float4 PS_Up5(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_TARGET { return Scale(position, uv, DownScale::Sixteenth, 16, _UpSampleDelta); }
#endif
float4 PS_Up6(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_TARGET { return Scale(position, uv, DownScale::Eighth, 8, _UpSampleDelta); }
#endif
float4 PS_Up7(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_TARGET { return Scale(position, uv, DownScale::Quarter, 4, _UpSampleDelta); }
#endif

float3 ColorCorrect(float3 col) : SV_TARGET {
    col *= _ExposureCorrect;

    col = Common::WhiteBalance(col.rgb, _Temperature, _Tint);
    col = max(0.0f, col);

    col = _Contrast * (col - 0.5f) + 0.5f + _Brightness;
    col = max(0.0f, col);

    col *= (_ColorFilter * _FilterIntensity);

    return lerp(Common::Luminance(col), col, _Saturation);
}

float4 PS_Blend(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float4 col = tex2D(Common::AcerolaBuffer, uv);
    float UIMask = 1.0f - tex2D(ReShade::BackBuffer, uv).a;

    float2 texelSize = float2(1.0f / (BUFFER_WIDTH / 2), 1.0f / (BUFFER_HEIGHT / 2));
    float3 bloom = _Intensity * pow(abs(ColorCorrect(SampleBox(DownScale::Half, uv, texelSize, _UpSampleDelta))), 1.0f / 2.2f) * UIMask;
    
    float3 output = col.rgb;
    
    // Add (Default)
    if (_BlendMode == 0) { 
        output += bloom;
    }
    // Screen
    else if (_BlendMode == 1) {
        output = 1.0f - (1.0f - output) * (1.0f - bloom);
    }
    // Color Dodge
    else if (_BlendMode == 2) {
        output = output / max(0.01f, (1.0f - (bloom - 0.001f)));
    }

    #if AFX_DEBUG_BLOOM
    return float4(bloom, col.a);
    #else
    return float4(output, col.a);
    #endif
}

technique AFX_Bloom  <ui_label = "AcerolaFX::泛光[AFX_Bloom]"; ui_tooltip = "(HDR) 将图像中明亮区域与自身混合，提亮高光。"; >  {
    pass Prefilter {
        RenderTarget = DownScale::HalfTex;
        VertexShader = PostProcessVS;
        PixelShader = PS_Prefilter;
    }

    #if AFX_NUM_DOWNSCALES > 1
    pass Down1 {
        RenderTarget = DownScale::QuarterTex;
        VertexShader = PostProcessVS;
        PixelShader = PS_Down1;
    }
    #if AFX_NUM_DOWNSCALES > 2
    pass Down2 {
        RenderTarget = DownScale::EighthTex;
        VertexShader = PostProcessVS;
        PixelShader = PS_Down2;
    }
    #if AFX_NUM_DOWNSCALES > 3
    pass Down3 {
        RenderTarget = DownScale::SixteenthTex;
        VertexShader = PostProcessVS;
        PixelShader = PS_Down3;
    }
    #if AFX_NUM_DOWNSCALES > 4
    pass Down4 {
        RenderTarget = DownScale::ThirtySecondthTex;
        VertexShader = PostProcessVS;
        PixelShader = PS_Down4;
    }
    #if AFX_NUM_DOWNSCALES > 5
    pass Down5 {
        RenderTarget = DownScale::SixtyFourthTex;
        VertexShader = PostProcessVS;
        PixelShader = PS_Down5;
    }
    #if AFX_NUM_DOWNSCALES > 6
    pass Down6 {
        RenderTarget = DownScale::OneTwentyEighthTex;
        VertexShader = PostProcessVS;
        PixelShader = PS_Down6;
    }
    #if AFX_NUM_DOWNSCALES > 7
    pass Down7 {
        RenderTarget = DownScale::TwoFiftySixthTex;
        VertexShader = PostProcessVS;
        PixelShader = PS_Down7;
    }

    pass Up1 {
        RenderTarget = DownScale::OneTwentyEighthTex;
        BlendEnable = true;
        DestBlend = ONE;
        VertexShader = PostProcessVS;
        PixelShader = PS_Up1;
    }
    #endif
    pass Up2 {
        RenderTarget = DownScale::SixtyFourthTex;
        BlendEnable = true;
        DestBlend = ONE;
        VertexShader = PostProcessVS;
        PixelShader = PS_Up2;
    }
    #endif
    pass Up3 {
        RenderTarget = DownScale::ThirtySecondthTex;
        BlendEnable = true;
        DestBlend = ONE;
        VertexShader = PostProcessVS;
        PixelShader = PS_Up3;
    }
    #endif
    pass Up4 {
        RenderTarget = DownScale::SixteenthTex;
        BlendEnable = true;
        DestBlend = ONE;
        VertexShader = PostProcessVS;
        PixelShader = PS_Up4;
    }
    #endif
    pass Up5 {
        RenderTarget = DownScale::EighthTex;
        BlendEnable = true;
        DestBlend = ONE;
        VertexShader = PostProcessVS;
        PixelShader = PS_Up5;
    }
    #endif
    pass Up6 {
        RenderTarget = DownScale::QuarterTex;
        BlendEnable = true;
        DestBlend = ONE;
        VertexShader = PostProcessVS;
        PixelShader = PS_Up6;
    }
    #endif
    pass Up7 {
        RenderTarget = DownScale::HalfTex;
        BlendEnable = true;
        DestBlend = ONE;
        VertexShader = PostProcessVS;
        PixelShader = PS_Up7;
    }
    #endif

    pass Blend {
        RenderTarget = AFXTemp1::AFX_RenderTex1;

        VertexShader = PostProcessVS;
        PixelShader = PS_Blend;
    }

    pass End {
        RenderTarget = Common::AcerolaBufferTex;

        VertexShader = PostProcessVS;
        PixelShader = PS_EndPass;
    }
}