function newProjectile(owner,x,y,tx,ty,speed)
	bullet = {}
	bullet.owner = owner
	bullet.x = x
	bullet.y = y
	bullet.tx, bullet.ty = tx, ty
	local dx = bullet.tx - bullet.x
	local dy = bullet.ty - bullet.y
	local h = math.sqrt(dx^2 + dy^2)
	local dh = speed / h
	bullet.vx = dx * dh
	bullet.vy = dy * dh
	local theta = math.atan2(-bullet.vy,-bullet.vx)
	-- Missile trails by Helvecta (https://love2d.org/forums/viewtopic.php?f=3&t=77704&start=10)
	if owner == "us" then
		bullet.trail = love.graphics.newParticleSystem(ourTrailImg, 32)
		bullet.flame = love.graphics.newParticleSystem(ourFlameImg, 64)
	else
		bullet.trail = love.graphics.newParticleSystem(theirTrailImg, 32)
		bullet.flame = love.graphics.newParticleSystem(theirFlameImg, 64)
	end
	bullet.trail:setEmissionRate(25)
	bullet.trail:setSizes(2,3)
	bullet.trail:setSpeed(speed*4,speed*6)
	bullet.trail:setSpread(0.5)
	bullet.trail:setInsertMode("random")
	bullet.trail:setParticleLifetime(0.5, 1)
	bullet.trail:setColors(255, 255, 255, 25, 255, 255, 255, 0)
	bullet.trail:setDirection(theta)
	--bullet.flame:setSpeed(20, 80)
	bullet.flame:setSpeed(speed,speed*4)
	bullet.flame:setEmissionRate(100)
	bullet.flame:setSizes(0.5, 1, 0)
	bullet.flame:setAreaSpread("uniform", 2, 2)
	bullet.flame:setInsertMode("random")
	bullet.flame:setSizeVariation(1)
	local flameLength = 20
	bullet.flame:setParticleLifetime(0.25,0.5)
	--bullet.flame:setParticleLifetime(flameLength/(speed*2),flameLength/speed)
	bullet.flame:setRotation(theta,theta)
	bullet.flame:setDirection(theta)
	bullet.flame:setColors(255, 255, 255, 100, 255, 255, 255, 255, 255, 255, 255, 0)

	return bullet
end

function explode(x,y)
	e = {}
	e.x = x
	e.y = y
	e.rad = 0
	e.embiggening = true
	table.insert(explosions, e)
	love.audio.newSource("pop.ogg", "static"):play()
end

function detonate(projectiles,i)
	if projectiles[i].owner == "them" then
		kills = kills + 1
	end
	explode( projectiles[i].x, projectiles[i].y )
	projectiles[i].trail:stop()
	projectiles[i].flame:stop()
	table.insert(ghosts, projectiles[i])
	table.remove(projectiles, i)
end

function updateProjectiles(projectiles,dt)
	for i,b in pairs(projectiles) do
                -- Detonate if reached target
                if (b.vx > 0 and b.x >= b.tx) or (b.vx < 0 and b.x < b.tx) then
			detonate(projectiles, i)
			break
                elseif (b.vy > 0 and b.y >= b.ty) or (b.vy < 0 and b.y < b.ty) then
			detonate(projectiles, i)
			break
                end
                -- Explode on collision
                if checkCollision(asteroidCanvas,b.x,b.y) then
			detonate(projectiles, i)
			break
                end
                -- Explode if exploded
                if checkCollision(splosionCanvas1,b.x,b.y) then
			detonate(projectiles, i)
			break
                end
                -- Explode if out of bounds
                --[[
                if b.x < -20 or b.x > love.graphics.getWidth() + 20 then
                        table.remove(us.bullets, i)
                end
                if b.y < -20 or b.y > love.graphics.getHeight() + 20 then
                        table.remove(us.bullets, i)
                end
                ]]--
                b.x = b.x + b.vx*dt
                b.y = b.y + b.vy*dt
                b.trail:update(dt)
		b.flame:update(dt)
	end
end

function drawProjectiles(projectiles,r,g,b)
	for _,p in pairs(projectiles) do
		love.graphics.setColor(255,255,255)
		love.graphics.draw(p.trail, p.x, p.y)
		love.graphics.draw(p.flame, p.x, p.y)
		love.graphics.setColor(r,g,b)
		love.graphics.circle("fill", p.x, p.y, 5, 8)
	end
	love.graphics.setColor(255,255,255,255)
end

function updateGhosts(dt)
	for i,g in pairs(ghosts) do
                g.x = g.x + g.vx*dt
                g.y = g.y + g.vy*dt
                g.trail:update(dt)
		g.flame:update(dt)
		if g.trail:getCount() == 0 then
			table.remove(ghosts, i)
		end
	end
end

function drawGhosts()
	for _,g in pairs(ghosts) do
		love.graphics.draw(g.trail, g.x, g.y)
		love.graphics.draw(g.flame, g.x, g.y)
	end
end
