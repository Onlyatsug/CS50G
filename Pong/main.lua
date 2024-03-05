Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

PADDLE_SPEED = 200

function love.load()

    pixelFontM = love.graphics.newFont("Pixel.ttf", 16)
    pixelFontL = love.graphics.newFont("Pixel.ttf", 80)

    love.window.setMode(
        WINDOW_WIDTH, WINDOW_HEIGHT,
        { fullscreen = false, resizable = false, vsync = true }
    )
    love.window.setTitle('Pong')

    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())

    sounds = {
        ['paddle'] = love.audio.newSource('sounds/paddle.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall'] = love.audio.newSource('sounds/wall.wav', 'static'),
    }

    playerOneScore = 0
    playerTwoScore = 0

    playerOne = Paddle(20, 30, 20, 80)
    playerTwo = Paddle(WINDOW_WIDTH - 40, WINDOW_HEIGHT - 110, 20, 80)

    ball = Ball(WINDOW_WIDTH / 2 - 5, WINDOW_HEIGHT / 2 - 5, 20, 20)

    gameState = 'start'
end

function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx= -math.random(140, 200)
        end
    elseif gameState == 'play' then
        if ball:collides(playerOne) then
            ball.dx = -ball.dx * 1.06
            ball.x = playerOne.x + playerOne.width

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds.paddle:play()
        end

        if ball:collides(playerTwo) then
            ball.dx = -ball.dx * 1.06
            ball.x = playerTwo.x - ball.width

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds.paddle:play()
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds.wall:play()
        end

        if ball.y >= WINDOW_HEIGHT - ball.height then
            ball.y = WINDOW_HEIGHT - ball.height
            ball.dy = -ball.dy
            sounds.wall:play()
        end
    end

    if gameState == 'play' then
        ball:update(dt)
    end
    if ball.x <= 0 then
        playerTwoScore = playerTwoScore + 1
        ball:reset()
        servingPlayer = 1
        gameState = 'serve'
        sounds.score:play()
        if playerTwoScore ==  10 then
            winPlayer = 2
        else
            gameState = 'serve'
            ball:reset()
        end
    end
    if ball.x >= WINDOW_WIDTH then
        playerOneScore = playerOneScore + 1
        ball:reset()
        servingPlayer = 2
        gameState ='serve'
        sounds.score:play()
        if playerOneScore ==  10 then
            winPlayer = 1
            gameState = 'done'
        else
            gameState = 'serve'
            ball:reset()
        end
    end
    if love.keyboard.isDown('w') then
        playerOne.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        playerOne.dy = PADDLE_SPEED
    else
        playerOne.dy = 0
    end

    if love.keyboard.isDown('up') then
        playerTwo.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        playerTwo.dy = PADDLE_SPEED
    else
        playerTwo.dy = 0
    end
    playerOne:update(dt)
    playerTwo:update(dt)
end

function love.keypressed(key)
    if key == 'escape'  then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset()

            playerOneScore = 0
            playerTwoScore = 0

            if winPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.draw()
    love.graphics.setFont(pixelFontM)
    playerOne:render()
    playerTwo:render()
    ball:render()

    if gameState == 'start' then
        love.graphics.print('Start State (Press key to play)', 180, 30)
    elseif gameState == 'play' then
        love.graphics.print('Play State (You are gaming)', 180, 30)
    elseif gameState == 'serve' then
        love.graphics.print('Serve State (Press key to serve)', 180, 30)
    elseif gameState == 'done' then
        love.graphics.print('Done State (Player ' .. tostring(winPlayer) .. ' wins!', 180, 30)
    end

    displayFPS()
    love.graphics.setFont(pixelFontL)
    love.graphics.print(tostring(playerOneScore), WINDOW_WIDTH / 2 - 120, WINDOW_HEIGHT / 3)
    love.graphics.print(tostring(playerTwoScore), WINDOW_WIDTH / 2 + 80, WINDOW_HEIGHT / 3)
end

function displayFPS()
    love.graphics.setColor(0, 1, 0)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1)
end
