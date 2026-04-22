#include "/lib/shaderSettings/particles.glsl"
//////////////////////////////////////////
// Complementary Shaders by EminGT      //
// With Euphoria Patches by SpacEagle17 //
//////////////////////////////////////////

//Common//
#include "/lib/common.glsl"
#include "/lib/shaderSettings/raindropColor.glsl"
//#define GLOWING_COLORED_PARTICLES
#define SMOKE_PARTICLE_OPACITY 0.5 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

#if defined MIRROR_DIMENSION || defined WORLD_CURVATURE
    #include "/lib/misc/distortWorld.glsl"
#endif

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

in vec2 texCoord;
in vec2 lmCoord;

flat in vec3 upVec, sunVec, northVec, eastVec;
in vec3 normal;

flat in vec4 glColor;

//Pipeline Constants//

//Common Variables//
float NdotU = dot(normal, upVec);
float NdotUmax0 = max(NdotU, 0.0);
float SdotU = dot(sunVec, upVec);
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;
float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
float shadowTime = shadowTimeVar2 * shadowTimeVar2;

#ifdef OVERWORLD
    vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
#else
    vec3 lightVec = sunVec;
#endif

//Common Functions//

//Includes//
#include "/lib/util/spaceConversion.glsl"
#include "/lib/lighting/mainLighting.glsl"
#include "/lib/util/dither.glsl"

#if MC_VERSION >= 11500
    #include "/lib/atmospherics/fog/mainFog.glsl"
#endif

#ifdef ATM_COLOR_MULTS
    #include "/lib/colors/colorMultipliers.glsl"
#endif

#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/misc/colorCodedPrograms.glsl"
#endif

#if defined BIOME_COLORED_NETHER_PORTALS && !defined BORDER_FOG
    #include "/lib/colors/skyColors.glsl"
#endif

#ifdef SS_BLOCKLIGHT
    #include "/lib/lighting/coloredBlocklight.glsl"
#endif

