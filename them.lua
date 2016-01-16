them = {}

them.missileSpeed = 30

them.missiles = {}

function them:fire()
	-- Generate random launching point outside the screen
	local theta = math.rad( love.math.random( -180, 180 ) )
	local r = math.sqrt( love.graphics.getWidth()^2 + love.graphics.getHeight()^2 ) / 2
	local x = math.cos(theta) * r + love.graphics.getWidth()/2
	local y = math.sin(theta) * r + love.graphics.getHeight()/2
	-- Select a city
	local city = love.math.random( table.getn(us.cities) )
	local tx = us.cities[city].x
	local ty = us.cities[city].y
	-- Launch projectile
	local missile = newProjectile( "them", x, y, tx, ty, self.missileSpeed )
	table.insert(self.missiles, missile)
end
