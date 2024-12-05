Shader "Custom/caustic"
{
    Properties
    {
        _MainTex("Base texture", 2D) = "white" {}
        _CausticTexture("caustic texture", 2D) = "white" {}
        _NoiseTexture("noise texture", 2D) = "white" {}
        _CausticStrength("caustic strength", Range(0,2)) = 1.0
        _CausticSpeed("caustic speed", Range(0.1,5.0)) = 1.0
    }

    SubShader
    {
        Tags {"Queue" = "Transparent" "RenderType"="Transparent"}
        LOD 200

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
            sampler2D _CausticTexture;
            sampler2D _NoiseTexture;
            float _CausticStrength;
            float _CausticSpeed;

            //vertex shader
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            //fragment shader
            fixed4 frag (v2f i) : SV_Target
            {
                //object base texture
                fixed4 baseColor = tex2D(_MainTex, i.uv);

                //noise texture for mimicking distortion
                float2 distortion = tex2D(_NoiseTexture, i.uv * 5.0).rg * 0.1;

                //change caustic texture uv coords
                float2 caustic_uv = i.uv + distortion + float2(_Time.y * _CausticSpeed, _Time.y * _CausticSpeed * 0.5);
                fixed4 caustic_tex = tex2D(_CausticTexture, caustic_uv);
                //change caustic color
                fixed4 caustic_color = caustic_tex * float4(0.5, 0.7, 1.0, 1.0);

                fixed4 output = baseColor + caustic_color * _CausticStrength;

                return output;
            }
        ENDCG
        }
    }
    FallBack "Diffuse"
}