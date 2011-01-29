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


    --assets
    require("banter.lua")
    function setRed()
        if sands.red > sands.total/2 then
            love.graphics.setColor(hsl(  0, 200*(1 - (sands.red/(sands.total/2) - 1)), 140+115*(sands.red/(sands.total/2) - 1)))
        else love.graphics.setColor(hsl(  0, 200, 140)) end
    end
    function setBlu()
        if sands.blu > sands.total/2 then
            love.graphics.setColor(hsl(150, 200*(1 - (sands.blu/(sands.total/2) - 1)), 140+115*(sands.blu/(sands.total/2) - 1)))
        else love.graphics.setColor(hsl(150, 200, 140)) end
    end
    font = love.graphics.newFont( "Chunkfive.otf", 64*scale )


    --Sands
    sands = {}
    sands.bodies = {}
    sands.shapes = {}
    sands.seed = 100 --pyramid(13)
    sands.total = sands.seed
    sands.red = 0
    sands.blu = 0
    sands.eq = 0.0
    sands.db = 0
    function sands:update(dt)
        self:spawn(width/2+150*scale, height/2)
        self:spawn(width/2-150*scale, height/2)
        sands:seedEq()
    end
    function sands:spawn(x, y)
        if self.seed>0 then
            self.bodies[self.seed] = love.physics.newBody(world, x, y, 0.02, 0)
            --if math.random(0, 100) == 0 then size = 2*10*scale else size = 10*scale end
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
    function sands:setBullet(bool)                                      --DBUG does not work, that is to say, slows down too much to work
        for k,v in pairs(self.bodies) do
            v:setBullet(bool)
        end
    end
    function sands:seedEq()
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
        setRed()
        love.graphics.polygon('fill',  20*scale, 0*scale,  164*scale,  230*scale,  -164*scale,  230*scale, -20*scale, 0*scale)
        setBlu()
        love.graphics.polygon('fill',  20*scale, 0*scale,  164*scale, -230*scale,  -164*scale, -230*scale, -20*scale, 0*scale)
        --frame
        love.graphics.setColor(255, 255, 255)
        love.graphics.polygon('fill',  20*scale, 0*scale,  164*scale, 230*scale,  210*scale, 230*scale,  64*scale, 0*scale,  210*scale, -230*scale,  164*scale, -230*scale)
        love.graphics.polygon('fill', -20*scale, 0*scale, -164*scale, 230*scale, -210*scale, 230*scale, -64*scale, 0*scale, -210*scale, -230*scale, -164*scale, -230*scale)
        love.graphics.polygon('fill', -210*scale,  230*scale, 210*scale,  230*scale, 236*scale,  270*scale, -236*scale,  270*scale)
        love.graphics.polygon('fill', -210*scale, -230*scale, 210*scale, -230*scale, 236*scale, -270*scale, -236*scale, -270*scale)
        love.graphics.pop()
    end
    function glass:fixDeviation()                                       --NOTE needed to fix ocassional deviation due to weight
        glass.body:setX(width/2)
        glass.body:setY(height/2)
    end


    --Gentleman
    Gentleman = {}
    Gentleman.__index = Gentleman
    function Gentleman.create(control, position, setColor)
    local self = {}
    setmetatable(self, Gentleman)
    self.insist = 1
    self.force = 75
    self.impulse = 0.5*scale
    self.state = 0
    self.delay = 0
    self.impatience = 0
    self.pop = false
    self.control = control
    self.position = position
    self.setColor = setColor
    self.size = 20*scale
    self.tension = 0
    return self
    end

    function Gentleman:update(dt)
        right = love.keyboard.isDown(self.control.right)
        left = love.keyboard.isDown(self.control.left)
        down = love.keyboard.isDown(self.control.down)
        if right and self.state <= 0 and self.impatience == 0 then
            glass.body:applyImpulse(-self.impulse * self.insist, 0, 0, self.impulse)
            self.state = self.insist/self.force*self.delay
            self.insist = 1
            self.impatience = 1
        elseif left and self.state <= 0 and self.impatience == 0 then
            glass.body:applyImpulse(self.impulse * self.insist, 0, 0, self.impulse)
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

        if math.abs(sands.eq)/sands.total < 1 then self.tension = (self.insist/10+math.abs(sands.eq)/sands.total*5)*scale
        else self.tension = self.tension*0.95 end
    end
    function Gentleman:forceImpulse(dt)
        if self.insist < 100 then
            self.insist = self.insist + self.force*dt
        else
            self.insist = 0
            self.pop = true                                             --TODO to be intercepted and reset by draw
        end
    end
    function Gentleman:draw()
        love.graphics.push()
        self.setColor()
        local size = self.size*(1+self.insist/20)
        love.graphics.circle('fill', self.position[1]+math.random(-self.tension, self.tension), self.position[2]+math.random(-self.tension, self.tension), size, 32)
        love.graphics.pop()
    end

    red = Gentleman.create({right="d", down="s", left="a"}, {width*0.2, height*0.8}, setRed)
    blu = Gentleman.create({right="right", down="down", left="left"}, {width*0.8, height*0.8}, setBlu)


    --banter
    banter = {}
    banter.memory = sands.eq                                            --NOTE to compare the current sands.eq to
    banter.side = 0.2                                                   --NOTE 0 means white, and giving colors text briefly
    banter.giver = ""
    banter.taker = ""
    function banter:update(dt)
        if sands.eq > self.memory then
            self.side = 1
        elseif sands.eq < self.memory then
            self.side = -1
        else
            self.side = self.side*0.95                                  --TODO should make this dt aware
            if self.side == 0 then self:rephrase()                      --NOTE unexpected effect, I like it better than the usual
            elseif math.abs(self.side) < 0.1 then self.side = 0 end
        end
        self.memory = sands.eq
    end
    function banter:draw()
        --love.graphics.push()                                          --NOTE pushing or pulling messes up text, bug in LOVE2D itself
        local tension = 5*scale*math.abs(sands.eq/sands.total)
        love.graphics.setFont( font )
        if math.abs(sands.eq/sands.total) == 1 and self.side == 0 then
            if sands.eq > 0 then       love.graphics.setColor(hsl(0,200,140))
            elseif sands.eq < 0 then   love.graphics.setColor(hsl(150,200,140)) end
            love.graphics.printf("Why, you're welcome!", 0, height*0.1-48*scale, width, "center")
            love.graphics.setColor(255, 255, 255)
            love.graphics.printf("...", 0, height*0.9-48*scale, width, "center")
        else
            if self.side > 0 then       love.graphics.setColor(hsl(0,200,140))
            elseif self.side < 0 then   love.graphics.setColor(hsl(150,200,140))
            else                        love.graphics.setColor(255, 255, 255, 255) end
            love.graphics.printf(self.giver, math.random(-tension, tension), height*0.1-48*scale+math.random(-tension, tension), width, "center")
            if self.side < 0 then       love.graphics.setColor(hsl(0,200,140))
            elseif self.side > 0 then   love.graphics.setColor(hsl(150,200,140))
            else                        love.graphics.setColor(255, 255, 255) end
            love.graphics.printf(self.taker, math.random(-tension, tension), height*0.9-48*scale+math.random(-tension, tension), width, "center")
        end
        --love.graphics.push()
    end
    function banter:rephrase()
        self.giver = giver[math.random(#giver)]
        self.taker = taker[math.random(#taker)]
    end

end

function love.update(dt)
    world:update(dt)
    red:update(dt)
    blu:update(dt)
    glass:update(dt)
    sands:update(dt)
    banter:update(dt)

    --bulletmode                                                        --DBUG remove when not needed
    if love.keyboard.isDown("up") then
        sands:setBullet(true)
    end
end

function love.draw()
    --debug "console"
    --love.graphics.print(banter.side, 10, 10)

    glass:draw()
    sands:draw()
    red:draw()
    blu:draw()
    banter:draw()
end
