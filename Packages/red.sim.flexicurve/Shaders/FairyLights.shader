// Made with Amplify Shader Editor v1.9.9.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FlexiCurve/Fairy Lights"
{
	Properties
	{
		[Header(Wire)] _WireColor( "Wire Color", Color ) = ( 1, 1, 1, 0 )
		_WireAlbedo( "Wire Albedo", 2D ) = "white" {}
		[NoScaleOffset] _WireMAOES( "Wire MAOES", 2D ) = "white" {}
		[NoScaleOffset] _WireNormal( "Wire Normal", 2D ) = "bump" {}
		_WireMetallic( "Wire Metallic", Range( 0, 1 ) ) = 0
		_WireSmoothness( "Wire Smoothness", Range( 0, 1 ) ) = 1
		_WireAO( "Wire AO", Range( 0, 1 ) ) = 0.2836054
		_WireNormalWeight( "Wire Normal Weight", Float ) = 1
		[HDR] _WireEmissionColor( "Wire Emission Color", Color ) = ( 0, 0, 0, 1 )
		[HDR][NoScaleOffset] _EmissionMap( "Wire Emission Map", 2D ) = "white" {}
		[Header(Elements)] _ElementColor( "Element Color", Color ) = ( 1, 1, 1, 0 )
		_ElementAlbedo( "Element Albedo", 2D ) = "white" {}
		[NoScaleOffset] _ElementWireMAOES( "Element Wire MAOES", 2D ) = "white" {}
		[NoScaleOffset] _ElementNormal( "Element Normal", 2D ) = "bump" {}
		_ElementMetallic( "Element Metallic", Range( 0, 1 ) ) = 0
		_ElementSmoothness( "Element Smoothness", Range( 0, 1 ) ) = 1
		_ElementAO( "Element AO", Range( 0, 1 ) ) = 1
		_ElementNormalWeight1( "Element Normal Weight", Float ) = 1
		[HDR] _ElementEmissionColor( "Element Emission Color", Color ) = ( 0, 0, 0, 1 )
		[HDR][NoScaleOffset] _EmissionMap1( "Element Emission Map", 2D ) = "white" {}
		[Header(Scrolling Effect)] _ScrollingColor( "Scrolling Color", Color ) = ( 1, 1, 1, 1 )
		[NoScaleOffset] _ScrollingMap( "Scrolling Map", 2D ) = "white" {}
		_ScrollingBrightness( "Scrolling Brightness", Float ) = 1
		_Scale( "Scrolling Scale", Float ) = 1
		_Speed( "Scrolling Speed", Float ) = 2
		_ScrollingHueShiftSpeed( "Scrolling Hue Shift Speed", Float ) = 0
		[Header(Other)][Toggle( _LIGHTVOLUMES_ON )] _LightVolumes( "Enable Light Volumes", Float ) = 1
		_LightVolumesBias( "Light Volumes Bias", Float ) = 0
		[Toggle( _SPECULARS_ON )] _Speculars( "Speculars", Float ) = 1
		[Toggle( _DOMINANTDIRSPECULARS_ON )] _DominantDirSpeculars( "Dominant Dir Speculars", Float ) = 0
		[Enum(UnityEngine.Rendering.CullMode)] _Culling( "Culling", Float ) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull [_Culling]
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "LightVolumes.cginc"
		#include "UnityStandardBRDF.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 5.0
		#pragma shader_feature_local _SPECULARS_ON
		#pragma shader_feature_local _LIGHTVOLUMES_ON
		#pragma shader_feature_local _DOMINANTDIRSPECULARS_ON
		#define ASE_VERSION 19905
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float3 uv_texcoord;
			uint ASEIsFrontFace : SV_IsFrontFace;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
		};

		uniform float _Culling;
		uniform sampler2D _WireNormal;
		uniform sampler2D _WireAlbedo;
		uniform float4 _WireAlbedo_ST;
		uniform float _WireNormalWeight;
		uniform sampler2D _ElementNormal;
		uniform sampler2D _ElementAlbedo;
		uniform float4 _ElementAlbedo_ST;
		uniform float _ElementNormalWeight1;
		uniform float4 _WireColor;
		uniform float4 _ElementColor;
		uniform float _ScrollingHueShiftSpeed;
		uniform sampler2D _ScrollingMap;
		uniform float _Scale;
		uniform float _Speed;
		uniform float4 _ScrollingColor;
		uniform float _ScrollingBrightness;
		uniform sampler2D _WireMAOES;
		uniform float _WireMetallic;
		uniform float _WireSmoothness;
		uniform float _WireAO;
		uniform sampler2D _ElementWireMAOES;
		uniform float _ElementMetallic;
		uniform float _ElementSmoothness;
		uniform float _ElementAO;
		uniform float4 _WireEmissionColor;
		uniform sampler2D _EmissionMap;
		uniform float4 _ElementEmissionColor;
		uniform sampler2D _EmissionMap1;
		uniform float _LightVolumesBias;


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 uvs_WireAlbedo = i.uv_texcoord;
			uvs_WireAlbedo.xy = i.uv_texcoord.xy * _WireAlbedo_ST.xy + _WireAlbedo_ST.zw;
			float3 uvs_ElementAlbedo = i.uv_texcoord;
			uvs_ElementAlbedo.xy = i.uv_texcoord.xy * _ElementAlbedo_ST.xy + _ElementAlbedo_ST.zw;
			float ElementMask495 = sign( i.uv_texcoord.z );
			float3 lerpResult512 = lerp( UnpackScaleNormal( tex2D( _WireNormal, uvs_WireAlbedo.xy ), _WireNormalWeight ) , UnpackScaleNormal( tex2D( _ElementNormal, uvs_ElementAlbedo.xy ), _ElementNormalWeight1 ) , ElementMask495);
			float3 switchResult510 = (((i.ASEIsFrontFace>0)?(lerpResult512):(( lerpResult512 * float3( 1,1,-1 ) ))));
			float3 Normal437 = switchResult510;
			o.Normal = Normal437;
			float2 uv_WireAlbedo = i.uv_texcoord * _WireAlbedo_ST.xy + _WireAlbedo_ST.zw;
			float2 uv_ElementAlbedo = i.uv_texcoord * _ElementAlbedo_ST.xy + _ElementAlbedo_ST.zw;
			float4 lerpResult504 = lerp( ( _WireColor * tex2D( _WireAlbedo, uv_WireAlbedo ) ) , ( _ElementColor * tex2D( _ElementAlbedo, uv_ElementAlbedo ) ) , ElementMask495);
			float3 Albedo337 = (lerpResult504).rgb;
			o.Albedo = Albedo337;
			float mulTime489 = _Time.y * _ScrollingHueShiftSpeed;
			float mulTime480 = _Time.y * -_Speed;
			float temp_output_481_0 = ( ( i.uv_texcoord.z * _Scale ) + mulTime480 );
			float2 appendResult482 = (float2(temp_output_481_0 , temp_output_481_0));
			float3 hsvTorgb488 = RGBToHSV( ( tex2D( _ScrollingMap, appendResult482 ) * _ScrollingColor * _ScrollingBrightness ).rgb );
			float3 hsvTorgb491 = HSVToRGB( float3(( mulTime489 + hsvTorgb488.x ),hsvTorgb488.y,hsvTorgb488.z) );
			float4 tex2DNode50 = tex2D( _WireMAOES, uvs_WireAlbedo.xy );
			float lerpResult57 = lerp( 1.0 , tex2DNode50.g , _WireAO);
			float4 appendResult520 = (float4(( tex2DNode50.r * _WireMetallic ) , ( tex2DNode50.a * _WireSmoothness ) , lerpResult57 , tex2DNode50.b));
			float4 tex2DNode519 = tex2D( _ElementWireMAOES, uvs_ElementAlbedo.xy );
			float lerpResult526 = lerp( 1.0 , tex2DNode519.g , _ElementAO);
			float4 appendResult527 = (float4(( tex2DNode519.r * _ElementMetallic ) , ( tex2DNode519.a * _ElementSmoothness ) , lerpResult526 , tex2DNode519.b));
			float4 lerpResult528 = lerp( appendResult520 , appendResult527 , ElementMask495);
			float4 break530 = lerpResult528;
			float Effects_Mask541 = break530.w;
			float3 Element_Emission496 = ( ElementMask495 * hsvTorgb491 * Effects_Mask541 );
			float3 lerpResult539 = lerp( ( _WireEmissionColor.rgb * tex2D( _EmissionMap, uvs_WireAlbedo.xy ).rgb ) , ( _ElementEmissionColor.rgb * tex2D( _EmissionMap1, i.uv_texcoord.xy ).rgb ) , ElementMask495);
			float3 normalizeResult349 = normalize( (WorldNormalVector( i , Normal437 )) );
			float3 World_Normal112 = normalizeResult349;
			float3 worldNormal2_g222 = World_Normal112;
			float3 appendResult427 = (float3(unity_SHAr.w , unity_SHAg.w , unity_SHAb.w));
			float localLightVolumeSH1_g3 = ( 0.0 );
			float3 ase_positionWS = i.worldPos;
			float3 temp_output_6_0_g3 = ase_positionWS;
			float3 worldPos1_g3 = temp_output_6_0_g3;
			float3 L01_g3 = float3( 0,0,0 );
			float3 L1r1_g3 = float3( 0,0,0 );
			float3 L1g1_g3 = float3( 0,0,0 );
			float3 L1b1_g3 = float3( 0,0,0 );
			float3 temp_output_470_0 = ( _LightVolumesBias * World_Normal112 );
			float3 temp_output_17_0_g3 = temp_output_470_0;
			float3 worldPosOffset1_g3 = temp_output_17_0_g3;
			LightVolumeSH( worldPos1_g3 , L01_g3 , L1r1_g3 , L1g1_g3 , L1b1_g3 , worldPosOffset1_g3 );
			float localLightVolumeAdditiveSH9_g4 = ( 0.0 );
			float3 temp_output_6_0_g4 = ase_positionWS;
			float3 worldPos9_g4 = temp_output_6_0_g4;
			float3 L09_g4 = float3( 0,0,0 );
			float3 L1r9_g4 = float3( 0,0,0 );
			float3 L1g9_g4 = float3( 0,0,0 );
			float3 L1b9_g4 = float3( 0,0,0 );
			float3 temp_output_17_0_g4 = temp_output_470_0;
			float3 worldPosOffset9_g4 = temp_output_17_0_g4;
			LightVolumeAdditiveSH( worldPos9_g4 , L09_g4 , L1r9_g4 , L1g9_g4 , L1b9_g4 , worldPosOffset9_g4 );
			#ifdef LIGHTMAP_ON
				float3 staticSwitch467 = L09_g4;
			#else
				float3 staticSwitch467 = L01_g3;
			#endif
			#ifdef _LIGHTVOLUMES_ON
				float3 staticSwitch431 = staticSwitch467;
			#else
				float3 staticSwitch431 = appendResult427;
			#endif
			float3 L098 = staticSwitch431;
			float3 L02_g222 = L098;
			#ifdef LIGHTMAP_ON
				float3 staticSwitch93 = L1r9_g4;
			#else
				float3 staticSwitch93 = L1r1_g3;
			#endif
			#ifdef _LIGHTVOLUMES_ON
				float3 staticSwitch461 = staticSwitch93;
			#else
				float3 staticSwitch461 = (unity_SHAr).xyz;
			#endif
			float3 L1r99 = staticSwitch461;
			float3 L1r2_g222 = L1r99;
			#ifdef LIGHTMAP_ON
				float3 staticSwitch94 = L1g9_g4;
			#else
				float3 staticSwitch94 = L1g1_g3;
			#endif
			#ifdef _LIGHTVOLUMES_ON
				float3 staticSwitch462 = staticSwitch94;
			#else
				float3 staticSwitch462 = (unity_SHAg).xyz;
			#endif
			float3 L1g100 = staticSwitch462;
			float3 L1g2_g222 = L1g100;
			#ifdef LIGHTMAP_ON
				float3 staticSwitch95 = L1b9_g4;
			#else
				float3 staticSwitch95 = L1b1_g3;
			#endif
			#ifdef _LIGHTVOLUMES_ON
				float3 staticSwitch463 = staticSwitch95;
			#else
				float3 staticSwitch463 = (unity_SHAb).xyz;
			#endif
			float3 L1b101 = staticSwitch463;
			float3 L1b2_g222 = L1b101;
			float3 localLightVolumeEvaluate2_g222 = LightVolumeEvaluate( worldNormal2_g222 , L02_g222 , L1r2_g222 , L1g2_g222 , L1b2_g222 );
			float Metallic334 = ( break530.x * break530.x );
			float3 temp_output_406_0 = ( localLightVolumeEvaluate2_g222 * Albedo337 * ( 1.0 - Metallic334 ) );
			float3 temp_output_138_0_g220 = Albedo337;
			float3 albedo157_g220 = temp_output_138_0_g220;
			float Smoothness109 = break530.y;
			float temp_output_3_0_g220 = Smoothness109;
			float smoothness157_g220 = temp_output_3_0_g220;
			float temp_output_137_0_g220 = Metallic334;
			float metallic157_g220 = temp_output_137_0_g220;
			float3 temp_output_2_0_g220 = World_Normal112;
			float3 worldNormal157_g220 = temp_output_2_0_g220;
			float3 ase_viewVectorWS = ( _WorldSpaceCameraPos.xyz - ase_positionWS );
			float3 ase_viewDirSafeWS = Unity_SafeNormalize( ase_viewVectorWS );
			float3 temp_output_9_0_g220 = ase_viewDirSafeWS;
			float3 viewDir157_g220 = temp_output_9_0_g220;
			float3 temp_output_65_0_g220 = L098;
			float3 L0157_g220 = temp_output_65_0_g220;
			float3 temp_output_1_0_g220 = L1r99;
			float3 L1r157_g220 = temp_output_1_0_g220;
			float3 temp_output_36_0_g220 = L1g100;
			float3 L1g157_g220 = temp_output_36_0_g220;
			float3 temp_output_37_0_g220 = L1b101;
			float3 L1b157_g220 = temp_output_37_0_g220;
			float3 localLightVolumeSpecular157_g220 = LightVolumeSpecular( albedo157_g220 , smoothness157_g220 , metallic157_g220 , worldNormal157_g220 , viewDir157_g220 , L0157_g220 , L1r157_g220 , L1g157_g220 , L1b157_g220 );
			float3 temp_output_138_0_g221 = Albedo337;
			float3 albedo158_g221 = temp_output_138_0_g221;
			float temp_output_3_0_g221 = Smoothness109;
			float smoothness158_g221 = temp_output_3_0_g221;
			float temp_output_137_0_g221 = Metallic334;
			float metallic158_g221 = temp_output_137_0_g221;
			float3 temp_output_2_0_g221 = World_Normal112;
			float3 worldNormal158_g221 = temp_output_2_0_g221;
			float3 temp_output_9_0_g221 = ase_viewDirSafeWS;
			float3 viewDir158_g221 = temp_output_9_0_g221;
			float3 temp_output_65_0_g221 = L098;
			float3 L0158_g221 = temp_output_65_0_g221;
			float3 temp_output_1_0_g221 = L1r99;
			float3 L1r158_g221 = temp_output_1_0_g221;
			float3 temp_output_36_0_g221 = L1g100;
			float3 L1g158_g221 = temp_output_36_0_g221;
			float3 temp_output_37_0_g221 = L1b101;
			float3 L1b158_g221 = temp_output_37_0_g221;
			float3 localLightVolumeSpecularDominant158_g221 = LightVolumeSpecularDominant( albedo158_g221 , smoothness158_g221 , metallic158_g221 , worldNormal158_g221 , viewDir158_g221 , L0158_g221 , L1r158_g221 , L1g158_g221 , L1b158_g221 );
			#ifdef _DOMINANTDIRSPECULARS_ON
				float3 staticSwitch410 = localLightVolumeSpecularDominant158_g221;
			#else
				float3 staticSwitch410 = localLightVolumeSpecular157_g220;
			#endif
			float AO357 = break530.z;
			float3 Speculars412 = ( staticSwitch410 * AO357 );
			#ifdef _SPECULARS_ON
				float3 staticSwitch361 = ( temp_output_406_0 + Speculars412 );
			#else
				float3 staticSwitch361 = temp_output_406_0;
			#endif
			float3 IndirectAndSpeculars444 = ( staticSwitch361 * AO357 );
			float3 Emission452 = ( ( Element_Emission496 * lerpResult539 ) + IndirectAndSpeculars444 );
			o.Emission = Emission452;
			o.Metallic = Metallic334;
			o.Smoothness = Smoothness109;
			o.Occlusion = AO357;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred noambient 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xyz = customInputData.uv_texcoord;
				o.customPack1.xyz = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xyz;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback Off
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
}
/*ASEBEGIN
Version=19905
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;497;-480,832;Inherit;False;2436;754.8;Elements Emission;22;476;483;484;485;486;487;488;489;490;491;474;475;477;478;479;480;481;492;496;495;482;542;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;436;-2272,256;Inherit;False;1115.2;487.8;Light Volumes;9;470;469;468;467;95;94;93;79;78;;0.9834821,1,0.7150943,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;474;-448,1152;Inherit;False;Property;_Speed;Scrolling Speed;24;0;Create;False;0;0;0;False;0;False;2;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;443;-475.0907,-2336;Inherit;False;1718.712;988.7617;Metallic Smoothness AO;26;535;536;523;522;521;519;50;526;57;524;54;525;51;357;109;334;531;530;528;529;527;520;56;53;52;541;;1,0.8500044,0.4735848,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;469;-2208,512;Inherit;False;112;World Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;468;-2208,432;Inherit;False;Property;_LightVolumesBias;Light Volumes Bias;27;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;475;-320,880;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;477;-272,1152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;478;-272,1040;Inherit;False;Property;_Scale;Scrolling Scale;23;0;Create;False;0;0;0;False;0;False;1;11.29;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;536;-416,-1808;Inherit;False;0;498;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;535;-384,-2256;Inherit;False;0;500;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;439;-2128,-1296;Inherit;False;1457.596;758.2194;Normal;15;517;534;514;516;515;509;508;518;112;349;14;511;510;437;512;;0.5792453,0.6214049,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;435;-1744,-512;Inherit;False;579.2;735.9199;Defaul Unity Light Probes;7;427;426;425;424;430;429;428;;0.8294254,1,0.6396227,1;0;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;459;-480,-1296;Inherit;False;1380;643;Speculars;14;359;410;360;111;114;339;340;362;411;123;108;115;122;412;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;109;992,-1808;Inherit;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;470;-1968,464;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;479;-80,1024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;480;-128,1152;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;52;-128,-2080;Inherit;False;Property;_WireSmoothness;Wire Smoothness;5;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;53;-128,-2000;Inherit;False;Property;_WireMetallic;Wire Metallic;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;56;-128,-1920;Inherit;False;Property;_WireAO;Wire AO;6;0;Create;True;0;0;0;False;0;False;0.2836054;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;521;-128,-1616;Inherit;False;Property;_ElementSmoothness;Element Smoothness;15;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;522;-128,-1536;Inherit;False;Property;_ElementMetallic;Element Metallic;14;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;523;-128,-1456;Inherit;False;Property;_ElementAO;Element AO;16;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;519;-160,-1824;Inherit;True;Property;_ElementWireMAOES;Element Wire MAOES;12;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;50;-128,-2272;Inherit;True;Property;_WireMAOES;Wire MAOES;2;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;483;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;111;-400,-1168;Inherit;False;109;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;114;-432,-784;Inherit;False;112;World Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;339;-400,-1232;Inherit;False;337;Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;340;-400,-1104;Inherit;False;334;Metallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;123;-400,-848;Inherit;False;101;L1b;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;108;-400,-976;Inherit;False;99;L1r;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;115;-400,-1040;Inherit;False;98;L0;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;122;-400,-912;Inherit;False;100;L1g;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;424;-1680,-320;Inherit;False;Global;unity_SHAr;unity_SHAr;17;0;Fetch;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;425;-1680,-144;Inherit;False;Global;unity_SHAg;unity_SHAg;17;0;Fetch;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;426;-1680,32;Inherit;False;Global;unity_SHAb;unity_SHAb;17;0;Fetch;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;78;-1760,336;Inherit;False;LightVolume;-1;;3;78706f2b7f33b1c44b4f381a7904a7e1;4,8,0,10,0,11,0,12,0;2;6;FLOAT3;0,0,0;False;17;FLOAT3;0,0,0;False;4;FLOAT3;13;FLOAT3;14;FLOAT3;15;FLOAT3;16
Node;AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;79;-1760,496;Inherit;False;LightVolume;-1;;4;78706f2b7f33b1c44b4f381a7904a7e1;4,8,1,10,1,11,1,12,1;2;6;FLOAT3;0,0,0;False;17;FLOAT3;0,0,0;False;4;FLOAT3;13;FLOAT3;14;FLOAT3;15;FLOAT3;16
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;518;-1440,-880;Inherit;False;437;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;481;80,1136;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;51;176,-2064;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;525;176,-1728;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;54;176,-2160;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;524;176,-1824;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;526;176,-1632;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;57;176,-1968;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;362;-128,-1248;Inherit;False;LightVolumeSpecular;-1;;220;a5ec4a1f240e00f47a5deb132f113431;1,159,0;9;138;FLOAT3;1,1,1;False;3;FLOAT;0;False;137;FLOAT;0;False;65;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;36;FLOAT3;0,0,0;False;37;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;9;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;411;-128,-960;Inherit;False;LightVolumeSpecular;-1;;221;a5ec4a1f240e00f47a5deb132f113431;1,159,1;9;138;FLOAT3;1,1,1;False;3;FLOAT;0;False;137;FLOAT;0;False;65;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;36;FLOAT3;0,0,0;False;37;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;9;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;357;992,-1728;Inherit;False;AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;428;-1424,-320;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;429;-1424,-144;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;430;-1424,32;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;427;-1360,-448;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;93;-1440,400;Inherit;False;Property;_AdditiveOnly;Additive Only;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;467;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;94;-1440,496;Inherit;False;Property;_AdditiveOnly;Additive Only;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;467;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;95;-1440,592;Inherit;False;Property;_AdditiveOnly;Additive Only;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;467;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;467;-1440,304;Inherit;False;Property;LIGHTMAP_ON;LIGHTMAP_ON;15;0;Create;False;0;0;0;False;0;False;0;0;0;False;LIGHTMAP_ON;Toggle;2;Key0;Key1;Fetch;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;14;-1232,-880;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;482;224,1136;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;520;384,-1952;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;527;384,-1808;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;529;320,-1648;Inherit;False;495;ElementMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;359;256,-992;Inherit;False;357;AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;410;160,-1104;Inherit;False;Property;_DominantDirSpeculars;Dominant Dir Speculars;29;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;531;832,-1888;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;461;-1072,128;Inherit;False;Property;_Keyword0;Keyword 0;26;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;431;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;462;-1072,224;Inherit;False;Property;_Keyword1;Keyword 1;26;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;431;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;463;-1072,320;Inherit;False;Property;_Keyword2;Keyword 2;26;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;431;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;349;-1056,-880;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;431;-1072,32;Inherit;False;Property;_LightVolumes;Enable Light Volumes;26;0;Create;False;0;0;0;False;1;Header(Other);False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;484;448,1296;Inherit;False;Property;_ScrollingColor;Scrolling Color;20;1;[Header];Create;True;1;Scrolling Effect;0;0;False;0;False;1,1,1,1;1,0.3944412,0,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;483;384,1104;Inherit;True;Property;_ScrollingMap;Scrolling Map;21;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;a5333a23d8b017d42ad7ea95116c483d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;485;512,1488;Inherit;False;Property;_ScrollingBrightness;Scrolling Brightness;22;0;Create;True;0;0;0;False;0;False;1;26.77;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;528;560,-1856;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;458;-480,-592;Inherit;False;1685;417;Indirect and Speculars;16;464;361;124;444;413;406;80;338;350;336;451;450;449;448;113;465;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;360;496,-1104;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;334;992,-1888;Inherit;False;Metallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;99;-816,128;Inherit;False;L1r;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;100;-816,224;Inherit;False;L1g;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;101;-816,320;Inherit;False;L1b;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;98;-816,32;Inherit;False;L0;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;112;-912,-880;Inherit;False;World Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;487;752,1120;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;486;656,1024;Inherit;False;Property;_ScrollingHueShiftSpeed;Scrolling Hue Shift Speed;25;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;530;704,-1856;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;113;-432,-544;Inherit;False;112;World Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;448;-400,-480;Inherit;False;98;L0;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;449;-400,-416;Inherit;False;99;L1r;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;450;-400,-352;Inherit;False;100;L1g;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;451;-400,-288;Inherit;False;101;L1b;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;336;-192,-288;Inherit;False;334;Metallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;412;656,-1104;Inherit;False;Speculars;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RGBToHSVNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;488;944,1120;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;489;960,1040;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;350;-112,-544;Inherit;False;LightVolumeEvaluate;-1;;222;4919cc1d83093f24f802ce655e9f3303;0;5;5;FLOAT3;0,0,0;False;13;FLOAT3;1,1,1;False;14;FLOAT3;0,0,0;False;15;FLOAT3;0,0,0;False;16;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;338;-48,-368;Inherit;False;337;Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;80;-16,-288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;413;176,-384;Inherit;False;412;Speculars;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;460;-480,-128;Inherit;False;1552.131;909.0266;Emission Plus Indirect and Speculars;15;452;417;447;539;540;538;533;532;537;415;473;414;416;543;544;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;490;1168,1120;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;541;992,-1632;Inherit;False;Effects Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;406;176,-544;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;124;368,-464;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;473;-416,160;Inherit;False;0;500;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;533;-416,576;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.HSVToRGBNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;491;1296,1152;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;542;1296,1328;Inherit;False;541;Effects Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;457;-2160,-2256;Inherit;False;1457.531;886.7407;Albedo;10;498;500;505;503;499;337;504;506;502;501;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;361;496,-544;Inherit;False;Property;_Speculars;Speculars;28;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;464;560,-432;Inherit;False;357;AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;476;1168,960;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;414;-192,144;Inherit;True;Property;_EmissionMap;Wire Emission Map;9;2;[HDR];[NoScaleOffset];Create;False;0;0;0;False;0;False;483;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;532;-192,560;Inherit;True;Property;_EmissionMap1;Element Emission Map;19;2;[HDR];[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;492;1552,1120;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;415;-128,-64;Inherit;False;Property;_WireEmissionColor;Wire Emission Color;8;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,1;1,1,1,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;537;-128,352;Inherit;False;Property;_ElementEmissionColor;Element Emission Color;18;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,1;1,1,1,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;465;768,-544;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;515;-2048,-1072;Inherit;False;Property;_WireNormalWeight;Wire Normal Weight;7;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;516;-2080,-864;Inherit;False;Property;_ElementNormalWeight1;Element Normal Weight;17;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;514;-2048,-1200;Inherit;False;0;500;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;534;-2080,-992;Inherit;False;0;498;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;501;-2000,-2192;Inherit;False;Property;_WireColor;Wire Color;0;1;[Header];Create;True;1;Wire;0;0;False;0;False;1,1,1,0;1,1,1,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;499;-2000,-1792;Inherit;False;Property;_ElementColor;Element Color;10;1;[Header];Create;True;1;Elements;0;0;False;0;False;1,1,1,0;0.04905649,0.04905649,0.04905649,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;495;1296,960;Inherit;False;ElementMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;498;-2064,-1584;Inherit;True;Property;_ElementAlbedo;Element Albedo;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;500;-2064,-2000;Inherit;True;Property;_WireAlbedo;Wire Albedo;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;416;128,64;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;538;128,464;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;540;128,576;Inherit;False;495;ElementMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;496;1712,1120;Inherit;False;Element Emission;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;444;944,-544;Inherit;False;IndirectAndSpeculars;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;508;-1808,-1200;Inherit;True;Property;_WireNormal;Wire Normal;3;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;509;-1808,-1008;Inherit;True;Property;_ElementNormal;Element Normal;13;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;502;-1744,-2032;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;503;-1744,-1792;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;505;-1744,-1680;Inherit;False;495;ElementMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;517;-1744,-816;Inherit;False;495;ElementMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;539;384,272;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;543;320,160;Inherit;False;496;Element Emission;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;512;-1488,-1200;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;511;-1296,-1104;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,1,-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;504;-1520,-2032;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;447;384,448;Inherit;False;444;IndirectAndSpeculars;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;544;560,256;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwitchByFaceNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;510;-1136,-1200;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;506;-1344,-2032;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;417;720,272;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;437;-928,-1200;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;337;-1120,-2032;Inherit;False;Albedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;452;832,272;Inherit;False;Emission;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;418;1856,-1584;Inherit;False;Property;_Culling;Culling;30;1;[Enum];Create;False;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;440;1440,-1840;Inherit;False;334;Metallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;442;1440,-1680;Inherit;False;357;AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;438;1440,-2000;Inherit;False;437;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;453;1440,-1920;Inherit;False;452;Emission;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;454;1440,-2080;Inherit;False;337;Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;441;1440,-1760;Inherit;False;109;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;72;1856,-2048;Float;False;True;-1;7;AmplifyShaderEditor.MaterialInspector;0;0;Standard;FlexiCurve/Fairy Lights;False;False;False;False;True;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;_ZWrite;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;True;Opaque;;Geometry;ForwardOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;True;_Culling;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;477;0;474;0
WireConnection;109;0;530;1
WireConnection;470;0;468;0
WireConnection;470;1;469;0
WireConnection;479;0;475;3
WireConnection;479;1;478;0
WireConnection;480;0;477;0
WireConnection;519;1;536;0
WireConnection;50;1;535;0
WireConnection;78;17;470;0
WireConnection;79;17;470;0
WireConnection;481;0;479;0
WireConnection;481;1;480;0
WireConnection;51;0;50;4
WireConnection;51;1;52;0
WireConnection;525;0;519;4
WireConnection;525;1;521;0
WireConnection;54;0;50;1
WireConnection;54;1;53;0
WireConnection;524;0;519;1
WireConnection;524;1;522;0
WireConnection;526;1;519;2
WireConnection;526;2;523;0
WireConnection;57;1;50;2
WireConnection;57;2;56;0
WireConnection;362;138;339;0
WireConnection;362;3;111;0
WireConnection;362;137;340;0
WireConnection;362;65;115;0
WireConnection;362;1;108;0
WireConnection;362;36;122;0
WireConnection;362;37;123;0
WireConnection;362;2;114;0
WireConnection;411;138;339;0
WireConnection;411;3;111;0
WireConnection;411;137;340;0
WireConnection;411;65;115;0
WireConnection;411;1;108;0
WireConnection;411;36;122;0
WireConnection;411;37;123;0
WireConnection;411;2;114;0
WireConnection;357;0;530;2
WireConnection;428;0;424;0
WireConnection;429;0;425;0
WireConnection;430;0;426;0
WireConnection;427;0;424;4
WireConnection;427;1;425;4
WireConnection;427;2;426;4
WireConnection;93;1;78;14
WireConnection;93;0;79;14
WireConnection;94;1;78;15
WireConnection;94;0;79;15
WireConnection;95;1;78;16
WireConnection;95;0;79;16
WireConnection;467;1;78;13
WireConnection;467;0;79;13
WireConnection;14;0;518;0
WireConnection;482;0;481;0
WireConnection;482;1;481;0
WireConnection;520;0;54;0
WireConnection;520;1;51;0
WireConnection;520;2;57;0
WireConnection;520;3;50;3
WireConnection;527;0;524;0
WireConnection;527;1;525;0
WireConnection;527;2;526;0
WireConnection;527;3;519;3
WireConnection;410;1;362;0
WireConnection;410;0;411;0
WireConnection;531;0;530;0
WireConnection;531;1;530;0
WireConnection;461;1;428;0
WireConnection;461;0;93;0
WireConnection;462;1;429;0
WireConnection;462;0;94;0
WireConnection;463;1;430;0
WireConnection;463;0;95;0
WireConnection;349;0;14;0
WireConnection;431;1;427;0
WireConnection;431;0;467;0
WireConnection;483;1;482;0
WireConnection;528;0;520;0
WireConnection;528;1;527;0
WireConnection;528;2;529;0
WireConnection;360;0;410;0
WireConnection;360;1;359;0
WireConnection;334;0;531;0
WireConnection;99;0;461;0
WireConnection;100;0;462;0
WireConnection;101;0;463;0
WireConnection;98;0;431;0
WireConnection;112;0;349;0
WireConnection;487;0;483;0
WireConnection;487;1;484;0
WireConnection;487;2;485;0
WireConnection;530;0;528;0
WireConnection;412;0;360;0
WireConnection;488;0;487;0
WireConnection;489;0;486;0
WireConnection;350;5;113;0
WireConnection;350;13;448;0
WireConnection;350;14;449;0
WireConnection;350;15;450;0
WireConnection;350;16;451;0
WireConnection;80;0;336;0
WireConnection;490;0;489;0
WireConnection;490;1;488;1
WireConnection;541;0;530;3
WireConnection;406;0;350;0
WireConnection;406;1;338;0
WireConnection;406;2;80;0
WireConnection;124;0;406;0
WireConnection;124;1;413;0
WireConnection;491;0;490;0
WireConnection;491;1;488;2
WireConnection;491;2;488;3
WireConnection;361;1;406;0
WireConnection;361;0;124;0
WireConnection;476;0;475;3
WireConnection;414;1;473;0
WireConnection;532;1;533;0
WireConnection;492;0;495;0
WireConnection;492;1;491;0
WireConnection;492;2;542;0
WireConnection;465;0;361;0
WireConnection;465;1;464;0
WireConnection;495;0;476;0
WireConnection;416;0;415;5
WireConnection;416;1;414;5
WireConnection;538;0;537;5
WireConnection;538;1;532;5
WireConnection;496;0;492;0
WireConnection;444;0;465;0
WireConnection;508;1;514;0
WireConnection;508;5;515;0
WireConnection;509;1;534;0
WireConnection;509;5;516;0
WireConnection;502;0;501;0
WireConnection;502;1;500;0
WireConnection;503;0;499;0
WireConnection;503;1;498;0
WireConnection;539;0;416;0
WireConnection;539;1;538;0
WireConnection;539;2;540;0
WireConnection;512;0;508;0
WireConnection;512;1;509;0
WireConnection;512;2;517;0
WireConnection;511;0;512;0
WireConnection;504;0;502;0
WireConnection;504;1;503;0
WireConnection;504;2;505;0
WireConnection;544;0;543;0
WireConnection;544;1;539;0
WireConnection;510;0;512;0
WireConnection;510;1;511;0
WireConnection;506;0;504;0
WireConnection;417;0;544;0
WireConnection;417;1;447;0
WireConnection;437;0;510;0
WireConnection;337;0;506;0
WireConnection;452;0;417;0
WireConnection;72;0;454;0
WireConnection;72;1;438;0
WireConnection;72;2;453;0
WireConnection;72;3;440;0
WireConnection;72;4;441;0
WireConnection;72;5;442;0
ASEEND*/
//CHKSM=15E6EC8C5684DF68E43783F202570F1BBA61BA57