//Program//
void main() {
    vec4 color = texture2D(tex, texCoord);
    vec4 colorP = color;
    color *= glColor;

    vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
    vec3 viewPos = ScreenToView(screenPos);
    float lViewPos = length(viewPos);
    vec3 playerPos = ViewToPlayer(viewPos);

    float dither = texture2DLod(noisetex, gl_FragCoord.xy / 128.0, 0.0).b;
    #ifdef TAA
        dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
    #endif

    #ifdef ATM_COLOR_MULTS
        atmColorMult = GetAtmColorMult();
    #endif

    #ifdef VL_CLOUDS_ACTIVE
        float cloudLinearDepth = texelFetch(gaux2, texelCoord, 0).a;

        if (cloudLinearDepth > 0.0) // Because Iris changes the pipeline position of opaque particles
        if (pow2(cloudLinearDepth + OSIEBCA * dither) * renderDistance < min(lViewPos, renderDistance)) discard;
    #endif

    float emission = 0.0, enderDragonDead = 1.0, materialMask = OSIEBCA * 254.0; // No SSAO, No TAA, Reduce Reflection
    vec2 lmCoordM = lmCoord;
    vec3 normalM = normal, geoNormal = normal, shadowMult = vec3(1.0);
    vec3 worldGeoNormal = normalize(ViewToPlayer(geoNormal * 10000.0));
    float purkinjeOverwrite = 0.0;
    #if defined IPBR && defined IPBR_PARTICLE_FEATURES
        // We don't want to detect particles from the block atlas
        #if MC_VERSION >= 12000
            float atlasCheck = 5000.0; // I think texture atlas got bigger in newer mc
        #else
            float atlasCheck = 900.0;
        #endif

        vec2 tSize = textureSize(tex, 0);
        if (tSize.x < atlasCheck) {
        vec2 texCoordScaled = texCoord * 16384;
        if (texCoordScaled.x < 5752) {
            if (texCoordScaled.y < 9856) {
                if (texCoordScaled.x < 4096) {
                    if (texCoordScaled.y < 9552) {
                        if (texCoordScaled.x < 3184) {
                            if (texCoordScaled.x >= 2944 && texCoordScaled.x < 3008 && texCoordScaled.y >= 9400 && texCoordScaled.y < 9552) {
                                color.rgb *= 0.7;
                                color.a *= 0.6;
                            }
                        } else {
                            if (texCoordScaled.x >= 3184 && texCoordScaled.x < 3248 && texCoordScaled.y >= 9392 && texCoordScaled.y < 9552) {
                                color.rgb *= 0.7;
                                color.a *= 0.6;
                            }
                        }
                    } else {
                        if (texCoordScaled.x < 2048) {
                            if (texCoordScaled.y < 9656) {
                                if (texCoordScaled.x < 448) {
                                    if (texCoordScaled.x >= 0 && texCoordScaled.x < 320 && texCoordScaled.y >= 9552 && texCoordScaled.y < 9656) {
                                        emission = 5.0;
                                    }
                                } else {
                                    if (texCoordScaled.x < 640) {
                                        if (texCoordScaled.x >= 448 && texCoordScaled.x < 512 && texCoordScaled.y >= 9552 && texCoordScaled.y < 9656) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 640 && texCoordScaled.x < 704 && texCoordScaled.y >= 9552 && texCoordScaled.y < 9656) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    }
                                }
                            } else {
                                if (texCoordScaled.x < 640) {
                                    if (texCoordScaled.x < 448) {
                                        if (texCoordScaled.x >= 0 && texCoordScaled.x < 320 && texCoordScaled.y >= 9656 && texCoordScaled.y < 9680) {
                                            emission = 5.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 448 && texCoordScaled.x < 512 && texCoordScaled.y >= 9656 && texCoordScaled.y < 9680) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    }
                                } else {
                                    if (texCoordScaled.x < 1984) {
                                        if (texCoordScaled.x >= 640 && texCoordScaled.x < 704 && texCoordScaled.y >= 9656 && texCoordScaled.y < 9680) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 1984 && texCoordScaled.x < 2048 && texCoordScaled.y >= 9656 && texCoordScaled.y < 9784) {
                                            if (color.b > 0.6 && color.a > 0.9) {
                                                color.rgb = pow1_5(color.rgb);
                                                emission = 2.5;
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            if (texCoordScaled.y < 9656) {
                                if (texCoordScaled.x < 3184) {
                                    if (texCoordScaled.x >= 2944 && texCoordScaled.x < 3008 && texCoordScaled.y >= 9552 && texCoordScaled.y < 9656) {
                                        color.rgb *= 0.7;
                                        color.a *= 0.6;
                                    }
                                } else {
                                    if (texCoordScaled.x >= 3184 && texCoordScaled.x < 3248 && texCoordScaled.y >= 9552 && texCoordScaled.y < 9648) {
                                        color.rgb *= 0.7;
                                        color.a *= 0.6;
                                    }
                                }
                            } else {
                                if (texCoordScaled.x < 3072) {
                                    if (texCoordScaled.x >= 2048 && texCoordScaled.x < 2432 && texCoordScaled.y >= 9656 && texCoordScaled.y < 9784) {
                                        emission = pow2(color.b);
                                    }
                                } else {
                                    if (texCoordScaled.x >= 3072 && texCoordScaled.x < 3200 && texCoordScaled.y >= 9776 && texCoordScaled.y < 9856) {
                                        emission = 1.6 * pow2(color.b);
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if (texCoordScaled.y < 9728) {
                        if (texCoordScaled.x < 4672) {
                            if (texCoordScaled.x < 4288) {
                                if (texCoordScaled.x >= 4096 && texCoordScaled.x < 4160 && texCoordScaled.y >= 9600 && texCoordScaled.y < 9728) {
                                    color.a *= 0.5;
                                    materialMask = 0.0;
                                }
                            } else {
                                if (texCoordScaled.x < 4480) {
                                    if (texCoordScaled.x >= 4288 && texCoordScaled.x < 4352 && texCoordScaled.y >= 9600 && texCoordScaled.y < 9728) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                } else {
                                    if (texCoordScaled.x >= 4480 && texCoordScaled.x < 4544 && texCoordScaled.y >= 9600 && texCoordScaled.y < 9728) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                }
                            }
                        } else {
                            if (texCoordScaled.x < 4864) {
                                if (texCoordScaled.x >= 4672 && texCoordScaled.x < 4736 && texCoordScaled.y >= 9600 && texCoordScaled.y < 9728) {
                                    color.a *= 0.5;
                                    materialMask = 0.0;
                                }
                            } else {
                                if (texCoordScaled.x < 5056) {
                                    if (texCoordScaled.x >= 4864 && texCoordScaled.x < 4928 && texCoordScaled.y >= 9600 && texCoordScaled.y < 9728) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                } else {
                                    if (texCoordScaled.x >= 5056 && texCoordScaled.x < 5120 && texCoordScaled.y >= 9600 && texCoordScaled.y < 9728) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                }
                            }
                        }
                    } else {
                        if (texCoordScaled.x < 4544) {
                            if (texCoordScaled.x < 4352) {
                                if (texCoordScaled.x >= 4288 && texCoordScaled.x < 4352 && texCoordScaled.y >= 9728 && texCoordScaled.y < 9856) {
                                    color.a *= 0.5;
                                    materialMask = 0.0;
                                }
                            } else {
                                if (texCoordScaled.x < 4480) {
                                    if (texCoordScaled.x >= 4352 && texCoordScaled.x < 4480 && texCoordScaled.y >= 9728 && texCoordScaled.y < 9856) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                } else {
                                    if (texCoordScaled.x >= 4480 && texCoordScaled.x < 4544 && texCoordScaled.y >= 9728 && texCoordScaled.y < 9856) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                }
                            }
                        } else {
                            if (texCoordScaled.x < 4672) {
                                if (texCoordScaled.x >= 4544 && texCoordScaled.x < 4672 && texCoordScaled.y >= 9728 && texCoordScaled.y < 9856) {
                                    color.a *= 0.5;
                                    materialMask = 0.0;
                                }
                            } else {
                                if (texCoordScaled.x < 4736) {
                                    if (texCoordScaled.x >= 4672 && texCoordScaled.x < 4736 && texCoordScaled.y >= 9728 && texCoordScaled.y < 9856) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                } else {
                                    if (texCoordScaled.x >= 4736 && texCoordScaled.x < 4800 && texCoordScaled.y >= 9728 && texCoordScaled.y < 9856) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                if (texCoordScaled.x < 3712) {
                    if (texCoordScaled.y < 9984) {
                        if (texCoordScaled.x < 3456) {
                            if (texCoordScaled.y < 9912) {
                                if (texCoordScaled.x >= 3072 && texCoordScaled.x < 3200 && texCoordScaled.y >= 9856 && texCoordScaled.y < 9904) {
                                    emission = 1.6 * pow2(color.b);
                                }
                            } else {
                                if (texCoordScaled.x >= 1472 && texCoordScaled.x < 2432 && texCoordScaled.y >= 9912 && texCoordScaled.y < 9984) {
                                    color.a *= 0.5;
                                    materialMask = 0.0;
                                }
                            }
                        } else {
                            if (texCoordScaled.x < 3584) {
                                if (texCoordScaled.x >= 3456 && texCoordScaled.x < 3520 && texCoordScaled.y >= 9880 && texCoordScaled.y < 9984) {
                                    color.a *= 0.5;
                                    materialMask = 0.0;
                                }
                            } else {
                                if (texCoordScaled.x >= 3584 && texCoordScaled.x < 3648 && texCoordScaled.y >= 9880 && texCoordScaled.y < 9984) {
                                    color.a *= 0.5;
                                    materialMask = 0.0;
                                }
                            }
                        }
                    } else {
                        if (texCoordScaled.x < 3168) {
                            if (texCoordScaled.x < 992) {
                                if (texCoordScaled.x < 928) {
                                    if (texCoordScaled.x >= 768 && texCoordScaled.x < 832 && texCoordScaled.y >= 9984 && texCoordScaled.y < 10048) {
                                        if (color.b > 1.15 * (color.r + color.g) && color.g > color.r * 1.25 && color.g < 0.425 && color.b > 0.75) { // Water Particle
                                            materialMask = 0.0;
                                            color.rgb = sqrt3(color.rgb);
                                            color.rgb *= 0.7;
                                            if (dither > 0.4) discard;
                                            #ifdef NO_RAIN_ABOVE_CLOUDS
                                                if (cameraPosition.y > maximumCloudsHeight) discard;
                                            #endif
                                        #ifdef OVERWORLD
                                        } else if (color.b > 0.7 && color.r < 0.28 && color.g < 0.425 && color.g > color.r * 1.4) { // physics mod rain
                                            #ifdef NO_RAIN_ABOVE_CLOUDS
                                                if (cameraPosition.y > maximumCloudsHeight) discard;
                                            #endif
                                        
                                            if (color.a < 0.1 || isEyeInWater == 3) discard;
                                            color.a *= rainTexOpacity;
                                            color.rgb = sqrt2(color.rgb) * (blocklightCol * 2.0 * lmCoord.x + ambientColor * lmCoord.y * (0.7 + 0.35 * sunFactor));
                                        } else if (color.rgb == vec3(1.0) && color.a < 0.765 && color.a > 0.605) { // physics mod snow (default snow opacity only)
                                            #ifdef NO_RAIN_ABOVE_CLOUDS
                                                if (cameraPosition.y > maximumCloudsHeight) discard;
                                            #endif
                                        
                                            if (color.a < 0.1 || isEyeInWater == 3) discard;
                                            color.a *= snowTexOpacity;
                                            color.rgb = sqrt2(color.rgb) * (blocklightCol * 2.0 * lmCoord.x + lmCoord.y * (0.7 + 0.35 * sunFactor) + ambientColor * 0.2);
                                        #endif
                                        } else if (color.r == color.g && color.r - 0.5 * color.b < 0.06) { // Underwater Particle
                                            color.rgb = sqrt2(color.rgb) * 0.35;
                                            if (fract(playerPos.y + cameraPosition.y) > 0.25) discard;
                                        }
                                        
                                        float dotColor = dot(color.rgb, color.rgb);
                                        if (dotColor > 0.25 && color.g < 0.5 && (color.b > color.r * 1.1 && color.r > 0.3 || color.r > (color.g + color.b) * 3.0)) {
                                            // Ender Particle, Crying Obsidian Particle, Redstone Particle
                                            emission = clamp(color.r * 8.0, 1.6, 5.0);
                                            color.rgb = pow1_5(color.rgb);
                                            lmCoordM = vec2(0.0);
                                            #if defined NETHER && defined BIOME_COLORED_NETHER_PORTALS
                                                if (color.b > color.r * color.r && color.g < 0.16 && color.r > 0.2)
                                                    color.rgb = changeColorFunction(color.rgb, 10.0, netherColor, 1.0); // Nether Portal
                                            #endif
                                        } else if (color.r > 0.83 && color.g > 0.23 && color.b < 0.4) {
                                            // Lava Particles
                                            emission = 2.0;
                                            color.b *= 0.5;
                                            color.r *= 1.2;
                                            color.rgb += vec3(min(pow2(pow2(emission * 0.35)), 0.4)) * LAVA_TEMPERATURE * 0.5;
                                            emission *= LAVA_EMISSION;
                                            #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.5, colorSoul, inSoulValley);
                                            #endif
                                            #ifdef PURPLE_END_FIRE_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.5, colorEndBreath, 1.0);
                                            #endif
                                        }
                                    }
                                } else {
                                    if (texCoordScaled.x >= 928 && texCoordScaled.x < 960 && texCoordScaled.y >= 9984 && texCoordScaled.y < 10048) {
                                        #ifdef GLOWING_POTION_EFFECT
                                            emission = 4.0 * pow2(pow2(colorP.r));
                                        #endif
                                    }
                                }
                            } else {
                                if (texCoordScaled.x < 1056) {
                                    if (texCoordScaled.x >= 992 && texCoordScaled.x < 1024 && texCoordScaled.y >= 9984 && texCoordScaled.y < 10048) {
                                        #ifdef GLOWING_POTION_EFFECT
                                            emission = 4.0 * pow2(pow2(colorP.r));
                                        #endif
                                    }
                                } else {
                                    if (texCoordScaled.x < 1472) {
                                        if (texCoordScaled.x >= 1056 && texCoordScaled.x < 1088 && texCoordScaled.y >= 9984 && texCoordScaled.y < 10048) {
                                            #ifdef GLOWING_POTION_EFFECT
                                                emission = 4.0 * pow2(pow2(colorP.r));
                                            #endif
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 1472 && texCoordScaled.x < 2432 && texCoordScaled.y >= 9984 && texCoordScaled.y < 10040) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    }
                                }
                            }
                        } else {
                            if (texCoordScaled.y < 10008) {
                                if (texCoordScaled.x < 3584) {
                                    if (texCoordScaled.x >= 3456 && texCoordScaled.x < 3520 && texCoordScaled.y >= 9984 && texCoordScaled.y < 10008) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                } else {
                                    if (texCoordScaled.x >= 3584 && texCoordScaled.x < 3648 && texCoordScaled.y >= 9984 && texCoordScaled.y < 10008) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                }
                            } else {
                                if (texCoordScaled.x < 3264) {
                                    if (texCoordScaled.x >= 3168 && texCoordScaled.x < 3200 && texCoordScaled.y >= 10048 && texCoordScaled.y < 10112) {
                                        materialMask = 0.0;
                                        color.rgb = sqrt3(color.rgb);
                                        color.rgb *= 0.7;
                                        if (dither > 0.4) discard;
                                        
                                        #ifdef NO_RAIN_ABOVE_CLOUDS
                                            if (cameraPosition.y > maximumCloudsHeight) discard;
                                        #endif
                                    }
                                } else {
                                    if (texCoordScaled.y < 10048) {
                                        if (texCoordScaled.x >= 3368 && texCoordScaled.x < 3496 && texCoordScaled.y >= 10008 && texCoordScaled.y < 10048) {
                                            if (color.b > 1.15 * (color.r + color.g) && color.g > color.r * 1.25 && color.g < 0.425 && color.b > 0.75) { // Water Particle
                                                materialMask = 0.0;
                                                color.rgb = sqrt3(color.rgb);
                                                color.rgb *= 0.7;
                                                if (dither > 0.4) discard;
                                                #ifdef NO_RAIN_ABOVE_CLOUDS
                                                    if (cameraPosition.y > maximumCloudsHeight) discard;
                                                #endif
                                            #ifdef OVERWORLD
                                            } else if (color.b > 0.7 && color.r < 0.28 && color.g < 0.425 && color.g > color.r * 1.4) { // physics mod rain
                                                #ifdef NO_RAIN_ABOVE_CLOUDS
                                                    if (cameraPosition.y > maximumCloudsHeight) discard;
                                                #endif
                                            
                                                if (color.a < 0.1 || isEyeInWater == 3) discard;
                                                color.a *= rainTexOpacity;
                                                color.rgb = sqrt2(color.rgb) * (blocklightCol * 2.0 * lmCoord.x + ambientColor * lmCoord.y * (0.7 + 0.35 * sunFactor));
                                            } else if (color.rgb == vec3(1.0) && color.a < 0.765 && color.a > 0.605) { // physics mod snow (default snow opacity only)
                                                #ifdef NO_RAIN_ABOVE_CLOUDS
                                                    if (cameraPosition.y > maximumCloudsHeight) discard;
                                                #endif
                                            
                                                if (color.a < 0.1 || isEyeInWater == 3) discard;
                                                color.a *= snowTexOpacity;
                                                color.rgb = sqrt2(color.rgb) * (blocklightCol * 2.0 * lmCoord.x + lmCoord.y * (0.7 + 0.35 * sunFactor) + ambientColor * 0.2);
                                            #endif
                                            } else if (color.r == color.g && color.r - 0.5 * color.b < 0.06) { // Underwater Particle
                                                color.rgb = sqrt2(color.rgb) * 0.35;
                                                if (fract(playerPos.y + cameraPosition.y) > 0.25) discard;
                                            }
                                            
                                            float dotColor = dot(color.rgb, color.rgb);
                                            if (dotColor > 0.25 && color.g < 0.5 && (color.b > color.r * 1.1 && color.r > 0.3 || color.r > (color.g + color.b) * 3.0)) {
                                                // Ender Particle, Crying Obsidian Particle, Redstone Particle
                                                emission = clamp(color.r * 8.0, 1.6, 5.0);
                                                color.rgb = pow1_5(color.rgb);
                                                lmCoordM = vec2(0.0);
                                                #if defined NETHER && defined BIOME_COLORED_NETHER_PORTALS
                                                    if (color.b > color.r * color.r && color.g < 0.16 && color.r > 0.2)
                                                        color.rgb = changeColorFunction(color.rgb, 10.0, netherColor, 1.0); // Nether Portal
                                                #endif
                                            } else if (color.r > 0.83 && color.g > 0.23 && color.b < 0.4) {
                                                // Lava Particles
                                                emission = 2.0;
                                                color.b *= 0.5;
                                                color.r *= 1.2;
                                                color.rgb += vec3(min(pow2(pow2(emission * 0.35)), 0.4)) * LAVA_TEMPERATURE * 0.5;
                                                emission *= LAVA_EMISSION;
                                                #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                                    color.rgb = changeColorFunction(color.rgb, 3.5, colorSoul, inSoulValley);
                                                #endif
                                                #ifdef PURPLE_END_FIRE_INTERNAL
                                                    color.rgb = changeColorFunction(color.rgb, 3.5, colorEndBreath, 1.0);
                                                #endif
                                            }
                                        }
                                    } else {
                                        if (texCoordScaled.x < 3368) {
                                            if (texCoordScaled.x >= 3264 && texCoordScaled.x < 3296 && texCoordScaled.y >= 10048 && texCoordScaled.y < 10112) {
                                                materialMask = 0.0;
                                                color.rgb = sqrt3(color.rgb);
                                                color.rgb *= 0.7;
                                                if (dither > 0.4) discard;
                                                
                                                #ifdef NO_RAIN_ABOVE_CLOUDS
                                                    if (cameraPosition.y > maximumCloudsHeight) discard;
                                                #endif
                                            }
                                        } else {
                                            if (texCoordScaled.x >= 3368 && texCoordScaled.x < 3496 && texCoordScaled.y >= 10048 && texCoordScaled.y < 10072) {
                                                if (color.b > 1.15 * (color.r + color.g) && color.g > color.r * 1.25 && color.g < 0.425 && color.b > 0.75) { // Water Particle
                                                    materialMask = 0.0;
                                                    color.rgb = sqrt3(color.rgb);
                                                    color.rgb *= 0.7;
                                                    if (dither > 0.4) discard;
                                                    #ifdef NO_RAIN_ABOVE_CLOUDS
                                                        if (cameraPosition.y > maximumCloudsHeight) discard;
                                                    #endif
                                                #ifdef OVERWORLD
                                                } else if (color.b > 0.7 && color.r < 0.28 && color.g < 0.425 && color.g > color.r * 1.4) { // physics mod rain
                                                    #ifdef NO_RAIN_ABOVE_CLOUDS
                                                        if (cameraPosition.y > maximumCloudsHeight) discard;
                                                    #endif
                                                
                                                    if (color.a < 0.1 || isEyeInWater == 3) discard;
                                                    color.a *= rainTexOpacity;
                                                    color.rgb = sqrt2(color.rgb) * (blocklightCol * 2.0 * lmCoord.x + ambientColor * lmCoord.y * (0.7 + 0.35 * sunFactor));
                                                } else if (color.rgb == vec3(1.0) && color.a < 0.765 && color.a > 0.605) { // physics mod snow (default snow opacity only)
                                                    #ifdef NO_RAIN_ABOVE_CLOUDS
                                                        if (cameraPosition.y > maximumCloudsHeight) discard;
                                                    #endif
                                                
                                                    if (color.a < 0.1 || isEyeInWater == 3) discard;
                                                    color.a *= snowTexOpacity;
                                                    color.rgb = sqrt2(color.rgb) * (blocklightCol * 2.0 * lmCoord.x + lmCoord.y * (0.7 + 0.35 * sunFactor) + ambientColor * 0.2);
                                                #endif
                                                } else if (color.r == color.g && color.r - 0.5 * color.b < 0.06) { // Underwater Particle
                                                    color.rgb = sqrt2(color.rgb) * 0.35;
                                                    if (fract(playerPos.y + cameraPosition.y) > 0.25) discard;
                                                }
                                                
                                                float dotColor = dot(color.rgb, color.rgb);
                                                if (dotColor > 0.25 && color.g < 0.5 && (color.b > color.r * 1.1 && color.r > 0.3 || color.r > (color.g + color.b) * 3.0)) {
                                                    // Ender Particle, Crying Obsidian Particle, Redstone Particle
                                                    emission = clamp(color.r * 8.0, 1.6, 5.0);
                                                    color.rgb = pow1_5(color.rgb);
                                                    lmCoordM = vec2(0.0);
                                                    #if defined NETHER && defined BIOME_COLORED_NETHER_PORTALS
                                                        if (color.b > color.r * color.r && color.g < 0.16 && color.r > 0.2)
                                                            color.rgb = changeColorFunction(color.rgb, 10.0, netherColor, 1.0); // Nether Portal
                                                    #endif
                                                } else if (color.r > 0.83 && color.g > 0.23 && color.b < 0.4) {
                                                    // Lava Particles
                                                    emission = 2.0;
                                                    color.b *= 0.5;
                                                    color.r *= 1.2;
                                                    color.rgb += vec3(min(pow2(pow2(emission * 0.35)), 0.4)) * LAVA_TEMPERATURE * 0.5;
                                                    emission *= LAVA_EMISSION;
                                                    #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                                        color.rgb = changeColorFunction(color.rgb, 3.5, colorSoul, inSoulValley);
                                                    #endif
                                                    #ifdef PURPLE_END_FIRE_INTERNAL
                                                        color.rgb = changeColorFunction(color.rgb, 3.5, colorEndBreath, 1.0);
                                                    #endif
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if (texCoordScaled.y < 9880) {
                        if (texCoordScaled.x < 3952) {
                            if (texCoordScaled.x >= 3904 && texCoordScaled.x < 3952 && texCoordScaled.y >= 9872 && texCoordScaled.y < 9880) {
                                emission = 5.0;
                            }
                        } else {
                            if (texCoordScaled.y < 9864) {
                                if (texCoordScaled.x >= 4088 && texCoordScaled.x < 4792 && texCoordScaled.y >= 9856 && texCoordScaled.y < 9864) {
                                    if (color.b > 0.6 && color.a > 0.9) {
                                        color.rgb = pow1_5(color.rgb);
                                        emission = 2.5;
                                    }
                                }
                            } else {
                                if (texCoordScaled.x < 4088) {
                                    if (texCoordScaled.x >= 3952 && texCoordScaled.x < 4016 && texCoordScaled.y >= 9864 && texCoordScaled.y < 9880) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                } else {
                                    if (texCoordScaled.x >= 4088 && texCoordScaled.x < 4792 && texCoordScaled.y >= 9864 && texCoordScaled.y < 9880) {
                                        if (color.b > 0.6 && color.a > 0.9) {
                                            color.rgb = pow1_5(color.rgb);
                                            emission = 2.5;
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        if (texCoordScaled.x < 4100) {
                            if (texCoordScaled.y < 9984) {
                                if (texCoordScaled.x < 3952) {
                                    if (texCoordScaled.x < 3904) {
                                        if (texCoordScaled.x >= 3712 && texCoordScaled.x < 3776 && texCoordScaled.y >= 9880 && texCoordScaled.y < 9984) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 3904 && texCoordScaled.x < 3952 && texCoordScaled.y >= 9880 && texCoordScaled.y < 9968) {
                                            emission = 5.0;
                                        }
                                    }
                                } else {
                                    if (texCoordScaled.x < 4088) {
                                        if (texCoordScaled.x >= 3952 && texCoordScaled.x < 4016 && texCoordScaled.y >= 9880 && texCoordScaled.y < 9984) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 4088 && texCoordScaled.x < 4100 && texCoordScaled.y >= 9880 && texCoordScaled.y < 9984) {
                                            if (color.b > 0.6 && color.a > 0.9) {
                                                color.rgb = pow1_5(color.rgb);
                                                emission = 2.5;
                                            }
                                        }
                                    }
                                }
                            } else {
                                if (texCoordScaled.x < 4004) {
                                    if (texCoordScaled.x < 3952) {
                                        if (texCoordScaled.x >= 3712 && texCoordScaled.x < 3776 && texCoordScaled.y >= 9984 && texCoordScaled.y < 10008) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 3952 && texCoordScaled.x < 4004 && texCoordScaled.y >= 9984 && texCoordScaled.y < 9992) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    }
                                } else {
                                    if (texCoordScaled.y < 10048) {
                                        if (texCoordScaled.x < 4048) {
                                            if (texCoordScaled.x >= 4004 && texCoordScaled.x < 4016 && texCoordScaled.y >= 9984 && texCoordScaled.y < 9992) {
                                                color.a *= 0.5;
                                                materialMask = 0.0;
                                            }
                                        } else {
                                            if (texCoordScaled.x >= 4048 && texCoordScaled.x < 4080 && texCoordScaled.y >= 9984 && texCoordScaled.y < 10048) {
                                                #ifdef GLOWING_POTION_EFFECT
                                                    emission = 4.0 * pow2(pow2(colorP.r));
                                                #endif
                                            }
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 4004 && texCoordScaled.x < 4036 && texCoordScaled.y >= 10048 && texCoordScaled.y < 10112) {
                                            materialMask = 0.0;
                                            color.rgb = sqrt3(color.rgb);
                                            color.rgb *= 0.7;
                                            if (dither > 0.4) discard;
                                            
                                            #ifdef NO_RAIN_ABOVE_CLOUDS
                                                if (cameraPosition.y > maximumCloudsHeight) discard;
                                            #endif
                                        }
                                    }
                                }
                            }
                        } else {
                            if (texCoordScaled.y < 9984) {
                                if (texCoordScaled.x >= 4100 && texCoordScaled.x < 4792 && texCoordScaled.y >= 9880 && texCoordScaled.y < 9984) {
                                    if (color.b > 0.6 && color.a > 0.9) {
                                        color.rgb = pow1_5(color.rgb);
                                        emission = 2.5;
                                    }
                                }
                            } else {
                                if (texCoordScaled.x < 4240) {
                                    if (texCoordScaled.y < 10048) {
                                        if (texCoordScaled.x < 4176) {
                                            if (texCoordScaled.x >= 4112 && texCoordScaled.x < 4144 && texCoordScaled.y >= 9984 && texCoordScaled.y < 10048) {
                                                #ifdef GLOWING_POTION_EFFECT
                                                    emission = 4.0 * pow2(pow2(colorP.r));
                                                #endif
                                            }
                                        } else {
                                            if (texCoordScaled.x >= 4176 && texCoordScaled.x < 4208 && texCoordScaled.y >= 9984 && texCoordScaled.y < 10048) {
                                                #ifdef GLOWING_POTION_EFFECT
                                                    emission = 4.0 * pow2(pow2(colorP.r));
                                                #endif
                                            }
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 4100 && texCoordScaled.x < 4132 && texCoordScaled.y >= 10048 && texCoordScaled.y < 10112) {
                                            materialMask = 0.0;
                                            color.rgb = sqrt3(color.rgb);
                                            color.rgb *= 0.7;
                                            if (dither > 0.4) discard;
                                            
                                            #ifdef NO_RAIN_ABOVE_CLOUDS
                                                if (cameraPosition.y > maximumCloudsHeight) discard;
                                            #endif
                                        }
                                    }
                                } else {
                                    if (texCoordScaled.y < 10048) {
                                        if (texCoordScaled.x < 4304) {
                                            if (texCoordScaled.x >= 4240 && texCoordScaled.x < 4272 && texCoordScaled.y >= 9984 && texCoordScaled.y < 10048) {
                                                #ifdef GLOWING_POTION_EFFECT
                                                    emission = 4.0 * pow2(pow2(colorP.r));
                                                #endif
                                            }
                                        } else {
                                            if (texCoordScaled.x >= 4304 && texCoordScaled.x < 4336 && texCoordScaled.y >= 9984 && texCoordScaled.y < 10048) {
                                                #ifdef GLOWING_POTION_EFFECT
                                                    emission = 4.0 * pow2(pow2(colorP.r));
                                                #endif
                                            }
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 4740 && texCoordScaled.x < 4772 && texCoordScaled.y >= 10048 && texCoordScaled.y < 10112) {
                                            if (color.b > 0.6 && color.a > 0.9) {
                                                color.rgb = pow1_5(color.rgb);
                                                emission = 2.5;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            if (texCoordScaled.y < 9824) {
                if (texCoordScaled.x < 11652) {
                    if (texCoordScaled.y < 9560) {
                        if (texCoordScaled.x < 8984) {
                            if (texCoordScaled.x >= 8284 && texCoordScaled.x < 8348 && texCoordScaled.y >= 9432 && texCoordScaled.y < 9560) {
                                color.rgb *= 0.7;
                                color.a *= 0.6;
                            }
                        } else {
                            if (texCoordScaled.y < 9488) {
                                if (texCoordScaled.x >= 10884 && texCoordScaled.x < 11204 && texCoordScaled.y >= 9456 && texCoordScaled.y < 9488) {
                                    color.rgb *= 0.7;
                                    color.a *= 0.6;
                                }
                            } else {
                                if (texCoordScaled.x < 10884) {
                                    if (texCoordScaled.x >= 8984 && texCoordScaled.x < 9176 && texCoordScaled.y >= 9488 && texCoordScaled.y < 9560) {
                                        emission = 5.0;
                                    }
                                } else {
                                    if (texCoordScaled.x >= 10884 && texCoordScaled.x < 11204 && texCoordScaled.y >= 9488 && texCoordScaled.y < 9560) {
                                        color.rgb *= 0.7;
                                        color.a *= 0.6;
                                    }
                                }
                            }
                        }
                    } else {
                        if (texCoordScaled.x < 8560) {
                            if (texCoordScaled.y < 9592) {
                                if (texCoordScaled.x < 8412) {
                                    if (texCoordScaled.x >= 8284 && texCoordScaled.x < 8348 && texCoordScaled.y >= 9560 && texCoordScaled.y < 9592) {
                                        color.rgb *= 0.7;
                                        color.a *= 0.6;
                                    }
                                } else {
                                    if (texCoordScaled.x >= 8412 && texCoordScaled.x < 8476 && texCoordScaled.y >= 9560 && texCoordScaled.y < 9592) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                }
                            } else {
                                if (texCoordScaled.x < 7600) {
                                    if (texCoordScaled.x < 7488) {
                                        if (texCoordScaled.x >= 7296 && texCoordScaled.x < 7360 && texCoordScaled.y >= 9696 && texCoordScaled.y < 9824) {
                                            #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                                            #endif
                                            #ifdef PURPLE_END_FIRE_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                                            #endif
                                            
                                            emission = 2.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 7488 && texCoordScaled.x < 7552 && texCoordScaled.y >= 9696 && texCoordScaled.y < 9824) {
                                            #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                                            #endif
                                            #ifdef PURPLE_END_FIRE_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                                            #endif
                                            
                                            emission = 2.0;
                                        }
                                    }
                                } else {
                                    if (texCoordScaled.x < 8284) {
                                        if (texCoordScaled.x >= 7600 && texCoordScaled.x < 7664 && texCoordScaled.y >= 9592 && texCoordScaled.y < 9720) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x < 8412) {
                                            if (texCoordScaled.x >= 8284 && texCoordScaled.x < 8348 && texCoordScaled.y >= 9592 && texCoordScaled.y < 9688) {
                                                color.rgb *= 0.7;
                                                color.a *= 0.6;
                                            }
                                        } else {
                                            if (texCoordScaled.x >= 8412 && texCoordScaled.x < 8476 && texCoordScaled.y >= 9592 && texCoordScaled.y < 9688) {
                                                color.a *= 0.5;
                                                materialMask = 0.0;
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            if (texCoordScaled.y < 9688) {
                                if (texCoordScaled.x < 8984) {
                                    if (texCoordScaled.x >= 8604 && texCoordScaled.x < 8668 && texCoordScaled.y >= 9560 && texCoordScaled.y < 9688) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                } else {
                                    if (texCoordScaled.x < 10884) {
                                        if (texCoordScaled.x >= 8984 && texCoordScaled.x < 9176 && texCoordScaled.y >= 9560 && texCoordScaled.y < 9616) {
                                            emission = 5.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 10884 && texCoordScaled.x < 11204 && texCoordScaled.y >= 9560 && texCoordScaled.y < 9688) {
                                            color.rgb *= 0.7;
                                            color.a *= 0.6;
                                        }
                                    }
                                }
                            } else {
                                if (texCoordScaled.x < 10884) {
                                    if (texCoordScaled.x >= 8560 && texCoordScaled.x < 8624 && texCoordScaled.y >= 9688 && texCoordScaled.y < 9816) {
                                        #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                            color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                                        #endif
                                        #ifdef PURPLE_END_FIRE_INTERNAL
                                            color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                                        #endif
                                        
                                        emission = 2.0;
                                    }
                                } else {
                                    if (texCoordScaled.y < 9696) {
                                        if (texCoordScaled.x >= 10884 && texCoordScaled.x < 11204 && texCoordScaled.y >= 9688 && texCoordScaled.y < 9696) {
                                            color.rgb *= 0.7;
                                            color.a *= 0.6;
                                        }
                                    } else {
                                        if (texCoordScaled.x < 11524) {
                                            if (texCoordScaled.x >= 10884 && texCoordScaled.x < 11204 && texCoordScaled.y >= 9696 && texCoordScaled.y < 9712) {
                                                color.rgb *= 0.7;
                                                color.a *= 0.6;
                                            }
                                        } else {
                                            if (texCoordScaled.x >= 11524 && texCoordScaled.x < 11588 && texCoordScaled.y >= 9696 && texCoordScaled.y < 9824) {
                                                #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                                    color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                                                #endif
                                                #ifdef PURPLE_END_FIRE_INTERNAL
                                                    color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                                                #endif
                                                
                                                emission = 2.0;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if (texCoordScaled.y < 9624) {
                        if (texCoordScaled.x < 15880) {
                            if (texCoordScaled.x >= 13260 && texCoordScaled.x < 13900 && texCoordScaled.y >= 8856 && texCoordScaled.y < 9112) {
                                #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                    color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                                #endif
                                #ifdef PURPLE_END_FIRE_INTERNAL
                                    color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                                #endif
                                
                                emission = 2.0;
                            }
                        } else {
                            if (texCoordScaled.y < 9576) {
                                if (texCoordScaled.x >= 15880 && texCoordScaled.x < 15944 && texCoordScaled.y >= 9448 && texCoordScaled.y < 9576) {
                                    color.rgb *= 0.7;
                                    color.a *= 0.6;
                                }
                            } else {
                                if (texCoordScaled.x < 16008) {
                                    if (texCoordScaled.x >= 15880 && texCoordScaled.x < 15944 && texCoordScaled.y >= 9576 && texCoordScaled.y < 9624) {
                                        color.rgb *= 0.7;
                                        color.a *= 0.6;
                                    }
                                } else {
                                    if (texCoordScaled.x >= 16008 && texCoordScaled.x < 16072 && texCoordScaled.y >= 9576 && texCoordScaled.y < 9624) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                }
                            }
                        }
                    } else {
                        if (texCoordScaled.x < 12484) {
                            if (texCoordScaled.x < 11908) {
                                if (texCoordScaled.x < 11780) {
                                    if (texCoordScaled.x >= 11652 && texCoordScaled.x < 11716 && texCoordScaled.y >= 9696 && texCoordScaled.y < 9824) {
                                        #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                            color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                                        #endif
                                        #ifdef PURPLE_END_FIRE_INTERNAL
                                            color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                                        #endif
                                        
                                        emission = 2.0;
                                    }
                                } else {
                                    if (texCoordScaled.x >= 11780 && texCoordScaled.x < 11844 && texCoordScaled.y >= 9696 && texCoordScaled.y < 9824) {
                                        #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                            color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                                        #endif
                                        #ifdef PURPLE_END_FIRE_INTERNAL
                                            color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                                        #endif
                                        
                                        emission = 2.0;
                                    }
                                }
                            } else {
                                if (texCoordScaled.x < 12036) {
                                    if (texCoordScaled.x >= 11908 && texCoordScaled.x < 11972 && texCoordScaled.y >= 9696 && texCoordScaled.y < 9824) {
                                        #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                            color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                                        #endif
                                        #ifdef PURPLE_END_FIRE_INTERNAL
                                            color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                                        #endif
                                        
                                        emission = 2.0;
                                    }
                                } else {
                                    if (texCoordScaled.x < 12164) {
                                        if (texCoordScaled.x >= 12036 && texCoordScaled.x < 12100 && texCoordScaled.y >= 9696 && texCoordScaled.y < 9824) {
                                            #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                                            #endif
                                            #ifdef PURPLE_END_FIRE_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                                            #endif
                                            
                                            emission = 2.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 12164 && texCoordScaled.x < 12228 && texCoordScaled.y >= 9696 && texCoordScaled.y < 9824) {
                                            #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                                            #endif
                                            #ifdef PURPLE_END_FIRE_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                                            #endif
                                            
                                            emission = 2.0;
                                        }
                                    }
                                }
                            }
                        } else {
                            if (texCoordScaled.y < 9704) {
                                if (texCoordScaled.x < 15880) {
                                    if (texCoordScaled.x >= 13816 && texCoordScaled.x < 14584 && texCoordScaled.y >= 9624 && texCoordScaled.y < 9704) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                } else {
                                    if (texCoordScaled.x < 16008) {
                                        if (texCoordScaled.x >= 15880 && texCoordScaled.x < 15944 && texCoordScaled.y >= 9624 && texCoordScaled.y < 9704) {
                                            color.rgb *= 0.7;
                                            color.a *= 0.6;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 16008 && texCoordScaled.x < 16072 && texCoordScaled.y >= 9624 && texCoordScaled.y < 9704) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    }
                                }
                            } else {
                                if (texCoordScaled.x < 13816) {
                                    if (texCoordScaled.x >= 12484 && texCoordScaled.x < 12740 && texCoordScaled.y >= 9776 && texCoordScaled.y < 9824) {
                                        emission = 1.6 * pow2(color.b);
                                    }
                                } else {
                                    if (texCoordScaled.x < 15032) {
                                        if (texCoordScaled.x >= 13816 && texCoordScaled.x < 14584 && texCoordScaled.y >= 9704 && texCoordScaled.y < 9752) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 15032 && texCoordScaled.x < 15096 && texCoordScaled.y >= 9704 && texCoordScaled.y < 9824) {
                                            #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                                            #endif
                                            #ifdef PURPLE_END_FIRE_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                                            #endif
                                            
                                            emission = 2.0;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                if (texCoordScaled.x < 12380) {
                    if (texCoordScaled.y < 9968) {
                        if (texCoordScaled.x < 8896) {
                            if (texCoordScaled.y < 9872) {
                                if (texCoordScaled.x >= 5752 && texCoordScaled.x < 5816 && texCoordScaled.y >= 9856 && texCoordScaled.y < 9872) {
                                    color.a *= 0.5;
                                    materialMask = 0.0;
                                }
                            } else {
                                if (texCoordScaled.x < 8640) {
                                    if (texCoordScaled.x >= 5752 && texCoordScaled.x < 5816 && texCoordScaled.y >= 9872 && texCoordScaled.y < 9968) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                } else {
                                    if (texCoordScaled.x < 8768) {
                                        if (texCoordScaled.x >= 8640 && texCoordScaled.x < 8704 && texCoordScaled.y >= 9872 && texCoordScaled.y < 9968) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 8768 && texCoordScaled.x < 8832 && texCoordScaled.y >= 9872 && texCoordScaled.y < 9968) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    }
                                }
                            }
                        } else {
                            if (texCoordScaled.y < 9856) {
                                if (texCoordScaled.x >= 11804 && texCoordScaled.x < 12188 && texCoordScaled.y >= 9824 && texCoordScaled.y < 9856) {
                                    if (color.b > 0.6 && color.a > 0.9) {
                                        color.rgb = pow1_5(color.rgb);
                                        emission = 2.5;
                                    }
                                }
                            } else {
                                if (texCoordScaled.x < 11804) {
                                    if (texCoordScaled.x < 9024) {
                                        if (texCoordScaled.x >= 8896 && texCoordScaled.x < 8960 && texCoordScaled.y >= 9872 && texCoordScaled.y < 9968) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 9024 && texCoordScaled.x < 9088 && texCoordScaled.y >= 9872 && texCoordScaled.y < 9968) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    }
                                } else {
                                    if (texCoordScaled.x < 12188) {
                                        if (texCoordScaled.x >= 11804 && texCoordScaled.x < 12188 && texCoordScaled.y >= 9856 && texCoordScaled.y < 9952) {
                                            if (color.b > 0.6 && color.a > 0.9) {
                                                color.rgb = pow1_5(color.rgb);
                                                emission = 2.5;
                                            }
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 12188 && texCoordScaled.x < 12252 && texCoordScaled.y >= 9856 && texCoordScaled.y < 9968) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        if (texCoordScaled.x < 8896) {
                            if (texCoordScaled.y < 9976) {
                                if (texCoordScaled.x < 8640) {
                                    if (texCoordScaled.x >= 5752 && texCoordScaled.x < 5816 && texCoordScaled.y >= 9968 && texCoordScaled.y < 9976) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                } else {
                                    if (texCoordScaled.x < 8768) {
                                        if (texCoordScaled.x >= 8640 && texCoordScaled.x < 8704 && texCoordScaled.y >= 9968 && texCoordScaled.y < 9976) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 8768 && texCoordScaled.x < 8832 && texCoordScaled.y >= 9968 && texCoordScaled.y < 9976) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    }
                                }
                            } else {
                                if (texCoordScaled.x < 8640) {
                                    if (texCoordScaled.x < 7640) {
                                        if (texCoordScaled.x >= 5752 && texCoordScaled.x < 5816 && texCoordScaled.y >= 9976 && texCoordScaled.y < 9984) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 7640 && texCoordScaled.x < 7672 && texCoordScaled.y >= 9976 && texCoordScaled.y < 10040) {
                                            if (color.b > 1.15 * (color.r + color.g) && color.g > color.r * 1.25 && color.g < 0.425 && color.b > 0.75) { // Water Particle
                                                materialMask = 0.0;
                                                color.rgb = sqrt3(color.rgb);
                                                color.rgb *= 0.7;
                                                if (dither > 0.4) discard;
                                                #ifdef NO_RAIN_ABOVE_CLOUDS
                                                    if (cameraPosition.y > maximumCloudsHeight) discard;
                                                #endif
                                            #ifdef OVERWORLD
                                            } else if (color.b > 0.7 && color.r < 0.28 && color.g < 0.425 && color.g > color.r * 1.4) { // physics mod rain
                                                #ifdef NO_RAIN_ABOVE_CLOUDS
                                                    if (cameraPosition.y > maximumCloudsHeight) discard;
                                                #endif
                                            
                                                if (color.a < 0.1 || isEyeInWater == 3) discard;
                                                color.a *= rainTexOpacity;
                                                color.rgb = sqrt2(color.rgb) * (blocklightCol * 2.0 * lmCoord.x + ambientColor * lmCoord.y * (0.7 + 0.35 * sunFactor));
                                            } else if (color.rgb == vec3(1.0) && color.a < 0.765 && color.a > 0.605) { // physics mod snow (default snow opacity only)
                                                #ifdef NO_RAIN_ABOVE_CLOUDS
                                                    if (cameraPosition.y > maximumCloudsHeight) discard;
                                                #endif
                                            
                                                if (color.a < 0.1 || isEyeInWater == 3) discard;
                                                color.a *= snowTexOpacity;
                                                color.rgb = sqrt2(color.rgb) * (blocklightCol * 2.0 * lmCoord.x + lmCoord.y * (0.7 + 0.35 * sunFactor) + ambientColor * 0.2);
                                            #endif
                                            } else if (color.r == color.g && color.r - 0.5 * color.b < 0.06) { // Underwater Particle
                                                color.rgb = sqrt2(color.rgb) * 0.35;
                                                if (fract(playerPos.y + cameraPosition.y) > 0.25) discard;
                                            }
                                            
                                            float dotColor = dot(color.rgb, color.rgb);
                                            if (dotColor > 0.25 && color.g < 0.5 && (color.b > color.r * 1.1 && color.r > 0.3 || color.r > (color.g + color.b) * 3.0)) {
                                                // Ender Particle, Crying Obsidian Particle, Redstone Particle
                                                emission = clamp(color.r * 8.0, 1.6, 5.0);
                                                color.rgb = pow1_5(color.rgb);
                                                lmCoordM = vec2(0.0);
                                                #if defined NETHER && defined BIOME_COLORED_NETHER_PORTALS
                                                    if (color.b > color.r * color.r && color.g < 0.16 && color.r > 0.2)
                                                        color.rgb = changeColorFunction(color.rgb, 10.0, netherColor, 1.0); // Nether Portal
                                                #endif
                                            } else if (color.r > 0.83 && color.g > 0.23 && color.b < 0.4) {
                                                // Lava Particles
                                                emission = 2.0;
                                                color.b *= 0.5;
                                                color.r *= 1.2;
                                                color.rgb += vec3(min(pow2(pow2(emission * 0.35)), 0.4)) * LAVA_TEMPERATURE * 0.5;
                                                emission *= LAVA_EMISSION;
                                                #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                                    color.rgb = changeColorFunction(color.rgb, 3.5, colorSoul, inSoulValley);
                                                #endif
                                                #ifdef PURPLE_END_FIRE_INTERNAL
                                                    color.rgb = changeColorFunction(color.rgb, 3.5, colorEndBreath, 1.0);
                                                #endif
                                            }
                                        }
                                    }
                                } else {
                                    if (texCoordScaled.x < 8768) {
                                        if (texCoordScaled.x >= 8640 && texCoordScaled.x < 8704 && texCoordScaled.y >= 9976 && texCoordScaled.y < 10000) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 8768 && texCoordScaled.x < 8832 && texCoordScaled.y >= 9976 && texCoordScaled.y < 10000) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    }
                                }
                            }
                        } else {
                            if (texCoordScaled.y < 10000) {
                                if (texCoordScaled.x < 10104) {
                                    if (texCoordScaled.x < 9024) {
                                        if (texCoordScaled.x >= 8896 && texCoordScaled.x < 8960 && texCoordScaled.y >= 9968 && texCoordScaled.y < 10000) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 9024 && texCoordScaled.x < 9088 && texCoordScaled.y >= 9968 && texCoordScaled.y < 10000) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    }
                                } else {
                                    if (texCoordScaled.x < 12188) {
                                        if (texCoordScaled.x >= 10104 && texCoordScaled.x < 10264 && texCoordScaled.y >= 9968 && texCoordScaled.y < 10000) {
                                            #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                                            #endif
                                            #ifdef PURPLE_END_FIRE_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                                            #endif
                                            
                                            emission = 2.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 12188 && texCoordScaled.x < 12252 && texCoordScaled.y >= 9968 && texCoordScaled.y < 9984) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    }
                                }
                            } else {
                                if (texCoordScaled.x < 10104) {
                                    if (texCoordScaled.x >= 8960 && texCoordScaled.x < 9088 && texCoordScaled.y >= 10000 && texCoordScaled.y < 10064) {
                                        if (color.b > 1.15 * (color.r + color.g) && color.g > color.r * 1.25 && color.g < 0.425 && color.b > 0.75) { // Water Particle
                                            materialMask = 0.0;
                                            color.rgb = sqrt3(color.rgb);
                                            color.rgb *= 0.7;
                                            if (dither > 0.4) discard;
                                            #ifdef NO_RAIN_ABOVE_CLOUDS
                                                if (cameraPosition.y > maximumCloudsHeight) discard;
                                            #endif
                                        #ifdef OVERWORLD
                                        } else if (color.b > 0.7 && color.r < 0.28 && color.g < 0.425 && color.g > color.r * 1.4) { // physics mod rain
                                            #ifdef NO_RAIN_ABOVE_CLOUDS
                                                if (cameraPosition.y > maximumCloudsHeight) discard;
                                            #endif
                                        
                                            if (color.a < 0.1 || isEyeInWater == 3) discard;
                                            color.a *= rainTexOpacity;
                                            color.rgb = sqrt2(color.rgb) * (blocklightCol * 2.0 * lmCoord.x + ambientColor * lmCoord.y * (0.7 + 0.35 * sunFactor));
                                        } else if (color.rgb == vec3(1.0) && color.a < 0.765 && color.a > 0.605) { // physics mod snow (default snow opacity only)
                                            #ifdef NO_RAIN_ABOVE_CLOUDS
                                                if (cameraPosition.y > maximumCloudsHeight) discard;
                                            #endif
                                        
                                            if (color.a < 0.1 || isEyeInWater == 3) discard;
                                            color.a *= snowTexOpacity;
                                            color.rgb = sqrt2(color.rgb) * (blocklightCol * 2.0 * lmCoord.x + lmCoord.y * (0.7 + 0.35 * sunFactor) + ambientColor * 0.2);
                                        #endif
                                        } else if (color.r == color.g && color.r - 0.5 * color.b < 0.06) { // Underwater Particle
                                            color.rgb = sqrt2(color.rgb) * 0.35;
                                            if (fract(playerPos.y + cameraPosition.y) > 0.25) discard;
                                        }
                                        
                                        float dotColor = dot(color.rgb, color.rgb);
                                        if (dotColor > 0.25 && color.g < 0.5 && (color.b > color.r * 1.1 && color.r > 0.3 || color.r > (color.g + color.b) * 3.0)) {
                                            // Ender Particle, Crying Obsidian Particle, Redstone Particle
                                            emission = clamp(color.r * 8.0, 1.6, 5.0);
                                            color.rgb = pow1_5(color.rgb);
                                            lmCoordM = vec2(0.0);
                                            #if defined NETHER && defined BIOME_COLORED_NETHER_PORTALS
                                                if (color.b > color.r * color.r && color.g < 0.16 && color.r > 0.2)
                                                    color.rgb = changeColorFunction(color.rgb, 10.0, netherColor, 1.0); // Nether Portal
                                            #endif
                                        } else if (color.r > 0.83 && color.g > 0.23 && color.b < 0.4) {
                                            // Lava Particles
                                            emission = 2.0;
                                            color.b *= 0.5;
                                            color.r *= 1.2;
                                            color.rgb += vec3(min(pow2(pow2(emission * 0.35)), 0.4)) * LAVA_TEMPERATURE * 0.5;
                                            emission *= LAVA_EMISSION;
                                            #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.5, colorSoul, inSoulValley);
                                            #endif
                                            #ifdef PURPLE_END_FIRE_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.5, colorEndBreath, 1.0);
                                            #endif
                                        }
                                    }
                                } else {
                                    if (texCoordScaled.x >= 10104 && texCoordScaled.x < 10264 && texCoordScaled.y >= 10000 && texCoordScaled.y < 10032) {
                                        #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                            color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                                        #endif
                                        #ifdef PURPLE_END_FIRE_INTERNAL
                                            color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                                        #endif
                                        
                                        emission = 2.0;
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if (texCoordScaled.y < 9904) {
                        if (texCoordScaled.x < 12996) {
                            if (texCoordScaled.y < 9864) {
                                if (texCoordScaled.x >= 12484 && texCoordScaled.x < 12740 && texCoordScaled.y >= 9824 && texCoordScaled.y < 9864) {
                                    emission = 1.6 * pow2(color.b);
                                }
                            } else {
                                if (texCoordScaled.x < 12484) {
                                    if (texCoordScaled.x >= 12380 && texCoordScaled.x < 12444 && texCoordScaled.y >= 9864 && texCoordScaled.y < 9904) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                } else {
                                    if (texCoordScaled.x >= 12484 && texCoordScaled.x < 12740 && texCoordScaled.y >= 9864 && texCoordScaled.y < 9904) {
                                        emission = 1.6 * pow2(color.b);
                                    }
                                }
                            }
                        } else {
                            if (texCoordScaled.y < 9832) {
                                if (texCoordScaled.x >= 15032 && texCoordScaled.x < 15096 && texCoordScaled.y >= 9824 && texCoordScaled.y < 9832) {
                                    #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                        color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                                    #endif
                                    #ifdef PURPLE_END_FIRE_INTERNAL
                                        color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                                    #endif
                                    
                                    emission = 2.0;
                                }
                            } else {
                                if (texCoordScaled.x < 14916) {
                                    if (texCoordScaled.x >= 12996 && texCoordScaled.x < 13060 && texCoordScaled.y >= 9880 && texCoordScaled.y < 9904) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                } else {
                                    if (texCoordScaled.x >= 14916 && texCoordScaled.x < 15236 && texCoordScaled.y >= 9832 && texCoordScaled.y < 9904) {
                                        if (color.b > 0.6 && color.a > 0.9) {
                                            color.rgb = pow1_5(color.rgb);
                                            emission = 2.5;
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        if (texCoordScaled.x < 14916) {
                            if (texCoordScaled.y < 9992) {
                                if (texCoordScaled.x < 12892) {
                                    if (texCoordScaled.x >= 12380 && texCoordScaled.x < 12444 && texCoordScaled.y >= 9904 && texCoordScaled.y < 9992) {
                                        color.a *= 0.5;
                                        materialMask = 0.0;
                                    }
                                } else {
                                    if (texCoordScaled.x < 12996) {
                                        if (texCoordScaled.x >= 12892 && texCoordScaled.x < 12956 && texCoordScaled.y >= 9904 && texCoordScaled.y < 9992) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 12996 && texCoordScaled.x < 13060 && texCoordScaled.y >= 9904 && texCoordScaled.y < 9992) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    }
                                }
                            } else {
                                if (texCoordScaled.x < 12996) {
                                    if (texCoordScaled.x < 12892) {
                                        if (texCoordScaled.x >= 12380 && texCoordScaled.x < 12412 && texCoordScaled.y >= 9992 && texCoordScaled.y < 10056) {
                                            #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                                            #endif
                                            #ifdef PURPLE_END_FIRE_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                                            #endif
                                            
                                            emission = 2.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 12892 && texCoordScaled.x < 12956 && texCoordScaled.y >= 9992 && texCoordScaled.y < 10032) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    }
                                } else {
                                    if (texCoordScaled.y < 10008) {
                                        if (texCoordScaled.x >= 12996 && texCoordScaled.x < 13060 && texCoordScaled.y >= 9992 && texCoordScaled.y < 10008) {
                                            color.a *= 0.5;
                                            materialMask = 0.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 14556 && texCoordScaled.x < 14588 && texCoordScaled.y >= 10008 && texCoordScaled.y < 10072) {
                                            #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                                            #endif
                                            #ifdef PURPLE_END_FIRE_INTERNAL
                                                color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                                            #endif
                                            
                                            emission = 2.0;
                                        }
                                    }
                                }
                            }
                        } else {
                            if (texCoordScaled.y < 9936) {
                                if (texCoordScaled.x >= 14916 && texCoordScaled.x < 15236 && texCoordScaled.y >= 9904 && texCoordScaled.y < 9936) {
                                    if (color.b > 0.6 && color.a > 0.9) {
                                        color.rgb = pow1_5(color.rgb);
                                        emission = 2.5;
                                    }
                                }
                            } else {
                                if (texCoordScaled.x < 16228) {
                                    if (texCoordScaled.y < 10032) {
                                        if (texCoordScaled.x >= 14916 && texCoordScaled.x < 15236 && texCoordScaled.y >= 9936 && texCoordScaled.y < 9960) {
                                            if (color.b > 0.6 && color.a > 0.9) {
                                                color.rgb = pow1_5(color.rgb);
                                                emission = 2.5;
                                            }
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 16132 && texCoordScaled.x < 16228 && texCoordScaled.y >= 10032 && texCoordScaled.y < 10096) {
                                            if (color.a > 0.0) {
                                                emission = 1.0;
                                                color.rgb *= color.rgb;
                                            }
                                        }
                                    }
                                } else {
                                    if (texCoordScaled.y < 10032) {
                                        if (texCoordScaled.x >= 16324 && texCoordScaled.x < 16372 && texCoordScaled.y >= 9936 && texCoordScaled.y < 10032) {
                                            emission = 5.0;
                                        }
                                    } else {
                                        if (texCoordScaled.x >= 16228 && texCoordScaled.x < 16260 && texCoordScaled.y >= 10032 && texCoordScaled.y < 10096) {
                                            if (color.b > 0.6 && color.a > 0.9) {
                                                color.rgb = pow1_5(color.rgb);
                                                emission = 2.5;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    bool noSmoothLighting = false;

    #else
        #if defined OVERWORLD && defined NO_RAIN_ABOVE_CLOUDS || defined NETHER && (defined BIOME_COLORED_NETHER_PORTALS || defined SOUL_SAND_VALLEY_OVERHAUL_INTERNAL)
            if (atlasSize.x < 900.0) {
                if (color.b > 1.15 * (color.r + color.g) && color.g > color.r * 1.25 && color.g < 0.425 && color.b > 0.75) { // Water Particle
                    #ifdef NO_RAIN_ABOVE_CLOUDS
                        if (cameraPosition.y > maximumCloudsHeight) discard;
                    #endif
                }
                #ifdef OVERWORLD
                if (color.b > 0.7 && color.r < 0.28 && color.g < 0.425 && color.g > color.r * 1.4) { // physics mod rain
                    #ifdef NO_RAIN_ABOVE_CLOUDS
                        if (cameraPosition.y > maximumCloudsHeight) discard;
                    #endif
                    if (color.a < 0.1 || isEyeInWater == 3) discard;
                    color.a *= rainTexOpacity;
                    color.rgb = sqrt2(color.rgb) * (blocklightCol * 2.0 * lmCoord.x + ambientColor * lmCoord.y * (0.7 + 0.35 * sunFactor));
                    color.rgb *= vec3(WEATHER_TEX_R, WEATHER_TEX_G, WEATHER_TEX_B);
                } else if (color.rgb == vec3(1.0) && color.a < 0.765 && color.a > 0.605) { // physics mod snow (default snow opacity only)
                    #ifdef NO_RAIN_ABOVE_CLOUDS
                        if (cameraPosition.y > maximumCloudsHeight) discard;
                    #endif
                    if (color.a < 0.1 || isEyeInWater == 3) discard;
                    color.a *= snowTexOpacity;
                    color.rgb = sqrt2(color.rgb) * (blocklightCol * 2.0 * lmCoord.x + lmCoord.y * (0.7 + 0.35 * sunFactor) + ambientColor * 0.2);
                    color.rgb *= vec3(WEATHER_TEX_R, WEATHER_TEX_G, WEATHER_TEX_B);
                }
                #endif
                if (color.r == 1.0 && color.b < 0.778 && color.g < 0.97) { // Fire Particle
                    #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                        color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                    #endif
                    #ifdef PURPLE_END_FIRE_INTERNAL
                        color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                    #endif
                    emission = 2.0;
                }
                if (max(abs(colorP.r - colorP.b), abs(colorP.b - colorP.g)) < 0.001) {
                    if (dot(color.rgb, color.rgb) > 0.25 && color.g < 0.5 && (color.b > color.r * 1.1 && color.r > 0.3 || color.r > (color.g + color.b) * 3.0)) {
                        #if defined NETHER && defined BIOME_COLORED_NETHER_PORTALS
                            vec3 color2 = pow1_5(color.rgb);
                            if (color2.b > color2.r * color2.r && color2.g < 0.16 && color2.r > 0.2) {
                                emission = clamp(color2.r * 8.0, 1.6, 5.0);
                                color.rgb = color.rgb = changeColorFunction(color.rgb, 10.0, netherColor, 1.0);
                                lmCoordM = vec2(0.0);
                            }
                        #endif
                    } else if (color.r > 0.83 && color.g > 0.23 && color.b < 0.4) {
                        #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                            color.rgb = changeColorFunction(color.rgb, 3.5, colorSoul, inSoulValley);
                        #endif
                        #ifdef PURPLE_END_FIRE_INTERNAL
                            color.rgb = changeColorFunction(color.rgb, 3.5, colorEndBreath, 1.0);
                        #endif
                    }
                }
            }
        #endif
        bool noSmoothLighting = true;
    #endif

    #ifdef REDUCE_CLOSE_PARTICLES
        if (lViewPos - 1.0 < dither) discard;
    #endif

    #ifdef GLOWING_COLORED_PARTICLES
        if (atlasSize.x < 900.0) {
            if (dot(glColor.rgb, vec3(1.0)) < 2.99) {
                emission = 5.0;
            }
        }
    #endif

    #if MONOTONE_WORLD > 0
        #if MONOTONE_WORLD == 1
            color.rgb = vec3(1.0);
        #elif MONOTONE_WORLD == 2
            color.rgb = vec3(0.0);
        #else
            color.rgb = vec3(0.5);
        #endif
    #endif

    #ifdef SS_BLOCKLIGHT
        blocklightCol = ApplyMultiColoredBlocklight(blocklightCol, screenPos, playerPos, lmCoord.x);
    #endif

    bool isLightSource = lmCoord.x > 0.99;

    DoLighting(color, shadowMult, playerPos, viewPos, lViewPos, geoNormal, normalM, dither,
               worldGeoNormal, lmCoordM, noSmoothLighting, false, true,
               false, 0, 0.0, 1.0, emission, purkinjeOverwrite, isLightSource,
               enderDragonDead);

    #if MC_VERSION >= 11500
        vec3 nViewPos = normalize(viewPos);

        float VdotU = dot(nViewPos, upVec);
        float VdotS = dot(nViewPos, sunVec);
        float sky = 0.0;

        float prevAlpha = color.a;
        DoFog(color, sky, lViewPos, playerPos, VdotU, VdotS, dither, false, 0.0, 0.0);
        color.a = prevAlpha;
    #endif

    vec3 translucentMult = mix(vec3(0.666), color.rgb * (1.0 - pow2(pow2(color.a))), color.a);

    float SSBLMask = 0.0;
    #ifdef ENTITIES_ARE_LIGHT
        SSBLMask = 1.0;
    #endif

    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);
    #endif

    /* DRAWBUFFERS:063 */
    gl_FragData[0] = color;
    gl_FragData[1] = vec4(0.0, materialMask, 0.0, lmCoord.x + clamp01(purkinjeOverwrite) + clamp01(emission));
    gl_FragData[2] = vec4(1.0 - translucentMult, 1.0);

    #ifdef SS_BLOCKLIGHT
        /* RENDERTARGETS: 0,6,3,9,10 */
        gl_FragData[3] = vec4(0.0, 0.0, 0.0, SSBLMask);
        gl_FragData[4] = vec4(0.0, 0.0, 0.0, SSBLMask);
    #endif
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

out vec2 texCoord;
out vec2 lmCoord;

flat out vec3 upVec, sunVec, northVec, eastVec;
out vec3 normal;

flat out vec4 glColor;

//Attributes//

#if defined WAVE_EVERYTHING || defined ATLAS_ROTATION
    attribute vec4 mc_midTexCoord;
#endif

//Common Variables//

//Common Functions//

//Includes//

#ifdef WAVE_EVERYTHING
    #include "/lib/materials/materialMethods/wavingBlocks.glsl"
#endif

//Program//
void main() {
    vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
    gl_Position = ftransform();

    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    #ifdef ATLAS_ROTATION
        texCoord += texCoord * float(hash33(mod(cameraPosition * 0.5, vec3(100.0))));
    #endif
    lmCoord  = GetLightMapCoordinates();

    glColor = gl_Color;

    normal = normalize(gl_NormalMatrix * gl_Normal);
    upVec = normalize(gbufferModelView[1].xyz);
    eastVec = normalize(gbufferModelView[0].xyz);
    northVec = normalize(gbufferModelView[2].xyz);
    sunVec = GetSunVector();

    #if defined MIRROR_DIMENSION || defined WORLD_CURVATURE || defined WAVE_EVERYTHING
        #ifdef MIRROR_DIMENSION
            doMirrorDimension(position);
        #endif
        #ifdef WORLD_CURVATURE
            position.y += doWorldCurvature(position.xz);
        #endif
        #ifdef WAVE_EVERYTHING
            DoWaveEverything(position.xyz);
        #endif
        gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
    #endif

    #ifdef FLICKERING_FIX
        gl_Position.z -= 0.000002;
    #endif
}

#endif
