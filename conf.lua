dofile("globals.lua")
local settings = require("settings")
local utils = require("utils")

function love.conf(t)
    print("love conf")
    t.window.title = "Chess Puzzles"
    t.title = "Chess Puzzles"

    settings.update_relative_vars()
    utils.pretty_print(settings)

    t.window.width = ScreenWidth
    t.window.height = ScreenHeight
    print("window width" .. tostring(t.window.width))
    print("window height" .. tostring(t.window.height))
    t.window.borderless = false
    t.window.resizable = false
    t.window.fullscreen = true
    t.window.fullscreentype = "desktop"

    t.window.icon = "resources/icon.png"

    t.audio.mic = false

    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = true
    t.modules.sound = true
    t.modules.system = false
    t.modules.thread = true
    t.modules.timer = true
    t.modules.touch = true
    t.modules.video = true
    t.modules.window = true
    utils.pretty_print(t)
    print("load conf done")
end
