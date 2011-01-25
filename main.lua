function love.load()

    width = 800
    height = 500
    fullscreen = false
    love.graphics.setMode(width, height, fullscreen)
    
end

function love.update(dt)
end

function love.draw()    
    love.graphics.print('Gentlemen, start your givings!', 10, 10)
end
