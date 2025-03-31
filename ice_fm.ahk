#Persistent
#NoEnv
#InstallKeybdHook
DllCall("SetProcessDPIAware") ; Fix Windows DPI Scaling
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
SetTitleMatchMode, 2
SetTimer, CountdownTimers, 1200
SetTimer, UpdateUI, 50
SetTimer, CheckChiBarsTimer, 100 ; Check chi bars every 0.1 seconds

; Initialize countdown variables
ice_cold_snap_CD := 0
ice_massive_snowball_CD := 0
force_blast_CD := 0
bale_fire_CD := 0
inferno_CD := 0

ice_cold_snap_ready := true
ice_massive_snowball_ready := true
force_blast_ready := true
bale_fire_ready := true
inferno_ready := true

full_chi_bars := 0

current_stance := "ember" ; Initialize stance as ice, can be "ice" or "ember"

; Create UI
Gui, 3: New, -Caption +AlwaysOnTop +ToolWindow +LastFound
Gui, 3: Color, Black
WinSet, TransColor, Black
Gui, 3: Font, s12 cRed, Arial
Gui, 3: Add, Text, vTimerText x10 y10 w300 h160, Cooldowns:
Gui, 3: Show, x2232 y607 w300 h180, TimerOverlay

F1::
  MouseGetPos, MouseX, MouseY
  PixelGetColor, color, MouseX, MouseY, RGB
  MsgBox, Mouse: (%MouseX%, %MouseY%)`nColor: %color%`nVirtual Key Position
  clipboard = (%MouseX%, %MouseY%), %color%

  ; Create a small visual marker
  Gui, +AlwaysOnTop -Caption +ToolWindow
  Gui, Color, black
  Gui, Show, x%MouseX% y%MouseY% w5 h5 NA, KeyMarker
return

F2:: ; Remove all UI elements
  Gui, 1: Destroy
  Gui, 2: Destroy
return

F3::
  Gui, 3: Destroy
return

F4::
  Reload
  Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
  MsgBox, 4,, The script could not be reloaded. Would you like to open it for editing?
    IfMsgBox Yes
  Edit
return

#IfWinActive ahk_exe BNSR.exe
r::
LButton::
q::
  current_stance := "ember"
  if (A_ThisHotkey = "r")
    Send, r
  else if (A_ThisHotkey = "LButton")
    Click
  else if (A_ThisHotkey = "q")
    Send, q
return

t::
RButton::
e::
2::
3::
  current_stance := "ice"
  SetTimer, CheckIceStance, 10000 ; Set 10 second timer
  if (A_ThisHotkey = "t")
    Send, t
  else if (A_ThisHotkey = "RButton")
    Click right
  else if (A_ThisHotkey = "e")
    Send, e
  else if (A_ThisHotkey = "2")
    Send, 2
  else if (A_ThisHotkey = "3")
    Send, 3
return

CheckIceStance:
  if (current_stance = "ice") {
    current_stance := "ember"
    SetTimer, CheckIceStance, Off
  }
return

;; Main Macro

