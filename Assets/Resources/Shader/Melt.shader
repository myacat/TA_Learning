Shader "Unlit/Dissolve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BurnMap("BumpMap",2D) = "white"{}
        _BurnScale("Mask Scale",Range(0,1)) = 1
        _LineWidth("LineWidth",Range(0,1)) = 0.3
        _BurnColor("Bump Color",Color) = (1,1,1,1)
        _AddBurnColor("Add Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        LOD 100

        Pass
        {
            
            Tags {"LightMode"="ForwardBase" }
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include"Lighting.cginc"
            #include"AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uvMain : TEXCOORD0;
                float2 uvBurn:TEXCOORD1;
                float3 position:TEXCOORD2;
                float3 normalDir:TEXCOORD3;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BurnMap;
            float4 _BurnMap_ST;
            fixed _BurnScale;
            fixed4 _BurnColor;
            fixed4 _AddBurnColor;
            fixed _LineWidth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvBurn = TRANSFORM_TEX(v.uv, _BurnMap);
                o.position = UnityObjectToWorldDir(v.vertex);
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                fixed4 MainColor = tex2D(_MainTex, i.uvMain);
                fixed BurnColor = tex2D(_BurnMap, i.uvBurn).r;
                float ClipMount = BurnColor - _BurnScale;                
                MainColor.a = smoothstep(0, _LineWidth, ClipMount+_LineWidth-0.1);
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.position));
                float3 normalDir = normalize(i.normalDir);
                float halflambert = dot(lightDir, normalDir) * 0.5 + 0.5;
                float3 diffuse = _LightColor0.rgb *MainColor* halflambert;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * MainColor;
                fixed3 color = diffuse + ambient;

                
                clip(ClipMount);
                
                float lerpscale = smoothstep(0,_LineWidth/3,abs(ClipMount));
                fixed3 burncolor = lerp(_BurnColor, _AddBurnColor, lerpscale);

                
                color = lerp(burncolor, color, abs(lerpscale));

                return fixed4(color, MainColor.a);
            }
            ENDCG
        }
    }
}
