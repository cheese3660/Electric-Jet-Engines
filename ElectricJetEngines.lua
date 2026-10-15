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
    local modes = {}
    part:PatchModule("Module_Engine", function(module)
        module:PatchData("Data_Engine", function(engine)
            for _, mode in pairs(engine.engineModes) do
                modes[#modes + 1] = mode
            end
        end)
    end)

    PM.VSwift:AddPartSwitch(part, function(data)
        data.ActiveVariants = { "standard" }
        data.DefaultActiveVariants = { "standard" }
        data:EnsureVariantSet("propulsion", function(set)
            set:EnsureVariant("standard", function(variant) end)
            set:EnsureVariant("electric", function(variant)
                variant:EnsureTransformer("EngineModeSwapper", function(swapper)
                    for _, mode in pairs(modes) do
                        swapper:Append(mode)
                        swapper[mode.engineID].propellant.mixtureName = "ElectricJetPropellant"
                    end
                end)
                variant:EnsureTransformer("ResourceContainerRemover", function(remover)
                    remover.Containers = { "MethaneAir", "Methane", "LiquidFuel" }
                end)
            end)
        end)
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

local function electricAviationNode(id, x, cost, prerequisite, engine)
    PM.Science:NewTechNode(id, function(node)
        node.NameLocKey = "ElectricEngines/TechNodes/Names/" .. id
        node.DescriptionLocKey = "ElectricEngines/TechNodes/Descriptions/" .. id
        node.IconID = "ICO-RDCenter-Plane-24x"
        node.RequiredSciencePoints = cost
        node.RequiredTechNodeIDs:Append(prerequisite)
        node.TechTreePosition.x = x
        node.TechTreePosition.y = 90
        node.UnlockedVariants:Append({ PartName = engine, VariantSetId = "propulsion", VariantId = "electric" })
    end):Feature("TechTree")
end

electricAviationNode("tNode_1v_electric_aviation_01", 1080, 100, "tNode_1v_aero_02", "engine_1v_turbofan_methane_wheesley")
electricAviationNode("tNode_2v_electric_aviation_02", 2520, 600, "tNode_2v_aero_03", "engine_1v_turbofan_methane_panther")
electricAviationNode("tNode_3v_electric_aviation_03", 3960, 4000, "tNode_2v_electric_aviation_02", "engine_2v_turbofan_methane_goliath")