XButton2::
  while GetKeyState("XButton2", "P") {
    loop_active := "Macro Running"

    ; Combo = 2 R T and fill in skills in between

    ; Ice rain 
    PixelGetColor, ice_rain, 2528, 1235, RGB
    if (ice_rain = 0x182E34) {
      Send, 2
      current_stance := "ice"
      Sleep, 50
    }

    ; Check blazing palm 
    PixelGetColor, ember_blazing_palm, 2755, 1231, RGB
    ; Check if we cast blazing palm or cast it with additional skill
    if (ember_blazing_palm = 0xFFFAC6) {
      if(bale_fire_ready = true || inferno_ready = true) {
        if(bale_fire_ready = true) {
          send, r
          sleep, 750 ; wait for bottom skill to appear
          Send, c
          bale_fire_ready := false
          bale_fire_CD := 18
        } else if(inferno_ready = true) {
          send, r
          sleep, 1000 ; wait for bottom skill to appear
          send, x
          inferno_ready := false
          inferno_CD := 45
        }
      } else {
        ; No skill ready, just cast blazing palm and go to next skill
        send, r
        Sleep, 50
      }
      current_stance := "ember"
    }

    ; Rorate through Ice Skills 
    PixelGetColor, ice_palm, 2827, 1239, RGB
    if (ice_palm = 0x187DFF) {
      if(ice_cold_snap_ready = true || ice_massive_snowball_ready = true || force_blast_ready = true) {
        if(ice_cold_snap_ready = true) {
          send, t
          sleep, 700
          Send, z
          ice_cold_snap_ready := false
          ice_cold_snap_CD := 30
          ; Chain in massive snowball if it's ready
          if(ice_massive_snowball_ready = true) {
            sleep, 100
            Send, x
            ice_massive_snowball_ready := false
            ice_massive_snowball_CD := 18
          }
        } 
        ; Cast massive snowball if cold snap is in cooldown
        else if(ice_cold_snap_ready = false && ice_massive_snowball_ready = true) {
          send, t
          sleep, 50
          Send, x
          ice_massive_snowball_ready := false
          ice_massive_snowball_CD := 18
          ice_cold_snap_CD -= 20
        } else if(force_blast_ready = true) {
          sleep, 50
          Send, 1
          force_blast_ready := false
          force_blast_CD := 12
          ice_massive_snowball_CD -= 5
          sleep, 50

        }
        current_stance := "ice"
      }
    }

    ; Ice F or Dual Dragon on chi bar less than half
    if(full_chi_bars < 5) {
      send, f
      sleep, 50
    }
  }
  loop_active := "Macro Stopped"
return

IsGrayish(color) {
  ; Extract RGB components
  R := (color >> 16) & 0xFF
  G := (color >> 8) & 0xFF
  B := color & 0xFF

  ; For gray/black colors, R, G, and B values should be similar and relatively low
return (Abs(R - G) < 30 && Abs(G - B) < 30 && Abs(R - B) < 30 && R < 128)
}

; Function to check if color is in blue/white range
IsBlueWhitish(color) {
  ; Extract RGB components
  R := (color >> 16) & 0xFF
  G := (color >> 8) & 0xFF
  B := color & 0xFF

  ; For blue-white, B should be high, and R/G should be relatively high but less than B
return (B > 180 && R > 100 && G > 100 && B > R && B > G)
}

CheckChiBars() {
  ; Check all bars from 10 to 1
  PixelGetColor, bar5, 2539, 1134, RGB

  ; If the color is in gray/black range, return 4, else return 5
  if (IsGrayish(bar5)) {
    return 4
  } else {
    return 5
  }
}

CheckChiBarsTimer:
  global full_chi_bars
  chi_bar := CheckChiBars()
  full_chi_bars := chi_bar
return

CountdownTimers:
  if (ice_cold_snap_CD > 0) {
    ice_cold_snap_CD -= 1
  } else {
    ice_cold_snap_CD := 0
    ice_cold_snap_ready := true
  }

  if (ice_massive_snowball_CD > 0) {
    ice_massive_snowball_CD -= 1
  } else {
    ice_massive_snowball_CD := 0
    ice_massive_snowball_ready := true
  }

  if (force_blast_CD > 0) {
    force_blast_CD -= 1
  } else {
    force_blast_CD := 0
    force_blast_ready := true
  }

  if (bale_fire_CD > 0) {
    bale_fire_CD -= 1
  } else {
    bale_fire_CD := 0
    bale_fire_ready := true
  }

  if (inferno_CD > 0) {
    inferno_CD -= 1
  } else {
    inferno_CD := 0
    inferno_ready := true
  }
return

UpdateUI:
  GuiControl, 3:, TimerText, Loop Status: %loop_active%`nCurrent Stance: %current_stance%`nChi Bars: %full_chi_bars%`nIce Cold Snap: %ice_cold_snap_CD%s [%ice_cold_snap_ready%]`nIce Massive Snowball: %ice_massive_snowball_CD%s [%ice_massive_snowball_ready%]`nForce Blast: %force_blast_CD%s [%force_blast_ready%]`nBale Fire: %bale_fire_CD%s [%bale_fire_ready%]`nInferno: %inferno_CD%s [%inferno_ready%]
    return

return

