#Requires AutoHotkey v2.0

F8::
{
  MouseGetPos(&mouseX, &mouseY)
  color := PixelGetColor(mouseX, mouseY, "RGB")
  color := SubStr(color, -9)
  ToolTip(mouseX " " mouseY " " color)
  clipboard := "(" mouseX ", " mouseY ") == '" color "'"
  return
}

; 冰玉颜色
ice := PixelGetColor(1, 1, "RGB")
iceCD := PixelGetColor(1, 1, "RGB")

; 双龙颜色
doubleDragon := PixelGetColor(1, 1, "RGB")
doubleDragonCD := PixelGetColor(1, 1, "RGB")
; 炎掌颜色

; 炎掌CD颜色
fire := PixelGetColor(1, 1, "RGB")
fireCD := PixelGetColor(1, 1, "RGB")

; 冰掌颜色
iceHand := PixelGetColor(1, 1, "RGB")
iceHandCD := PixelGetColor(1, 1, "RGB")

; 炎炮颜色
fireCannon := PixelGetColor(1, 1, "RGB")
fireCannonCD := PixelGetColor(1, 1, "RGB")

; 真空破颜色
vacuumBreaker := PixelGetColor(1, 1, "RGB")
vacuumBreakerCD := PixelGetColor(1, 1, "RGB")

XButton2::
{
  while GetKeyState("XButton2", "P") {
    if (PixelGetColor(2809, 1019) == "0x1B1E2B") {
      Send "{R}"
      Sleep 100
    }
    else if (PixelGetColor(1, 1) == "0x000000") {
      Send "{T}"
      Sleep 100
    }

    if (!GetKeyState("XButton2", "P"))
      break
  }
}
