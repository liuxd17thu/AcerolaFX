#include "Includes/AcerolaFX_Common.fxh"
#include "Includes/AcerolaFX_TempTex1.fxh"
#include "Includes/AcerolaFX_TempTex2.fxh"
#include "Includes/AcerolaFX_TempTex3.fxh"
#include "Includes/AcerolaFX_TempTex4.fxh"

uniform bool _ConsiderSkyInfinity <
    ui_label = "视天空为无穷远";
    ui_tooltip = "将天空盒视作位于无穷远处。禁用以聚焦天空。";
> = true;

uniform float _FocalPlaneDistance <
    ui_min = 0.0f; ui_max = 1000.0f;
    ui_label = "聚焦平面";
    ui_type = "slider";
    ui_tooltip = "调节细节清晰的距离。";
> = 40.0f;

uniform float _FocusRange <
    ui_min = 0.0f; ui_max = 1000.0f;
    ui_label = "聚焦范围";
    ui_type = "slider";
    ui_tooltip = "调节聚焦平面附近细节清晰的范围。";
> = 20.0f;

uniform int _InverseTonemapper <
    ui_category = "色调映射设置";
    ui_category_closed = true;
    ui_type = "combo";
    ui_label = "反向色调映射算子";
    ui_tooltip = "将LDR转换为SDR。";
    ui_items = "无色调映射\0"
               "扩展的Reinhard\0"
               "Lottes\0";
> = 0;

uniform bool _ReverseTonemap <
    ui_category = "色调映射设置";
    ui_category_closed = true;
    ui_label = "逆色调映射";
    ui_tooltip = "使用上面的色调映射函数将HDR散景模糊映射至SDR。如果准备改用色调映射着色器，请禁用这个。";
> = true;

uniform float _Exposure <
    ui_category = "色调映射设置";
    ui_category_closed = true;
    ui_min = 0.0f; ui_max = 5.0f;
    ui_label = "曝光";
    ui_type = "drag";
    ui_tooltip = "调节远景和近景曝光。";
> = 1.0f;

uniform bool _UseKaris <
    ui_category = "色调映射设置";
    ui_category_closed = true;
    ui_label = "反向Karis均值";
    ui_tooltip = "较亮像素具有更高权重，从而获得更真实的高光。";
> = true;


uniform float _LuminanceMultiplier <
    ui_category = "色调映射设置";
    ui_category_closed = true;
    ui_min = 0.0f; ui_max = 5.0f;
    ui_label = "亮度乘数";
    ui_type = "slider";
    ui_tooltip = "调节反向Karis加权的亮度乘数。";
> = 1.0f;

uniform float _LuminanceBias <
    ui_category = "色调映射设置";
    ui_category_closed = true;
    ui_min = 0.0f; ui_max = 5.0f;
    ui_label = "亮度偏置";
    ui_type = "slider";
    ui_tooltip = "调节反向Karis加权的亮度偏置。";
> = 0.0f;

uniform int _KernelShape <
    ui_category = "散景设置";
    ui_category_closed = true;
    ui_type = "combo";
    ui_label = "光圈形状";
    ui_tooltip = "核形状";
    ui_items = "圆形\0"
               "方形\0"
               "钻石\0"
               "六边形\0"
               "八边形\0"
               "星形\0";
> = 0;

uniform int _KernelRotation <
    ui_category = "散景设置";
    ui_category_closed = true;
    ui_min = -180; ui_max = 180;
    ui_label = "旋转";
    ui_type = "slider";
    ui_tooltip = "散景形状旋转。";
> = 0;

uniform float _Strength <
    ui_category = "散景设置";
    ui_category_closed = true;
    ui_min = 0.0f; ui_max = 3.0f;
    ui_label = "采样距离";
    ui_type = "drag";
    ui_tooltip = "调节散景核采样点的距离，作为散景尺寸的乘数。";
> = 1.0f;

