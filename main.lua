local widget = require("widget")

local dW = display.contentWidth
local dH = display.contentHeight

local heading = 0
local startX = 0
local startY = dH * 0.8
local lastX = 0
local lastY = 0

local allDisplayObjects = {}

function clear_all_points()
	startX = 0
	startY = dH * 0.8		-- dH is the screen height
	lastX = 0			-- value doesn’t matter; we’ll set it later
	lastY = 0			-- value doesn’t matter; we’ll set it later
	for k, v in pairs(allDisplayObjects) do
	  display.remove(v)
	end
end

stack = {}

cur_color = 0

colours = {
	{["name"] = "White", ["t"] = {1,1,1}},
	{["name"] = "Red", ["t"] = {1,0,0}},
	-- {["name"] = "Orange", ["t"] = {1,0.5,0}},
	{["name"] = "Yellow", ["t"] = {1,1,0}},
	{["name"] = "Green", ["t"] = {0,1,0}},
	{["name"] = "Cyan", ["t"] = {0,1,1}},
	{["name"] = "Blue", ["t"] = {0,0,1}},
	{["name"] = "Magenta", ["t"] = {1,0,1}}
}

shape_rules = {
	{
		name="Classic Koch",
		rules={
			["F"] = "F+F--F+F",
			["+"] = "+",
			["-"] = "-",
			["C"] = "C"
		},
		axiom="F+CF--CF+CF",
		angle=60,
		length=dW,
		startX=0,
		startY=dH*0.8,
		lm=1/3
	},
	{
		name="Square Koch",
		rules={
			["F"] = "F+F-F-F+F",
			["+"] = "+",
			["-"] = "-",
			["C"] = "C"
		},
		axiom="CF+CF-CF-CF+CF",
		angle=90,
		length=dW,
		startX=0,
		startY=dH*0.8,
		lm=1/3
	},
	{
		name="Keyhole Sierpinski",
		rules={
			["F"] = "+G-F-G+",
			["G"] = "-F+G+F-",
			["+"] = "+",
			["-"] = "-",
			["C"] = "C"
		},
		axiom="+CG-CF-CG+",
		angle=60,
		length=dW*0.8,
		startX=dW*0.2,
		startY=dH*0.8,
		lm=0.46
	},
	{
		name="Classic Sierpinski",
		rules={
			["F"] = "CF-G+F+G-F",
			["G"] = "GG",
			["+"] = "+",
			["-"] = "-",
			["C"] = "C"
		},
		axiom="CF-CG-CG",
		angle=-120,
		length=dW*0.8,
		startX=dW*0.3,
		startY=dH*0.8,
		lm=0.5
	},
	{
		name="The Dragon",
		rules={
			["F"] = "F",
			["X"] = "CX+YF+",
			["Y"] = "C-FX-Y",
			["+"] = "+",
			["-"] = "-",
			["C"] = "C"
		},
		axiom="FX",
		angle=90,
		length=dW*0.4,
		startX=dW*0.3,
		startY=dH*0.5,
		lm=0.7,
		gen_offset=1
	},
	{
		name="Penrose Snowflake",
		rules={
			["F"] = "CF--F--F-----F+F--F",
			["+"] = "+",
			["-"] = "-",
			["C"] = "C"
		},
		axiom="CF--CF--CF--CF--CF",
		angle=36,
		length=dW*0.5,
		startX=dW*0.4,
		startY=dH*0.35,
		lm=0.4
	},
	{
		name="Navajo Rug",
		rules={
			["F"] = "CF[F]-F+F[--F]+F-F",
			["+"] = "+",
			["-"] = "-",
			["C"] = "C",
			["["] = "[",
			["]"] = "]"
		},
		axiom="CF-CF-CF-CF",
		angle=90,
		length=dW,
		startX=dW*1/3,
		startY=dH*0.35,
		lm=1/3
	},
	{
		name="Bush",
		rules={
			["F"] = "CFF+[+F-F-F]-[-F+F+F]",
			["+"] = "+",
			["-"] = "-",
			["C"] = "C",
			["["] = "[",
			["]"] = "]"
		},
		axiom="F",
		angle=25,
		length=dW*0.8,
		startX=dW*0,
		startY=dH*0.6,
		lm=0.4444
	},
	{
		name="Plant",
		rules={
			["F"] = "FF",
			["X"] = "CF-[[X]+X]+F[+FX]-X",
			["+"] = "+",
			["-"] = "-",
			["C"] = "C",
			["["] = "[",
			["]"] = "]"
		},
		axiom="X",
		angle=25,
		length=dW,
		startX=dW*0.1,
		startY=dH*0.5,
		lm=0.4444,
		gen_offset=1
	},
	{
		name="Hilbert Curve",
		rules={
			["F"] = "F",
			["X"] = "C-YF+XFX+FY-",
			["Y"] = "C+XF-YFY-FX+",
			["+"] = "+",
			["-"] = "-",
			["C"] = "C"
		},
		axiom="X",
		angle=90,
		length=dW*2,
		startX=dW*0.3,
		startY=dH*0.3,
		lm=0.42,
		gen_offset=1
	},
	{
		name="Gosper Curve",
		rules={
			["F"] = "F-G--G+FC++FF+G-",
			["G"] = "+F-GG--G-F++F+G",
			["+"] = "+",
			["-"] = "-",
			["C"] = "C",
			["["] = "[",
			["]"] = "]"
		},
		axiom="F",
		angle=60,
		length=dW*0.6,
		startX=dW*0.4,
		startY=dH*0.4,
		lm=1/math.sqrt(7)
	},
	{
		name="Honeycomb",
		rules={
			["F"] = "F",
			["X"] = "CF[+X]-X",
			["+"] = "+",
			["-"] = "-",
			["C"] = "C",
			["["] = "[",
			["]"] = "]"
		},
		axiom="X",
		angle=60,
		length=dW*0.7,
		startX=dW*0.4,
		startY=dH*0.5,
		lm=0.7,
		gen_offset=1
	},
	{
	    name = "Algae",
	    rules = {
	        ["F"] = "FG",
	        ["G"] = "F",
	        ["+"] = "+",
	        ["-"] = "-",
	        ["C"] = "C",
	    },
	    axiom = "X",
	    angle = 25,
	    length = dW * 0.5,
	    startX = dW * 0.3,
	    startY = dH * 0.7,
	    lm = 0.5,
	    gen_offset=1
	}
}

