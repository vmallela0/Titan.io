--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

local aspectRatio = display.pixelHeight / display.pixelWidth

application = 
{
   content = 
   { 
      fps = 60,
      -- WRONG width = aspectRatio > 1.5 and 320 or math.ceil( 480 / aspectRatio ),
      -- WRONG height = aspectRatio < 1.5 and 480 or math.ceil( 320 * aspectRatio ),
      width = aspectRatio > 1.5 and 800 or math.floor( 480 / aspectRatio ), -- BETTER
      height = aspectRatio < 1.5 and 1040 or math.floor( 320 * aspectRatio ), -- BETTER
	  scale = "letterbox",
	  

	  --[[
		imageSuffix =
		{
			    ["@2x"] = 2,
			    ["@4x"] = 4,
		},
		--]]
   }
}