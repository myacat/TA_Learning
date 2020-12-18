Shader "Unlit/Distort"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DistortMap("Distort Map",2D) = "white"{}
        _DistortScale("Distort Scale",Range(0,0.2)) = 0.1
        _DistortSpeed("Distort Speed",Vector) = (1,1,1,1)
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
            sampler2D _DistortMap;
            float4 _DistortMap_ST;
            fixed4 _DistortSpeed;
            fixed _DistortScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {

                float2 uv = i.uv;
                
                float distort = tex2D(_DistortMap, uv + _Time.x * _DistortSpeed).r;
                distort = lerp(-distort, distort, saturate(distort)) * _DistortScale;
                uv += distort ;
                float4 col = tex2D(_MainTex,uv);
                //col *= distort;
                return col;
            }
            ENDCG
        }
    }
}