-- basic functions

local function turn( degrees )
	heading = heading + degrees
end


local function draw(length)
	local rads = heading * math.pi / 180
	lastX = startX + length * math.cos(rads)
	lastY = startY + length * math.sin(rads)
	local line = display.newLine(startX, startY, lastX, lastY)
	-- print(cur_color)
	line:setStrokeColor(unpack(colours[cur_color+1].t))
	table.insert(allDisplayObjects, line)
	startX = lastX
	startY = lastY
end

local function expand_rules(axiom, rules, generations)
	-- print("Push: "..axiom..", "..generations)
	local newrule = ""
	for i=1,#axiom do
		local c = string.sub(axiom, i, i)
		if generations > 1 then
			local tmpnewrule = c
			for j=1,generations-1 do
				tmpnewrule = expand_rules(tmpnewrule, rules, 1)
			end
			newrule = newrule..tmpnewrule
		else
			newrule = newrule..rules[c]
		end
	end
	-- print("Pop: "..newrule..", "..generations)
	return newrule
end

local function create_rules(axiom, rules, generations)
	-- print(axiom..", "..generations)
	-- if generations == 1 then
	-- 	print(rules[axiom]..", "..generations)
	-- 	print("-----")
	-- 	return rules[axiom]
	-- elseif #axiom == 1 then
	-- 	print(rules[axiom]..", "..generations)
	-- 	print("-----")
	-- 	return rules[axiom]
	-- else
	-- 	local newrule = ""
	-- 	for i=1,#axiom do
	-- 		local c = string.sub(axiom, i, i)
	-- 		newrule = newrule..create_rules(c, rules, generations-1)
	-- 	end
	-- 	print(newrule..", "..generations)
	-- 	print("-----")
	-- 	return newrule
	-- end
	return(expand_rules(axiom, rules, generations))
