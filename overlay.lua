title = {}
title.screen = love.graphics.newImage("title.screen.png")
title.overlay = love.graphics.newImage("title.overlay.png")
title.size = 1024
title.fadein	= 0.001
title.fadeout	= 1
title.start = false
function title:update(dt)
	if self.fadein < 1 then self.fadein = self.fadein*(1+dt*5)
	else self.fadein = 1 end
	if self.start then self.fadeout = self.fadeout - dt else self.fadeout = 1 end
	if self.fadeout < 0 then gamestate = 1 control.fadeout = 1 end
	if love.keyboard.isDown(" ") then
        self.start = true
    end
end
function title:draw()
	local factor = height/self.size
	love.graphics.push()
	love.graphics.setColor(hsl(138, 20, 50, 255*self.fadeout))
	love.graphics.rectangle('fill', 0, 0, width, height)
	love.graphics.setColor(255, 255, 255, 255*self.fadeout)
	love.graphics.draw(self.screen, (width-height)/2, 0, 0, factor, factor)
	love.graphics.setColor(255, 255, 255, 255*self.fadein*self.fadeout)
	love.graphics.draw(self.overlay, (width-height)/2, 0, 0, factor, factor)
	love.graphics.pop()
end

function eventControl()
	if love.keyboard.isDown("escape") then
        gamestate = 0                                                   --NOTE to restart
        title.start = false
	title.fadein = 0.001
    end
    if (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")) and love.keyboard.isDown("f4") then
		love.event.push('q')
    end
end

control = {}
control.red =  love.graphics.newImage("red.overlay2.png")
control.blu =  love.graphics.newImage("blu.overlay2.png")
control.size = 1024
control.fadeout = 1
function control:update(dt)
    self.fadeout = self.fadeout - dt/5
    if self.fadeout <= 0 then self.fadeout = 0 end
end
function control:draw()
	local factor = height/self.size
	love.graphics.push()
	love.graphics.setColor(255, 255, 255, 255*self.fadeout)
	love.graphics.draw(self.red, red.position[1], red.position[2], 0, factor, factor, 128, 128)
	love.graphics.draw(self.blu, blu.position[1], blu.position[1], 0, factor, factor, 0, 0)
	love.graphics.pop()
end

restart = {}
restart.overlay = love.graphics.newImage("restart.overlay.png")
restart.size = 1024
restart.fadein = 0.01
function restart:update(dt)
    if self.fadein < 1 then self.fadein = self.fadein*(1+dt*10)
    else self.fadein = 1 end
end
function restart:draw()
	local factor = height/self.size
	love.graphics.push()
	love.graphics.setColor(255, 255, 255, 255*self.fadein)
	love.graphics.draw(self.overlay, (width-height)/2, 0, 0, factor, factor)
	love.graphics.pop()
end
