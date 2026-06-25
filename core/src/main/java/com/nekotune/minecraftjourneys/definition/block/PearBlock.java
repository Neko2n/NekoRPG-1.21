package com.nekotune.minecraftjourneys.definition.block;

import java.util.stream.Stream;

import com.farcr.nomansland.common.registry.items.NMLItems;
import net.hecco.bountifulfares.definition.block.custom.FruitBlock;
import net.minecraft.core.BlockPos;
import net.minecraft.core.Direction;
import net.minecraft.world.item.Item;
import net.minecraft.world.level.BlockGetter;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.phys.shapes.BooleanOp;
import net.minecraft.world.phys.shapes.CollisionContext;
import net.minecraft.world.phys.shapes.Shapes;
import net.minecraft.world.phys.shapes.VoxelShape;

@SuppressWarnings("null")
public class PearBlock extends FruitBlock {
    private static final VoxelShape[] NORTH_SHAPES;
    private static final VoxelShape[] EAST_SHAPES;
    private static final VoxelShape[] SOUTH_SHAPES;
    private static final VoxelShape[] WEST_SHAPES;

    public PearBlock(Properties settings) {
        super(settings);
    }

    @Override
    public Item getFruitItem() {
        return NMLItems.PEAR.get();
    }

    @Override
    public VoxelShape getShape(BlockState state, BlockGetter world, BlockPos pos, CollisionContext context) {
        if ((Integer) state.getValue(SLICES) != 0) {
            if (state.getValue(FACING) == Direction.NORTH) {
                return NORTH_SHAPES[(Integer) state.getValue(SLICES) - 1];
            }
            if (state.getValue(FACING) == Direction.EAST) {
                return EAST_SHAPES[(Integer) state.getValue(SLICES) - 1];
            }
            if (state.getValue(FACING) == Direction.SOUTH) {
                return SOUTH_SHAPES[(Integer) state.getValue(SLICES) - 1];
            }
            if (state.getValue(FACING) == Direction.WEST) {
                return WEST_SHAPES[(Integer) state.getValue(SLICES) - 1];
            }
        }
        return Shapes.join(
                Block.box((double) 4.0F, (double) 16.0F, (double) 4.0F, (double) 12.0F, (double) 20.0F, (double) 12.0F),
                Block.box((double) 0.0F, (double) 0.0F, (double) 0.0F, (double) 16.0F, (double) 16.0F, (double) 16.0F),
                BooleanOp.OR);
    }

