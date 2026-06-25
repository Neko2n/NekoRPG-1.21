package com.nekotune.minecraftjourneys;

import net.minecraft.client.Minecraft;
import net.neoforged.api.distmarker.Dist;
import net.neoforged.bus.api.SubscribeEvent;
import net.neoforged.fml.ModContainer;
import net.neoforged.fml.common.EventBusSubscriber;
import net.neoforged.fml.common.Mod;
import net.neoforged.fml.event.lifecycle.FMLClientSetupEvent;
import net.neoforged.neoforge.client.gui.ConfigurationScreen;
import net.neoforged.neoforge.client.gui.IConfigScreenFactory;

/**
 * This class will not load on dedicated servers. Accessing client side code from here is safe.
 * You can use EventBusSubscriber to automatically register all static methods in the class annotated with @SubscribeEvent
 */
@Mod(value = MinecraftJourneys.MODID, dist = Dist.CLIENT)
@EventBusSubscriber(modid = MinecraftJourneys.MODID, value = Dist.CLIENT)
public class MinecraftJourneysClient {
    public MinecraftJourneysClient(ModContainer container) {
        // Allows NeoForge to create a config screen for this mod's configs.
        // The config screen is accessed by going to the Mods screen > clicking on your mod > clicking on config.
        // Do not forget to add translations for your config options to the en_us.json file.
        container.registerExtensionPoint(IConfigScreenFactory.class, ConfigurationScreen::new);
    }

    @SubscribeEvent
    static void onClientSetup(FMLClientSetupEvent event) {
        // Some client setup code
        MinecraftJourneys.LOGGER.info("HELLO FROM CLIENT SETUP");
        MinecraftJourneys.LOGGER.info("MINECRAFT NAME >> {}", Minecraft.getInstance().getUser().getName());
    }
}