end




local function draw_from_rules(rules, length, angle)
	-- cur_color = 1
	for i=1,#rules do
		local c = string.sub(rules, i, i)
		if c == "F" then
			draw(length)
		elseif c == "G" then
			draw(length)
		elseif c == "+" then
			turn(-angle)
		elseif c == "-" then
			turn(angle)
		elseif c == "C" then
			cur_color = (cur_color + 1)%#colours
		elseif c == "[" then
			table.insert(stack, {startX, startY, heading})
		elseif c == "]" then
			startX, startY, heading = unpack(stack[#stack])
			table.remove(stack, #stack)
		end
	end
end


local function lindenmayer(generation, axiom, rules, angle, len, lm)
	-- print("\n\n----------------------------------------")
	if generation == 1 then
		draw_from_rules(axiom, len*lm, angle)
	else
		draw_from_rules(create_rules(axiom, rules, generation), len*(lm^generation), angle)	
	end
end


---------
-- main
---------
local generation = 1
local shape = 1

local function draw_it(generation, shape)
	heading = 0
	shape_rule = shape_rules[shape]["rules"]
	shape_axiom = shape_rules[shape]["axiom"]
	shape_angle = shape_rules[shape]["angle"]
	shape_len = shape_rules[shape]["length"]
	startX = shape_rules[shape]["startX"]
	startY = shape_rules[shape]["startY"]
	shape_lm = shape_rules[shape]["lm"]
	if shape_rules[shape]["gen_offset"] ~= nil then
		generation = generation + shape_rules[shape]["gen_offset"]
	end
	lindenmayer(generation, shape_axiom, shape_rule, shape_angle, shape_len, shape_lm)
end

local function generationsStepperPress( event )
    if ( "increment" == event.phase ) then
        generation = generation + 1
        clear_all_points()
        draw_it(generation, shape)
    elseif ( "decrement" == event.phase ) then
        generation = generation - 1
        clear_all_points()
        draw_it(generation, shape)
    end
    generationsCounter.text = generation
end

-- Create the widget
local generationsStepper = widget.newStepper(
    {
        x = dW*0.8,
        y = dH*0.2,
        minimumValue = 0,
        maximumValue = 7,
        onPress = generationsStepperPress
    }
)

generationsCounter = display.newText("1", dW*0.8, dH*0.1, "Arial", 30)
generationsText = display.newText("Generations", dW*0.8, dH*0.02, "Arial", 16)


local function shapeStepperPress( event )
    if ( "increment" == event.phase ) then
        shape = shape + 1
        clear_all_points()
        draw_it(generation, shape)
    elseif ( "decrement" == event.phase ) then
        shape = shape - 1
        clear_all_points()
        draw_it(generation, shape)
    end
    shapeCounter.text = shape_rules[shape].name
end

draw_it(generation, shape)

-- Create the widget
local shapeStepper = widget.newStepper(
    {
        x = dW*0.2,
        y = dH*0.2,
        minimumValue = 0,
        maximumValue = #shape_rules - 1,
        onPress = shapeStepperPress
    }
)
shapeCounter = display.newText("Classic Koch", dW*0.2, dH*0.1, "Arial", 30)
shapeText = display.newText("Shape", dW*0.2, dH*0.02, "Arial", 16)

local function reload()
	draw_it(generation, shape)
end

local refresh_bth = widget.newButton({
	x = dW/2,
	y = dH*0.95,
	label="Reload Colors",
	labelColor = { default={ 0.2, 0.7, 1 }, over={ 0, 1, 0, 1 } },
	onPress=reload
})















