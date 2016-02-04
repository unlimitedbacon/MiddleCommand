them = {}

them.missileSpeed = 30

them.ammo = 0
them.missiles = {}

function them:fire()
	-- Generate random launching point outside the screen
	local theta = math.rad( love.math.random( -180, 180 ) )
	local r = math.sqrt( love.graphics.getWidth()^2 + love.graphics.getHeight()^2 ) / 2
	local x = math.cos(theta) * r + love.graphics.getWidth()/2
	local y = math.sin(theta) * r + love.graphics.getHeight()/2
	-- Select a target
	local targets = {}
	if curLevel.targetBases then
		targets = catTables({us.cities,us.bases})
	else
		targets = us.cities
	end
	local target = love.math.random( table.getn(targets) )
	local tx = targets[target].x
	local ty = targets[target].y
	-- Launch projectile
	local missile = newProjectile( "them", x, y, tx, ty, self.missileSpeed )
	self.ammo = self.ammo - 1
	table.insert(self.missiles, missile)
end