uniform bool _NearPointFilter <
    ui_category = "近景设置";
    ui_category_closed = true;
    ui_label = "点过滤";
    ui_tooltip = "模糊采样时的点过滤。";
> = false;

uniform int _NearKernelSize <
    ui_category = "近景设置";
    ui_category_closed = true;
    ui_min = 1; ui_max = 13;
    ui_label = "散景核尺寸";
    ui_type = "slider";
    ui_tooltip = "近景散景核尺寸。";
> = 6;

uniform int _NearFillWidth <
    ui_category = "近景设置";
    ui_category_closed = true;
    ui_min = 0; ui_max = 5;
    ui_label = "填充尺寸";
    ui_type = "slider";
    ui_tooltip = "尝试减轻欠采样的最大滤波器半径。";
> = 1;

uniform float _NearExposure <
    ui_category = "近景设置";
    ui_category_closed = true;
    ui_min = 0.0f; ui_max = 3.0f;
    ui_label = "曝光";
    ui_type = "slider";
    ui_tooltip = "近景曝光值。";
> = 0.0f;

uniform bool _FarPointFilter <
    ui_category = "远景设置";
    ui_category_closed = true;
    ui_label = "点过滤";
    ui_tooltip = "模糊采样时的点过滤。";
> = false;

uniform int _FarKernelSize <
    ui_category = "远景设置";
    ui_category_closed = true;
    ui_min = 1; ui_max = 13;
    ui_label = "散景核尺寸";
    ui_type = "slider";
    ui_tooltip = "远景散景核尺寸。";
> = 6;

uniform int _FarFillWidth <
    ui_category = "远景设置";
    ui_category_closed = true;
    ui_min = 0; ui_max = 5;
    ui_label = "填充尺寸";
    ui_type = "slider";
    ui_tooltip = "尝试减轻欠采样的最大滤波器半径。";
> = 1;

uniform float _FarExposure <
    ui_category = "远景设置";
    ui_category_closed = true;
    ui_min = 0.0f; ui_max = 3.0f;
    ui_label = "曝光";
    ui_type = "slider";
    ui_tooltip = "远景曝光值。";
> = 0.0f;

uniform bool _PreventSpillage <
    ui_category = "高级设置";
    ui_category_closed = true;
    ui_label = "避免溢出";
    ui_tooltip = "尝试避免来自背景像素的强度溢出。";
> = false;

uniform int _CoCFill <
    ui_category = "高级设置";
    ui_category_closed = true;
    ui_min = 0; ui_max = 10;
    ui_label = "近弥散圆填充";
    ui_type = "slider";
    ui_tooltip = "近平面的弥散圆边界尺寸。";
> = 3;

uniform int _CoCBlur <
    ui_category = "高级设置";
    ui_category_closed = true;
    ui_min = 0; ui_max = 10;
    ui_label = "近弥散圆模糊";
    ui_type = "slider";
    ui_tooltip = "近平面的弥散圆模糊强度。";
> = 3;

texture2D AFX_CoC { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RG8; };
sampler2D CoC { Texture = AFX_CoC; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};
sampler2D CoCLinear { Texture = AFX_CoC; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR;};

texture2D AFX_NearColor { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16; };
storage2D s_NearColor { Texture = AFX_NearColor; };
sampler2D NearColor { Texture = AFX_NearColor; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};
sampler2D NearColorLinear { Texture = AFX_NearColor; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR;};

texture2D AFX_FarColor { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16; };
storage2D s_FarColor { Texture = AFX_FarColor; };
sampler2D FarColor { Texture = AFX_FarColor; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};
sampler2D FarColorLinear { Texture = AFX_FarColor; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR;};

texture2D AFX_NearCoCBlur { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R8; };
sampler2D NearCoCBlur { Texture = AFX_NearCoCBlur; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};
sampler2D NearCoCBlurLinear { Texture = AFX_NearCoCBlur; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR;};

