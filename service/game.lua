local card_suit = {
	101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113,
	201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213,
	301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313,
	401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413
}

math.randomseed(os.time())

local function ShuffleArray_Fisher_Yates( cards )
	local len = #cards
	if( len == 0 ) then return end
	local index
	local tmp
	while( len > 1 ) do
		index = math.random(1, len)
		local temp = cards[len]
		cards[len] = cards[index]
		cards[index] = temp
		len = len - 1
	end
end


local map = {
	[1] = "♠",
	[2] = '♥',
	[3] = '♣',
	[4] = '♦'
}


local function str_card( value )
	return map[math.floor(value/100)]..value%100
end

ShuffleArray_Fisher_Yates(card_suit)

local count = 1
local string = ""
for i,v in ipairs(card_suit) do
	string = string .. str_card(v) .. '\t'
	if count % 10 == 0 then
		print(string)
		string = ""
	end
	count = count + 1
end