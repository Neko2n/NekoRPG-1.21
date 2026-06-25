package com.nekotune.minecraftjourneys.registry;

import java.util.function.Supplier;

import com.nekotune.minecraftjourneys.MinecraftJourneys;
import com.nekotune.minecraftjourneys.definition.block.PearBlock;

import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.SoundType;
import net.minecraft.world.level.block.state.properties.NoteBlockInstrument;
import net.minecraft.world.level.material.MapColor;
import net.minecraft.world.level.material.PushReaction;

@SuppressWarnings("null")
public class Blocks {

    /**
     * The Bountiful Fares fruit block for pears from No Man's Land.
     */
    public static final Supplier<Block> PEAR_BLOCK = MinecraftJourneys.BLOCKS.registerBlock(
        "pear_block",
        (properties) -> new PearBlock(properties
            .mapColor(MapColor.COLOR_LIGHT_GREEN)
            .strength(1f)
            .instrument(NoteBlockInstrument.DIDGERIDOO)
            .sound(SoundType.WOOD)
            .pushReaction(PushReaction.DESTROY)
    ));
}