texture2D AFX_FullPing { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16; };
sampler2D FullPing { Texture = AFX_FullPing; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};
sampler2D FullPingLinear { Texture = AFX_FullPing; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR;};
float4 PS_BlitPing(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return tex2D(FullPingLinear, uv); }

sampler2D Bokeh { Texture = AFXTemp1::AFX_RenderTex1; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
storage2D s_Bokeh { Texture = AFXTemp1::AFX_RenderTex1; };
float4 PS_EndPass(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return tex2D(Bokeh, uv).rgba; }

float Brightness(float3 c) {
    return max(c.r, max(c.g, c.b));
}

float3 InverseTonemap(float3 col) {
    float3 x = col * _Exposure;

    if (_InverseTonemapper == 0) { // No Tonemap
        return x;
    } else if (_InverseTonemapper == 1) { // Extended Reinhard
        return col / (_Exposure * max(1.0 - col / _Exposure, 0.001));
    } else if (_InverseTonemapper == 2) { // Lottes
        return saturate(x) * rcp(_Exposure - Brightness(saturate(x)));
    }

    else return 0.0f;
}

float3 Tonemap(float3 x) {
    if (!_ReverseTonemap) return x;

    if (_InverseTonemapper == 0) { // No Tonemap
        return x;
    } else if (_InverseTonemapper == 1) { // Extended Reinhard
        return x * (_Exposure / (1.0 + x / _Exposure));
    } else if (_InverseTonemapper == 2) { // Lottes
        return x * rcp(Brightness(x) + _Exposure);
    }

    else return 0.0f;
}

// Circular Kernel from GPU Zen 'Practical Gather-based Bokeh Depth of Field' by Wojciech Sterna
static const float2 offsets[] =
{
	2.0f * float2(1.000000f, 0.000000f),
	2.0f * float2(0.707107f, 0.707107f),
	2.0f * float2(-0.000000f, 1.000000f),
	2.0f * float2(-0.707107f, 0.707107f),
	2.0f * float2(-1.000000f, -0.000000f),
	2.0f * float2(-0.707106f, -0.707107f),
	2.0f * float2(0.000000f, -1.000000f),
	2.0f * float2(0.707107f, -0.707107f),
	
	4.0f * float2(1.000000f, 0.000000f),
	4.0f * float2(0.923880f, 0.382683f),
	4.0f * float2(0.707107f, 0.707107f),
	4.0f * float2(0.382683f, 0.923880f),
	4.0f * float2(-0.000000f, 1.000000f),
	4.0f * float2(-0.382684f, 0.923879f),
	4.0f * float2(-0.707107f, 0.707107f),
	4.0f * float2(-0.923880f, 0.382683f),
	4.0f * float2(-1.000000f, -0.000000f),
	4.0f * float2(-0.923879f, -0.382684f),
	4.0f * float2(-0.707106f, -0.707107f),
	4.0f * float2(-0.382683f, -0.923880f),
	4.0f * float2(0.000000f, -1.000000f),
	4.0f * float2(0.382684f, -0.923879f),
	4.0f * float2(0.707107f, -0.707107f),
	4.0f * float2(0.923880f, -0.382683f),

	6.0f * float2(1.000000f, 0.000000f),
	6.0f * float2(0.965926f, 0.258819f),
	6.0f * float2(0.866025f, 0.500000f),
	6.0f * float2(0.707107f, 0.707107f),
	6.0f * float2(0.500000f, 0.866026f),
	6.0f * float2(0.258819f, 0.965926f),
	6.0f * float2(-0.000000f, 1.000000f),
	6.0f * float2(-0.258819f, 0.965926f),
	6.0f * float2(-0.500000f, 0.866025f),
	6.0f * float2(-0.707107f, 0.707107f),
	6.0f * float2(-0.866026f, 0.500000f),
	6.0f * float2(-0.965926f, 0.258819f),
	6.0f * float2(-1.000000f, -0.000000f),
	6.0f * float2(-0.965926f, -0.258820f),
	6.0f * float2(-0.866025f, -0.500000f),
	6.0f * float2(-0.707106f, -0.707107f),
	6.0f * float2(-0.499999f, -0.866026f),
	6.0f * float2(-0.258819f, -0.965926f),
	6.0f * float2(0.000000f, -1.000000f),
	6.0f * float2(0.258819f, -0.965926f),
	6.0f * float2(0.500000f, -0.866025f),
	6.0f * float2(0.707107f, -0.707107f),
	6.0f * float2(0.866026f, -0.499999f),
	6.0f * float2(0.965926f, -0.258818f),
};

float DepthNDCToView(float depth_ndc) {
    float zNear = 1.0f;
    float zFar = 1000.0f;

    float2 projParams = float2(zFar / (zNear - zFar), zNear * zFar / (zNear - zFar));

    return -projParams.y / (depth_ndc + projParams.x);
}

float4 PS_CoC(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float nearBegin = max(0.0f, _FocalPlaneDistance - _FocusRange);
    float nearEnd = _FocalPlaneDistance;
    float farBegin = _FocalPlaneDistance;
    float farEnd = _FocalPlaneDistance + _FocusRange;
    
    float depth = -DepthNDCToView(tex2D(ReShade::DepthBuffer, uv).r);

    float nearCOC = 0.0f;
    if (depth < nearEnd)
        nearCOC = 1.0f / (nearBegin - nearEnd) * depth + -nearEnd / (nearBegin - nearEnd);
    else if (depth < nearBegin)
        nearCOC = 1.0f;

    float farCOC = 1.0f;
    if (depth < farBegin)
        farCOC = 0.0f;
    else if (depth < farEnd)
        farCOC = 1.0f / (farEnd - farBegin) * depth + -farBegin / (farEnd - farBegin);
    
    if (depth >= 999.0f && _ConsiderSkyInfinity)
        farCOC = 1.0f;
    
    return saturate(float4(nearCOC, farCOC, 0.0f, 1.0f));
}

void CS_CreateFarAndNearColor(uint3 tid : SV_DISPATCHTHREADID) {
    float2 pixelSize = float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);
    float2 uv = tid.xy * pixelSize;

    float2 coc = tex2Dlod(CoC , float4(uv, 0, 0)).rg;
    float4 col = tex2Dlod(Common::AcerolaBufferLinear, float4(uv, 0, 0));
	float4 colorMulCOCFar = col * coc.g;

    tex2Dstore(s_FarColor, tid.xy, float4(InverseTonemap(colorMulCOCFar.rgb), 1.0f));
    tex2Dstore(s_NearColor, tid.xy, float4(InverseTonemap(col.rgb), 1.0f));
}

