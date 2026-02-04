------------------------------------------------------------------------------------------------------
-- Manual Compute HRP
-- Computes Humanoid.HipHeight from the selected Model's bounding box and HumanoidRootPart.
------------------------------------------------------------------------------------------------------

local Selection = game:GetService("Selection")

local PLUGIN_NAME = "Manual Compute HRP"
local PLUGIN_SUMMARY = "Compute HipHeight from the selected Model's geometry and HumanoidRootPart."
local PLUGIN_ICON = "rbxassetid://6284437024"

local toolbar = plugin:CreateToolbar("Manual Compute HRP")
local button = toolbar:CreateButton(PLUGIN_NAME, PLUGIN_SUMMARY, PLUGIN_ICON)

local function runCompute()
	local selection = Selection:Get()
	local model = selection[1]

	if not model or not model:IsA("Model") then
		warn("Please select a Model!")
		return
	end

	local hrp = model:FindFirstChild("HumanoidRootPart")
	local humanoid = model:FindFirstChildOfClass("Humanoid")

	if not hrp or not humanoid then
		warn("Model must have a HumanoidRootPart and a Humanoid.")
		return
	end

	-- 1. Find the lowest point of the model's geometry (the paws/belly)
	local orientation, size = model:GetBoundingBox()
	local modelBottomY = orientation.Position.Y - (size.Y / 2)

	-- 2. Find the bottom point of the HumanoidRootPart
	local hrpBottomY = hrp.Position.Y - (hrp.Size.Y / 2)

	-- 3. Calculate the distance between the two
	-- HipHeight = The 'gap' the Humanoid needs to maintain to keep the HRP at its current height
	local computedHipHeight = hrpBottomY - modelBottomY

	-- 4. Apply
	humanoid.AutomaticScalingEnabled = false
	humanoid.HipHeight = math.max(0, computedHipHeight)

	print("--- HipHeight Computation Complete ---")
	print("Model Bottom Y: " .. modelBottomY)
	print("HRP Bottom Y: " .. hrpBottomY)
	print("New HipHeight: " .. humanoid.HipHeight)
end

button.Click:Connect(runCompute)
