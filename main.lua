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
    seed = 0
    while base>0 do
        seed = seed + base
        base = base - 1
    end
    return seed
end

function polar(x, y)
    if x>0 then
        a = math.atan(y/x)
        if y<0 then
            a = 2*PI+a
        end
    elseif x<0 then
        a = PI+math.atan(y/x)
    else
        if y > 0 then
            a = PI/2
        elseif y < 0 then
            a = PI*1.5
        else
            a = 0
        end
    end

    d = math.sqrt(x*x + y*y)
    return a, d
end

function diffDeg(a, b)
    x = math.abs(a-b)
    if x > 180 then
        x = 360 - x
    end
    return x
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
    sands.seed = 100 --pyramid(13)
    sands.total = sands.seed
    sands.red = 0
    sands.blu = 0
    sands.eq = 0.0                                                      --NOTE -1 means one side has won
    sands.db = 0
    function sands:update(dt)
        self:spawn(width/2+200*scale, height/2)
        self:spawn(width/2-200*scale, height/2)
        sands:seedEq()
    end
    function sands:spawn(x, y)
        if self.seed>0 then
            self.bodies[self.seed] = love.physics.newBody(world, x, y, 0.02, 0)
            self.shapes[self.seed] = love.physics.newCircleShape(self.bodies[self.seed], 0, 0, 10*scale)
            self.shapes[self.seed]:setFriction(0.1)
            self.seed = self.seed - 1
        end
    end
    function sands:draw()
        love.graphics.push()
        love.graphics.setColor(255, 255, 255)
        for k,v in pairs(self.bodies) do
            love.graphics.circle('fill', v:getX(), v:getY(), self.shapes[k]:getRadius())
        end
        love.graphics.pop()
    end
    function sands:setBullet(bool)                                      --DBUG does not work, that is to say, slows down too much when needed
        for k,v in pairs(self.bodies) do
            v:setBullet(bool)
        end
    end
    function sands:seedEq()                                            --can't get pcall() to work to check if body existis before calling
        eq = 0
        self.red = 0
        self.blu = 0
        for k,v in pairs(sands.bodies) do
            --~ if pcall(function() if v == null then return true end end) then
                x = v:getX() - origin:getX()
                y = v:getY() - origin:getY()
                d = math.deg(polar(x, y))%360
                a = math.deg((glass.body:getAngle()-PI/2)%(2*PI))

                if math.sqrt(x*x + y*y) < 300*scale then
                    if diffDeg(d, a) > 90 then
                        eq = eq - 1
                        self.red = self.red + 1
                    elseif diffDeg(d, a) < 90 then
                        eq = eq + 1
                        self.blu = self.blu + 1
                    end
                --~ else
                    --~ --lost grain
                    --~ self.count = self.count - 1
                    --~ v:destroy()
                end
            --~ end
        end
        self.eq = self.blu - self.red
        self.total = self.blu + self.red
        self.db = eq

    end


    --glass
    glass = {}

    glass.body = love.physics.newBody(world, width/2, height/2, 10, 10)
    glass.body:setBullet(true)
    glass.joint = love.physics.newRevoluteJoint(origin, glass.body, origin:getX(), origin:getY())
    glass.shape = {}
    glass.shape.top     = love.physics.newPolygonShape(glass.body, -164*scale, -230*scale,  164*scale, -230*scale,  164*scale, -250*scale, -164*scale, -250*scale)
    glass.shape.bottom  = love.physics.newPolygonShape(glass.body, -164*scale,  230*scale,  164*scale,  230*scale,  164*scale,  250*scale, -164*scale,  250*scale)
    glass.shape.right   = love.physics.newPolygonShape(glass.body,  20*scale, 0*scale,  164*scale, 230*scale,  200*scale,  230*scale, 200*scale, -230*scale, 164*scale, -230*scale)
    glass.shape.left    = love.physics.newPolygonShape(glass.body, -20*scale, 0*scale, -164*scale, 230*scale, -200*scale,  230*scale, -200*scale, -230*scale, -164*scale, -230*scale)
    for k,v in pairs(glass.shape) do
        v:setFriction(0.1*scale)
    end

    glass.body:setAngularDamping(10*scale)
    glass.body:setAngle(PI/2)

    function glass:update(dt)                                           --NOTE only for the hacky fix, sadly
        glass:fixDeviation()
    end

    function glass:draw()
        love.graphics.push()
        love.graphics.translate(self.body:getX(), self.body:getY())
        love.graphics.rotate(self.body:getAngle())
        --lobe
        if sands.red > sands.total/2 then
            love.graphics.setColor(hsl(  0, 200*(1 - (sands.red/(sands.total/2) - 1)), 140+115*(sands.red/(sands.total/2) - 1)))
        else love.graphics.setColor(hsl(  0, 200, 140)) end
        love.graphics.polygon('fill',  20*scale, 0*scale,  164*scale,  230*scale,  -164*scale,  230*scale, -20*scale, 0*scale)
        if sands.blu > sands.total/2 then
            love.graphics.setColor(hsl(150, 200*(1 - (sands.blu/(sands.total/2) - 1)), 140+115*(sands.blu/(sands.total/2) - 1)))
        else love.graphics.setColor(hsl(150, 200, 140)) end
        love.graphics.polygon('fill',  20*scale, 0*scale,  164*scale, -230*scale,  -164*scale, -230*scale, -20*scale, 0*scale)
        --frame
        love.graphics.setColor(255, 255, 255)
        love.graphics.polygon('fill',  20*scale, 0*scale,  164*scale, 230*scale,  210*scale, 230*scale,  64*scale, 0*scale,  210*scale, -230*scale,  164*scale, -230*scale)
        love.graphics.polygon('fill', -20*scale, 0*scale, -164*scale, 230*scale, -210*scale, 230*scale, -64*scale, 0*scale, -210*scale, -230*scale, -164*scale, -230*scale)
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
    glass:update(dt)
    sands:update(dt)

    --bulletmode                                                        --DBUG remove when not needed
    if love.keyboard.isDown("up") then
        sands:setBullet(true)
    end
end

function love.draw()
    --debug "console"
    love.graphics.print(sands.total, 10, 10)

    glass:draw()
    sands:draw()
end