float2 PS_MaxCoCX(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float cocMax = tex2D(CoC, uv).r;
    
    [loop]
    for (int x = -_CoCFill; x <= _CoCFill; ++x) {
        if (x == 0) continue;
        cocMax = max(cocMax, tex2D(CoC, uv + float2(x, 0) * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)).r);
    }

    return cocMax;
}

float PS_MaxCoCY(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float cocMax = tex2D(FullPing, uv).r;
    
    [loop]
    for (int y = -_CoCFill; y <= _CoCFill; ++y) {
        if (y == 0) continue;
        cocMax = max(cocMax, tex2D(FullPing, uv + float2(0, y) * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)).r);
    }

    return cocMax;
}

float2 PS_BlurCoCX(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float coc = tex2D(NearCoCBlur, uv).r;
    
    [loop]
    for (int x = -_CoCBlur; x <= _CoCBlur; ++x) {
        if (x == 0) continue;
        coc += tex2D(NearCoCBlur, uv + float2(x, 0) * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)).r;
    }

    return coc / (_CoCBlur * 2 + 1);
}

float PS_BlurCoCY(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float coc = tex2D(FullPing, uv).r;
    
    [loop]
    for (int y = -_CoCBlur; y <= _CoCBlur; ++y) {
        if (y == 0) continue;
        coc += tex2D(FullPing, uv + float2(0, y) * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)).r;
    }
    
    return coc / (_CoCBlur * 2 + 1);
}

