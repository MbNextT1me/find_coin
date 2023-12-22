require "world"
require "player"
require "pqueue"
require "maze"
coinIsFind = false
function loadTextures()
    env = {
        tileset = love.graphics.newImage("assets/RogueEnvironment16x16.png"),
        textures = {},
    }

    local quads = {
        {0,  5*16,  0*16}, -- floor v1
        {1,  6*16,  0*16}, -- floor v2
        {2,  7*16,  0*16}, -- floor v3
        {3,  0*16,  0*16}, -- upper left corner
        {4,  3*16,  0*16}, -- upper right corner
        {5,  0*16,  3*16}, -- lower left corner
        {6,  3*16,  3*16}, -- lower right corner
        {7,  2*16,  0*16}, -- horizontal
        {8,  0*16,  2*16}, -- vertical
        {9,  1*16,  2*16}, -- up
        {10, 2*16,  3*16}, -- down
        {11, 2*16,  1*16}, -- left
        {12, 1*16,  1*16}, -- right
        {13, 2*16,  2*16}, -- down cross
        {14, 1*16,  3*16}, -- up cross
        {15, 3*16,  1*16}, -- left cross
        {16, 0*16,  1*16}, -- right cross
        {17, 3*16, 14*16}, -- spikes
        {18, 5*16, 13*16} -- coin
    }
    for i, q in ipairs(quads) do
        env.textures[q[1]] = love.graphics.newQuad(q[2], q[3], 16, 16, env.tileset:getDimensions())
    end

    pl = {
        tileset = love.graphics.newImage("assets/RoguePlayer_48x48.png"),
        textures = {}
    }

    for i = 1, 6 do
        pl.textures[i] = love.graphics.newQuad((i - 1) * 48, 48 * 2, 48, 48, pl.tileset:getDimensions())
    end

end

function love.load()
    width, height = love.graphics.getWidth(), love.graphics.getHeight()
    loadTextures()

    world = World:create()
    scaleX, scaleY = width / (world.width * 16), height / (world.height * 16)

    world:placeObjects()
    player = world.player

    mapPath = {}
end

function love.draw()
    love.graphics.scale(scaleX, scaleY)
    world:draw()
    player:draw(world)
    love.graphics.setFont(love.graphics.newFont(50))
    if coinIsFind then love.graphics.print("Opa-na dengi", 10, 10) end
end

function love.keypressed(key)
    local directions = {left = "left", right = "right", up = "up", down = "down"}
    world:move(directions[key])
end

function love.update(dt)
    player:update(dt, world)
    world:update(player)
    if not coinIsFind then
        findCoin(world:getEnv())
    end
end

function getNeighbours(env)
    local neighbours = {}

    local function insertNeighbour(dx, dy, direction)
        local temp = env.position[1] + dx  .. " " .. env.position[2] + dy
        mapPath[temp] = mapPath[temp] or 0
        table.insert(neighbours, {d = direction, v = mapPath[temp]})
    end

    if not env.left then insertNeighbour(-1, 0, "left") end
    if not env.right then insertNeighbour(1, 0, "right") end
    if not env.up then insertNeighbour(0, -1, "up") end
    if not env.down then insertNeighbour(0, 1, "down") end

    return neighbours
end

function findCoin(env)
    mapPath[env.position[1] .. " " .. env.position[2]] = (mapPath[env.position[1] .. " " .. env.position[2]] or 0) + 1

    local neighbours = getNeighbours(env)

    local minNeighbour = minBy(neighbours, function(n) return n.v end)
    if env.coin ~= "underfoot" or env.coin ~= "left" or env.coin~="right" or env.coin ~= "up" or env.coin ~= "down" then
        world:move(minNeighbour.d)
    end
    if env.coin == 'underfoot' then
        coinIsFind = true
    end
end

function minBy(array, keyFunc)
    local minValue, minItem = math.huge, nil
    for _, item in ipairs(array) do
        local value = keyFunc(item)
        if value < minValue then
            minValue, minItem = value, item
        end
    end
    return minItem
end
