#if COLORED_LIGHTING < 512
    const ivec3 sceneVoxelVolumeSize = ivec3(COLORED_LIGHTING_INTERNAL, 64, COLORED_LIGHTING_INTERNAL);
#else
    const ivec3 sceneVoxelVolumeSize = ivec3(512, 64, 512);
#endif

const ivec3 sceneVoxelLodVolumeSize = sceneVoxelVolumeSize / 4;

vec3 playerToSceneVoxel(vec3 playerPos) {
    return playerPos + cameraPositionBestFract + 0.5 * vec3(sceneVoxelVolumeSize);
}

vec3 playerToPreviousSceneVoxel(vec3 previousPlayerPos) {
    return previousPlayerPos + previousCameraPositionBestFract + 0.5 * vec3(sceneVoxelVolumeSize);
}

bool CheckInsideSceneVoxelVolume(vec3 voxelPos) {
    #ifndef SHADOW
        voxelPos -= 0.5 * sceneVoxelVolumeSize;
        voxelPos += sign(voxelPos) * 0.95;
        voxelPos += 0.5 * sceneVoxelVolumeSize;
    #endif
    voxelPos /= vec3(sceneVoxelVolumeSize);
    return clamp01(voxelPos) == voxelPos;
}

#include "/lib/voxelization/reflectionVoxelData.glsl"