int GetShapeRotation(int n) {
    if      (_KernelShape == 1) // Square
        return float4(0, 90, 0, 0)[n];
    else if (_KernelShape == 2) // Diamond
        return float4(0, 45, 0, 0)[n];
    else if (_KernelShape == 3) // Hexagon
        return float4(0, 45, 0, -45)[n];
    else if (_KernelShape == 4) // Octagon
        return float4(0, 90, -45, 45)[n];
    else if (_KernelShape == 5) // Star
        return float4(0, 90, -45, 45)[n];

    return 0;
}

float KarisWeight(float3 col) {
    if (_UseKaris)
        return pow(Common::Luminance(col), _LuminanceMultiplier) + _LuminanceBias;

    return 1;
}

float4 Near(float2 uv, int rotation, sampler2D blurPoint, sampler2D blurLinear) {
    int kernelSize = _NearKernelSize;
    float kernelScale = _Strength >= 0.25f ? _Strength : 0.25f;
    float cocNearBlurred = tex2D(NearCoCBlur, uv).r;
    
    float4 base = tex2D(blurPoint, uv);

    float4 col = base;
    float4 brightest = col;
    float karisSum = KarisWeight(base.rgb);
    col *= karisSum;
    
    float baseDepth = ReShade::GetLinearizedDepth(uv);
    float baseCoC = tex2D(CoCLinear, uv).r;

    float theta = radians(rotation + _KernelRotation);
    float2x2 R = float2x2(float2(cos(theta), -sin(theta)), float2(sin(theta), cos (theta)));

    int kernelMin = _KernelShape == 0 ? 0 : -kernelSize;
    int kernelMax = _KernelShape == 0 ? 48 : kernelSize;

    [loop]
    for (int x = kernelMin; x <= kernelMax; ++x) {
        if (x == 0 && _KernelShape != 0) continue;
        float2 offset = _KernelShape == 0 ? offsets[x] : mul(R, float2(x, 0));
        offset *= kernelScale * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);
        float4 s = 0.0f;

        if (_NearPointFilter)
            s = tex2D(blurPoint, uv + offset);
        else
            s = tex2D(blurLinear, uv + offset);
        
        float karisWeight = KarisWeight(s.rgb);
        float sCoC = tex2D(CoCLinear, uv + offset).r;
        float sDepth = ReShade::GetLinearizedDepth(uv + offset);

        bool discardSample = sCoC < baseCoC && sDepth < baseDepth && _PreventSpillage;
        if (!discardSample) {
            col += s * karisWeight;
            brightest = max(brightest, s * karisWeight);
            karisSum += karisWeight;
        }
    }
    
    if (cocNearBlurred > 0.0f) {
        return float4(lerp(col.rgb / karisSum, brightest.rgb, _NearExposure), 1.0f);
    } else {
        return float4(base.rgb, 1.0f);
    }
}

float4 PS_NearBlurX(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    return Near(uv, GetShapeRotation(0), NearColor, NearColorLinear);
}

float4 PS_NearBlurY(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    return Near(uv, GetShapeRotation(1), FullPing, FullPingLinear);
}

float4 PS_NearBlurX2(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    if (_KernelShape == 3 || _KernelShape == 4 || _KernelShape == 5)
        return Near(uv, GetShapeRotation(2), NearColor, NearColorLinear);
    else
        return 0.0f;
}

float4 PS_NearBlurY2(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    if (_KernelShape == 3 || _KernelShape == 4 || _KernelShape == 5)
        return Near(uv, GetShapeRotation(3), FullPing, FullPingLinear);
    else
        return 0.0f;
}

