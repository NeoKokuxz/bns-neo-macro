F8::
{
  MouseGetPos(&mouseX, &mouseY)
  color := PixelGetColor(mouseX, mouseY, "RGB")
  color := SubStr(color, -9)
  ToolTip(mouseX " " mouseY " " color)
  clipboard := "(" mouseX ", " mouseY ") == '" color "'"
  return
}

; Bee Color
bee := PixelGetColor(2809, 1019, "RGB")

; Bee CD Color
beeCD := PixelGetColor(2809, 1019, "RGB")

; Rose Color
rose := PixelGetColor(1, 1, "RGB")

; Rose CD Color
roseCD := PixelGetColor(1, 1, "RGB")

; Sunflower Color
sunflower := PixelGetColor(1, 1, "RGB")

; Sunflower CD Color
sunflowerCD := PixelGetColor(1, 1, "RGB")

; Thorn Color
thorn := PixelGetColor(1, 1, "RGB")

; Thorn CD Color
thornCD := PixelGetColor(1, 1, "RGB")

; Taunt Color
taunt := PixelGetColor(1, 1, "RGB")

; Taunt CD Color
tauntCD := PixelGetColor(1, 1, "RGB")

XButton2::
{
  while GetKeyState("XButton2", "P") {
    ; If bee is ready, use it
    if (bee == "0x1B1E2B") {
      Send "{R}"
      Sleep 100
    }
    ; If bee is in CD then use rose
    if (rose == "0x000000") {
      Send "{T}"
      Sleep 100
    }

    if (!GetKeyState("XButton2", "P"))
      break
  }
}

; Sunflower Macro
