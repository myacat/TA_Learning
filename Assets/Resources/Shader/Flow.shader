Shader "Unlit/Flow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseMap("Noise Map",2D) = "white"{}
        _NoiseSpeed("Noise Speed",Vector) = (1,1,1,1)
        _NoiseScale("Noise Scale",Range(0,1)) = 0.5
            _NoiseColor("NoiseColor",Color)=(1,1,1,1)
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
                float2 noiseUV:TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiseMap;
            float4 _NoiseMap_ST;
            float4 _NoiseSpeed;
            fixed _NoiseScale;
            fixed4 _NoiseColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.noiseUV = TRANSFORM_TEX(v.uv, _NoiseMap);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 noise = tex2D(_NoiseMap,i.noiseUV + _Time.x * _NoiseSpeed);
                fixed4 col = tex2D(_MainTex, i.uv);
                col += noise * _NoiseScale * _NoiseColor;
                return col;
            }
            ENDCG
        }
    }
}