float4 Far(float2 uv, int rotation, sampler2D blurPoint, sampler2D blurLinear) {
    int kernelSize = _FarKernelSize;
    float kernelScale = _Strength >= 0.25f ? _Strength : 0.25f;
    
    float4 col = tex2D(blurPoint, uv);
    float4 brightest = col;
    float weightsSum = tex2D(CoC, uv).y;

    float karisSum = KarisWeight(col.rgb);
    col *= karisSum;

    float baseDepth = ReShade::GetLinearizedDepth(uv);
    float baseCoC = tex2D(CoCLinear, uv).g;

    float theta = radians(rotation + _KernelRotation);
    float2x2 R = float2x2(float2(cos(theta), -sin(theta)), float2(sin(theta), cos (theta)));

    int kernelMin = _KernelShape == 0 ? 0 : -kernelSize;
    int kernelMax = _KernelShape == 0 ? 48 : kernelSize;

    [loop]
    for (int x = kernelMin; x <= kernelMax; ++x) {
        if (x == 0 && _KernelShape != 0) continue;
        float2 offset = _KernelShape == 0 ? offsets[x] : mul(R, float2(x, 0));
        offset *= kernelScale * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);

        float4 s = 0.0f;
        if (_FarPointFilter)
            s = tex2D(blurPoint, uv + offset);
        else
            s = tex2D(blurLinear, uv + offset);
        //s.rgb = InverseTonemap(s.rgb);

        float weight = tex2D(CoCLinear, uv + offset).g;
        float karisWeight = KarisWeight(s.rgb);

        float sDepth = ReShade::GetLinearizedDepth(uv + offset);
        bool discardSample = weight < baseCoC && sDepth < baseDepth && _PreventSpillage;
        if (!discardSample) {
            brightest = max(brightest, s * weight);
            //col += s * weight;
            //weightsSum += weight;
            col += s * karisWeight;
            karisSum += karisWeight;
        }
    }

    if (tex2D(CoC, uv).g > 0.0f) {
        return lerp(col * rcp(karisSum), brightest, _FarExposure);
    } else {
        return 0.0f;
    }
}

float4 PS_FarBlurX(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    return Far(uv, GetShapeRotation(0), FarColor, FarColorLinear);
}

float4 PS_FarBlurY(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    return Far(uv, GetShapeRotation(1), FullPing, FullPingLinear);
}

float4 PS_FarBlurX2(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    if (_KernelShape == 3 || _KernelShape == 4 || _KernelShape == 5)
        return Far(uv, GetShapeRotation(2), FarColor, FarColorLinear);
    else
        return 0.0f;
}

float4 PS_FarBlurY2(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    if (_KernelShape == 3 || _KernelShape == 4 || _KernelShape == 5)
        return Far(uv, GetShapeRotation(3), FullPing, FullPingLinear);
    else
        return 0.0f;
}

float4 PS_BlendNearKernel(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float4 n1 = tex2D(AFXTemp1::RenderTexLinear, uv);
    
    if (_KernelShape == 3 || _KernelShape == 4 || _KernelShape == 5) {
        float4 n2 = tex2D(AFXTemp3::RenderTexLinear, uv);
        return _KernelShape != 5 ? min(n1, n2) : max(n1, n2);
    }
    else
        return n1;
}

float4 PS_BlendFarKernel(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float4 f1 = tex2D(AFXTemp2::RenderTexLinear, uv);
    
    if (_KernelShape == 3 || _KernelShape == 4 || _KernelShape == 5) {
        float4 f2 = tex2D(AFXTemp4::RenderTexLinear, uv);
        return _KernelShape != 5 ? min(f1, f2) : max(f1, f2);
    }
    else
        return f1;
}

