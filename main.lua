--utility
function hsl(h, s, l) --http://love2d.org/wiki/HSL_color
    if s <= 0 then return l,l,l end
    h, s, l = h/256*6, s/255, l/255
    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1 then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else r,g,b = c,0,x
    end return math.ceil((r+m)*256),
               math.ceil((g+m)*256),
               math.ceil((b+m)*256)
end


function love.load()


    --setup
    width = 1600
    height = 900
    scale = 0.5
    width = width*scale
    height = height*scale
    fullscreen = false
    love.graphics.setMode(width, height, fullscreen)
    love.graphics.setBackgroundColor( hsl(138, 20, 50) )
    
    
    --physics
    gravity = 500
    meter = 50
    world = love.physics.newWorld(0, 0, width*3, height*3)
    world:setGravity(0, gravity)
    world:setMeter(meter)
    origin = love.physics.newBody(world, width/2, height/2, 0, 0)
    
    
    --sands--A SINGLE ONE, NOT FINAL
    sands = {}
    sands.body = love.physics.newBody(world, width/2, 200, 0.1, 0)
    sands.shape = love.physics.newCircleShape(sands.body, 0, 0, 7)
    function sands:draw()
        love.graphics.push()
        love.graphics.setColor(255, 255, 255)
        
        love.graphics.circle('fill', sands.body:getX(), sands.body:getY(), sands.shape:getRadius())
        
        love.graphics.pop()
    end
    
    
    --glass
    glass = {}
    
    glass.body = love.physics.newBody(world, width/2, height/2, 10, 10)
    glass.joint = love.physics.newRevoluteJoint(origin, glass.body, origin:getX(), origin:getY())
    glass.shape = {}
    glass.shape.top     = love.physics.newPolygonShape(glass.body, -164*scale, -230*scale,  164*scale, -230*scale,  164*scale, -250*scale, -164*scale, -250*scale)
    glass.shape.bottom  = love.physics.newPolygonShape(glass.body, -164*scale,  230*scale,  164*scale,  230*scale,  164*scale,  250*scale, -164*scale,  250*scale)
    glass.shape.right   = love.physics.newPolygonShape(glass.body,  18*scale, 0*scale,  164*scale, 230*scale,  164*scale, -230*scale, 200*scale, 0)
    glass.shape.left    = love.physics.newPolygonShape(glass.body, -18*scale, 0*scale, -164*scale, 230*scale, -164*scale, -230*scale, -200*scale, 0)
    
    glass.body:setAngularDamping(5)

    function glass:draw()
        love.graphics.push()
        love.graphics.setColor(255, 255, 255)
        love.graphics.translate(self.body:getX(), self.body:getY())
        love.graphics.rotate(self.body:getAngle())

        love.graphics.polygon('fill', 18*scale, 0*scale, 164*scale, 230*scale, 210*scale, 230*scale, 64*scale, 0*scale, 210*scale, -230*scale, 164*scale, -230*scale)
        love.graphics.polygon('fill', -18*scale, 0*scale, -164*scale, 230*scale, -210*scale, 230*scale, -64*scale, 0*scale, -210*scale, -230*scale, -164*scale, -230*scale)
        love.graphics.polygon('fill', -210*scale, 230*scale, 210*scale, 230*scale, 236*scale, 270*scale, -236*scale, 270*scale)
        love.graphics.polygon('fill', -210*scale, -230*scale, 210*scale, -230*scale, 236*scale, -270*scale, -236*scale, -270*scale)
        
        love.graphics.pop()
        
    end
    
    
    --gentleman "Class", not yet ready for instancing
    gentleman = {}
    gentleman.insist = 1
    gentleman.force = 50
    gentleman.impulse = 1*scale
    gentleman.state = 0
    gentleman.delay = 0
    gentleman.impatience = 0
    gentleman.control = {right="right", down="down", left="left"}
    function gentleman:update(dt)
        right = love.keyboard.isDown(self.control.right)
        left = love.keyboard.isDown(self.control.left)
        down = love.keyboard.isDown(self.control.down)
        if right and self.state <= 0 and self.impatience == 0 then
            glass.body:applyImpulse(-gentleman.impulse * self.insist, 0, 0, gentleman.impulse)
            self.state = self.insist/self.force*self.delay
            self.insist = 1
            self.impatience = 1
        elseif left and self.state <= 0 and self.impatience == 0 then
            glass.body:applyImpulse(gentleman.impulse * self.insist, 0, 0, gentleman.impulse)
            self.state = self.insist/self.force*self.delay
            self.insist = 1
            self.impatience = 1
        elseif down then
            self.insist = self.insist + self.force*dt
        end
        
        if not right and not left and not down then
            self.state = self.state - dt
            self.impatience = 0
        end
    end
    
    
end

function love.update(dt)
    world:update(dt)
    --here we are going to create some keyboard events
    gentleman:update(dt)

    
end

function love.draw()
    --Good evening gentlemen of the world.
    love.graphics.print(glass.body:getAngle(), 10, 10)
    
    --glass
    glass:draw()
    sands:draw()
end
