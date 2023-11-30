_G.viewer = client:getViewer()

IS_HOST = host:isHost()
TIME = 0
DATE = nil

function events.WORLD_TICK()
    TIME = TIME + 1
end