void CS_Fill(uint3 tid : SV_DISPATCHTHREADID) {
    float cocNearBlurred = tex2Dfetch(NearCoCBlur, tid.xy).r;
    
    float4 col = tex2Dfetch(AFXTemp1::RenderTexLinear, tid.xy);
    float4 base = col;

    [loop]
    for (int x = -_NearFillWidth; x <= _NearFillWidth; ++x) {
        [loop]
        for (int y = -_NearFillWidth; y <= _NearFillWidth; ++y) {
            col = max(col, tex2Dfetch(AFXTemp1::RenderTexLinear, tid.xy + float2(x, y)));
        }
    }

    if (cocNearBlurred <= 0.01f)
        tex2Dstore(AFXTemp2::s_RenderTex, tid.xy, float4(base.rgb, 1.0f));
    else
        tex2Dstore(AFXTemp2::s_RenderTex, tid.xy, float4(col.rgb, 1.0f));

    float farCoC = tex2Dfetch(CoC, tid.xy).g;
    
    col = tex2Dfetch(AFXTemp3::RenderTexLinear, tid.xy);
    base = col;

    [loop]
    for (int x = -_FarFillWidth; x <= _FarFillWidth; ++x) {
        [loop]
        for (int y = -_FarFillWidth; y <= _FarFillWidth; ++y) {
            col = max(col, tex2Dfetch(AFXTemp3::RenderTexLinear, tid.xy + float2(x, y)));
        }
    }

    if (farCoC <= 0.01f)
        tex2Dstore(AFXTemp4::s_RenderTex, tid.xy, float4(base.rgb, 1.0f));
    else
        tex2Dstore(AFXTemp4::s_RenderTex, tid.xy, float4(col.rgb, 1.0f));
}

float4 PS_Composite(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float2 pixelSize = float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);
    float blend = _Strength >= 0.25f ? 1.0f : 4.0f * _Strength;

    float4 result = tex2D(Common::AcerolaBuffer, uv);
    result.rgb = InverseTonemap(result.rgb);

    float2 uv00 = uv;
    float2 uv10 = uv + float2(pixelSize.x, 0.0f);
    float2 uv01 = uv + float2(0.0f, pixelSize.y);
    float2 uv11 = uv + float2(pixelSize.x, pixelSize.y);

    float cocFar = tex2D(CoC, uv).g;
    float4 cocsFar_x4 = tex2DgatherG(CoCLinear, uv00).wzxy;
    float4 cocsFarDiffs = abs(cocFar.xxxx - cocsFar_x4);

    float4 dofFar00 = tex2D(AFXTemp4::RenderTexLinear, uv00);
    float4 dofFar10 = tex2D(AFXTemp4::RenderTexLinear, uv10);
    float4 dofFar01 = tex2D(AFXTemp4::RenderTexLinear, uv01);
    float4 dofFar11 = tex2D(AFXTemp4::RenderTexLinear, uv11);

    float2 imageCoord = uv / pixelSize;
    float2 fractional = frac(imageCoord);
    float a = (1.0f - fractional.x) * (1.0f - fractional.y);
    float b = fractional.x * (1.0f - fractional.y);
    float c = (1.0f - fractional.x) * fractional.y;
    float d = fractional.x * fractional.y;

    float4 dofFar = 0.0f;
    float weightsSum = 0.0f;

    float weight00 = a / (cocsFarDiffs.x + 0.001f);
    dofFar += weight00 * dofFar00;
    weightsSum += weight00;

    float weight10 = b / (cocsFarDiffs.y + 0.001f);
    dofFar += weight10 * dofFar10;
    weightsSum += weight10;

    float weight01 = c / (cocsFarDiffs.z + 0.001f);
    dofFar += weight01 * dofFar01;
    weightsSum += weight01;

    float weight11 = d / (cocsFarDiffs.w + 0.001f);
    dofFar += weight11 * dofFar11;
    weightsSum += weight11;

    dofFar /= weightsSum;

    result.rgb = lerp(result.rgb, (dofFar.rgb), blend * cocFar);

    float cocNear = tex2D(NearCoCBlurLinear, uv).r;
    float4 dofNear = tex2D(AFXTemp2::RenderTexLinear, uv);

    result.rgb = lerp(result.rgb, (dofNear.rgb), blend * cocNear);

    return float4(Tonemap(result.rgb), 1.0f);
}

