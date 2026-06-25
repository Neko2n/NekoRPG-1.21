package com.nekotune.minecraftjourneys.definition.block;

import com.farcr.nomansland.common.registry.items.NMLItems;

import net.hecco.bountifulfares.definition.block.custom.HangingFruitBlock;
import net.hecco.bountifulfares.definition.platform.Services;
import net.hecco.bountifulfares.definition.platform.services.IPlatformHelper;
import net.hecco.bountifulfares.definition.trigger.PickFruitInteractionTrigger;
import net.hecco.bountifulfares.registry.content.BFSounds;
import net.hecco.bountifulfares.registry.misc.BFCriteriaTriggers;
import net.hecco.bountifulfares.registry.tags.BFBlockTags;
import net.hecco.nexuslib.platform.NLServices;
import net.minecraft.core.BlockPos;
import net.minecraft.core.Direction;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.sounds.SoundEvent;
import net.minecraft.sounds.SoundSource;
import net.minecraft.tags.TagKey;
import net.minecraft.world.InteractionResult;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.Items;
import net.minecraft.world.level.BlockGetter;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.LevelReader;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.state.*;
import net.minecraft.world.level.gameevent.GameEvent;
import net.minecraft.world.level.gameevent.GameEvent.Context;
import net.minecraft.world.phys.BlockHitResult;
import net.minecraft.world.phys.Vec3;
import net.minecraft.world.phys.shapes.BooleanOp;
import net.minecraft.world.phys.shapes.CollisionContext;
import net.minecraft.world.phys.shapes.Shapes;
import net.minecraft.world.phys.shapes.VoxelShape;

public class HangingPearBlock extends HangingFruitBlock {
   public HangingPearBlock(BlockBehaviour.Properties settings) {
      super(settings);
   }

   private static final VoxelShape[] SHAPES;
   private static final VoxelShape[] COLL_SHAPES;

   public VoxelShape getShape(BlockState state, BlockGetter world, BlockPos pos, CollisionContext context) {
      VoxelShape voxelShape = SHAPES[(Integer)state.getValue(AGE)];
      if (!NLServices.PLATFORM.isModLoaded("twigs") && !NLServices.PLATFORM.isModLoaded("etcetera")) {
         Vec3 vec3d = state.getOffset(world, pos);
         return voxelShape.move(vec3d.x, vec3d.y, vec3d.z);
      } else {
         return voxelShape;
      }
   }

   public VoxelShape getCollisionShape(BlockState state, BlockGetter world, BlockPos pos, CollisionContext context) {
      VoxelShape voxelShape = COLL_SHAPES[(Integer)state.getValue(AGE)];
      if (!NLServices.PLATFORM.isModLoaded("twigs") && !NLServices.PLATFORM.isModLoaded("etcetera")) {
         Vec3 vec3d = state.getOffset(world, pos);
         return voxelShape.move(vec3d.x, vec3d.y, vec3d.z);
      } else {
         return voxelShape;
      }
   }

   public float getMaxHorizontalOffset() {
      return !NLServices.PLATFORM.isModLoaded("twigs") && !NLServices.PLATFORM.isModLoaded("etcetera") ? super.getMaxHorizontalOffset() : 0.0F;
   }

   public boolean canSurvive(BlockState state, LevelReader world, BlockPos pos) {
      // TODO: Change to Pear Leaves when implemented.
      final TagKey<Block> VALID_BLOCKS = BFBlockTags.APPLE_LEAVES;
      return (Block.canSupportCenter(world, pos.above(), Direction.DOWN) || world.getBlockState(pos.above()).is(VALID_BLOCKS)) && !world.isWaterAt(pos);
   }

   public InteractionResult useWithoutItem(BlockState state, Level world, BlockPos pos, Player player, BlockHitResult hit) {
      int i = (Integer)state.getValue(AGE);
      if (i == 4) {
         HangingFruitBlock.popResource(world, pos, new ItemStack(Items.APPLE, 1));
         world.playSound((Player)null, pos, (SoundEvent)BFSounds.HANGING_FRUIT_PICK.get(), SoundSource.BLOCKS, 1.0F, 0.8F + world.random.nextFloat() * 0.4F);
         if (!world.isClientSide()) {
            if (((IPlatformHelper)Services.PLATFORM.get()).getBoolConfigValue("fruitReplaceWhenPicked")) {
               BlockState blockState = (BlockState)state.setValue(AGE, 0);
               world.setBlock(pos, blockState, 2);
               world.gameEvent(GameEvent.BLOCK_CHANGE, pos, Context.of(player, blockState));
            } else {
               world.removeBlock(pos, false);
            }

            ((PickFruitInteractionTrigger)BFCriteriaTriggers.PICK_FRUIT.get()).trigger((ServerPlayer)player, pos);
         }

         return InteractionResult.SUCCESS;
      } else {
         return super.useWithoutItem(state, world, pos, player, hit);
      }
   }

   public ItemStack getCloneItemStack(LevelReader world, BlockPos pos, BlockState state) {
      return new ItemStack(NMLItems.PEAR.get());
   }

   static {
      SHAPES = new VoxelShape[]{Block.box((double)7.0F, (double)13.0F, (double)7.0F, (double)9.0F, (double)16.0F, (double)9.0F), Block.box((double)6.0F, (double)13.0F, (double)6.0F, (double)10.0F, (double)16.0F, (double)10.0F), Block.box((double)6.5F, (double)13.0F, (double)6.5F, (double)9.5F, (double)16.0F, (double)9.5F), Shapes.join(Block.box((double)5.5F, (double)10.0F, (double)5.5F, (double)10.5F, (double)15.0F, (double)10.5F), Block.box((double)7.0F, (double)15.0F, (double)7.0F, (double)9.0F, (double)16.0F, (double)9.0F), BooleanOp.OR), Shapes.join(Block.box((double)5.0F, (double)8.0F, (double)5.0F, (double)11.0F, (double)14.0F, (double)11.0F), Block.box((double)7.0F, (double)14.0F, (double)7.0F, (double)9.0F, (double)16.0F, (double)9.0F), BooleanOp.OR)};
      COLL_SHAPES = new VoxelShape[]{Shapes.empty(), Shapes.empty(), Block.box((double)6.5F, (double)13.0F, (double)6.5F, (double)9.5F, (double)16.0F, (double)9.5F), Shapes.join(Block.box((double)5.5F, (double)10.0F, (double)5.5F, (double)10.5F, (double)15.0F, (double)10.5F), Block.box((double)7.0F, (double)15.0F, (double)7.0F, (double)9.0F, (double)16.0F, (double)9.0F), BooleanOp.OR), Shapes.join(Block.box((double)5.0F, (double)8.0F, (double)5.0F, (double)11.0F, (double)14.0F, (double)11.0F), Block.box((double)7.0F, (double)14.0F, (double)7.0F, (double)9.0F, (double)16.0F, (double)9.0F), BooleanOp.OR)};
   }
}
