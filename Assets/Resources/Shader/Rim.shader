// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Rim"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
        _RimColor("Rim Color",Color) = (1,1,1,1)
        _RimScale("Rim Scale",Range(0,1)) = 0.2
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
            
            #include "Lighting.cginc"
            //#include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;                
                float4 vertex : SV_POSITION;
                float3 position:TEXCOORD1;
                float3 wnormal:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _RimColor;
            fixed _RimScale;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);               
                o.wnormal = UnityObjectToWorldNormal(v.normal);
                o.position = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 normalDir = normalize(i.wnormal);
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.position));
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.position);

                fixed4 col = tex2D(_MainTex, i.uv);
                float halfLamb = dot(normalDir, lightDir) * 0.5 + 0.5;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * col;
                float3 rim = pow((1 - dot(normalDir, viewDir)), 1 / _RimScale) * _RimColor;

                float3 diffuse = _LightColor0.rgb * halfLamb * col * _Color;
                fixed3 color = diffuse + ambient + rim;
                
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