#if defined SHADOW && defined VERTEX_SHADER
    void UpdateSceneVoxelMap(int mat, vec3 normal, vec3 position) {
        ivec3 eligibleStages = ivec3(
            MC_RENDER_STAGE_TERRAIN_SOLID,
            MC_RENDER_STAGE_TERRAIN_CUTOUT,
            MC_RENDER_STAGE_TERRAIN_CUTOUT_MIPPED
        );

        if (!any(equal(ivec3(renderStage), eligibleStages))) return;

        vec3 viewPos  = mat3(gl_ModelViewMatrix) * (gl_Vertex.xyz + at_midBlock.xyz / 64.0) + gl_ModelViewMatrix[3].xyz;
        vec3 scenePos = mat3(shadowModelViewInverse) * viewPos + shadowModelViewInverse[3].xyz;
        vec3 voxelPos = playerToSceneVoxel(scenePos);

        if (CheckInsideSceneVoxelVolume(voxelPos)) {
            bool doSolidBlockCheck = true;
            bool storeToAllFaces = false;
            bool storeToAllFacesExceptTop = false;
            uint matM = mat > 10 ? uint(mat) : 1u;
            vec2 textureRad = abs(texCoord - mc_midTexCoord.xy);
            vec2 origin = mc_midTexCoord.xy - textureRad;
            if (mat < 12568) {
                if (mat < 12380) {
                    if (mat < 12341) {
                        if (mat < 12304) {
                            if (mat < 12296) {
                                if (mat < 12292) {
                                    if (mat < 12290) {
                                        if (mat < 12289) {
                                            if (mat == 12288) {
                                                return;
                                            }
                                        } else { // mat >= 12289
                                            if (mat == 12289) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12290
                                        if (mat < 12291) {
                                            if (mat == 12290) {
                                                return;
                                            }
                                        } else { // mat >= 12291
                                            if (mat == 12291) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12292
                                    if (mat < 12294) {
                                        if (mat < 12293) {
                                            if (mat == 12292) {
                                                return;
                                            }
                                        } else { // mat >= 12293
                                            if (mat == 12293) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12294
                                        if (mat < 12295) {
                                            if (mat == 12294) {
                                                return;
                                            }
                                        } else { // mat >= 12295
                                            if (mat == 12295) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            } else { // mat >= 12296
                                if (mat < 12300) {
                                    if (mat < 12298) {
                                        if (mat < 12297) {
                                            if (mat == 12296) {
                                                return;
                                            }
                                        } else { // mat >= 12297
                                            if (mat == 12297) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12298
                                        if (mat < 12299) {
                                            if (mat == 12298) {
                                                return;
                                            }
                                        } else { // mat >= 12299
                                            if (mat == 12299) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12300
                                    if (mat < 12302) {
                                        if (mat < 12301) {
                                            if (mat == 12300) {
                                                return;
                                            }
                                        } else { // mat >= 12301
                                            if (mat == 12301) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12302
                                        if (mat < 12303) {
                                            if (mat == 12302) {
                                                return;
                                            }
                                        } else { // mat >= 12303
                                            if (mat == 12303) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            }
                        } else { // mat >= 12304
                            if (mat < 12322) {
                                if (mat < 12315) {
                                    if (mat < 12313) {
                                        if (mat < 12309) {
                                            if (mat == 12308) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12309
                                            if (mat == 12312) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12313
                                        if (mat < 12314) {
                                            if (mat == 12313) {
                                                return;
                                            }
                                        } else { // mat >= 12314
                                            if (mat == 12314) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12315
                                    if (mat < 12317) {
                                        if (mat < 12316) {
                                            if (mat == 12315) {
                                                return;
                                            }
                                        } else { // mat >= 12316
                                            if (mat == 12316) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    } else { // mat >= 12317
                                        if (mat < 12321) {
                                            if (mat == 12320) {
                                                return;
                                            }
                                        } else { // mat >= 12321
                                            if (mat == 12321) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            } else { // mat >= 12322
                                if (mat < 12330) {
                                    if (mat < 12324) {
                                        if (mat < 12323) {
                                            if (mat == 12322) {
                                                return;
                                            }
                                        } else { // mat >= 12323
                                            if (mat == 12323) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12324
                                        if (mat < 12329) {
                                            if (mat == 12328) {
                                                return;
                                            }
                                        } else { // mat >= 12329
                                            if (mat == 12329) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12330
                                    if (mat < 12332) {
                                        if (mat < 12331) {
                                            if (mat == 12330) {
                                                return;
                                            }
                                        } else { // mat >= 12331
                                            if (mat == 12331) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12332
                                        if (mat < 12337) {
                                            if (mat == 12336) {
                                                return;
                                            }
                                        } else { // mat >= 12337
                                            if (mat == 12340) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else { // mat >= 12341
                        if (mat < 12361) {
                            if (mat < 12349) {
                                if (mat < 12345) {
                                    if (mat < 12343) {
                                        if (mat < 12342) {
                                            if (mat == 12341) {
                                                return;
                                            }
                                        } else { // mat >= 12342
                                            if (mat == 12342) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12343
                                        if (mat < 12344) {
                                            if (mat == 12343) {
                                                return;
                                            }
                                        } else { // mat >= 12344
                                            if (mat == 12344) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12345
                                    if (mat < 12347) {
                                        if (mat < 12346) {
                                            if (mat == 12345) {
                                                return;
                                            }
                                        } else { // mat >= 12346
                                            if (mat == 12346) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12347
                                        if (mat < 12348) {
                                            if (mat == 12347) {
                                                return;
                                            }
                                        } else { // mat >= 12348
                                            if (mat == 12348) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            } else { // mat >= 12349
                                if (mat < 12357) {
                                    if (mat < 12351) {
                                        if (mat < 12350) {
                                            if (mat == 12349) {
                                                return;
                                            }
                                        } else { // mat >= 12350
                                            if (mat == 12350) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12351
                                        if (mat < 12352) {
                                            if (mat == 12351) {
                                                return;
                                            }
                                        } else { // mat >= 12352
                                            if (mat == 12356) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12357
                                    if (mat < 12359) {
                                        if (mat < 12358) {
                                            if (mat == 12357) {
                                                return;
                                            }
                                        } else { // mat >= 12358
                                            if (mat == 12358) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12359
                                        if (mat < 12360) {
                                            if (mat == 12359) {
                                                return;
                                            }
                                        } else { // mat >= 12360
                                            if (mat == 12360) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            }
                        } else { // mat >= 12361
                            if (mat < 12369) {
                                if (mat < 12365) {
                                    if (mat < 12363) {
                                        if (mat < 12362) {
                                            if (mat == 12361) {
                                                return;
                                            }
                                        } else { // mat >= 12362
                                            if (mat == 12362) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12363
                                        if (mat < 12364) {
                                            if (mat == 12363) {
                                                return;
                                            }
                                        } else { // mat >= 12364
                                            if (mat == 12364) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12365
                                    if (mat < 12367) {
                                        if (mat < 12366) {
                                            if (mat == 12365) {
                                                return;
                                            }
                                        } else { // mat >= 12366
                                            if (mat == 12366) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12367
                                        if (mat < 12368) {
                                            if (mat == 12367) {
                                                return;
                                            }
                                        } else { // mat >= 12368
                                            if (mat == 12368) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            } else { // mat >= 12369
                                if (mat < 12373) {
                                    if (mat < 12371) {
                                        if (mat < 12370) {
                                            if (mat == 12369) {
                                                return;
                                            }
                                        } else { // mat >= 12370
                                            if (mat == 12370) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12371
                                        if (mat < 12372) {
                                            if (mat == 12371) {
                                                return;
                                            }
                                        } else { // mat >= 12372
                                            if (mat == 12372) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    }
                                } else { // mat >= 12373
                                    if (mat < 12378) {
                                        if (mat < 12377) {
                                            if (mat == 12376) {
                                                return;
                                            }
                                        } else { // mat >= 12377
                                            if (mat == 12377) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12378
                                        if (mat < 12379) {
                                            if (mat == 12378) {
                                                return;
                                            }
                                        } else { // mat >= 12379
                                            if (mat == 12379) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else { // mat >= 12380
                    if (mat < 12493) {
                        if (mat < 12449) {
                            if (mat < 12417) {
                                if (mat < 12394) {
                                    if (mat < 12389) {
                                        if (mat < 12381) {
                                            if (mat == 12380) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12381
                                            if (mat == 12388) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    } else { // mat >= 12389
                                        if (mat < 12393) {
                                            if (mat == 12392) {
                                                return;
                                            }
                                        } else { // mat >= 12393
                                            if (mat == 12393) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12394
                                    if (mat < 12396) {
                                        if (mat < 12395) {
                                            if (mat == 12394) {
                                                return;
                                            }
                                        } else { // mat >= 12395
                                            if (mat == 12395) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12396
                                        if (mat < 12413) {
                                            if (mat == 12412) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12413
                                            if (mat == 12416) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            } else { // mat >= 12417
                                if (mat < 12433) {
                                    if (mat < 12419) {
                                        if (mat < 12418) {
                                            if (mat == 12417) {
                                                return;
                                            }
                                        } else { // mat >= 12418
                                            if (mat == 12418) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12419
                                        if (mat < 12420) {
                                            if (mat == 12419) {
                                                return;
                                            }
                                        } else { // mat >= 12420
                                            if (mat == 12432) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12433
                                    if (mat < 12435) {
                                        if (mat < 12434) {
                                            if (mat == 12433) {
                                                return;
                                            }
                                        } else { // mat >= 12434
                                            if (mat == 12434) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12435
                                        if (mat < 12436) {
                                            if (mat == 12435) {
                                                return;
                                            }
                                        } else { // mat >= 12436
                                            if (mat == 12448) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            }
                        } else { // mat >= 12449
                            if (mat < 12461) {
                                if (mat < 12457) {
                                    if (mat < 12451) {
                                        if (mat < 12450) {
                                            if (mat == 12449) {
                                                return;
                                            }
                                        } else { // mat >= 12450
                                            if (mat == 12450) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12451
                                        if (mat < 12452) {
                                            if (mat == 12451) {
                                                return;
                                            }
                                        } else { // mat >= 12452
                                            if (mat == 12456) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12457
                                    if (mat < 12459) {
                                        if (mat < 12458) {
                                            if (mat == 12457) {
                                                return;
                                            }
                                        } else { // mat >= 12458
                                            if (mat == 12458) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12459
                                        if (mat < 12460) {
                                            if (mat == 12459) {
                                                return;
                                            }
                                        } else { // mat >= 12460
                                            if (mat == 12460) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    }
                                }
                            } else { // mat >= 12461
                                if (mat < 12468) {
                                    if (mat < 12466) {
                                        if (mat < 12465) {
                                            if (mat == 12464) {
                                                return;
                                            }
                                        } else { // mat >= 12465
                                            if (mat == 12465) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12466
                                        if (mat < 12467) {
                                            if (mat == 12466) {
                                                return;
                                            }
                                        } else { // mat >= 12467
                                            if (mat == 12467) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12468
                                    if (mat < 12482) {
                                        if (mat < 12481) {
                                            if (mat == 12480) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12481
                                            if (mat == 12481) {
                                                doSolidBlockCheck = false;
                                            }
                                        }
                                    } else { // mat >= 12482
                                        if (mat < 12485) {
                                            if (mat == 12484) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12485
                                            if (mat == 12492) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else { // mat >= 12493
                        if (mat < 12527) {
                            if (mat < 12501) {
                                if (mat < 12497) {
                                    if (mat < 12495) {
                                        if (mat < 12494) {
                                            if (mat == 12493) {
                                                return;
                                            }
                                        } else { // mat >= 12494
                                            if (mat == 12494) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12495
                                        if (mat < 12496) {
                                            if (mat == 12495) {
                                                return;
                                            }
                                        } else { // mat >= 12496
                                            if (mat == 12496) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12497
                                    if (mat < 12499) {
                                        if (mat < 12498) {
                                            if (mat == 12497) {
                                                return;
                                            }
                                        } else { // mat >= 12498
                                            if (mat == 12498) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12499
                                        if (mat < 12500) {
                                            if (mat == 12499) {
                                                return;
                                            }
                                        } else { // mat >= 12500
                                            if (mat == 12500) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    }
                                }
                            } else { // mat >= 12501
                                if (mat < 12512) {
                                    if (mat < 12510) {
                                        if (mat < 12509) {
                                            if (mat == 12508) {
                                                doSolidBlockCheck = false;
                                            }
                                        } else { // mat >= 12509
                                            if (mat == 12509) {
                                                doSolidBlockCheck = false;
                                            }
                                        }
                                    } else { // mat >= 12510
                                        if (mat < 12511) {
                                            if (mat == 12510) {
                                                doSolidBlockCheck = false;
                                            }
                                        } else { // mat >= 12511
                                            if (mat == 12511) {
                                                doSolidBlockCheck = false;
                                            }
                                        }
                                    }
                                } else { // mat >= 12512
                                    if (mat < 12525) {
                                        if (mat < 12513) {
                                            if (mat == 12512) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12513
                                            if (mat == 12524) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12525
                                        if (mat < 12526) {
                                            if (mat == 12525) {
                                                return;
                                            }
                                        } else { // mat >= 12526
                                            if (mat == 12526) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            }
                        } else { // mat >= 12527
                            if (mat < 12559) {
                                if (mat < 12531) {
                                    if (mat < 12529) {
                                        if (mat < 12528) {
                                            if (mat == 12527) {
                                                return;
                                            }
                                        } else { // mat >= 12528
                                            if (mat == 12528) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12529
                                        if (mat < 12530) {
                                            if (mat == 12529) {
                                                return;
                                            }
                                        } else { // mat >= 12530
                                            if (mat == 12530) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12531
                                    if (mat < 12557) {
                                        if (mat < 12532) {
                                            if (mat == 12531) {
                                                return;
                                            }
                                        } else { // mat >= 12532
                                            if (mat == 12556) {
                                                if (abs(abs(normal.x) - 0.5) < 0.25) {
                                                    doSolidBlockCheck = false;
                                                    storeToAllFaces = true;
                                                } else return;
                                            }
                                        }
                                    } else { // mat >= 12557
                                        if (mat < 12558) {
                                            if (mat == 12557) {
                                                if (abs(abs(normal.x) - 0.5) < 0.25) {
                                                    doSolidBlockCheck = false;
                                                    storeToAllFaces = true;
                                                } else return;
                                            }
                                        } else { // mat >= 12558
                                            if (mat == 12558) {
                                                if (abs(abs(normal.x) - 0.5) < 0.25) {
                                                    doSolidBlockCheck = false;
                                                    storeToAllFaces = true;
                                                } else return;
                                            }
                                        }
                                    }
                                }
                            } else { // mat >= 12559
                                if (mat < 12563) {
                                    if (mat < 12561) {
                                        if (mat < 12560) {
                                            if (mat == 12559) {
                                                if (abs(abs(normal.x) - 0.5) < 0.25) {
                                                    doSolidBlockCheck = false;
                                                    storeToAllFaces = true;
                                                } else return;
                                            }
                                        } else { // mat >= 12560
                                            if (mat == 12560) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12561
                                        if (mat < 12562) {
                                            if (mat == 12561) {
                                                return;
                                            }
                                        } else { // mat >= 12562
                                            if (mat == 12562) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12563
                                    if (mat < 12565) {
                                        if (mat < 12564) {
                                            if (mat == 12563) {
                                                return;
                                            }
                                        } else { // mat >= 12564
                                            if (mat == 12564) {
                                                doSolidBlockCheck = false;
                                                storeToAllFaces = true;
                                            }
                                        }
                                    } else { // mat >= 12565
                                        if (mat < 12566) {
                                            if (mat == 12565) {
                                                doSolidBlockCheck = false;
                                                storeToAllFaces = true;
                                            }
                                        } else { // mat >= 12566
                                            if (mat < 12567) {
                                                if (mat == 12566) {
                                                    doSolidBlockCheck = false;
                                                    storeToAllFaces = true;
                                                }
                                            } else { // mat >= 12567
                                                if (mat == 12567) {
                                                    doSolidBlockCheck = false;
                                                    storeToAllFaces = true;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else { // mat >= 12568
                if (mat < 12769) {
                    if (mat < 12680) {
                        if (mat < 12623) {
                            if (mat < 12600) {
                                if (mat < 12572) {
                                    if (mat < 12570) {
                                        if (mat < 12569) {
                                            if (mat == 12568) {
                                                return;
                                            }
                                        } else { // mat >= 12569
                                            if (mat == 12569) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12570
                                        if (mat < 12571) {
                                            if (mat == 12570) {
                                                return;
                                            }
                                        } else { // mat >= 12571
                                            if (mat == 12571) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12572
                                    if (mat < 12598) {
                                        if (mat < 12597) {
                                            if (mat == 12596) {
                                                return;
                                            }
                                        } else { // mat >= 12597
                                            if (mat == 12597) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12598
                                        if (mat < 12599) {
                                            if (mat == 12598) {
                                                return;
                                            }
                                        } else { // mat >= 12599
                                            if (mat == 12599) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            } else { // mat >= 12600
                                if (mat < 12604) {
                                    if (mat < 12602) {
                                        if (mat < 12601) {
                                            if (mat == 12600) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12601
                                            if (mat == 12601) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    } else { // mat >= 12602
                                        if (mat < 12603) {
                                            if (mat == 12602) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12603
                                            if (mat == 12603) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    }
                                } else { // mat >= 12604
                                    if (mat < 12621) {
                                        if (mat < 12609) {
                                            if (mat == 12608) {
                                                doSolidBlockCheck = false;
                                            }
                                        } else { // mat >= 12609
                                            if (mat == 12620) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12621
                                        if (mat < 12622) {
                                            if (mat == 12621) {
                                                return;
                                            }
                                        } else { // mat >= 12622
                                            if (mat == 12622) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            }
                        } else { // mat >= 12623
                            if (mat < 12669) {
                                if (mat < 12657) {
                                    if (mat < 12629) {
                                        if (mat < 12624) {
                                            if (mat == 12623) {
                                                return;
                                            }
                                        } else { // mat >= 12624
                                            if (mat == 12628) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    } else { // mat >= 12629
                                        if (mat < 12633) {
                                            if (mat == 12632) {
                                                doSolidBlockCheck = false;
                                            }
                                        } else { // mat >= 12633
                                            if (mat == 12656) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12657
                                    if (mat < 12659) {
                                        if (mat < 12658) {
                                            if (mat == 12657) {
                                                return;
                                            }
                                        } else { // mat >= 12658
                                            if (mat == 12658) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12659
                                        if (mat < 12660) {
                                            if (mat == 12659) {
                                                return;
                                            }
                                        } else { // mat >= 12660
                                            if (mat == 12668) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    }
                                }
                            } else { // mat >= 12669
                                if (mat < 12676) {
                                    if (mat < 12674) {
                                        if (mat < 12673) {
                                            if (mat == 12672) {
                                                return;
                                            }
                                        } else { // mat >= 12673
                                            if (mat == 12673) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12674
                                        if (mat < 12675) {
                                            if (mat == 12674) {
                                                return;
                                            }
                                        } else { // mat >= 12675
                                            if (mat == 12675) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12676
                                    if (mat < 12678) {
                                        if (mat < 12677) {
                                            if (mat == 12676) {
                                                return;
                                            }
                                        } else { // mat >= 12677
                                            if (mat == 12677) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12678
                                        if (mat < 12679) {
                                            if (mat == 12678) {
                                                return;
                                            }
                                        } else { // mat >= 12679
                                            if (mat == 12679) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else { // mat >= 12680
                        if (mat < 12696) {
                            if (mat < 12688) {
                                if (mat < 12684) {
                                    if (mat < 12682) {
                                        if (mat < 12681) {
                                            if (mat == 12680) {
                                                return;
                                            }
                                        } else { // mat >= 12681
                                            if (mat == 12681) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12682
                                        if (mat < 12683) {
                                            if (mat == 12682) {
                                                return;
                                            }
                                        } else { // mat >= 12683
                                            if (mat == 12683) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12684
                                    if (mat < 12686) {
                                        if (mat < 12685) {
                                            if (mat == 12684) {
                                                return;
                                            }
                                        } else { // mat >= 12685
                                            if (mat == 12685) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12686
                                        if (mat < 12687) {
                                            if (mat == 12686) {
                                                return;
                                            }
                                        } else { // mat >= 12687
                                            if (mat == 12687) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            } else { // mat >= 12688
                                if (mat < 12692) {
                                    if (mat < 12690) {
                                        if (mat < 12689) {
                                            if (mat == 12688) {
                                                return;
                                            }
                                        } else { // mat >= 12689
                                            if (mat == 12689) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12690
                                        if (mat < 12691) {
                                            if (mat == 12690) {
                                                return;
                                            }
                                        } else { // mat >= 12691
                                            if (mat == 12691) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12692
                                    if (mat < 12694) {
                                        if (mat < 12693) {
                                            if (mat == 12692) {
                                                return;
                                            }
                                        } else { // mat >= 12693
                                            if (mat == 12693) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12694
                                        if (mat < 12695) {
                                            if (mat == 12694) {
                                                return;
                                            }
                                        } else { // mat >= 12695
                                            if (mat == 12695) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            }
                        } else { // mat >= 12696
                            if (mat < 12711) {
                                if (mat < 12700) {
                                    if (mat < 12698) {
                                        if (mat < 12697) {
                                            if (mat == 12696) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12697
                                            if (mat == 12697) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    } else { // mat >= 12698
                                        if (mat < 12699) {
                                            if (mat == 12698) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12699
                                            if (mat == 12699) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    }
                                } else { // mat >= 12700
                                    if (mat < 12709) {
                                        if (mat < 12705) {
                                            if (mat == 12704) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12705
                                            if (mat == 12708) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    } else { // mat >= 12709
                                        if (mat < 12710) {
                                            if (mat == 12709) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12710
                                            if (mat == 12710) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    }
                                }
                            } else { // mat >= 12711
                                if (mat < 12733) {
                                    if (mat < 12717) {
                                        if (mat < 12712) {
                                            if (mat == 12711) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12712
                                            if (mat == 12716) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    } else { // mat >= 12717
                                        if (mat < 12729) {
                                            if (mat == 12728) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12729
                                            if (mat == 12732) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12733
                                    if (mat < 12735) {
                                        if (mat < 12734) {
                                            if (mat == 12733) {
                                                return;
                                            }
                                        } else { // mat >= 12734
                                            if (mat == 12734) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12735
                                        if (mat < 12736) {
                                            if (mat == 12735) {
                                                return;
                                            }
                                        } else { // mat >= 12736
                                            if (mat < 12761) {
                                                if (mat == 12760) {
                                                    if (textureRad.y < 5.0 / atlasSize.y) {
                                                        // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                        if (textureRad.x < 5.0 / atlasSize.x) return;
                                                    
                                                        // Half textureRad for stairs and slabs to not overshoot their textures
                                                        textureRad *= 0.5;
                                                    
                                                        // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                        // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                    }
                                                    
                                                    doSolidBlockCheck = false;
                                                    if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                                }
                                            } else { // mat >= 12761
                                                if (mat == 12768) {
                                                    if (textureRad.y < 5.0 / atlasSize.y) {
                                                        // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                        if (textureRad.x < 5.0 / atlasSize.x) return;
                                                    
                                                        // Half textureRad for stairs and slabs to not overshoot their textures
                                                        textureRad *= 0.5;
                                                    
                                                        // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                        // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                    }
                                                    
                                                    doSolidBlockCheck = false;
                                                    if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else { // mat >= 12769
                    if (mat < 12843) {
                        if (mat < 12805) {
                            if (mat < 12789) {
                                if (mat < 12785) {
                                    if (mat < 12777) {
                                        if (mat < 12773) {
                                            if (mat == 12772) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12773
                                            if (mat == 12776) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    } else { // mat >= 12777
                                        if (mat < 12781) {
                                            if (mat == 12780) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12781
                                            if (mat == 12784) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12785
                                    if (mat < 12787) {
                                        if (mat < 12786) {
                                            if (mat == 12785) {
                                                return;
                                            }
                                        } else { // mat >= 12786
                                            if (mat == 12786) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12787
                                        if (mat < 12788) {
                                            if (mat == 12787) {
                                                return;
                                            }
                                        } else { // mat >= 12788
                                            if (mat == 12788) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            } else { // mat >= 12789
                                if (mat < 12793) {
                                    if (mat < 12791) {
                                        if (mat < 12790) {
                                            if (mat == 12789) {
                                                return;
                                            }
                                        } else { // mat >= 12790
                                            if (mat == 12790) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12791
                                        if (mat < 12792) {
                                            if (mat == 12791) {
                                                return;
                                            }
                                        } else { // mat >= 12792
                                            if (mat == 12792) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12793
                                    if (mat < 12795) {
                                        if (mat < 12794) {
                                            if (mat == 12793) {
                                                return;
                                            }
                                        } else { // mat >= 12794
                                            if (mat == 12794) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12795
                                        if (mat < 12796) {
                                            if (mat == 12795) {
                                                return;
                                            }
                                        } else { // mat >= 12796
                                            if (mat == 12804) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    }
                                }
                            }
                        } else { // mat >= 12805
                            if (mat < 12831) {
                                if (mat < 12816) {
                                    if (mat < 12814) {
                                        if (mat < 12813) {
                                            if (mat == 12812) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12813
                                            if (mat == 12813) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    } else { // mat >= 12814
                                        if (mat < 12815) {
                                            if (mat == 12814) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12815
                                            if (mat == 12815) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    }
                                } else { // mat >= 12816
                                    if (mat < 12829) {
                                        if (mat < 12821) {
                                            if (mat == 12820) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12821
                                            if (mat == 12828) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12829
                                        if (mat < 12830) {
                                            if (mat == 12829) {
                                                return;
                                            }
                                        } else { // mat >= 12830
                                            if (mat == 12830) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            } else { // mat >= 12831
                                if (mat < 12839) {
                                    if (mat < 12837) {
                                        if (mat < 12832) {
                                            if (mat == 12831) {
                                                return;
                                            }
                                        } else { // mat >= 12832
                                            if (mat == 12836) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12837
                                        if (mat < 12838) {
                                            if (mat == 12837) {
                                                return;
                                            }
                                        } else { // mat >= 12838
                                            if (mat == 12838) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12839
                                    if (mat < 12841) {
                                        if (mat < 12840) {
                                            if (mat == 12839) {
                                                return;
                                            }
                                        } else { // mat >= 12840
                                            if (mat == 12840) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12841
                                        if (mat < 12842) {
                                            if (mat == 12841) {
                                                return;
                                            }
                                        } else { // mat >= 12842
                                            if (mat == 12842) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else { // mat >= 12843
                        if (mat < 12887) {
                            if (mat < 12859) {
                                if (mat < 12847) {
                                    if (mat < 12845) {
                                        if (mat < 12844) {
                                            if (mat == 12843) {
                                                return;
                                            }
                                        } else { // mat >= 12844
                                            if (mat == 12844) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12845
                                        if (mat < 12846) {
                                            if (mat == 12845) {
                                                return;
                                            }
                                        } else { // mat >= 12846
                                            if (mat == 12846) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12847
                                    if (mat < 12857) {
                                        if (mat < 12848) {
                                            if (mat == 12847) {
                                                return;
                                            }
                                        } else { // mat >= 12848
                                            if (mat == 12856) {
                                                if (abs(abs(normal.x) - 0.5) < 0.25) {
                                                    doSolidBlockCheck = false;
                                                    storeToAllFaces = true;
                                                } else return;
                                            }
                                        }
                                    } else { // mat >= 12857
                                        if (mat < 12858) {
                                            if (mat == 12857) {
                                                if (abs(abs(normal.x) - 0.5) < 0.25) {
                                                    doSolidBlockCheck = false;
                                                    storeToAllFaces = true;
                                                } else return;
                                            }
                                        } else { // mat >= 12858
                                            if (mat == 12858) {
                                                if (abs(abs(normal.x) - 0.5) < 0.25) {
                                                    doSolidBlockCheck = false;
                                                    storeToAllFaces = true;
                                                } else return;
                                            }
                                        }
                                    }
                                }
                            } else { // mat >= 12859
                                if (mat < 12863) {
                                    if (mat < 12861) {
                                        if (mat < 12860) {
                                            if (mat == 12859) {
                                                if (abs(abs(normal.x) - 0.5) < 0.25) {
                                                    doSolidBlockCheck = false;
                                                    storeToAllFaces = true;
                                                } else return;
                                            }
                                        } else { // mat >= 12860
                                            if (mat == 12860) {
                                                doSolidBlockCheck = false;
                                                storeToAllFaces = true;
                                            }
                                        }
                                    } else { // mat >= 12861
                                        if (mat < 12862) {
                                            if (mat == 12861) {
                                                doSolidBlockCheck = false;
                                                storeToAllFaces = true;
                                            }
                                        } else { // mat >= 12862
                                            if (mat == 12862) {
                                                doSolidBlockCheck = false;
                                                storeToAllFaces = true;
                                            }
                                        }
                                    }
                                } else { // mat >= 12863
                                    if (mat < 12885) {
                                        if (mat < 12864) {
                                            if (mat == 12863) {
                                                doSolidBlockCheck = false;
                                                storeToAllFaces = true;
                                            }
                                        } else { // mat >= 12864
                                            if (mat == 12884) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12885
                                        if (mat < 12886) {
                                            if (mat == 12885) {
                                                return;
                                            }
                                        } else { // mat >= 12886
                                            if (mat == 12886) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            }
                        } else { // mat >= 12887
                            if (mat < 12915) {
                                if (mat < 12897) {
                                    if (mat < 12889) {
                                        if (mat < 12888) {
                                            if (mat == 12887) {
                                                return;
                                            }
                                        } else { // mat >= 12888
                                            if (mat == 12888) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    } else { // mat >= 12889
                                        if (mat < 12893) {
                                            if (mat == 12892) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12893
                                            if (mat == 12896) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        }
                                    }
                                } else { // mat >= 12897
                                    if (mat < 12913) {
                                        if (mat < 12905) {
                                            if (mat == 12904) {
                                                if (textureRad.y < 5.0 / atlasSize.y) {
                                                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                                                    if (textureRad.x < 5.0 / atlasSize.x) return;
                                                
                                                    // Half textureRad for stairs and slabs to not overshoot their textures
                                                    textureRad *= 0.5;
                                                
                                                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                                                    // P.P.S: It seems like these checks only work well with default 16x textures but I don't have a better solution
                                                }
                                                
                                                doSolidBlockCheck = false;
                                                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
                                            }
                                        } else { // mat >= 12905
                                            if (mat == 12912) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12913
                                        if (mat < 12914) {
                                            if (mat == 12913) {
                                                return;
                                            }
                                        } else { // mat >= 12914
                                            if (mat == 12914) {
                                                return;
                                            }
                                        }
                                    }
                                }
                            } else { // mat >= 12915
                                if (mat < 12923) {
                                    if (mat < 12921) {
                                        if (mat < 12916) {
                                            if (mat == 12915) {
                                                return;
                                            }
                                        } else { // mat >= 12916
                                            if (mat == 12920) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12921
                                        if (mat < 12922) {
                                            if (mat == 12921) {
                                                return;
                                            }
                                        } else { // mat >= 12922
                                            if (mat == 12922) {
                                                return;
                                            }
                                        }
                                    }
                                } else { // mat >= 12923
                                    if (mat < 12925) {
                                        if (mat < 12924) {
                                            if (mat == 12923) {
                                                return;
                                            }
                                        } else { // mat >= 12924
                                            if (mat == 12924) {
                                                return;
                                            }
                                        }
                                    } else { // mat >= 12925
                                        if (mat < 12926) {
                                            if (mat == 12925) {
                                                return;
                                            }
                                        } else { // mat >= 12926
                                            if (mat < 12927) {
                                                if (mat == 12926) {
                                                    return;
                                                }
                                            } else { // mat >= 12927
                                                if (mat == 12927) {
                                                    return;
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


            if (mat == 10132) { // Grass Block Regular
                if (texture2D(tex, mc_midTexCoord.xy).a < 0.5) return; // Grass Block Side Overlay
            }

            if (abs(mat - 10009) <= 2) { // Leaves (10007, 10009, 10011)
                doSolidBlockCheck = false;
            }

            if (mat == 10129 // Farmland:Dry
                || mat == 10137 // Farmland:Wet
                || mat == 10493 // Dirt Path
            ) {
                doSolidBlockCheck = false;
                textureRad *= 0.5;
                origin.y += 2.0 / atlasSize.y;
            }

            if (abs(mat - 10069) <= 1 // Lava (10068, 10070)
            ) {
                if (abs(dot(textureRad, vec2(atlasSize.x, -atlasSize.y))) < 6.5)
                    storeToAllFaces = true;
                else return;
            }

            // Half blocks that we want to display as full blocks in reflections
            if (mat == 10035 // Stone Bricks, Mossy Stone Bricks
                || abs(mat - 10095) <= 12 && mat % 4 == 3 // Stone, Smooth Stone, Granite, Diorite, Andesite, Bricks, Mud Bricks
                || mat == 10155 // Cobblestone, Mossy Cobblestone
                || abs(mat - 10191) <= 32 && mat % 8 == 7 // Oak, Spruce, Birch, Jungle, Acacia, DarkOak, Mangrove, Crimson, Warped
                || mat == 10111 // Cobbled Deepslate
                || mat == 10115 // Polished Deepslate, Deepslate Bricks, Deepslate Tiles
                || mat == 10243 // Sandstone
                || mat == 10247 // Red Sandstone
                || mat == 10295 // Copper
                || mat == 10367 // Quartz
                || mat == 10379 // Purpur
                || mat == 10381 // Powder Snow
                || mat == 10419 // Nether Bricks
                || mat == 10423 // Red Nether Bricks
                || mat == 10431 // End Stone Bricks
                || mat == 10443 // Prismarine, Prismarine Bricks
                || mat == 10447 // Dark Prismarine
                || mat == 10483 // Blackstone
                || mat == 10715 // Tuff
                || mat == 10759 // Bamboo, Bamboo Mosaic
                || mat == 10763 // Cherry
                || mat == 10931 // Pale Oak
            ) {
                if (textureRad.y < 5.0 / atlasSize.y) {
                    // Discarding if textureRad is too small to fix (somewhat rare) flickering on stairs
                    if (textureRad.x < 5.0 / atlasSize.x) return;

                    // Half textureRad for stairs and slabs to not overshoot their textures
                    textureRad *= 0.5;

                    // P.S: Don't ask me how any of these checks make sense because I have absolutely no idea either
                }

                doSolidBlockCheck = false;
                if (normal.y < 0.5) storeToAllFacesExceptTop = true; // Not overriding top face or else carpets look broken on top of slabs
            }

            if (mat == 10669 || mat == 10843|| mat == 10845 || mat == 10925 || mat == 10953) { // Wool Carpets, Moss Carpet, Snow Layers < 8
                if (normal.y > 0.5) {
                    voxelPos.y -= 1.0;
                    doSolidBlockCheck = false;
                } else return;
            }

            if (mat == 10072 // Fire
                || mat == 10076 // Soul Fire
                || mat == 10332 // Amethyst Clusters
                || mat == 10544 // Glow Lichen
            ) {
                doSolidBlockCheck = false;
                storeToAllFaces = true;
            }

            if (mat == 10652 || mat == 10656) { // Campfire:Lit, Soul Campfire:Lit
                if (abs(abs(normal.x) - 0.5) < 0.25) {
                    doSolidBlockCheck = false;
                    storeToAllFaces = true;
                } else return;
            }

            // Blocks to remove from reflections
            if (mat == 10056 // Lava Cauldron
                || mat == 10404 // Sea Pickle
                || mat == 10496 // Torch
                || mat == 10500 // End Rod
                || mat == 10508 // Chorus Flower:Alive
                || mat == 10512 // Chorus Flower:Dead
                || mat == 10528 // Soul Torch
                || mat == 10556 // End Portal Frame:Active
                || mat == 10572 // Dragon Egg
                || mat == 10604 || mat == 10605 // Redstone Torch
                || mat == 10632 // Cave Vines
                || mat == 10644 // Powered Repeater, Powered Comparator
                || mat == 10776 // Crimson Fungus, Warped Fungus
                || mat == 10780 // Potted Crimson Fungus, Potted Warped Fungus
                || mat == 10836 // Brewing Stand
                || mat == 10884 // Weeping Vines
                || mat == 10972 // Firefly Bush
                || mat == 10976 // Open Eyeblossom
                || mat == 10980 // Potted Open Eyeblossom
                || abs(mat - 10562) <= 2 // Lantern & Soul Lantern
                || abs(mat - 10599) <= 3 // Redstone Wire
                || abs(mat - 10701) <= 3 // Non-Solid Sculk Stuff
                || abs(mat - 10786) <= 2 // Calibrated Sculk Sensor
                || abs(mat - 10911) <= 11 // Lit Candles & Candle Cakes
                || mat == 10984 // Copper Torch
                || mat == 10988 // Copper Lantern
            ) {
                return;
            }

            if (doSolidBlockCheck) {
                if (
                    mat % 2 == 1 // Non-solids
                    || abs(mat - 5000) <= 4999 // Block entities that we treat as non-solid
                )
                return;
            }

            imageStore(wsr_img, ivec3(voxelPos), uvec4(matM, 0u, 0u, 0u));
            storeFaceData(ivec3(voxelPos), round(normal), origin, textureRad.x, storeToAllFaces, storeToAllFacesExceptTop, scenePos);

            updateWsrBitmask(ivec3(voxelPos));
            updateWsrLodBitmask(ivec3(voxelPos / 4.0));
        }
    }

    #if WORLD_SPACE_PLAYER_REF == 1
        uniform writeonly image2D playerAtlas_img;

        #define updateAABB(aabb_min, aabb_max, pos) \
                      atomicMin(aabb_min.x, pos.x); \
                      atomicMin(aabb_min.y, pos.y); \
                      atomicMin(aabb_min.z, pos.z); \
                      atomicMax(aabb_max.x, pos.x); \
                      atomicMax(aabb_max.y, pos.y); \
                      atomicMax(aabb_max.z, pos.z);


        void UpdatePlayerVertexList(vec3 position) {
            if (entityId == 50017 && textureSize(tex, 0) == ivec2(64) && gl_VertexID < 288) { // Current Player

                // The atlas takes 4 frames to fully generate, reload every 600 frames
                if (framemod600 > 5 && framemod600 <= 9 && gl_VertexID < 256) {
                    int i = gl_VertexID * 4 + int(framemod4) * 1024;
                    for (int j = 0; j < 4; j++) {
                        ivec2 coord = ivec2((i + j) % 64, (i + j) / 64);
                        imageStore(playerAtlas_img, coord, texelFetch(tex, coord, 0));
                    }
                }

                ivec3 aabbPos = ivec3(position * 1000.0);

                if (gl_VertexID < 48) { // Head
                    updateAABB(playerVerticesSSBO.bounds.headMin, playerVerticesSSBO.bounds.headMax, aabbPos);
                } else if (gl_VertexID < 96) { // Right Hand
                    updateAABB(playerVerticesSSBO.bounds.rightHandMin, playerVerticesSSBO.bounds.rightHandMax, aabbPos);
                } else if (gl_VertexID < 144) { // Left Leg
                    updateAABB(playerVerticesSSBO.bounds.leftLegMin, playerVerticesSSBO.bounds.leftLegMax, aabbPos);
                } else if (gl_VertexID < 192) { // Left Hand
                    updateAABB(playerVerticesSSBO.bounds.leftHandMin, playerVerticesSSBO.bounds.leftHandMax, aabbPos);
                } else if (gl_VertexID < 240) { // Right leg
                    updateAABB(playerVerticesSSBO.bounds.rightLegMin, playerVerticesSSBO.bounds.rightLegMax, aabbPos);
                } else { // Torso
                    updateAABB(playerVerticesSSBO.bounds.torsoMin, playerVerticesSSBO.bounds.torsoMax, aabbPos);
                }

                if (gl_VertexID % 4 != 3) {
                    int ssboIndex = gl_VertexID - gl_VertexID / 4;
                    playerVerticesSSBO.vertexPositions[ssboIndex] = position;
                    playerVerticesSSBO.vertexData[ssboIndex] = texCoord;
                }
            }
        }
    #endif
#endif
