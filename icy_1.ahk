#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

; Initialize the state
global currentKey := "R"
global lastSkillTime := 0
global globalCD := 1.5 ; Global cooldown in seconds
global scriptRunning := false
global currentSkill := "None"

; Create GUI
Gui, New, +AlwaysOnTop -Caption +ToolWindow
Gui, Color, 000000
Gui, Font, s8, Consolas
Gui, Add, Text, vScriptStatus c00FF00 BackgroundTrans, Script: Stopped
Gui, Add, Text, vCurrentSkill c00FF00 BackgroundTrans, Current: None
Gui, Add, Text, vFireSkills c00FF00 BackgroundTrans, Fire Skills:
Gui, Add, Text, vIceSkills c00FF00 BackgroundTrans, Ice Skills:
Gui, Show, NoActivate, Skill Status

; Function to check color at position
CheckColor(x, y, expectedColor) {
  PixelGetColor, color, %x%, %y%, RGB
  return (color = expectedColor)
}

; Function to update GUI
UpdateGUI() {
  global scriptRunning, currentSkill
  GuiControl,, ScriptStatus, Script: % (scriptRunning ? "Running" : "Stopped")
  GuiControl,, CurrentSkill, Current: %currentSkill%

  ; Update Fire Skills
  fireStatus := "Fire Skills:`n"
  fireStatus .= "Bale Fire: " (bale_fire.ready ? "Ready" : "CD: " bale_fire.GetRemainingCD() "s") "`n"
  fireStatus .= "Meteor Shower: " (meteor_shower.ready ? "Ready" : "CD: " meteor_shower.GetRemainingCD() "s") "`n"
  fireStatus .= "Inferno: " (inferno.ready ? "Ready" : "CD: " inferno.GetRemainingCD() "s")
  GuiControl,, FireSkills, %fireStatus%

  ; Update Ice Skills
  iceStatus := "Ice Skills:`n"
  iceStatus .= "Cold Snap: " (cold_snap.ready ? "Ready" : "CD: " cold_snap.GetRemainingCD() "s") "`n"
  iceStatus .= "Massive Snowball: " (massive_snowball.ready ? "Ready" : "CD: " massive_snowball.GetRemainingCD() "s")
  GuiControl,, IceSkills, %iceStatus%
}

; Define the Skill class
class Skill {
  change_stance := false
  stance := ""
  ready := true
  cd := 0
  gcd := 0
  name := ""
  readyX := 0
  readyY := 0
  cdX := 0
  cdY := 0
  readyColor := "0x111111" ; Default ready color
  cdColor := "0xFFFFFF" ; Default cooldown color
  lastUsedTime := 0 ; When the skill was last used
  cooldownTime := 0 ; Cooldown duration in seconds
  cdReductionTarget := "" ; Name of the skill whose CD this skill can reduce
  cdReductionAmount := 0 ; Amount of CD reduction in seconds

  __New(change_stance := false, stance := "", ready := true, cd := 0, gcd := 0, name := "", 
  readyX := 0, readyY := 0, cdX := 0, cdY := 0, readyColor := "0x111111", cdColor := "0xFFFFFF",
  cdReductionTarget := "", cdReductionAmount := 0) {
    this.change_stance := change_stance
    this.stance := stance
    this.ready := ready
    this.cd := cd
    this.gcd := gcd
    this.name := name
    this.readyX := readyX
    this.readyY := readyY
    this.cdX := cdX
    this.cdY := cdY
    this.readyColor := readyColor
    this.cdColor := cdColor
    this.cooldownTime := cd ; Set cooldown time to the cd parameter
    this.cdReductionTarget := cdReductionTarget
    this.cdReductionAmount := cdReductionAmount
  }

  ; Check if skill is ready
  IsReady() {
    if (this.lastUsedTime = 0) return true
      return (A_TickCount - this.lastUsedTime) >= (this.cooldownTime * 1000)
  }

  ; Get remaining cooldown in seconds
  GetRemainingCD() {
    if (this.lastUsedTime = 0) return 0
      remaining := (this.cooldownTime * 1000 - (A_TickCount - this.lastUsedTime)) / 1000
    return (remaining > 0 ? Round(remaining, 1) : 0)
  }

  ; Mark skill as used
  MarkUsed() {
    this.lastUsedTime := A_TickCount
    this.ready := false
  }

  ; Update ready state based on cooldown
  UpdateState() {
    this.ready := this.IsReady()
  }

  ; Reduce cooldown of target skill
  ReduceTargetCD(targetSkill) {
    if (this.cdReductionTarget = targetSkill.name) {
      if (targetSkill.lastUsedTime > 0) {
        targetSkill.lastUsedTime := targetSkill.lastUsedTime - (this.cdReductionAmount * 1000)
        if (targetSkill.lastUsedTime < 0) {
          targetSkill.lastUsedTime := 0
          targetSkill.ready := true
        }
      }
    }
  }
}

; Function to create a new skill with default values
CreateSkill(params) {
  return new Skill(
  params.change_stance ?: false,
  params.stance ?: "",
  params.ready ?: true,
  params.cd ?: 0,
  params.gcd ?: 0,
  params.name ?: "",
  params.readyX ?: 0,
  params.readyY ?: 0,
  params.cdX ?: 0,
  params.cdY ?: 0,
  params.readyColor ?: "0x111111",
  params.cdColor ?: "0xFFFFFF",
  params.cdReductionTarget ?: "",
  params.cdReductionAmount ?: 0
  )
}

; Create new skill instances
; All Fire skills
blazing_palm := CreateSkill({
  change_stance: true,
  stance: "fire",
  name: "Blazing Palm",
  readyX: 100,
  readyY: 100,
  cdX: 100,
  cdY: 100
})