    static {
        NORTH_SHAPES = new VoxelShape[]{(VoxelShape)Stream.of(Block.box((double)8.0F, (double)0.0F, (double)0.0F, (double)16.0F, (double)16.0F, (double)16.0F), Block.box((double)0.0F, (double)0.0F, (double)8.0F, (double)8.0F, (double)16.0F, (double)16.0F), Block.box((double)4.0F, (double)16.0F, (double)8.0F, (double)12.0F, (double)20.0F, (double)12.0F), Block.box((double)8.0F, (double)16.0F, (double)4.0F, (double)12.0F, (double)20.0F, (double)8.0F)).reduce((v1, v2) -> Shapes.join(v1, v2, BooleanOp.OR)).get(), Shapes.join(Block.box((double)0.0F, (double)0.0F, (double)8.0F, (double)16.0F, (double)16.0F, (double)16.0F), Block.box((double)4.0F, (double)16.0F, (double)8.0F, (double)12.0F, (double)20.0F, (double)12.0F), BooleanOp.OR), Shapes.join(Block.box((double)0.0F, (double)0.0F, (double)8.0F, (double)8.0F, (double)16.0F, (double)16.0F), Block.box((double)4.0F, (double)16.0F, (double)8.0F, (double)8.0F, (double)20.0F, (double)12.0F), BooleanOp.OR)};
        EAST_SHAPES = new VoxelShape[]{(VoxelShape)Stream.of(Block.box((double)0.0F, (double)0.0F, (double)8.0F, (double)16.0F, (double)16.0F, (double)16.0F), Block.box((double)0.0F, (double)0.0F, (double)0.0F, (double)8.0F, (double)16.0F, (double)8.0F), Block.box((double)4.0F, (double)16.0F, (double)4.0F, (double)8.0F, (double)20.0F, (double)12.0F), Block.box((double)8.0F, (double)16.0F, (double)8.0F, (double)12.0F, (double)20.0F, (double)12.0F)).reduce((v1, v2) -> Shapes.join(v1, v2, BooleanOp.OR)).get(), Shapes.join(Block.box((double)0.0F, (double)0.0F, (double)0.0F, (double)8.0F, (double)16.0F, (double)16.0F), Block.box((double)4.0F, (double)16.0F, (double)4.0F, (double)8.0F, (double)20.0F, (double)12.0F), BooleanOp.OR), Shapes.join(Block.box((double)0.0F, (double)0.0F, (double)0.0F, (double)8.0F, (double)16.0F, (double)8.0F), Block.box((double)4.0F, (double)16.0F, (double)4.0F, (double)8.0F, (double)20.0F, (double)8.0F), BooleanOp.OR)};
        SOUTH_SHAPES = new VoxelShape[]{(VoxelShape)Stream.of(Block.box((double)0.0F, (double)0.0F, (double)0.0F, (double)8.0F, (double)16.0F, (double)16.0F), Block.box((double)8.0F, (double)0.0F, (double)0.0F, (double)16.0F, (double)16.0F, (double)8.0F), Block.box((double)4.0F, (double)16.0F, (double)4.0F, (double)12.0F, (double)20.0F, (double)8.0F), Block.box((double)4.0F, (double)16.0F, (double)8.0F, (double)8.0F, (double)20.0F, (double)12.0F)).reduce((v1, v2) -> Shapes.join(v1, v2, BooleanOp.OR)).get(), Shapes.join(Block.box((double)0.0F, (double)0.0F, (double)0.0F, (double)16.0F, (double)16.0F, (double)8.0F), Block.box((double)4.0F, (double)16.0F, (double)4.0F, (double)12.0F, (double)20.0F, (double)8.0F), BooleanOp.OR), Shapes.join(Block.box((double)8.0F, (double)0.0F, (double)0.0F, (double)16.0F, (double)16.0F, (double)8.0F), Block.box((double)8.0F, (double)16.0F, (double)4.0F, (double)12.0F, (double)20.0F, (double)8.0F), BooleanOp.OR)};
        WEST_SHAPES = new VoxelShape[]{(VoxelShape)Stream.of(Block.box((double)0.0F, (double)0.0F, (double)0.0F, (double)16.0F, (double)16.0F, (double)8.0F), Block.box((double)8.0F, (double)0.0F, (double)8.0F, (double)16.0F, (double)16.0F, (double)16.0F), Block.box((double)8.0F, (double)16.0F, (double)4.0F, (double)12.0F, (double)20.0F, (double)12.0F), Block.box((double)4.0F, (double)16.0F, (double)4.0F, (double)8.0F, (double)20.0F, (double)8.0F)).reduce((v1, v2) -> Shapes.join(v1, v2, BooleanOp.OR)).get(), Shapes.join(Block.box((double)8.0F, (double)0.0F, (double)0.0F, (double)16.0F, (double)16.0F, (double)16.0F), Block.box((double)8.0F, (double)16.0F, (double)4.0F, (double)12.0F, (double)20.0F, (double)12.0F), BooleanOp.OR), Shapes.join(Block.box((double)8.0F, (double)0.0F, (double)8.0F, (double)16.0F, (double)16.0F, (double)16.0F), Block.box((double)8.0F, (double)16.0F, (double)8.0F, (double)12.0F, (double)20.0F, (double)12.0F), BooleanOp.OR)};
    }
}
