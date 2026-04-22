#include "/lib/shaderSettings/entityMaterials.glsl"
if (entityId < 50128) { // 50000 to 50128
    if (entityId < 50064) { // 50000 to 50064
        if (entityId < 50032) { // 50000 to 50032
            if (entityId < 50016) { // 50000 to 50016
                if (entityId < 50008) { // 50000 to 50008
                    if (entityId == 50000) { // End Crystal
                        lmCoordM.x *= 0.7;

                        if (color.g * 1.2 < color.r) {
                            emission = 12.0 * color.g;
                            color.r *= 1.1;
                        }
                        emission *= END_CRYSTAL_EMISSION;
                    } else if (entityId == 50004) { // Lightning Bolt
                        #include "/lib/materials/specificMaterials/others/lightningBolt.glsl"
                    }
                } else { // 50008 to 50016
                    if (entityId == 50008) { // Item Frame, Glow Item Frame
                        noSmoothLighting = true;
                    } else if (entityId == 50012) { // Iron Golem
                        #include "/lib/materials/specificMaterials/terrain/ironBlock.glsl"

                        smoothnessD *= 0.4;
                    } else { // 50015 - Armor Stand
                        // Do nothing for now
                    }
                }
            } else { // 50016 to 50032
                if (entityId < 50024) { // 50016 to 50024
                    if (entityId == 50016 || entityId == 50017) { // Player
                        if (entityColor.a < 0.001) {
                            #ifdef COATED_TEXTURES
                                noiseFactor = 0.5;
                            #endif

                            if (CheckForColor(texelFetch(tex, ivec2(0, 0), 0).rgb, vec3(23, 46, 92))) {
                                for (int i = 63; i >= 56; i--) {
                                    vec3 dif = color.rgb - texelFetch(tex, ivec2(i, 0), 0).rgb;
                                    if (dif == clamp(dif, vec3(-0.001), vec3(0.001))) {
                                        emission = 2.0 * texelFetch(tex, ivec2(i, 1), 0).r;
                                    }
                                }
                            }
                            bool selfCheck = false;
                            #if IRIS_VERSION >= 10800
                                if (entityId == 50017) {
                                    selfCheck = true;
                                    entitySSBLMask = 0.0;
                                }
                            #else
                                if (length(playerPos) < 4.0) {
                                    selfCheck = true;
                                    entitySSBLMask = 0.0;
                                }
                            #endif
                        }
                    } else /*if (entityId == 50020)*/ { // Blaze
                        lmCoordM = vec2(0.9, 0.0);
                        emission = min(color.r, 0.7) * 1.4;

                        float dotColor = dot(color.rgb, color.rgb);
                        if (abs(dotColor - 1.5) > 1.4) {
                            emission = 5.0;
                        } else {
                            #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                                color.rgb = changeColorFunction(color.rgb, 2.0, colorSoul, inSoulValley);
                            #endif
                            #ifdef PURPLE_END_FIRE_INTERNAL
                                color.rgb = changeColorFunction(color.rgb, 2.0, colorEndBreath, 1.0);
                            #endif
                        }
                    }
                } else { // 50024 to 50032
                    if (entityId == 50024) { // Creeper
                        emission = max0(color.b - color.g - color.r) * 10.0;
                    } else /*if (entityId == 50028)*/ { // Drowned
                        if (atlasSize.x < 900) {
                            if (CheckForColor(color.rgb, vec3(143, 241, 215)) ||
                                CheckForColor(color.rgb, vec3( 49, 173, 183)) ||
                                CheckForColor(color.rgb, vec3(101, 224, 221))) emission = 2.5;
                        }
                    }
                }
            }
        } else { // 50032 to 50064
            if (entityId < 50048) { // 50032 to 50048
                if (entityId < 50040) { // 50032 to 50040
                    if (entityId == 50032) { // Guardian
                        vec3 absDif = abs(vec3(color.r - color.g, color.g - color.b, color.r - color.b));
                        float maxDif = max(absDif.r, max(absDif.g, absDif.b));
                        if (maxDif < 0.1 && color.b > 0.5 && color.b < 0.88) {
                            emission = pow2(pow1_5(color.b)) * 5.0;
                            color.rgb *= color.rgb;
                        }
                    } else /*if (entityId == 50036)*/ { // Elder Guardian
                        if (CheckForColor(color.rgb, vec3(203, 177, 165)) ||
                            CheckForColor(color.rgb, vec3(214, 155, 126))) {
                            emission = pow2(pow1_5(color.b)) * 10.0;
                            color.r *= 1.2;
                        }
                    }
                } else { // 50040 to 50048
                    if (entityId == 50040) { // Endermite
                        if (CheckForColor(color.rgb, vec3(87, 23, 50))) {
                            emission = 8.0;
                            color.rgb *= color.rgb;
                        }
                    } else /*if (entityId == 50044)*/ { // Ghast
                        if (entityColor.a < 0.001)
                            emission = max0(color.r - color.g - color.b) * 6.0;
                            #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                            if (color.r > color.b * 2.0) color.rgb = changeColorFunction(color.rgb, 7.0, colorSoul, inSoulValley);
                        #endif
                        #ifdef PURPLE_END_FIRE_INTERNAL
                            if (color.r > color.b * 2.0) color.rgb = changeColorFunction(color.rgb, 7.0, colorEndBreath, 1.0);
                        #endif
                }
                }
            } else { // 50048 to 50064
                if (entityId < 50056) { // 50048 to 50056
                    if (entityId == 50048) { // Glow Squid
                        lmCoordM.x = 0.0;
                        float dotColor = dot(color.rgb, color.rgb);
                        emission = pow2(pow2(min(dotColor * 0.65, 1.5))) + 0.45;
                    } else /*if (entityId == 50052)*/ { // Magma Cube
                        emission = color.g * 6.0;
                        #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                        color.rgb = changeColorFunction(color.rgb, 2.0, colorSoul, inSoulValley);
                        #endif
                        #ifdef PURPLE_END_FIRE_INTERNAL
                            color.rgb = changeColorFunction(color.rgb, 2.0, colorEndBreath, 1.0);
                        #endif
                    }
                } else { // 50056 to 50064
                    if (entityId == 50056) { // Stray
                        if (CheckForColor(color.rgb, vec3(230, 242, 246)) && texCoord.y > 0.35)
                            emission = 1.75;
                    } else /*if (entityId == 50060)*/ { // Vex
                        lmCoordM = vec2(0.0);
                        emission = pow2(pow2(color.r)) * 3.5 + 0.5;
                        color.a *= color.a;
                    }
                }
            }
        }
    } else { // 50064 to 50128
        if (entityId < 50096) { // 50064 to 50096
            if (entityId < 50080) { // 50064 to 50080
                if (entityId < 50072) { // 50064 to 50072
                    if (entityId == 50064) { // Witch
                        emission = 2.0 * color.g * float(color.g * 1.5 > color.b + color.r);
                    } else /*if (entityId == 50068)*/ { // Wither, Wither Skull
                        lmCoordM.x = 0.9;
                        emission = 3.0 * float(dot(color.rgb, color.rgb) > 1.0);
                    }
                } else { // 50072 to 50080
                    if (entityId == 50072) { // Experience Orb
                        emission = 7.5;

                        color.rgb *= color.rgb;
                    } else /*if (entityId == 50076)*/ { // Boats
                        playerPos.y += 0.38; // consistentBOAT2176: to avoid water shadow and the black inner shadow bug
                    }
                }
            } else { // 50080 to 50096
                if (entityId < 50088) { // 50080 to 50088
                    if (entityId == 50080) { // Allay
                        if (atlasSize.x < 900) {
                            lmCoordM = vec2(0.0);
                            emission = float(color.r > 0.9 && color.b > 0.9) * 5.0 + color.g;
                        } else {
                            lmCoordM.x = 0.8;
                        }
                    } else /*if (entityId == 50084)*/ { // Slime, Chicken
                        //only code is in Vertex Shader for now
                    }
                } else { // 50088 to 50096
                    if (entityId == 50088) { // Entity Flame (Iris Feature)
                        #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                            color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
                        #endif
                        #ifdef PURPLE_END_FIRE_INTERNAL
                            color.rgb = changeColorFunction(color.rgb, 3.0, colorEndBreath, 1.0);
                        #endif
                        emission = 1.3;
                    } else if (entityId == 50089) { // fireball, small fireball, dragon fireball
                        #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                            color.rgb = changeColorFunction(color.rgb, 4.0, colorSoul, inSoulValley);
                        #endif
                        #ifdef PURPLE_END_FIRE_INTERNAL
                            color.rgb = changeColorFunction(color.rgb, 4.0, colorEndBreath, 1.0);
                        #endif
                    } else /*if (entityId == 50092)*/ { // Trident Entity
                        #if defined IS_IRIS || defined IS_ANGELICA && ANGELICA_VERSION >= 20000008
                            // Only on Iris, because otherwise it would be inconsistent with the Trident item
                            #include "/lib/materials/specificMaterials/others/trident.glsl"
                        #endif
                    }
                }
            }
        } else { // 50096 to 50128
            if (entityId < 50112) { // 50096 to 50112
                if (entityId < 50104) { // 50096 to 50104
                    if (entityId == 50096) { // Minecart++
                        if (atlasSize.x < 900 && color.r * color.g * color.b + color.b > 0.3) {
                            #include "/lib/materials/specificMaterials/terrain/ironBlock.glsl"

                            smoothnessD *= 0.6;
                        }
                    } else /*if (entityId == 50100)*/ { // Bogged
                        if (CheckForColor(color.rgb, vec3(239, 254, 194)))
                            emission = 2.5;
                    }
                } else { // 50104 to 50112
                    if (entityId == 50104) { // Piglin++, Hoglin+
                        if (atlasSize.x < 900) {
                            if (CheckForColor(color.rgb, vec3(255)) || CheckForColor(color.rgb, vec3(255, 242, 246))) {
                                vec2 tSize = textureSize(tex, 0);
                                vec4 checkColorOneRight = texelFetch(tex, ivec2(texCoord * tSize) + ivec2(1, 0), 0);
                                if (
                                    CheckForColor(checkColorOneRight.rgb, vec3(201, 130, 101)) ||
                                    CheckForColor(checkColorOneRight.rgb, vec3(241, 158, 152)) ||
                                    CheckForColor(checkColorOneRight.rgb, vec3(223, 127, 119)) ||
                                    CheckForColor(checkColorOneRight.rgb, vec3(241, 158, 152)) ||
                                    CheckForColor(checkColorOneRight.rgb, vec3(165, 99, 80)) ||
                                    CheckForColor(checkColorOneRight.rgb, vec3(213, 149, 122)) ||
                                    CheckForColor(checkColorOneRight.rgb, vec3(255))
                                ) {
                                    emission = 1.0;
                                }
                            }
                        }
                    } else /*if (entityId == 50108)*/ { // Creaking
                        if (color.r > 0.7 && color.r > color.g * 1.2 && color.g > color.b * 2.0) { // Eyes
                                lmCoordM.x = 0.5;
                                emission = 5.0 * color.g;
                                color.rgb *= color.rgb;
                                purkinjeOverwrite = 1.0;
                        }
                    }
                }
            } else { // 50112 to 50128
                if (entityId < 50120) { // 50112 to 50120
                    if (entityId == 50112) { // Name Tag
                        noDirectionalShading = true;
                        color.rgb *= 1.5;
                        if (color.a < 0.5) {
                            color.a = 0.12;
                            color.rgb *= 5.0;
                        }
                    } else /*if (entityId == 50116)*/ { // Copper Golem
                        #include "/lib/materials/specificMaterials/terrain/copperBlock.glsl"

                        smoothnessD *= 0.5;
                    }
                } else { // 50120 to 50128
                    if (entityId == 50120) { // Parched
                        if (CheckForColor(color.rgb, vec3(254, 235, 194))) {
                            vec2 tSize = textureSize(tex, 0);
                            vec4 checkColorOneDown = texelFetch(tex, ivec2(texCoord * tSize) + ivec2(0, 1), 0);
                            if (CheckForColor(checkColorOneDown.rgb, vec3(135, 126, 118)) ||
                                CheckForColor(checkColorOneDown.rgb, vec3(106, 103, 98))
                            ) {
                                emission = 1.75;
                            }
                        }
                    } else /*if (entityId == 50124)*/ { // Zombie Nautilus
                        if (CheckForColor(color.rgb, vec3(143, 241, 215)) || CheckForColor(color.rgb, vec3(101, 224, 221)))
                            emission = 1.5;
                    }
                }
            }
        }
    }
} else if (entityId < 50128) { // 50128 to 50256
    if (entityId < 50192) { // 50128 to 50192
        if (entityId < 50160) { // 50128 to 50160
            if (entityId < 50144) { // 50128 to 50144
                if (entityId < 50136) { // 50128 to 50136
                    if (entityId < 50132) { // 50128 to 50132
                        // 50128
                        // 50129
                        // 50130
                        // 50131
                    } else { // 50132 to 50136
                        // 50132
                        // 50133
                        // 50134
                        // 50135
                    }
                } else { // 50136 to 50144
                    if (entityId < 50140) { // 50136 to 50140
                        // 50136
                        // 50137
                        // 50138
                        // 50139
                    } else { // 50140 to 50144
                        // 50140
                        // 50141
                        // 50142
                        // 50143
                    }
                }
            } else { // 50144 to 50160
                if (entityId < 50152) { // 50144 to 50152
                    if (entityId < 50148) { // 50144 to 50148
                        // 50144
                        // 50145
                        // 50146
                        // 50147
                    } else { // 50148 to 50152
                        // 50148
                        // 50149
                        // 50150
                        // 50151
                    }
                } else { // 50152 to 50160
                    if (entityId < 50156) { // 50152 to 50156
                        // 50152
                        // 50153
                        // 50154
                        // 50155
                    } else { // 50156 to 50160
                        // 50156
                        // 50157
                        // 50158
                        // 50159
                    }
                }
            }
        } else { // 50160 to 50192
            if (entityId < 50176) { // 50160 to 50176
                if (entityId < 50168) { // 50160 to 50168
                    if (entityId < 50164) { // 50160 to 50164
                        // 50160
                        // 50161
                        // 50162
                        // 50163
                    } else { // 50164 to 50168
                        // 50164
                        // 50165
                        // 50166
                        // 50167
                    }
                } else { // 50168 to 50176
                    if (entityId < 50172) { // 50168 to 50172
                        // 50168
                        // 50169
                        // 50170
                        // 50171
                    } else { // 50172 to 50176
                        // 50172
                        // 50173
                        // 50174
                        // 50175
                    }
                }
            } else { // 50176 to 50192
                if (entityId < 50184) { // 50176 to 50184
                    if (entityId < 50180) { // 50176 to 50180
                        // 50176
                        // 50177
                        // 50178
                        // 50179
                    } else { // 50180 to 50184
                        // 50180
                        // 50181
                        // 50182
                        // 50183
                    }
                } else { // 50184 to 50192
                    if (entityId < 50188) { // 50184 to 50188
                        // 50184
                        // 50185
                        // 50186
                        // 50187
                    } else { // 50188 to 50192
                        // 50188
                        // 50189
                        // 50190
                        // 50191
                    }
                }
            }
        }
    } else { // 50192 to 50256
        if (entityId < 50224) { // 50192 to 50224
            if (entityId < 50208) { // 50192 to 50208
                if (entityId < 50200) { // 50192 to 50200
                    if (entityId < 50196) { // 50192 to 50196
                        // 50192
                        // 50193
                        // 50194
                        // 50195
                    } else { // 50196 to 50200
                        // 50196
                        // 50197
                        // 50198
                        // 50199
                    }
                } else { // 50200 to 50208
                    if (entityId < 50204) { // 50200 to 50204
                        // 50200
                        // 50201
                        // 50202
                        // 50203
                    } else { // 50204 to 50208
                        // 50204
                        // 50205
                        // 50206
                        // 50207
                    }
                }
            } else { // 50208 to 50224
                if (entityId < 50216) { // 50208 to 50216
                    if (entityId < 50212) { // 50208 to 50212
                        // 50208
                        // 50209
                        // 50210
                        // 50211
                    } else { // 50212 to 50216
                        // 50212
                        // 50213
                        // 50214
                        // 50215
                    }
                } else { // 50216 to 50224
                    if (entityId < 50220) { // 50216 to 50220
                        // 50216
                        // 50217
                        // 50218
                        // 50219
                    } else { // 50220 to 50224
                        // 50220
                        // 50221
                        // 50222
                        // 50223
                    }
                }
            }
        } else { // 50224 to 50256
            if (entityId < 50240) { // 50224 to 50240
                if (entityId < 50232) { // 50224 to 50232
                    if (entityId < 50228) { // 50224 to 50228
                        // 50224
                        // 50225
                        // 50226
                        // 50227
                    } else { // 50228 to 50232
                        // 50228
                        // 50229
                        // 50230
                        // 50231
                    }
                } else { // 50232 to 50240
                    if (entityId < 50236) { // 50232 to 50236
                        // 50232
                        // 50233
                        // 50234
                        // 50235
                    } else { // 50236 to 50240
                        // 50236
                        // 50237
                        // 50238
                        // 50239
                    }
                }
            } else { // 50240 to 50256
                if (entityId < 50248) { // 50240 to 50248
                    if (entityId < 50244) { // 50240 to 50244
                        // 50240
                        // 50241
                        // 50242
                        // 50243
                    } else { // 50244 to 50248
                        // 50244
                        // 50245
                        // 50246
                        // 50247
                    }
                } else { // 50248 to 50256
                    if (entityId < 50252) { // 50248 to 50252
                        // 50248
                        // 50249
                        // 50250
                        // 50251
                    } else { // 50252 to 50256
                        // 50252
                        // 50253
                        // 50254
                        // 50255
                    }
                }
            }
        }
    }
}
 else if (entityId != 65535) {
    if (entityId < 51264) {
        if (entityId < 51232) {
            if (entityId < 51216) {
                if (entityId < 51208) {
                    if (entityId < 51204) {
                        // entity.51200 = crimson_forest_enderman
                        if (color.r > 0.91) {
                            emission = 3.0 * color.g;
                            color.r *= 1.2;
                    
                            overlayNoiseIntensity = 0.5;
                        }
                    
                        smoothnessG = color.r * 0.5;
                        smoothnessD = smoothnessG;
                    
                        #ifdef COATED_TEXTURES
                            noiseFactor = 0.77;
                        #endif
                    } else /*if (entityId < 51208)*/ {
                        // entity.51204 = crimson_forest_enderman
                        if (color.r > 0.91) {
                            emission = 3.0 * color.g;
                            color.r *= 1.2;
                    
                            overlayNoiseIntensity = 0.5;
                        }
                    
                        smoothnessG = color.r * 0.5;
                        smoothnessD = smoothnessG;
                    
                        #ifdef COATED_TEXTURES
                            noiseFactor = 0.77;
                        #endif
                    }
                } else /*if (entityId < 51216)*/ {
                    if (entityId < 51212) {
                        // entity.51208 = ice_spikes_enderman
                        smoothnessG = pow2(color.g) * color.g;
                        smoothnessD = smoothnessG;
                    } else /*if (entityId < 51216)*/ {
                        // entity.51212 = spirit
                        if (color.b > 1.3 * color.r || color.b > 0.9) {
                            emission = 1.5;
                            color.rgb = pow1_5(color.rgb);
                    
                            overlayNoiseIntensity = 0.0;
                            color.a = pow1_5(color.b) - 0.05;
                        }
                    }
                }
            } else /*if (entityId < 51232)*/ {
                if (entityId < 51224) {
                    if (entityId < 51220) {
                        // entity.51216 = stone_enderman
                        #include "/lib/materials/specificMaterials/terrain/stone.glsl"
                    } else /*if (entityId < 51224)*/ {
                        // entity.51220 = warped_forest_enderman
                        #ifdef MOD_NETHEREXP
                            if (color.r > 0.73) {
                                emission = 1.5 * color.b;
                    
                                overlayNoiseIntensity = 0.5;
                            }
                        #else
                            if (color.r > 0.91) {
                                emission = 3.0 * color.g;
                                color.r *= 1.2;
                    
                                overlayNoiseIntensity = 0.5;
                            }
                        #endif
                    
                        smoothnessG = color.g * 0.5;
                        smoothnessD = smoothnessG;
                    
                        #ifdef COATED_TEXTURES
                            noiseFactor = 0.77;
                        #endif
                    }
                } else /*if (entityId < 51232)*/ {
                    if (entityId < 51228) {
                        // entity.51224 = pink_salt_pillar
                        #include "/lib/materials/specificMaterials/terrain/pinkSalt.glsl"
                    
                        #if GLOWING_PINK_SALT >= 2
                            emission = pow2(color.g) * color.g * 3.0;
                            color.g *= 1.0 - emission * 0.07;
                            emission *= 1.3;
                        #endif
                    
                        overlayNoiseIntensity = 0.5;
                    } else /*if (entityId < 51232)*/ {
                        // entity.51228 = preserved
                        if (color.r > 0.8) {
                            #include "/lib/materials/specificMaterials/terrain/pinkSalt.glsl"
                    
                            if (entityId % 4 == 0) {
                                #if GLOWING_PINK_SALT >= 3
                                    emission = pow2(color.g) * color.g * 3.0;
                                    color.g *= 1.0 - emission * 0.07;
                                    emission *= 1.3;
                                #endif
                            } else {
                                #if GLOWING_PINK_SALT >= 2
                                    emission = pow2(color.g) * color.g * 3.0;
                                    color.g *= 1.0 - emission * 0.07;
                                    emission *= 1.3;
                                #endif
                            }
                    
                            overlayNoiseIntensity = 0.5;
                        }
                    }
                }
            }
        } else /*if (entityId < 51264)*/ {
            if (entityId < 51248) {
                if (entityId < 51240) {
                    if (entityId < 51236) {
                        // entity.51232 = sparkle
                        if (color.b / color.r > 1.2 && color.b > 0.4) {
                            materialMask = OSIEBCA; // Intense Fresnel
                            float factor = pow2(0.6 * color.b + 0.4 * color.g);
                            smoothnessG = 0.8 - factor * 0.3;
                            highlightMult = factor * 3.0;
                            smoothnessD = factor;
                    
                            overlayNoiseIntensity = 0.5;
                        } else if (color.r / color.b > 1.2 && color.r > 0.4) {
                            materialMask = OSIEBCA; // Intense Fresnel
                            float factor = pow2(0.8 * color.g + 0.2 * color.r);
                            smoothnessG = 0.8 - factor * 0.3;
                            highlightMult = factor * 3.0;
                            smoothnessD = factor;
                    
                            overlayNoiseIntensity = 0.5;
                        }
                    } else /*if (entityId < 51240)*/ {
                        // entity.51236 = spectre
                        emission = 1.2 + 4.0 * pow2(max0(color.b - color.r));
                    }
                } else /*if (entityId < 51248)*/ {
                    if (entityId < 51244) {
                        // entity.51240 = spectrepillar
                        emission = 0.3 + 0.2 * pow2(color.r);
                    } else /*if (entityId < 51248)*/ {
                        // entity.51244 = apparition
                        if (color.b - color.r > 0.1) {
                            emission = 0.3 * pow2(color.b);
                    
                            if (CheckForColor(color.rgb, vec3(1.0)))
                                emission += 2.0;
                        }
                    }
                }
            } else /*if (entityId < 51264)*/ {
                if (entityId < 51256) {
                    if (entityId < 51252) {
                        // entity.51248 = banshee
                        emission = 2.5 * sqrt1(color.b);
                    } else /*if (entityId < 51256)*/ {
                        // entity.51252 = ecto_slab
                        if (color.b > 0.65) {
                            emission = 3.0;
                            color.rgb *= sqrt1(GetLuminance(color.rgb));
                        }
                    }
                } else /*if (entityId < 51264)*/ {
                    if (entityId < 51260) {
                        // entity.51256 = vessel
                        if (color.b - color.r > 0.1) {
                            emission = 3.0;
                            color.rgb *= sqrt1(GetLuminance(color.rgb));
                        }
                    } else /*if (entityId < 51264)*/ {
                        // entity.51260 = foxhound
                        if (color.r > 0.8 || color.b > 0.8) {
                            emission = 2.0;
                            color.rgb *= sqrt1(GetLuminance(color.rgb));
                    
                            overlayNoiseIntensity = 0.0;
                        }
                    }
                }
            }
        }
    } else /*if (entityId < 51292)*/ {
        if (entityId < 51280) {
            if (entityId < 51272) {
                if (entityId < 51268) {
                    // entity.51264 = oretortoise
                    vec4 shellColour = texelFetch(tex, ivec2(26, 0), 0);
                    if (!CheckForColor(shellColour.rgb, vec3(56, 50, 55)) || shellColour.a < 0.1) {
                        if (CheckForColor(shellColour.rgb, vec3(55, 103, 146))) {  // Lapis Lazuli
                            #include "/lib/materials/specificMaterials/terrain/lapisBlock.glsl"
                            #ifdef GLOWING_ORETORTOISE
                            emission = dot(color.rgb, color.rgb) * 1.2;
                            #endif
                        } else {
                            vec4 oreColour = texelFetch(tex, ivec2(9, 44), 0);
                            if (shellColour.r > 10 * shellColour.b) {  // Redstone
                                #include "/lib/materials/specificMaterials/terrain/redstoneBlock.glsl"
                                #ifdef GLOWING_ORETORTOISE
                                emission = 0.75 + 3.0 * pow2(pow2(color.r));
                                color.gb *= 0.65;
                                #endif
                            } else if (shellColour.r > 2 * shellColour.b || shellColour.a < 0.1) {  // Copper
                                #include "/lib/materials/specificMaterials/terrain/rawCopperBlock.glsl"
                                #ifdef GLOWING_ORETORTOISE
                                emission = pow2(color.r) * 1.5 + color.g * 1.3 + 0.2;
                                #endif
                            } else if (shellColour.r > shellColour.b) {
                                if (shellColour.r > 2.5 * shellColour.g) {  // Spinel
                                    #include "/lib/materials/specificMaterials/terrain/spinelBlock.glsl"
                                    #ifdef GLOWING_ORETORTOISE
                                    emission = 0.45 * (1.6 * sqrt2(color.r) + 2.2 * pow2(color.r));
                                    #endif
                                } else {  // Iron
                                    #include "/lib/materials/specificMaterials/terrain/rawIronBlock.glsl"
                                    #ifdef GLOWING_ORETORTOISE
                                    emission = pow1_5(color.r) * 0.5;
                                    #endif
                                }
                            } else {  // Lead
                                #include "/lib/materials/specificMaterials/terrain/rawLeadBlock.glsl"
                                #ifdef GLOWING_ORETORTOISE
                                emission = 6.0 * sqrt2(max(color.r, color.b));
                                #endif
                            }
                        }
                    }
                
                    #ifdef GLOWING_ORETORTOISE
                        overlayNoiseIntensity = 0.6, overlayNoiseEmission = 0.5;
                        #ifdef SITUATIONAL_ORETORTOISE
                            emission *= skyLightCheck;
                            color.rgb = mix(color.rgb, color.rgb * pow(color.rgb, vec3(0.5 * min1(GLOWING_ORETORTOISE_MULT))), skyLightCheck);
                        #else
                            color.rgb *= pow(color.rgb, vec3(0.5 * min1(GLOWING_ORETORTOISE_MULT)));
                        #endif
                
                        emission *= GLOWING_ORETORTOISE_MULT * 1.5;
                    #endif
                } else /*if (entityId < 51272)*/ {
                    // entity.51268 = stoneling
                    #include "/lib/materials/specificMaterials/terrain/stone.glsl"
                
                    if (
                        CheckForColor(color.rgb, vec3(118, 148, 134)) ||
                        CheckForColor(color.rgb, vec3(106, 121, 120)) ||
                        CheckForColor(color.rgb, vec3(188, 188, 157)) ||
                        CheckForColor(color.rgb, vec3(92, 108, 96)) ||
                        CheckForColor(color.rgb, vec3(178, 178, 136))
                    ) {
                        float dotColor = dot(color.rgb, color.rgb);
                        emission = min(pow2(pow2(dotColor) * dotColor) * 1.4 + dotColor * 0.9, 6.0);
                        emission = mix(emission, dotColor * 1.5, min1(lViewPos / 96.0));
                    }
                }
            } else /*if (entityId < 51280)*/ {
                if (entityId < 51276) {
                    // entity.51272 = totem
                    smoothnessG = 2.0;
                    smoothnessD = smoothnessG;
                } else /*if (entityId < 51280)*/ {
                    // entity.51276 = wraith
                    if (color.b > 0.7) {
                        emission = 0.2 + 1.5 * pow2(color.b - color.r);
                        color.rgb = pow1_5(color.rgb);
                    }
                }
            }
        } else /*if (entityId < 51292)*/ {
            if (entityId < 51288) {
                if (entityId < 51284) {
                    // entity.51280 = pike
                    vec4 pikeColour = texelFetch(tex, ivec2(0, 31), 0);
                    if (CheckForColor(pikeColour.rgb, vec3(16, 12, 28))) {  // obsidian
                        #include "/lib/materials/specificMaterials/terrain/obsidian.glsl"
                
                        highlightMult *= 0.5;
                
                        if (color.r > 0.3) {
                            emission = 4.0 * color.r;
                            color.r *= 1.15;
                        }
                    } else if (CheckForColor(pikeColour.rgb, vec3(49, 71, 83))) {  // supercharged
                        if (color.r > 0.35 && color.b > 1.8 * color.r)
                        emission = 3.5 * color.b;
                    }
                } else /*if (entityId < 51288)*/ {
                    // entity.51284 = sonar
                    noSmoothLighting = true;
                    lmCoordM = vec2(1.0, 0.0);
                
                    emission = 2.0 * pow2(color.b);
                }
            } else /*if (entityId < 51292)*/ {
                // entity.51288 = thrasher
                vec2 tSize = textureSize(tex, 0);
                ivec2 texCoordScaled = ivec2(texCoord * tSize);
                if (entityId % 4 == 0) {  // thrasher
                    if ((texCoordScaled.x >= 30 && texCoordScaled.y >= 88) || (texCoordScaled.x >= 50 && texCoordScaled.y >= 63)) {
                        emission = 2.0 * pow2(color.b);
                        color.rgb *= sqrt(color.rgb);
                    }
                } else {  // great thrasher
                    if (texCoordScaled.x >= 48 && texCoordScaled.y >= 63) {
                        emission = 2.0 * pow2(color.b);
                    }
                }
            }
        }
    }
    
}
