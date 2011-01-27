--utility
function hsl(h, s, l)                                                   --LINK http://love2d.org/wiki/HSL_color
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

function pyramid(base)
    total = 0
    while base>0 do
        total = total + base
        base = base - 1
    end
    return total
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
    PI = 3.14139
    
    
    --physics
    gravity = 500*scale
    meter = 50*scale
    world = love.physics.newWorld(0, 0, width*3, height*3)
    world:setGravity(0, gravity)
    world:setMeter(meter)
    origin = love.physics.newBody(world, width/2, height/2, 0, 0)
    
    
    --Sands                                                             --TODO "Class" not yet ready for instancing
    sands = {}
    sands.bodies = {}
    sands.shapes = {}
    sands.count = pyramid(15)
    sands.eq = 0.0                                                      --NOTE -1 means one side has won
    function sands:fill(x, y)
        if self.count>0 then
            self.bodies[self.count] = love.physics.newBody(world, x, y, 0.02, 0)
            self.shapes[self.count] = love.physics.newCircleShape(self.bodies[self.count], 0, 0, 10*scale)
            self.shapes[self.count]:setFriction(0.1)
            self.count = self.count - 1
        end
    end
    function sands:draw()
        love.graphics.push()
        love.graphics.setColor(255, 255, 255)
        for k,v in pairs(sands.bodies) do 
            love.graphics.circle('fill', v:getX(), v:getY(), sands.shapes[k]:getRadius())
        end
        love.graphics.pop()
    end
    function sands:setBullet(bool)                                      --DBUG does not work, that is to say, slows down too much when needed
        for k,v in pairs(sands.bodies) do 
            v:setBullet(bool)
        end
    end
    function sands:countEq()                                            --TODO write function to see who's winning
        --count sand equilibrium here, make it fast
    end
    
    
    --glass
    glass = {}
    
    glass.body = love.physics.newBody(world, width/2, height/2, 10, 10)
    glass.body:setBullet(true)
    glass.joint = love.physics.newRevoluteJoint(origin, glass.body, origin:getX(), origin:getY())
    glass.shape = {}
    glass.shape.top     = love.physics.newPolygonShape(glass.body, -164*scale, -230*scale,  164*scale, -230*scale,  164*scale, -250*scale, -164*scale, -250*scale)
    glass.shape.bottom  = love.physics.newPolygonShape(glass.body, -164*scale,  230*scale,  164*scale,  230*scale,  164*scale,  250*scale, -164*scale,  250*scale)
    glass.shape.right   = love.physics.newPolygonShape(glass.body,  18*scale, 0*scale,  164*scale, 230*scale,  164*scale, -230*scale, 200*scale, 0)
    glass.shape.left    = love.physics.newPolygonShape(glass.body, -18*scale, 0*scale, -164*scale, 230*scale, -164*scale, -230*scale, -200*scale, 0)
    for k,v in pairs(glass.shape) do 
        v:setFriction(0.1*scale)
    end
    
    glass.body:setAngularDamping(10*scale)
    glass.body:setAngle(PI/2)

    function glass:draw()
        love.graphics.push()
        love.graphics.setColor(255, 255, 255)
        love.graphics.translate(self.body:getX(), self.body:getY())
        love.graphics.rotate(self.body:getAngle())
        --actual draw
        love.graphics.polygon('fill',  18*scale, 0*scale,  164*scale, 230*scale,  210*scale, 230*scale,  64*scale, 0*scale,  210*scale, -230*scale,  164*scale, -230*scale)
        love.graphics.polygon('fill', -18*scale, 0*scale, -164*scale, 230*scale, -210*scale, 230*scale, -64*scale, 0*scale, -210*scale, -230*scale, -164*scale, -230*scale)
        love.graphics.polygon('fill', -210*scale,  230*scale, 210*scale,  230*scale, 236*scale,  270*scale, -236*scale,  270*scale)
        love.graphics.polygon('fill', -210*scale, -230*scale, 210*scale, -230*scale, 236*scale, -270*scale, -236*scale, -270*scale)
        love.graphics.pop()
    end
    function glass:fixDeviation()                                       --NOTE needed to fix deviation due to weight
        glass.body:setX(width/2)
        glass.body:setY(height/2)
    end
    
    
    --gentleman                                                         --TODO "Class", not yet ready for instancing
    gentleman = {}
    gentleman.insist = 1
    gentleman.force = 75
    gentleman.impulse = 0.5*scale
    gentleman.state = 0
    gentleman.delay = 0
    gentleman.impatience = 0
    gentleman.pop = false
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
            self:forceImpulse(dt)
        end
        
        if not right and not left and not down then
            self.state = self.state - dt
            self.impatience = 0
        end
    end
    function gentleman:forceImpulse(dt)
        if self.insist < 100 then
            self.insist = self.insist + self.force*dt
        else
            self.insist = 0
            self.pop = true                                             --TODO to be intercepted and reset by draw
        end
    end
    
    
end

function love.update(dt)
    world:update(dt)
    gentleman:update(dt)
    glass:fixDeviation()                                                --NOTE needed to fix deviation due to weight
    
    --filling sands
    --sands:fill(width/2, 400*scale)    
    sands:fill(width/2+200*scale, height/2)  
    
    --bulletmode                                                        --DBUG remove when not needed
    if love.keyboard.isDown("up") then
        sands:setBullet(true)
    end  
end

function love.draw()
    --debug "console"
    love.graphics.print(gentleman.insist, 10, 10)
    
    glass:draw()
    sands:draw()
end