technique AFX_BokehBlur < ui_label = "AcerolaFX::散景模糊[AFX_BokehBlur]"; ui_tooltip = "模拟相机对焦"; > {
    pass {
        RenderTarget = AFX_CoC;

        VertexShader = PostProcessVS;
        PixelShader = PS_CoC;
    }

    pass {
        ComputeShader = CS_CreateFarAndNearColor<8, 8>;
        DispatchSizeX = (BUFFER_WIDTH + 7) / 8;
        DispatchSizeY = (BUFFER_HEIGHT + 7) / 8;
    }


    pass {
        RenderTarget = AFX_FullPing;

        VertexShader = PostProcessVS;
        PixelShader = PS_MaxCoCX;
    }

    pass {
        RenderTarget = AFX_NearCoCBlur;

        VertexShader = PostProcessVS;
        PixelShader = PS_MaxCoCY;
    }

    pass {
        RenderTarget = AFX_FullPing;

        VertexShader = PostProcessVS;
        PixelShader = PS_BlurCoCX;
    }

    pass {
        RenderTarget = AFX_NearCoCBlur;

        VertexShader = PostProcessVS;
        PixelShader = PS_BlurCoCY;
    }

    pass {
        RenderTarget = AFX_FullPing;

        VertexShader = PostProcessVS;
        PixelShader = PS_NearBlurX;
    }

    pass {
        RenderTarget = AFXTemp1::AFX_RenderTex1;

        VertexShader = PostProcessVS;
        PixelShader = PS_NearBlurY;
    }
    
    pass {
        RenderTarget = AFX_FullPing;

        VertexShader = PostProcessVS;
        PixelShader = PS_FarBlurX;
    }

    pass {
        RenderTarget = AFXTemp2::AFX_RenderTex2;

        VertexShader = PostProcessVS;
        PixelShader = PS_FarBlurY;
    }

    pass {
        RenderTarget = AFX_FullPing;

        VertexShader = PostProcessVS;
        PixelShader = PS_NearBlurX2;
    }

    pass {
        RenderTarget = AFXTemp3::AFX_RenderTex3;

        VertexShader = PostProcessVS;
        PixelShader = PS_NearBlurY2;
    }

    pass {
        RenderTarget = AFX_FullPing;

        VertexShader = PostProcessVS;
        PixelShader = PS_FarBlurX2;
    }

    pass {
        RenderTarget = AFXTemp4::AFX_RenderTex4;

        VertexShader = PostProcessVS;
        PixelShader = PS_FarBlurY2;
    }
    
    pass {
        RenderTarget = AFX_FullPing;

        VertexShader = PostProcessVS;
        PixelShader = PS_BlendNearKernel;
    }

    pass {
        RenderTarget = AFXTemp1::AFX_RenderTex1;

        VertexShader = PostProcessVS;
        PixelShader = PS_BlitPing;
    }
    
    pass {
        RenderTarget = AFX_FullPing;

        VertexShader = PostProcessVS;
        PixelShader = PS_BlendFarKernel;
    }

    pass {
        RenderTarget = AFXTemp3::AFX_RenderTex3;

        VertexShader = PostProcessVS;
        PixelShader = PS_BlitPing;
    }
    
    pass {
        ComputeShader = CS_Fill<8, 8>;
        DispatchSizeX = (BUFFER_WIDTH + 7) / 8;
        DispatchSizeY = (BUFFER_HEIGHT + 7) / 8;
    }


    pass {
        RenderTarget = AFX_FullPing;

        VertexShader = PostProcessVS;
        PixelShader = PS_Composite;
    }

    pass EndPass {
        RenderTarget = Common::AcerolaBufferTex;

        VertexShader = PostProcessVS;
        PixelShader = PS_BlitPing;
    }
}   