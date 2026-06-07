--------------------
---- MONITORES ----
--------------------

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@144",
    position = "auto",
    scale    = 1,
    vrr      = 0,
})

-- Monitor externo HDMI
-- hl.monitor({
--   output   = "HDMI-A-1",
--   mode     = "1920x1080@75",
--   position = "0x0",
--   scale    = 1,
--   vrr      = 1,
-- })


---------------------
---- MIS PROGRAMAS ----
---------------------

local terminal    = "kitty"
local fileManager = "nemo"
local menu        = "rofi -show drun"
local browser     = "firefox"
local code        = "code-oss"
local musicplayer = "rmpc"
local pick        = "hyprpicker"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("mpd")
end)


-------------------------------
---- VARIABLES DE ENTORNO ----
-------------------------------

hl.env("HYPRCURSOR_THEME", "handhelds")
hl.env("HYPRCURSOR_SIZE", "12")

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "0")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("MOZ_ENABLE_WAYLAND", "1")

hl.env("GTK_THEME", "my-theme")

hl.env("XCURSOR_THEME", "Default")
hl.env("XCURSOR_SIZE", "24")

hl.env("WLR_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card0")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in          = 3,
        gaps_out         = 3,
        border_size      = 1,
        col              = {
            active_border   = "rgba(50,50,50,1)",
            inactive_border = "rgba(0,0,0,1)",
        },
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 12,
        rounding_power   = 5,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow           = {
            enabled      = false,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur             = {
            enabled  = true,
            size     = 5,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        font_family             = "JetBrainsMono",
    },
})


--------------------
---- ANIMACIONES ----
--------------------

hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("md3_standard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })
hl.curve("md3_decel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("md3_accel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.1 } } })
hl.curve("crazyshot", { type = "bezier", points = { { 0.1, 1.5 }, { 0.76, 0.92 } } })
hl.curve("hyprnostretch", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })
hl.curve("fluent_decel", { type = "bezier", points = { { 0.1, 1 }, { 0, 1 } } })
hl.curve("easeInOutCirc", { type = "bezier", points = { { 0.85, 0 }, { 0.15, 1 } } })
hl.curve("easeOutCirc", { type = "bezier", points = { { 0, 0.55 }, { 0.45, 1 } } })
hl.curve("easeOutExpo", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "md3_decel", style = "popin 60%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.5, bezier = "md3_decel" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.5, bezier = "easeOutExpo", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "md3_decel", style = "slidevert" })


-----------------------
---- WORKSPACE ----
-----------------------

hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })

hl.window_rule({
    name        = "no-gaps-f1",
    match       = { float = false, workspace = "f[1]" },
    border_size = 0,
    rounding    = 0,
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout     = "latam,us",
        kb_variant    = "",
        kb_model      = "",
        kb_options    = "grp:win_space_toggle",
        kb_rules      = "",
        follow_mouse  = 1,
        scroll_factor = 1,
        touchpad      = {
            natural_scroll = false,
        },
    },
})

hl.device({
    name        = "kingston-hyperx-pulsefire-surge",
    sensitivity = 0,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Alias para no repetir tanto
local exec = hl.dsp.exec_cmd

-- Apps principales
hl.bind(mainMod .. " + RETURN", exec(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + E", exec(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", exec(menu))
hl.bind(mainMod .. " + U", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + B", exec(browser))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + C", exec(code))
hl.bind(mainMod .. " + M", exec(terminal .. " " .. musicplayer))
hl.bind(mainMod .. " + O", exec("obsidian"))
hl.bind(mainMod .. " + K", exec("krita"))
hl.bind(mainMod .. " + P", exec(pick .. " -a"))

-- Salir de Hyprland
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit())

-- Screenshots con hyprshot
hl.bind("Print", exec("hyprshot -m output -o ~/images/screenshots/"))
hl.bind("SHIFT + Print", exec("hyprshot -m region -o ~/images/screenshots/ -c"))
hl.bind("CTRL + Print", exec("hyprshot -m window -o ~/images/screenshots/"))

-- Mover foco
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Mover ventana en el tiling
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.move({ direction = "down" }))

-- Workspaces 1–10 (10 → tecla 0)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll entre workspaces con la rueda
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Mover/redimensionar ventanas arrastrando con ratón
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volumen
hl.bind("XF86AudioRaiseVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })

-- Brillo
hl.bind("XF86MonBrightnessUp", exec("brightnessctl -d amdgpu_bl1 s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", exec("brightnessctl -d amdgpu_bl1 s 10%-"), { locked = true, repeating = true }) -- Playerctl (media keys)

hl.bind("XF86AudioNext", exec("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", exec("playerctl previous"), { locked = true })


----------------------------------
---- WINDOW RULES ----
----------------------------------

hl.window_rule({
    match   = { class = "^(nemo)$" },
    opacity = "0.98 override 0.89 override",
})

hl.window_rule({
    match = { class = "^(feh)$" },
    float = true,
    size  = { 1200, 1200 },
})

hl.window_rule({ match = { class = "^(krita)$" }, workspace = 1 })
hl.window_rule({ match = { class = "^(firefox)$" }, workspace = 2 })
hl.window_rule({ match = { class = "^(code-oss)$" }, workspace = 3 })
hl.window_rule({ match = { class = "^(discord)$" }, workspace = 4 })

hl.window_rule({
    match = { title = "^(Control de volumen)$" },
    float = true,
    size  = { 600, 600 },
    move  = "68% 3%",
})
