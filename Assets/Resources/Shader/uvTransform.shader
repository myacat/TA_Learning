Shader "Unlit/uvTransform"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    //Toggle float属性 值为0关/1开 
    //可以使用shader_feature  也可以直接使用#if
    [Toggle] _ScaleOnCenter("Scale On Center",Float) = 0

        _Uscroll("Uscroll",Range(-1,1)) = 0.2
        _Vscroll("Vscroll",Range(-1,1)) = 0.2
        _Angle("Angle",Range(0,360)) = 0
        //生成下拉列表
        [KeywordEnum(Default,Repeat,Clamp,Mirror,MirrorOnce)]_WrapMode("WrapMode",Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            

            #include "UnityCG.cginc"
            #pragma shader_feature  _SCALEONCENTER_ON
            #pragma shader_feature _WRAPMODE_DEFAULT _WRAPMODE_REPEAT _WRAPMODE_CLAMP _WRAPMODE_MIRROR _WRAPMODE_MIRRORONCE

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;                
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _Uscroll;
            fixed _Vscroll;
            fixed _Angle;

            //旋转
            float2 Rotation(float2 scrUV,fixed angle) 
            {
                //转换为弧度 cos（弧度）
                angle /= 57.3;
                float2x2 rotMatrix;
                rotMatrix[0] = float2(cos(angle), -sin(angle));
                rotMatrix[1] = float2(sin(angle), cos(angle));
                return mul(rotMatrix, scrUV);
            }

            //uv变化
            float2 Transform(float2 scrUV, half4 argST,fixed angle) 
            {
                
                #if _SCALEONCENTER_ON
                    scrUV -= 0.5;           
                #endif           
                
                scrUV = scrUV * argST.xy + argST.zw;
                scrUV = Rotation(scrUV, angle);

                #if _SCALEONCENTER_ON
                    scrUV += 0.5;
                #endif 

                //uv动画
                scrUV.x += _Uscroll * _Time.z;
                scrUV.y += _Vscroll * _Time.z;
                return scrUV;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = Transform(v.uv, _MainTex_ST,_Angle);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv;

                #if _WRAPMODE_CLAMP
                    uv = saturate(i.uv);
                #elif _WRAPMODE_REPEAT
                    uv = frac(i.uv);
                #elif _WRAPMODE_MIRROR
            //frac 返回小数 abs返回绝对值
                    uv = frac(abs(i.uv));
                #elif _WRAPMODE_MIRRORONCE
                    uv = saturate(abs(i.uv));
                #elif _WRAPMODE_DEFAULT
                    uv = i.uv;
                #endif

                fixed4 col = tex2D(_MainTex, uv);
                
                return col;
            }
            ENDCG
        }
    }
}
