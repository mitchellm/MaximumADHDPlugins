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
	local models = {}
	for _, obj in ipairs(selection) do
		if obj:IsA("Model") then
			table.insert(models, obj)
		end
	end

	if #models == 0 then
		warn("Manual Compute HRP: Please select one or more Models.")
		return
	end

	local processed = 0
	local skipped = {}

	for _, model in ipairs(models) do
		local hrp = model:FindFirstChild("HumanoidRootPart")
		local humanoid = model:FindFirstChildOfClass("Humanoid")

		if not hrp or not humanoid then
			table.insert(skipped, model.Name)
			continue
		end

		-- 1. Find the lowest point of the model's geometry (the paws/belly)
		local orientation, size = model:GetBoundingBox()
		local modelBottomY = orientation.Position.Y - (size.Y / 2)

		-- 2. Find the bottom point of the HumanoidRootPart
		local hrpBottomY = hrp.Position.Y - (hrp.Size.Y / 2)

		-- 3. Calculate the distance between the two
		-- HipHeight = The 'gap' the Humanoid needs to maintain to keep the HRP at its current height
		local computedHipHeight = hrpBottomY - modelBottomY

		-- 4. Apply HipHeight
		humanoid.AutomaticScalingEnabled = false
		humanoid.HipHeight = math.max(0, computedHipHeight)

		-- 5. Set pivot at the same point (bottom center of geometry, keep orientation)
		local pivotPos = Vector3.new(orientation.Position.X, modelBottomY, orientation.Position.Z)
		model:PivotTo(CFrame.new(pivotPos) * orientation.Rotation)

		processed += 1
		print(string.format("[%s] HipHeight = %.3f  (model bottom Y = %.3f, HRP bottom Y = %.3f)", model.Name, humanoid.HipHeight, modelBottomY, hrpBottomY))
	end

	-- Summary
	print("--- Manual Compute HRP ---")
	if processed > 0 then
		print(string.format("Processed %d model(s): HipHeight + Pivot set to geometry bottom.", processed))
	end
	if #skipped > 0 then
		warn(string.format("Skipped %d (no HumanoidRootPart/Humanoid): %s", #skipped, table.concat(skipped, ", ")))
	end
end

button.Click:Connect(runCompute)
