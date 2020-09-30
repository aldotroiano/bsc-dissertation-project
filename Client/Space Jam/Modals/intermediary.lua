local composer = require( "composer" )

function show_gm()      --show game screen
composer.showOverlay( "game_engine", {effect = "fade", time = 200})
end

function restart_gm()   --restart game screen and drop entities
composer.removeScene( "game_engine")

timer.performWithDelay(300, function()    --show game engine
  composer.showOverlay("game_engine", {effect = "fade", time = 200})end)
end