bale_fire := CreateSkill({
  stance: "fire",
  name: "Bale Fire",
  cd: 18,
  readyX: 100,
  readyY: 120,
  cdX: 100,
  cdY: 120,
  readyColor: "0x222222",
  cdColor: "0xEEEEEE"
  })

  meteor_shower := CreateSkill({
    stance: "fire",
    name: "Meteor Shower",
    cd: 30,
    readyX: 100,
    readyY: 140,
    cdX: 100,
    cdY: 140,
    readyColor: "0x333333",
  cdColor: "0xDDDDDD"
  })

  inferno := CreateSkill({
    stance: "fire",
    name: "Inferno",
    cd: 45,
    readyX: 100,
    readyY: 160,
    cdX: 100,
    cdY: 160,
    readyColor: "0x444444",
  cdColor: "0xCCCCCC"
  })

  ; All Ice skills
  frost_palm := CreateSkill({
    change_stance: true,
    stance: "ice",
    name: "Frost Palm",
    readyX: 100,
    readyY: 180,
    cdX: 100,
    cdY: 180,
    readyColor: "0x555555",
  cdColor: "0xBBBBBB"
  })

  force_blast := CreateSkill({
    stance: "ice",
    name: "Force Blast",
    cd: 12,
    readyX: 100,
    readyY: 200,
    cdX: 100,
    cdY: 200,
    readyColor: "0x666666",
    cdColor: "0xAAAAAA",
    cdReductionTarget: "Massive Snowball",
    cdReductionAmount: 5
  })

  cold_snap := CreateSkill({
    stance: "ice",
    name: "Cold Snap",
    cd: 30,
    readyX: 100,
    readyY: 200,
    cdX: 100,
    cdY: 200,
    readyColor: "0x666666",
  cdColor: "0xAAAAAA"
  })

  massive_snowball := CreateSkill({
    stance: "ice",
    name: "Massive Snowball",
    cd: 18,
    readyX: 100,
    readyY: 220,
    cdX: 100,
    cdY: 220,
    readyColor: "0x777777",
    cdColor: "0x999999",
    cdReductionTarget: "Cold Snap",
    cdReductionAmount: 20
  })

  ; Function to check if enough time has passed since last skill
  IsGCDReady() {
    global lastSkillTime, globalCD
  return (A_TickCount - lastSkillTime) >= (globalCD * 1000)
}

; Function to verify skill state
VerifySkillState(skill) {
  if (skill.ready) {
  return CheckColor(skill.readyX, skill.readyY, skill.readyColor)
} else {
  return CheckColor(skill.cdX, skill.cdY, skill.cdColor)
}
}

; Function to use a skill
UseSkill(skill) {
  global lastSkillTime, currentSkill
  skill.UpdateState() ; Update skill's ready state

  if (skill.ready && IsGCDReady()) {
    if (skill.change_stance) {
      Send, %skill.stance%
      currentSkill := "Stance: " skill.stance
      Sleep, 100 ; Wait for stance change
    }
    Send, %skill.cd%
    Sleep, 100 ; Wait for skill to register

    ; Verify if skill was successfully used
    if (VerifySkillState(skill)) {
      currentSkill := skill.name
      lastSkillTime := A_TickCount
      skill.MarkUsed() ; Mark skill as used and start cooldown

      ; Apply CD reduction if applicable
      if (skill.cdReductionTarget = "Cold Snap") {
        skill.ReduceTargetCD(cold_snap)
      } else if (skill.cdReductionTarget = "Massive Snowball") {
        skill.ReduceTargetCD(massive_snowball)
      }

      UpdateGUI()
      return true
    } else {
      ; If verification failed, try again
      Send, %skill.cd%
      Sleep, 100
      if (VerifySkillState(skill)) {
        currentSkill := skill.name
        lastSkillTime := A_TickCount
        skill.MarkUsed() ; Mark skill as used and start cooldown

        ; Apply CD reduction if applicable
        if (skill.cdReductionTarget = "Cold Snap") {
          skill.ReduceTargetCD(cold_snap)
        } else if (skill.cdReductionTarget = "Massive Snowball") {
          skill.ReduceTargetCD(massive_snowball)
        }

        UpdateGUI()
        return true
      }
    }
  }
  return false
}

; Function to try using fire skills
TryUseFireSkills() {
  if (UseSkill(blazing_palm)) return true
  if (UseSkill(bale_fire)) return true
if (UseSkill(inferno)) return true
  if (UseSkill(meteor_shower)) return true
  return false
}

; Function to try using ice skills
TryUseIceSkills() {
  if (UseSkill(frost_palm)) return true
  if (UseSkill(cold_snap)) return true
if (UseSkill(massive_snowball)) return true
  if (UseSkill(force_blast)) return true
  return false
}

; XButton2 (Mouse Back Button) hotkey
XButton2::
  global scriptRunning
  scriptRunning := true
  UpdateGUI()
  while GetKeyState("XButton2", "P") ; While XButton2 is held down
  {
    Send, 2
    Send, r
    if (TryUseFireSkills()) {
      Sleep, 100 ; Only wait if a skill was used
    }
    Send, t
    if (TryUseIceSkills()) {
      Sleep, 100 ; Only wait if a skill was used
    }
  }
  scriptRunning := false
  UpdateGUI()
return

; F1 hotkey to get mouse position and color
F1::
  MouseGetPos, mouseX, mouseY
  PixelGetColor, color, %mouseX%, %mouseY%, RGB
  output := "Mouse Position: X=" mouseX ", Y=" mouseY "`nColor: " color
  MsgBox, %output%
  SetClipboard(output)
return

; F2 to exit script
F2::ExitApp
