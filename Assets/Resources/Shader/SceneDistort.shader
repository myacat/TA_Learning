Shader "Unlit/SceneDistort"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DistortScale("Distort Scale",Range(0,5)) = 1
        _DisTimeFact("Time Fact",Range(0,5)) = 1
        _DistortSpeed("Distort Speed",Vector) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        LOD 100
            
        GrabPass
        {
            //抓屏贴图的名称，抓屏的贴图可以通过这张贴图来获取，而且每一帧不管有多个物体使用了该shader，只会有一个进行抓屏操作
            //如果此处为空，则默认抓屏到_GrabTexture中
            "_GrabTempTex"
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 grabPos:TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _GrabTempTex;
            float4 _GrabTempTex_ST;
            fixed _DistortScale;
            fixed _DisTimeFact;
            fixed4 _DistortSpeed;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                o.grabPos = ComputeGrabScreenPos(o.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                
            float4 offset = tex2D(_MainTex, i.uv + _Time.x * _DisTimeFact * _DistortSpeed);
            i.grabPos.xy -= offset.xy * _DistortScale - _DistortScale/2;
            float4 color = tex2Dproj(_GrabTempTex, i.grabPos);
                return color;
            }
            ENDCG
        }
    }
}
