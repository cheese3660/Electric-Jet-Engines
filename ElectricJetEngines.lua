-- Electric Jet Engines
-- Converts the Wheesley, Whittle, and Goliath turbofans to run on
-- ElectricCharge instead of fuel. Optionally rebalances the tech tree.

-- ── Campaign features ─────────────────────────────────────────────────────
-- Each campaign can switch these on or off (Mods menu -> Default Features,
-- or the campaign Feature Editor). No restart-required config toggles needed.
-- Names and descriptions come from localizations/electric_jet_engines.csv.

PM:DefineFeature("Wheesley", { recommended = true })
PM:DefineFeature("Whittle",  { recommended = true })
PM:DefineFeature("Goliath",  { recommended = true })
PM:DefineFeature("TechTree", { recommended = true })

-- ── Electric propellant recipe ────────────────────────────────────────────
-- NewRecipe creates a recipe-style resource (ingredients list).
-- 50 000 EC consumed per propellant recipe unit.

PM.Resources:NewRecipe("ElectricJetPropellant", function(recipe)
    recipe.displayNameKey  = "Resource/DisplayName/ElectricCharge"
    recipe.abbreviationKey = "Resource/Abbreviation/EC"
    recipe.vfxFuelType     = "Electric"
    recipe.ingredients:Add("ElectricCharge", 50000.0)
end)

-- ── Helper: swap propellant on all engine modes, strip fuel containers ────

local function electrifyEngine(part)
    part:PatchModule("Module_Engine", function(module)
        module:PatchData("Data_Engine", function(engine)
            for _, mode in pairs(engine.engineModes) do
                mode.propellant.mixtureName = "ElectricJetPropellant"
            end
        end)
    end)
    part.resourceContainers:RemoveWhere(function(c)
        return c.name == "MethaneAir"
            or c.name == "Methane"
            or c.name == "LiquidFuel"
    end)
end

-- ── Part patches ──────────────────────────────────────────────────────────

PM.Parts:Patch("ElectricWheesley")
    :Feature("Wheesley")
    :Named("engine_1v_turbofan_methane_wheesley")
    :Do(function(part) electrifyEngine(part) end)

PM.Parts:Patch("ElectricWhittle")
    :Feature("Whittle")
    :Named("engine_0v_methane_whittle")
    :Do(function(part) electrifyEngine(part) end)

PM.Parts:Patch("ElectricGoliath")
    :Feature("Goliath")
    :Named("engine_2v_turbofan_methane_goliath")
    :Do(function(part) electrifyEngine(part) end)

-- ── Tech tree rebalance ───────────────────────────────────────────────────

PM.Science:PatchTechNodes("ElectricEnginesTechTree")
    :Feature("TechTree")
    :Do(function(node)

        -- Light Aviation: add Panther + Z-1K battery alongside existing parts
        if node.ID == "tNode_1v_aero_02" then
            node.UnlockedPartsIDs:Clear()
            node.UnlockedPartsIDs:Append("cockpit_1v_m1_crew")
            node.UnlockedPartsIDs:Append("cockpit_1v_m1_inline_crew")
            node.UnlockedPartsIDs:Append("fueltank_1v_m1_inline_methane")
            node.UnlockedPartsIDs:Append("engine_1v_turbofan_methane_wheesley")
            node.UnlockedPartsIDs:Append("engine_1v_turbofan_methane_panther")
            node.UnlockedPartsIDs:Append("landinggear_1v")
            node.UnlockedPartsIDs:Append("landinggear_1v_fixed")
            node.UnlockedPartsIDs:Append("intake_1v_circular")
            node.UnlockedPartsIDs:Append("wing_1v_procedural_light")
            node.UnlockedPartsIDs:Append("stabilizer_2v_procedural_heavy")
            node.UnlockedPartsIDs:Append("storage_1v_battery_electricity")
        end

        -- Enlarged Power Systems: remove Z-1K battery
        if node.ID == "tNode_2v_electronics_01" then
            node.UnlockedPartsIDs:Clear()
            node.UnlockedPartsIDs:Append("solararray_2v_accordion")
            node.UnlockedPartsIDs:Append("fuelcell_0v")
        end

        -- Mk2 Jets: remove Panther
        if node.ID == "tNode_2v_aero_01" then
            node.UnlockedPartsIDs:Clear()
            node.UnlockedPartsIDs:Append("cockpit_2v_m2_crew")
            node.UnlockedPartsIDs:Append("cockpit_2v_m2_inline_crew")
            node.UnlockedPartsIDs:Append("landinggear_2v")
            node.UnlockedPartsIDs:Append("airbrake_1v")
            node.UnlockedPartsIDs:Append("intake_1v_m1_nacelle_methane")
            node.UnlockedPartsIDs:Append("fueltank_2v_m2_inline_methane_1x1")
            node.UnlockedPartsIDs:Append("fueltank_2v_m2_inline_methane_1x2")
            node.UnlockedPartsIDs:Append("wing_2v_procedural_heavy")
        end

    end)
