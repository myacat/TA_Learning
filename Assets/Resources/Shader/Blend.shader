Shader "Unlit/Blend"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlendLerp("BlendLerp",Float) = 1
        _Interim("Interim",Range(0,0.7)) = 0.3
        _LineColor("LineColor",Color) = (1,1,1,1)
            _LineScale("LineScale",Range(0,0.5)) = 0.2
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" "Queue" = "Transparent" }
            LOD 100

            /*Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                float4 _LineColor;
    fixed _LineScale;
                struct a2v
                {
                    float4 vertex:POSITION;

                };
                struct v2f
                {
                    float4 vertex:SV_POSITION;
                };
                v2f vert(a2v v) 
                {
                    v2f o;
                    o.vertex.xyz=
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    return o;
                }
                fixed3 frag(v2f o) :SV_TARGET
                {
                    return _LineColor;
                }
            ENDCG
        }*/
        Pass
        {
                    Blend SrcAlpha OneMinusSrcAlpha
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
                float3 position : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _BlendLerp;
            float _Interim;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.position = UnityObjectToWorldDir(v.vertex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                if (i.position.y < _BlendLerp)
                {
                    
                    col.a = lerp(1, 0, saturate(_BlendLerp - i.position.y + _Interim ));
                }
                
                return col;
            }
            ENDCG
        }
    }
}
