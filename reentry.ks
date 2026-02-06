//Orbitas Raras
//Landing Pad Norte
//PrintInfo
//Adjust Angle Rocket or Pod
//Precise SBurn

//                                        .========.
//========================================| LANDER |========================================
//                                        |========|

//////////////////////////////////////
/////// VARIABLES FOR TWEAKING ///////
//////////////////////////////////////

Parameter Pad           is "Anywhere".			// Land at this location ([Pad_Name], [Vessel_Name], "Target" or "[LAT], [LNG])"
Parameter ShowInfo      is  True.				// Show printed information in the kOS console

Parameter ExtraAlt      is  0.					// Altitude offset (in meters) for 'Suicide Burn' calculation
Parameter Efficiency    is  0.					// Efficiency of the Suicide Burn between 0-100 (a value greater than 0 is less efficiency but safer)
Parameter AutoSlope     is "Yes".				// Find a place to land with a slope within the margin of 'MaxSlope' around the landing point
Parameter MaxSlope      is  5.					// Maximum slope angle for landing (only when 'AutoSlope' is "Yes")
Parameter AutoWarp      is "Yes".				// Warp automatically
Parameter AutoStage     is  0.					// Stage automatically while deorbiting
Parameter Stages        is List("Auto", "No", "Once").		// List of stage modes
Parameter AutoRetract   is "Yes".				// Prepare ship for reentry.

Parameter GEAR_ON       is "Yes".				// Lower Gear automatically
Parameter GEAR_ON_Time  is  5.					// Lower Gear this value (in seconds) before impact (only when 'GEAR_ON' is "Yes")
Parameter BRAKES_ON     is "Yes".				// Deploy aerobrakes automatically
Parameter RCS_ON        is "Yes".				// Turn ON or OFF RCS automatically
Parameter LMODE         is "Engine".				// Landing mode ("Engine" or "Chute")

Parameter lANTENNAS_ON  is "No".				// Activate antennas on ground
Parameter lLIGHTS_ON    is "No".				// Activate lights on ground
Parameter lSOLAR_ON     is "No".				// Activate solar panels on ground
Parameter lDRILLS_ON    is "No".				// Deploy drills on ground
Parameter lRADIATORS_ON is "No".				// Activate radiators on ground
Parameter lLADDER_ON    is "No".				// Activate ladders on ground
Parameter lBRAKES_ON    is "No".				// Activate brakes on ground
Parameter lSAS_ON       is "No".				// Activate SAS on ground
Parameter lRCS_ON       is "No".				// Activate RCS on ground
Parameter lAG           is  0.					// Activate selected 'Action Group'

Set ShipHeight to GetShipHeight(Ship).				// Altitude offset from bottom
Set Ship:Control:PilotMainThrottle to 0.			// Set throttle to 0
Set Terminal:Width to 50. Set Terminal:Height to 36.    	// Terminal size
Set Config:IPU to 500.						// Change IPU settings

//////////////////////////
/////// REQUISITES ///////
//////////////////////////

If Addons:TR:Available = False { ClearScreen.
  Print "                       LANDER                      " at (0, 2).
  Print "    .========================================.     " at (0, 10).
  Print "    |       TRAJECTORIES NOT INSTALLED       |     " at (0, 11).
  Print "    |========================================|     " at (0, 12).
  Print "            (9) Press 'ENTER' to exit              " at (0, 19).
  Print "  By: Kobayashi " at (34, 34).
  Set TimeExit to Time:Seconds + 10. Until False {
    If Round(TimeExit - Time:Seconds) < 10 and Round(TimeExit - Time:Seconds) > 0 { Print Round(TimeExit - Time:Seconds) at (13, 19). }
    If TimeExit < Time:Seconds { If Core:HasAction("Close Terminal") = True and ShowInfo = True { Core:DoAction("Close Terminal", True). } Reboot. Break. }
    If Terminal:Input:HasChar { Set ch to Terminal:Input:GetChar(). If ch = Terminal:Input:Enter { Reboot. Break. } If Terminal:Input:HasChar Terminal:Input:Clear. }
  }
}

////////////////////////////
/////// LANDING-PADS ///////
////////////////////////////

Set LandingPads to List(). { Set PadN to 0.
  If Ship:Body:Name = "Kerbin" {
    LandingPads:Add("LaunchPad").		LandingPads:Add(LatLng(-0.097207, -74.557672)). LandingPads:Add(Body:Name).
    LandingPads:Add("Pad1").			LandingPads:Add(LatLng(-0.096808, -74.617447)). LandingPads:Add(Body:Name).
    LandingPads:Add("Pad2"). 			LandingPads:Add(LatLng(-0.096767, -74.620048)). LandingPads:Add(Body:Name).
    LandingPads:Add("HeliPad").  		LandingPads:Add(LatLng(-0.092562, -74.663084)). LandingPads:Add(Body:Name).
    LandingPads:Add("Island Airfield").		LandingPads:Add(LatLng(-1.519712, -71.899433)). LandingPads:Add(Body:Name).
    LandingPads:Add("Island Airfield (Tower)"). LandingPads:Add(LatLng(-1.523246, -71.911106)). LandingPads:Add(Body:Name).
    LandingPads:Add("KSC Pool").  		LandingPads:Add(LatLng(-0.086810, -74.661199)). LandingPads:Add(Body:Name).
    LandingPads:Add("Round Range").    		LandingPads:Add(LatLng(-6.056890,  99.471429)). LandingPads:Add(Body:Name).
    LandingPads:Add("KSC 2").   		LandingPads:Add(LatLng(20.663470,-146.420970)). LandingPads:Add(Body:Name).
  }
  If HasTarget = True and Target:Body:Name = Body:Name and ShipStatus(Target) <> "Flying" { LandingPads:Add("'Target'"). LandingPads:Add(Target:GeoPosition). LandingPads:Add(Body:Name). }
  If Exists("Pads") = True { Set cPads to List(). Run Pads. From { Set cPadN to 0. } Until cPadN > cPads:Length -3 Step { Set cPadN to cPadN + 3.} Do { If cPads[cPadN + 2] = Body:Name { LandingPads:Add(cPads[cPadN]). LandingPads:Add(LatLng(cPads[cPadN + 1]:Split(",")[0]:ToNumber, cPads[cPadN + 1]:Split(",")[1]:ToNumber)). LandingPads:Add(cPads[cPadN + 2]). }}}
  For cWaypoint in AllWaypoints() { If cWaypoint:Body:Name = Ship:Body:Name {Set AddWaypoint to True. From { Set cPadN to 0. } Until cPadN > LandingPads:Length -3 Step { Set cPadN to cPadN + 3.} Do { If LandingPads[cPadN] = cWaypoint:Name and LandingPads[cPadN + 1] = cWaypoint:GeoPosition { Set AddWaypoint to False. Break. }} If AddWaypoint = True { LandingPads:Add("'" + cWaypoint:Name + "'"). LandingPads:Add(cWaypoint:GeoPosition). LandingPads:Add(cWaypoint:Body:Name). }}}
  List Targets in AllTargets. For cTarget in AllTargets { If cTarget:Body:Name = Body:Name and ShipStatus(cTarget) <> "Flying" { LandingPads:Add("'" + cTarget:Name + "'"). LandingPads:Add(cTarget:GeoPosition). LandingPads:Add(cTarget:Body:Name). }}
  If ShipStatus = "Flying" { LandingPads:Add("Anywhere"). LandingPads:Add(LatLng(0, 0)). LandingPads:Add(Body:Name). If Periapsis > Body:Atm:Height { LandingPads:Add("Anywhere (land)"). LandingPads:Add(LatLng(0, 0)). LandingPads:Add(Body:Name). LandingPads:Add("Anywhere (water)"). LandingPads:Add(LatLng(0, 0)). LandingPads:Add(Body:Name). }}
  Set cPad to "". If LandingPads:Length > 0 { From { Set cPadN to 0. } Until cPadN > LandingPads:Length -3 Step { Set cPadN to cPadN + 3.} Do { If LandingPads[cPadN]:Replace("'", "") = Pad or LandingPads[cPadN] = Pad { Set PadN to cPadN. Set Pad to LandingPads[cPadN]. Set LandingPad to LandingPads[cPadN + 1]. Set cPad to Pad. Break. }}}
  If cPad = "" and Pad:Contains(",") = True { Set GeoPosLat to Pad:Split(",")[0]. Set GeoPosLng to Pad:Split(",")[1]. Set GeoPos to LatLng(GeoPosLat:ToNumber, GeoPosLng:ToNumber). Set Pad to "'" + Round(GeoPos:Lat, 3)+ ", " + Round(GeoPos:Lng, 3) + "'". LandingPads:Add(Pad). LandingPads:Add(GeoPos). LandingPads:Add(body:Name). Set PadN to LandingPads:Length -3. Set LandingPad to GeoPos. Set cPad to Pad. }
  If LandingPads:Length = 0 { Set Pad to "No Pads". } Else { If cPad = "" { Set Pad to LandingPads[LandingPads:Length - 3]. Set LandingPad to LandingPads[LandingPads:Length - 2]. }}
}

////////////////////////
///////// MENU /////////
////////////////////////

Set StartProgram to False. Set ShowProgram to True. Set LandedSettings to False. Set Mode to "". Set SubMode to "". Set SBurning to False.
Until StartProgram = True { If ShowInfo = False or ShipStatus <> "Flying" Break.

  If ShowProgram = True and LandedSettings = True { ClearScreen. Set ShowProgram to False. 
    Print "                      LANDER                       " at (0,  2).
    Print "                                                   " at (0,  3).
    Print "                  LANDING SETTINGS                 " at (0,  4).
    Print " .===============================================. " at (0,  5).
    Print " | (1) Antennas:         | (6) Ladder:           | " at (0,  6).
    Print " |-----------------------------------------------| " at (0,  7).
    Print " | (2) Lights:           | (7) Brakes:           | " at (0,  8).
    Print " |-----------------------------------------------| " at (0,  9).
    Print " | (3) Solar Panels:     | (8) SAS:              | " at (0, 10).
    Print " |-----------------------------------------------| " at (0, 11).
    Print " | (4) Drills:           | (9) RCS:              | " at (0, 12).
    Print " |-----------------------------------------------| " at (0, 13).
    Print " | (5) Radiators:        | (0) Action Group:     | " at (0, 14).
    Print " |===============================================| " at (0, 15).
    Print "            Press 'BACKSPACE' to go back           " at (0, 22).
    Print "  By: Kobayashi " at (34, 34).
  }
  If LandedSettings = True {
    Print Spacer(lANTENNAS_ON:Length, 4) + lANTENNAS_ON at (24 - (Spacer(lANTENNAS_ON:Length, 4) + lANTENNAS_ON):Length,  6).		Print Spacer(lLADDER_ON:Length, 4) + lLADDER_ON at (48 - (Spacer(lLADDER_ON:Length, 4) + lLADDER_ON):Length,  6).
    Print Spacer(lLIGHTS_ON:Length, 4) + lLIGHTS_ON at (24 - (Spacer(lLIGHTS_ON:Length, 4) + lLIGHTS_ON):Length,  8).			Print Spacer(lBRAKES_ON:Length, 4) + lBRAKES_ON at (48 - (Spacer(lBRAKES_ON:Length, 4) + lBRAKES_ON):Length,  8).
    Print Spacer(lSOLAR_ON:Length, 4) + lSOLAR_ON at (24 - (Spacer(lSOLAR_ON:Length, 4) + lSOLAR_ON):Length, 10).			Print Spacer(lSAS_ON:Length, 4) + lSAS_ON at (48 - (Spacer(lSAS_ON:Length, 4) + lSAS_ON):Length, 10).
    Print Spacer(lDRILLS_ON:Length, 4) + lDRILLS_ON at (24 - (Spacer(lDRILLS_ON:Length, 4) + lDRILLS_ON):Length, 12).			Print Spacer(lRCS_ON:Length, 4) + lRCS_ON at (48 - (Spacer(lRCS_ON:Length, 4) + lRCS_ON):Length, 12).
    Print Spacer(lRADIATORS_ON:Length, 4) + lRADIATORS_ON at (24 - (Spacer(lRADIATORS_ON:Length, 4) + lRADIATORS_ON):Length, 14).	If lAG = 0 {Print "No" at (46, 14). } Else { Print Spacer(lAG + "":Length, 2) + lAG at (48 - (Spacer(lAG + "":Length, 2) + lAG):Length, 14). }

    If Terminal:Input:HasChar { Set ch to Terminal:Input:GetChar().
      If ch = "1"   If lANTENNAS_ON  = "Yes"   { Set lANTENNAS_ON to  "No". }   Else   { Set lANTENNAS_ON to  "Yes". }
      If ch = "2"   If lLIGHTS_ON    = "Yes"   { Set lLIGHTS_ON to    "No". }   Else   { Set lLIGHTS_ON to    "Yes". }
      If ch = "3"   If lSOLAR_ON     = "Yes"   { Set lSOLAR_ON to     "No". }   Else   { Set lSOLAR_ON to     "Yes". }
      If ch = "4"   If lDRILLS_ON    = "Yes"   { Set lDRILLS_ON to    "No". }   Else   { Set lDRILLS_ON to    "Yes". }
      If ch = "5"   If lRADIATORS_ON = "Yes"   { Set lRADIATORS_ON to "No". }   Else   { Set lRADIATORS_ON to "Yes". }      
      If ch = "6"   If lLADDER_ON    = "Yes"   { Set lLADDER_ON to    "No". }   Else   { Set lLADDER_ON to    "Yes". }
      If ch = "7"   If lBRAKES_ON    = "Yes"   { Set lBRAKES_ON to    "No". }   Else   { Set lBRAKES_ON to    "Yes". }
      If ch = "8"   If lSAS_ON       = "Yes"   { Set lSAS_ON to       "No". }   Else   { Set lSAS_ON to       "Yes". }
      If ch = "9"   If lRCS_ON       = "Yes"   { Set lRCS_ON to       "No". }   Else   { Set lRCS_ON to       "Yes". }
      If ch = "0"   If lAG           = 10 { Set lAG to 0. } Else { Set lAG to lAG  + 1. }
      If ch = "l"   { Set LandedSettings to False. Set ShowProgram to True. }
      If ch = Terminal:Input:Backspace { Set LandedSettings to False. Set ShowProgram to True. } If Terminal:Input:HasChar Terminal:Input:Clear.
    }
  }

  If ShowProgram = True and LandedSettings = False { ClearScreen. Set ShowProgram to False. 
    Print "                      LANDER                       " at (0,  2).
    Print "                                                   " at (0,  3).
    Print "    .========================================.     " at (0,  4).
    Print "    | (< >) PAD:                             |     " at (0,  5).
    Print " .===============================================. " at (0,  6).
    Print " | Terrain Alt:          | Distance:             | " at (0,  7).
    Print " |-----------------------------------------------| " at (0,  8).
    Print " | Biome:                | Body:                 | " at (0,  9).
    Print " |===============================================| " at (0, 10).
    Print "                                                   " at (0, 11).
    Print "                     SETTINGS                      " at (0, 12).
    Print " .===============================================. " at (0, 13).
    Print " | (M) Mode:             | (R) RCS:              | " at (0, 14).
    Print " |-----------------------------------------------| " at (0, 15).
    Print " | (A) Extra Alt:        | (G) Gear:             | " at (0, 16).
    Print " |-----------------------------------------------| " at (0, 17).
    Print " | (E) Efficiency:       | (B) Aerobrakes:       | " at (0, 18).
    Print " |-----------------------------------------------| " at (0, 19).
    Print " | (P) Auto-Slope:       | (W) Auto-Warp:        | " at (0, 20).
    Print " |-----------------------------------------------| " at (0, 21).
    Print " | (S) Auto-Stage:       | (T) Auto-Retract:     | " at (0, 22).
    Print " |===============================================| " at (0, 23).
    Print "   (L) Landing settings                            " at (0, 25).
    Print "               Press 'ENTER' to start              " at (0, 30).
    Print "  By: Kobayashi " at (34, 34).
  }

  If LandedSettings = False {
    If Pad <> "Anywhere" and Pad <> "Anywhere (land)" and Pad <> "Anywhere (water)" {
      Set APad to FormatDistance(MAX(LandingPad:TerrainHeight, 0), 1).
      Set DPad to FormatDistance(LandingPad:Distance, 1).
      If Addons:Biome:Available = True { Set BPad to Addons:Biome:At(Ship:Body, LandingPad). } Else { Set BPad to "Unknow". }
    } Else { Set APad to "      -". Set DPad  to "-". Set BPad to "-". }

    Print Pad  + Spacer(Pad:Length,  26) at (18, 5). Print "|    " at (45, 5).
    Print Spacer(APad:Length,  9) + APad at (24 - (Spacer(APad:Length,  9) + APad):Length, 7).
    Print Spacer(DPad:Length, 9) + DPad at (48 - (Spacer(DPad:Length, 9) + DPad):Length, 7).
    Print Spacer(BPad:Length, 14) + BPad at (24 - (Spacer(BPad:Length, 14) + BPad):Length, 9).
    Print Spacer(Ship:Body:Name:Length, 9) + Ship:Body:Name at (48 - (Spacer(Ship:Body:Name:Length, 9) + Ship:Body:Name):Length, 9).

    Print Spacer(LMODE:Length, 6) + LMODE at (24 - (Spacer(LMODE:Length, 6) + LMODE):Length, 14).
    If LMODE = "Chute" { Print " N/A" at (20, 16). } Else { Print Spacer(FormatDistance(ExtraAlt):Length, 5) + FormatDistance(ExtraAlt) at (24 - (Spacer(FormatDistance(ExtraAlt):Length, 5) + FormatDistance(ExtraAlt)):Length, 16). }
    If LMODE = "Chute" { Print " N/A" at (20, 18). } Else { Print Spacer((Round(100 - (Efficiency / 10)) + "%"):Length, 4) + Round(100 - (Efficiency / 10)) + "%" at (24 - (Spacer((Round(100 - (Efficiency / 10)) + "%"):Length, 4) + Round(100 - (Efficiency / 10)) + "%"):Length, 18). }
    If Pad <> "Anywhere" and Pad <> "Anywhere (land)" { Print " N/A" at (20, 20). } Else { Print Spacer(AutoSlope:Length, 3) + AutoSlope at (24 - (Spacer(AutoSlope:Length, 3) + AutoSlope):Length, 20). }
    Print Spacer(Stages[AutoStage]:Length, 4) + Stages[AutoStage] at (24 - (Spacer(Stages[AutoStage]:Length, 4) + Stages[AutoStage]):Length, 22).

    Print Spacer(RCS_ON:Length, 4) + RCS_ON at (48 - (Spacer(RCS_ON:Length, 4) + RCS_ON):Length, 14).
    Print Spacer(GEAR_ON:Length, 4) + GEAR_ON at (48 - (Spacer(GEAR_ON:Length, 4) + GEAR_ON):Length, 16).
    Print Spacer(BRAKES_ON:Length, 4) + BRAKES_ON at (48 - (Spacer(BRAKES_ON:Length, 4) + BRAKES_ON):Length, 18).
    Print Spacer(AutoWarp:Length, 4) + AutoWarp at (48 - (Spacer(AutoWarp:Length, 4) + AutoWarp):Length, 20).
    Print Spacer(AutoRetract:Length, 4) + AutoRetract at (48 - (Spacer(AutoRetract:Length, 4) + AutoRetract):Length, 22).

    If Terminal:Input:HasChar { Set ch to Terminal:Input:GetChar().

      If LandingPads:Length > 0 If ch = Terminal:Input:LeftCursorOne  { If PadN = -1 Set PadN to 0. If PadN = 0 { Set PadN to LandingPads:Length - 3. } Else { Set PadN to PadN - 3. } Set Pad to LandingPads[PadN]. Set LandingPad to LandingPads[PadN + 1]. }
      If LandingPads:Length > 0 If ch = Terminal:Input:RightCursorOne { If PadN = -1 Set PadN to LandingPads:Length - 3. If PadN = LandingPads:Length - 3 { Set PadN to 0. } Else { Set PadN to PadN + 3. } Set Pad to LandingPads[PadN]. Set LandingPad to LandingPads[PadN + 1]. }
      If UnChar(ch) = 97    { If ExtraAlt < 50      Set ExtraAlt to ExtraAlt + 1. }
      If UnChar(ch) = 65    { If ExtraAlt > 0       Set ExtraAlt to ExtraAlt - 1. }
      If UnChar(ch) = 69    { If Efficiency < 1000  Set Efficiency to Efficiency + 50. }
      If UnChar(ch) = 101   { If Efficiency > 0     Set Efficiency to Efficiency - 50. }

      If ch = "m"   If LMODE  =  "Engine"   { Set LMODE to   "Chute". }   Else   { Set LMODE to   "Engine". }
      If Pad = "Anywhere" { If ch = "p" If AutoSlope = "Yes" { Set AutoSlope to "No". } Else { Set AutoSlope to "Yes". }}
      If ch = "s" If AutoStage = Stages:Length -1 { Set AutoStage to 0. } Else { Set AutoStage to AutoStage + 1. }
      If ch = "r"   If RCS_ON      = "Yes"   { Set RCS_ON to      "No". }   Else   { Set RCS_ON to      "Yes". }
      If ch = "g"   If GEAR_ON     = "Yes"   { Set GEAR_ON to     "No". }   Else   { Set GEAR_ON to     "Yes". }
      If ch = "b"   If BRAKES_ON   = "Yes"   { Set BRAKES_ON to   "No". }   Else   { Set BRAKES_ON to   "Yes". }
      If ch = "w"   If AutoWarp    = "Yes"   { Set AutoWarp to    "No". }   Else   { Set AutoWarp to    "Yes". }
      If ch = "t"   If AutoRetract = "Yes"   { Set AutoRetract to "No". }   Else   { Set AutoRetract to "Yes". }
      If ch = "l"   { Set ShowProgram to True. Set LandedSettings to True. }
      If ch = Terminal:Input:Enter { Set StartProgram to True. If Pad = "'Target'" { If HasTarget = True { Set Pad to "'" + Target:Name + "'". Set LandingPad to Target:GeoPosition. } Else { Set Pad to "Anywhere". Set LandingPad to LatLng(0, 0). }}}
      If Terminal:Input:HasChar Terminal:Input:Clear.
    }
  }
}

////////////////////////////////
///////// MAIN PROGRAM /////////
////////////////////////////////

SAS Off. If RCS_ON = "Yes" { RCS On. } Else { RCS Off. }
If Stages[AutoStage] = "Auto" When AvailableThrust = 0 and HasEngines = True Then { Stage. Wait 0.1. If AvailableThrust = 0 Wait 1. Preserve. }

//// FLIGHT STATE ////

If Periapsis > 0 { Set CurrentMode to "Orbit".
} Else If ShipStatus <> "Flying" { Set CurrentMode to "Landed".
} Else If Altitude > Body:ATM:Height { Set CurrentMode to "Coast".
} Else If Altitude < Body:ATM:Height and GroundSpeed > 500 { Set CurrentMode to "Aerobrake".
} Else If Altitude < Body:ATM:Height and GroundSpeed < 500 { Set CurrentMode to "SBurn".
} Else { Reboot. }

//// ORBIT ////

If CurrentMode = "Orbit" {
  If Pad <> "Anywhere (land)" and Pad <> "Anywhere (water)" { If AutoWarp = "Yes" Set Warp to 3. Set Mode to "Wait to deorbit". PrintInfo(CurrentMode).
    Until ApproachingLNG(Ship, LandingPad:LNG) = True and ABS(GeoPositionDistanceLNG(Ship:GeoPosition, LandingPad:LNG) - (((2 * Body:Radius) * Constant:PI) / 4)) < (((2 * Body:Radius) * Constant:PI) / 4) / 10 { PrintInfo. }
    Set NewLandingPad to GeoPositionFrom(LandingPad, ((GeoPositionDistance(Ship:GeoPosition, LandingPad) / ((Velocity:Orbit:MAG + VelocityAt(Ship, Time:Seconds + (GeoPositionDistance(Ship:GeoPosition, LandingPad) / Velocity:Orbit:MAG)):Orbit:MAG) / 2)) * ((COS(LandingPad:LAT) * ((2 * Body:Radius) * Constant:PI)) / Body:RotationPeriod)), 90).
    If ABS(GetHeading() - GetHeading(NewLandingPad:Position)) > 0.2 {
      If NewLandingPad:LAT > Ship:GeoPosition:LAT { Set DirMode to Ship:Position - Body:Position. } Else { Set DirMode to Ship:Position + Body:Position. }
      Set Warp to 0. Set Mode to "Matching angle". Lock Steering to VCRS(Ship:Velocity:Orbit, DirMode).
      Until VANG(Facing:Vector, VCRS(Ship:Velocity:Orbit, DirMode)) < 2 { PrintInfo. } Lock Throttle to MAX(ABS(GetHeading() - GetHeading(NewLandingPad:Position)), GetTWR(0.5)).
      Until ABS(GetHeading() - GetHeading(NewLandingPad:Position)) <= 0.1 { PrintInfo. } Lock Throttle to 0.
    } Set Warp to 0. Set Mode to "Deorbiting".
    Lock Steering to Retrograde. Until VANG(Facing:Vector, Retrograde:Vector) < 2 { PrintInfo. } Wait 5. If Addons:TR:HasImpact = False Lock Throttle to MAX(Periapsis / 10, GetTWR(1)).
    Until Addons:TR:HasImpact = True { PrintInfo. } Lock Throttle to 0.

    If ShowInfo = True { Set TimeExit to Time:Seconds + 10. Set MessageCh to False. Set Counter to 10. Set Mode to "Waiting...". Print "                | YOU CAN STAGE NOW |              " at (0, 16). Print "           (9) Press 'ENTER' to continue           " at (0, 20). Print "         Press 'SPACE' to stage and continue       " at (0, 22).
      Until False { PrintInfo().
        Set MessageCh to Not MessageCh. If MessageCh = False { Print "                .- - - - - - - - - -.              " at (0, 15). Print "                |- - - - - - - - - -|              " at (0, 17). } Else { Print "                . - - - - - - - - - .              " at (0, 15). Print "                | - - - - - - - - - |              " at (0, 17). } Wait 0.3.
        If Round(TimeExit - Time:Seconds) < 10 and Round(TimeExit - Time:Seconds) > 0 { Print Round(TimeExit - Time:Seconds) at (12, 20). }
        If TimeExit < Time:Seconds { Break. } If Terminal:Input:HasChar { Set ch to Terminal:Input:GetChar(). If ch = Terminal:Input:Enter { Break. } If ch = " " { Stage. Wait 1. Break. } If Terminal:Input:HasChar Terminal:Input:Clear. }
      } Print "                                                   " at (0, 15). Print "                                                   " at (0, 16). Print "                                                   " at (0, 17). Print "                                                   " at (0, 20). Print "                                                   " at (0, 22).
    }

    Lock TargetDist to GeoPositionDistance(LandingPad, Addons:TR:ImpactPos). Set Mode to "Deorbiting".
    Until TargetDist < 10000 and Periapsis < Body:ATM:Height / 2 or Periapsis < -(Body:Radius / 100) { PrintInfo. If TargetDist < 50000 { Lock Throttle to GetTWR(0.1). } Else { Lock Throttle to GetTWR(1). }}
    Set TargetDistOld to 0. Set SteeringPitch to 0. Until False {
      Set SteeringDir to GeoDir(Addons:TR:ImpactPos, LandingPad) - 180. Set SteeringPitch to 0. Lock Steering to Heading(SteeringDir, SteeringPitch).
      If VANG(Heading(SteeringDir, SteeringPitch):Vector, Ship:Facing:Vector) < 5 { Lock Throttle to GetTWR(0.3). } Else { If Throttle > 0 Lock Throttle to 0. }
      If TargetDist > TargetDistOld and TargetDist < 5000 { Lock Throttle to 0. Break. } Set TargetDistOld to TargetDist.
    } Lock Steering to Retrograde. Until VANG(Facing:Vector, Retrograde:Vector) < 2 { PrintInfo. } Wait 5.
  } Else If Pad = "Anywhere (land)" or Pad = "Anywhere (water)" { Set Mode to "Deorbiting". PrintInfoA(CurrentMode).
    Set Warp to 0. Lock Steering to Retrograde.
    Until VANG(Facing:Vector, Retrograde:Vector) < 2 { PrintInfoA. } Lock Throttle to 1.
    Until Addons:TR:HasImpact = True { PrintInfo. } Lock Throttle to 0. Set TimeExit to Time:Seconds + 10. Set Mode to "Stage now if you must". Print "             Press 'ENTER' to continue             " at (0, 12).
    Until False { PrintInfo(). If TimeExit < Time:Seconds { Break. } If Terminal:Input:HasChar { Set ch to Terminal:Input:GetChar(). If ch = Terminal:Input:Enter { Break. } If Terminal:Input:HasChar Terminal:Input:Clear. }}
    Lock Throttle to GetTWR(0.3). Print "                                                   " at (0, 12).
    Until False { PrintInfoA.
      If Pad = "Anywhere" and Periapsis < Body:ATM:Height / 2 { If AutoSlope = "Yes" { Lock Throttle to GetTWR(0.3). } Else { Lock Throttle to GetTWR(0.1). } If Addons:TR:ImpactPos:TerrainHeight > 0 { If AutoSlope = "Yes" and SlopeAt(Addons:TR:ImpactPos) < MaxSlope { Break. } Else If AutoSlope = "No" { Break. }} Else { Break. }} 
      If Pad = "Anywhere (land)" and Periapsis < Body:ATM:Height / 2 { If AutoSlope = "Yes" { Lock Throttle to GetTWR(0.3). } Else { Lock Throttle to GetTWR(0.1). } If Addons:TR:ImpactPos:TerrainHeight > 0 { If AutoSlope = "Yes" and SlopeAt(Addons:TR:ImpactPos) < MaxSlope { Break. } Else If AutoSlope = "No" { Break. }}}
      If Pad = "Anywhere (water)" and Periapsis < Body:ATM:Height / 2 { Lock Throttle to GetTWR(0.3). If Addons:TR:ImpactPos:TerrainHeight < 0 { Break. }}
    } Lock Throttle to 0. Set LandingPad to Addons:TR:ImpactPos. Lock Steering to Retrograde. Until VAng(Facing:Vector, Retrograde:Vector) < 2 { PrintInfo. } Wait 5. 
  } Addons:TR:SetTarget(LandingPad). If Altitude > Body:ATM:Height { Set CurrentMode to "Coast". } Else { Set CurrentMode to "Aerobrake". }
}

//// COAST ////

If CurrentMode = "Coast" { If AutoWarp = "Yes" Set Warp to 3. Set Mode to "Coasting to atm". PrintInfo(CurrentMode).
  Until Altitude < Body:ATM:Height + 3000 { PrintInfo. }
  Set Warp to 0. Lock Steering to SRFRetrograde. Set Mode to "Prepare for reentry". If AutoRetract = "Yes" PrepareShip("All", False). If Stages[AutoStage] = "Once" Stage.
  Until Altitude < Body:ATM:Height { PrintInfo. } Set CurrentMode to "Aerobrake".
}

//// AEROBRAKE ////

If CurrentMode = "Aerobrake" { Set Mode to "Aerobraking". PrintInfo(CurrentMode).
  If Pad = "Anywhere" Set LandingPad to Addons:TR:ImpactPos. Addons:TR:SetTarget(LandingPad). Lock Steering to Addons:TR:CorrectedVector.
  If AutoWarp = "Yes" and GroundSpeed > 1200 { Set WarpMode to "PHYSICS". Set Warp to 2. }
  Until Altitude < Body:ATM:Height and GroundSpeed < 500 { PrintInfo. } 
  Set Warp to 0. Set CurrentMode to "SBurn".
}

//// SUICIDE BURN ////

If CurrentMode = "SBurn" { If Pad = "Anywhere" Set LandingPad to Addons:TR:ImpactPos.
  If Pad = "Anywhere" or Pad = "Anywhere (land)" or Pad = "Anywhere (water)" { Lock TrueAltitude to Altitude - (ShipHeight + ExtraAlt + 5 + MAX(Addons:TR:ImpactPos:TerrainHeight, 0)). } Else { Lock TrueAltitude to Altitude - (ShipHeight + ExtraAlt + 5 + MAX(LandingPad:TerrainHeight, 0)). }
  Set ShipHeight to GetShipHeight(Ship). Lock TrueRadar to Ship:GeoPosition:Distance - ShipHeight. Set BurnAlt to 0. Set IdealThrottle to 0. Set PrepSBurn to False.
  If BRAKES_ON = "Yes" Brakes On. If GEAR_ON = "Yes" { When Addons:TR:TimeTillImpact < GEAR_ON_Time Then { Gear On. }}

  If LMODE = "Engine" { Set Mode to "Ballistic Drop". PrintInfo(CurrentMode).
    Until VerticalSpeed > -5 { PrintInfo().
      If SBurning = False {
        Set BurnAlt to ABS(MaxVertDecel() + Efficiency).
        If TrueAltitude < BurnAlt + 500 { Set PrepSBurn to True. InitSteeringPIDs(30). Lock Steering to Heading(SteeringDir, SteeringPitch). }
        If TrueAltitude < BurnAlt and IdealThrottle >= 1 { Set SBurning to True. Set Efficiency to 0. Lock Throttle to IdealThrottle. Set Mode to "Suicide burn". }
      } Set IdealThrottle to ABS(MaxVertDecel() / (TrueAltitude - Efficiency)).
      If SBurning = False and PrepSBurn = False and GroundSpeed < 500 {
        //---------------------------------------------------------------
        Set MaxAngle to 40.  // Maximum angle for GlidePath
        Set AngleMode to 0. // [0 for Pods], [-1 for Fuel Tanks]
        //---------------------------------------------------------------
        Set AdjustAngle to MIN((GeoPositionDistance(LandingPad, Addons:TR:ImpactPos) / 10) * 10, MaxAngle).
        Set LandingPadVect to (LandingPad:Position - Addons:TR:ImpactPos:Position):Normalized * AngleMode.
        Set RotateBy to MIN((LandingPad:Position - Addons:TR:ImpactPos:Position):MAG , AdjustAngle). Set SteeringVect to (Ship:Velocity:Surface * -1):Normalized * 40.
        Set LoopCount to 0. Until (RotateBy - VANG(SteeringVect, (Ship:Velocity:Surface * -1):Normalized)) < 3 {
          If VANG(SteeringVect, (Ship:Velocity:Surface * -1):Normalized) > RotateBy Break.
          Set LoopCount to LoopCount + 1. If LoopCount > 100 Break.
          Set SteeringVect to SteeringVect + LandingPadVect.
        } Lock Steering to SteeringVect:Direction.
      }
      If SBurning = True { SteeringPIDs(10). Set Throttle_PID to PIDLoop(0.3, 0.3, 0.005, 0, 1). }
    } Set Mode to "Landing". Lock Throttle to Throttle_PID:Update(Time:Seconds, VerticalSpeed). Set Throttle_PID:SetPoint to MIN(-(TrueRadar / 2), -1). If GeoPositionDistance(Ship:GeoPosition, LandingPad) > 5 InitSteeringPIDs(50, True).
    Until GeoPositionDistance(Ship:GeoPosition, LandingPad) < 2 and GroundSpeed < 2 { SteeringPIDs(10). If Altitude - (ShipHeight + ExtraAlt) < LandingPad:TerrainHeight + 5 { Set Throttle_PID:SetPoint to 1. } Else { Set Throttle_PID:SetPoint to 0. }}
    Until ShipStatus <> "Flying" { PrintInfo(). Set Throttle_PID:SetPoint to MIN(-(TrueRadar / 2), -2). } Set CurrentMode to "Landed". Set SubMode to "Landed".
  }

  If LMODE = "Chute" { Set Mode to "Ballistic Drop". PrintInfo(CurrentMode).
    Until ShipStatus <> "Flying" { PrintInfo().
      If TrueAltitude < 2500 { Set PrepSBurn to True. Lock Steering to SRFRetrograde. }
      If TrueAltitude < 2000 { Set SBurning to True. Unlock Steering. Set Mode to "Controlled descent". Chutes(True). }
      If SBurning = False and PrepSBurn = False and GroundSpeed < 500 {
        Set AdjustAngle to MIN((GeoPositionDistance(LandingPad, Addons:TR:ImpactPos) / 10) * 10, 70). Set AngleMode to 1.
        Set LandingPadVect to (LandingPad:Position - Addons:TR:ImpactPos:Position):Normalized * AngleMode.
        Set RotateBy to MIN((LandingPad:Position - Addons:TR:ImpactPos:Position):MAG , AdjustAngle). Set SteeringVect to (Ship:Velocity:Surface * -1):Normalized * 40.
        Set LoopCount to 0. Until (RotateBy - VANG(SteeringVect, (Ship:Velocity:Surface * -1):Normalized)) < 3 {
          If VANG(SteeringVect, (Ship:Velocity:Surface * -1):Normalized) > RotateBy Break.
          Set LoopCount to LoopCount + 1. If LoopCount > 100 Break.
          Set SteeringVect to SteeringVect + LandingPadVect.
        } Lock Steering to SteeringVect:Direction.
      } If TrueRadar < 10 Lock TrueAltitude to TrueRadar.
    }
  } Set CurrentMode to "Landed". Set SubMode to "Landed".
}

//// LANDED ////

If CurrentMode = "Landed" { PrintInfo(CurrentMode).
  If SubMode = "Landed" { Unlock Throttle. Unlock Steering. AG(lAG). SAS On. Wait 2. SAS Off. RCS Off.
    If lANTENNAS_ON  = "Yes"   { ANTENNAS On.     }
    If lLIGHTS_ON    = "Yes"   { LIGHTS On.       }
    If lSOLAR_ON     = "Yes"   { PANELS On.       }
    If lRADIATORS_ON = "Yes"   { RADIATORS On.    }
    If lLADDER_ON    = "Yes"   { LADDERS On.      }
    If lBRAKES_ON    = "Yes"   { BRAKES On.       }   Else   { BRAKES Off. }
    If lSAS_ON       = "Yes"   { SAS On.          }   Else   { SAS Off. }
    If lRCS_ON       = "Yes"   { RCS On.          }   Else   { RCS Off. }
    If lDRILLS_ON    = "Yes"   { DEPLOYDRILLS On. Set TimeExit to Time:Seconds + 5. If  ShowInfo = True Print "               (5) Deploying drills                " at (0, 20). Until False {
      If Round(TimeExit - Time:Seconds) < 6 and Round(TimeExit - Time:Seconds) > 0 and ShowInfo = True { Print Round(TimeExit - Time:Seconds) at (14, 20). } If TimeExit < Time:Seconds { Reboot. Break. }
    }}
  }
  Set TimeExit to Time:Seconds + 10. Until False {
    Print FormatDistance(Alt:Radar - ShipHeight, 1) + Spacer(FormatDistance(Alt:Radar - ShipHeight, 1):Length, 11) at (26, 5). If Addons:Biome:Available = True { Set IBiome to Addons:Biome:At(Ship:Body, Ship:GeoPosition). } Else { Set IBiome to "Unknow". } Print IBiome + Spacer(IBiome:Length, 17) at (21, 7).
    If Round(TimeExit - Time:Seconds) < 10 and Round(TimeExit - Time:Seconds) > 0 and ShowInfo = True { Print Round(TimeExit - Time:Seconds) at (14, 15). }
    If TimeExit < Time:Seconds { If Core:HasAction("Close Terminal") = True and ShowInfo = True { Core:DoAction("Close Terminal", True). } Reboot. Break. }
    If Terminal:Input:HasChar { Set ch to Terminal:Input:GetChar(). If ch = Terminal:Input:Enter { Reboot. Break. } If Terminal:Input:HasChar Terminal:Input:Clear. }
  }
}

//                                        .================.
//========================================| END OF PROGRAM |========================================
//                                        |================|

// .==============.
// | PRINT INFO A |
// |==============|

Function PrintInfoA { Parameter cMode is "". If ShowInfo = False Return 0.
  If CurrentMode = "Orbit" {
    If cMode <> "" { ClearScreen.
      Print "                      LANDER                       " at (0, 2).
      Print " .===============================================. " at (0, 4).
      Print " | Mode:                 | Apoapsis:             | " at (0, 5).
      Print " |-----------------------------------------------| " at (0, 6).
      Print " |                       | Periapsis:            | " at (0, 7).
      Print " |===============================================| " at (0, 8).
      Print "  By: Kobayashi " at (34, 34).
    }
    Print Mode + Spacer(Mode:Length, 15) at (9, 5).				
    Print FormatDistance(Apoapsis, 1) + Spacer(FormatDistance(Apoapsis, 1):Length, 10) at (38, 5).
    Print FormatDistance(Periapsis, 1) + Spacer(FormatDistance(Periapsis, 1):Length, 10) at (38, 7).

  } Else If CurrentMode = "Coast" { Local cStopDist to 0.
    If cMode <> "" { ClearScreen.
      Print "                      LANDER                       " at (0, 2).
      Print " .===============================================. " at (0, 4).
      Print " | Mode:                 | Altitude:             | " at (0, 5).
      Print " |-----------------------------------------------| " at (0, 6).
      Print " | Descending:           | H. Speed:             | " at (0, 7).
      Print " |===============================================| " at (0, 8).
      Print "  By: Kobayashi " at (34, 34).
    }

    //If AutoSlope = "No" {
      //Print "Braking in: " at (3, 7). Set StopDist to FormatDistance(MAX(Altitude - 15000, 0), 1).
    //} Else {
      //Print "Descending: " at (3, 7). Set StopDist to FormatDistance(MAX(Altitude - 15000, 0), 1).
    //}

    Print Mode + Spacer(Mode:Length, 15) at (9, 5).								Print FormatDistance(Altitude, 1) + Spacer(FormatDistance(Altitude, 1):Length, 8) at (38, 5).
    //Print StopDist + Spacer(StopDist:Length, 8) at (15, 7).							Print Round(GroundSpeed) + " m/s" + Spacer((Round(GroundSpeed) + " m/s"):Length, 8) at (38, 7).

  } Else If CurrentMode = "Aerobrake" { Local IBiome to "".
    If cMode <> "" { ClearScreen.
      Print "                      LANDER                       " at (0, 2).
      Print " .===============================================. " at (0, 4).
      Print " | Mode:                 | Altitude:             | " at (0, 5).
      Print " |-----------------------------------------------| " at (0, 6).
      Print " | Biome:                | H. Speed:             | " at (0, 7).
      Print " |===============================================| " at (0, 8).
      Print "  By: Kobayashi " at (34, 34).
    }

    If AutoSlope = "No" {
      If Addons:Biome:Available = True { Set IBiome to Addons:Biome:At(Ship:Body, Ship:GeoPosition). } Else { Set IBiome to "Unknow". }
      Print IBiome + Spacer(IBiome:Length, 13) at (10, 7).
    } Else {
      If Sloping = "Yes" {
        //Print "Slope:      " at (3, 7). Set StopDist to Round(cSlope, 1) + "º".
        //Print StopDist + Spacer(StopDist:Length, 8) at (15, 7).
        //Print  "Found landing point with slope of " + Round(SlopeAt(LandingPad, 3), 1) + "º    " at (6, 10).
      } Else If Sloping = "Brake"  {
        If Addons:Biome:Available = True { Set IBiome to Addons:Biome:At(Ship:Body, Ship:GeoPosition). } Else { Set IBiome to "Unknow". }
        Print IBiome + Spacer(IBiome:Length, 13) at (10, 7).
        //Print  "Found landing point with slope of " + Round(SlopeAt(LandingPad, 3), 1) + "º    " at (6, 10).
      }
    }

    Print Mode + Spacer(Mode:Length, 15) at (9, 5).								Print FormatDistance(Altitude, 1) + Spacer(FormatDistance(Altitude, 1):Length, 8) at (38, 5).
    							    							Print Round(GroundSpeed) + " m/s" + Spacer((Round(GroundSpeed) + " m/s"):Length, 8) at (38, 7).

  } Else If CurrentMode = "SBurn" { Local ABurn to 0. Local IBiome to "".
    If cMode <> "" { ClearScreen.
      Print "                      LANDER                       " at (0,  2).
      Print " .===============================================. " at (0,  4).
      Print " | Mode:                 | Altitude:             | " at (0,  5).
      Print " |-----------------------------------------------| " at (0,  6).
      Print " | Biome:                | H. Speed:             | " at (0,  7).
      Print " |-----------------------------------------------| " at (0,  8).
      Print " | SBurn in:             | V. Speed:             | " at (0,  9).
      Print " |===============================================| " at (0, 10).
      Print "  By: Kobayashi " at (34, 34).
    }

    If SBurning = False { Print "SBurn in:" at (3, 9). Set ABurn to FormatDistance(MAX(TrueAltitude - (BurnAlt), 0), 1). } Else { Print "Throttle:" at (3, 9). Set ABurn to MAX(MIN(Round(Throttle * 100), 100), 0) + "%". }
    If Addons:Biome:Available = True { Set IBiome to Addons:Biome:At(Ship:Body, Ship:GeoPosition). } Else { Set IBiome to "Unknow". }

    Print Mode + Spacer(Mode:Length, 15) at (9, 5).								Print FormatDistance(TrueAltitude, 1) + Spacer(FormatDistance(TrueAltitude, 1):Length, 8) at (38, 5).
    Print IBiome + Spacer(IBiome:Length, 13) at (10, 7).							Print Round(GroundSpeed) + " m/s" + Spacer((Round(GroundSpeed) + " m/s"):Length, 8) at (38, 7).
    Print ABurn + Spacer(ABurn:Length, 10) at (15, 9).								Print Round(VerticalSpeed) + " m/s" + Spacer((Round(VerticalSpeed) + " m/s"):Length, 8) at (38, 9).

    If AutoSlope = "Yes" Print  "Found landing point with slope of " + Round(SlopeAt(LandingPad, 3), 1) + "º    " at (6, 12).
  }
}

// .============.
// | PRINT INFO |
// |============|

Function PrintInfo { Parameter cMode is "". If ShowInfo = False Return 0.
  If CurrentMode = "Orbit" {
    If cMode <> "" { ClearScreen. Local DirectionAngle to 0. Local DeorbitDist to 0.
      Print "                      LANDER                       " at (0,  2).
      Print " .===============================================. " at (0,  4).
      Print " | Mode:                 | Apoapsis:             | " at (0,  5).
      Print " |-----------------------------------------------| " at (0,  6).
      Print " | Dir. Angle:           | Periapsis:            | " at (0,  7).
      Print " |-----------------------------------------------| " at (0,  8).
      Print " | Deorbit in:           | Pad Dist:             | " at (0,  9).
      Print " |===============================================| " at (0, 10).
      Print "  By: Kobayashi " at (34, 34).
    }
    If ApproachingLNG(Ship, LandingPad:LNG) = True {
     Set DeorbitIn to MAX(GeoPositionDistanceLNG(Ship:GeoPosition, LandingPad:LNG) - (((2 * Body:Radius) * Constant:PI) / 4), 0).
    } Else {
     Set DeorbitIn to MAX(((2 * Body:Radius) * Constant:PI) - ((((2 * Body:Radius) * Constant:PI) / 4) + GeoPositionDistanceLNG(Ship:GeoPosition, LandingPad:LNG)), 0).
    } If SBurning = True { Set DeorbitIn to "Now". } Else { Set DeorbitIn to FormatDistance(DeorbitIn). }
    If SubMode = "NewLandingPad" { Set DirectionAngle to Round(ABS(GetHeading() - GetHeading(NewLandingPad:Position)), 1) + "". } Else { Set DirectionAngle to Round(ABS(GetHeading() - GetHeading(LandingPad:Position)), 1) + "". }

    Print Mode + Spacer(Mode:Length, 15) at (9, 5).								Print FormatDistance(Apoapsis, 1) + Spacer(FormatDistance(Apoapsis, 1):Length, 10) at (38, 5).
    Print DirectionAngle + Spacer(DirectionAngle:Length, 4) at (17, 7).						Print FormatDistance(Periapsis, 1) + Spacer(FormatDistance(Periapsis, 1):Length, 10) at (38, 7).
    Print DeorbitIn + Spacer(DeorbitIn:Length, 7) at (17, 9).							Print FormatDistance(GeoPositionDistance(Ship:GeoPosition, LandingPad, Altitude), 1) + Spacer(FormatDistance(GeoPositionDistance(Ship:GeoPosition, LandingPad, Altitude), 1):Length, 10) at (38, 9).

  } Else If CurrentMode = "Coast" {
    If cMode <> "" { ClearScreen.
      Print "                      LANDER                       " at (0,  2).
      Print " .===============================================. " at (0,  4).
      Print " | Mode:                 | Altitude:             | " at (0,  5).
      Print " |-----------------------------------------------| " at (0,  6).
      Print " | Dir. Angle:           | H. Speed:             | " at (0,  7).
      Print " |-----------------------------------------------| " at (0,  8).
      Print " | Braking in:           | Pad Dist:             | " at (0,  9).
      Print " |===============================================| " at (0, 10).
      Print "  By: Kobayashi " at (34, 34).
    }
    Local DirectionAngle to Round(ABS(GetHeading() - GetHeading(LandingPad:Position))) + "".
    //Local StopDist to GeoPositionDistance(Ship:GeoPosition, LandingPad, Altitude) - StopDistance.
    Local PadDist to GeoPositionDistance(Ship:GeoPosition, LandingPad, Altitude).

    Print Mode + Spacer(Mode:Length, 15) at (9, 5).								Print FormatDistance(Altitude, 1) + Spacer(FormatDistance(Altitude, 1):Length, 8) at (38, 5).
    Print DirectionAngle + Spacer(DirectionAngle:Length, 4) at (17, 7).						Print Round(GroundSpeed) + " m/s" + Spacer((Round(GroundSpeed) + " m/s"):Length, 8) at (38, 7).
    //Print FormatDistance(StopDist, 1) + Spacer(FormatDistance(StopDist, 1):Length, 8) at (15, 9).		
    Print FormatDistance(PadDist, 1) + Spacer(FormatDistance(PadDist, 1):Length, 10) at (38, 9).

  } Else If CurrentMode = "Aerobrake" {
    If cMode <> "" { ClearScreen.
      Print "                      LANDER                       " at (0, 2).
      Print " .===============================================. " at (0, 4).
      Print " | Mode:                 | Altitude:             | " at (0, 5).
      Print " |-----------------------------------------------| " at (0, 6).
      Print " | Pad Dist:             | H. Speed:             | " at (0, 7).
      Print " |===============================================| " at (0, 8).
      Print "  By: Kobayashi " at (34, 34).
    }
    Local PadDist to GeoPositionDistance(Ship:GeoPosition, LandingPad, Altitude).

    Print Mode + Spacer(Mode:Length, 15) at (9, 5).								Print FormatDistance(Altitude, 1) + Spacer(FormatDistance(Altitude, 1):Length, 8) at (38, 5).
    Print FormatDistance(PadDist, 1) + Spacer(FormatDistance(PadDist, 1):Length, 10) at (15, 7). 		Print Round(GroundSpeed) + " m/s" + Spacer((Round(GroundSpeed) + " m/s"):Length, 8) at (38, 7).

  } Else If CurrentMode = "SBurn" { Local ABurn to 0.
    If cMode <> "" { ClearScreen.
      Print "                      LANDER                       " at (0,  2).
      Print " .===============================================. " at (0,  4).
      Print " | Mode:                 | Altitude:             | " at (0,  5).
      Print " |-----------------------------------------------| " at (0,  6).
      Print " | Pad Dist:             | H. Speed:             | " at (0,  7).
      Print " |-----------------------------------------------| " at (0,  8).
      Print " | SBurn in:             | V. Speed:             | " at (0,  9).
      Print " |===============================================| " at (0, 10).
      Print "  By: Kobayashi " at (34, 34).
    }
    If SBurning = False { Print "SBurn in:" at (3, 9). Set ABurn to FormatDistance(MAX(TrueAltitude - BurnAlt, 0), 1). } Else { Print "Throttle:" at (3, 9). Set ABurn to MAX(MIN(Round(Throttle * 100), 100), 0) + "%". }
    Local PadDist to GeoPositionDistance(Ship:GeoPosition, LandingPad, Altitude).

    Print Mode + Spacer(Mode:Length, 15) at (9, 5).								Print FormatDistance(TrueAltitude, 1) + Spacer(FormatDistance(TrueAltitude, 1):Length, 8) at (38, 5).
    Print FormatDistance(PadDist, 1) + Spacer(FormatDistance(PadDist, 1):Length, 10) at (15, 7). 		Print Round(GroundSpeed) + " m/s" + Spacer((Round(GroundSpeed) + " m/s"):Length, 8) at (38, 7).
    Print ABurn + Spacer(ABurn:Length, 10) at (15, 9). 								Print Round(VerticalSpeed) + " m/s" + Spacer((Round(VerticalSpeed) + " m/s"):Length, 8) at (38, 9).

  } Else If CurrentMode = "Landed" {
    If cMode <> "" { ClearScreen.
      Print "                       LANDER                      " at (0,  2).
      Print "            .=========================.            " at (0,  4).
      Print "            | Altitude:               |            " at (0,  5).
      Print "            |-------------------------|            " at (0,  6).
      Print "            | Biome:                  |            " at (0,  7).
      Print "            |=========================|            " at (0,  8).
      Print "             (9) Press 'ENTER' to exit             " at (0, 15).
      Print "  By: Kobayashi " at (34, 34).
    }
  }
}

//                                        .===========.
//========================================| FUNCTIONS |========================================
//                                        |===========|

// .==========.
// | STEERING |
// |==========|

Function InitSteeringPIDs { Parameter MaxAngle is 50, RoadMode is False.
  If RoadMode = True {
    Set EastVelPID to PIDLoop(3, 0.01, 1, -MaxAngle, MaxAngle). Set EastPosPID to PIDLoop(1700, 0, 100, -30, 30). Set EastPosPID:SetPoint to LandingPad:LNG.
    Set NorthVelPID to PIDLoop(3, 0.01, 1, -MaxAngle, MaxAngle). Set NorthPosPID to PIDLoop(1700, 0, 100, -30, 30). Set NorthPosPID:SetPoint to LandingPad:LAT.
  } Else {
    Set EastVelPID to PIDLoop(2, 0.01, 1, -MaxAngle, MaxAngle). Set EastPosPID to PIDLoop(4500, 0, 100, -30, 30). Set EastPosPID:SetPoint to LandingPad:LNG.
    Set NorthVelPID to PIDLoop(2, 0.01, 1, -MaxAngle, MaxAngle). Set NorthPosPID to PIDLoop(4500, 0, 100, -30, 30). Set NorthPosPID:SetPoint to LandingPad:LAT.
  }
  Set SteeringPitch to 90. Set SteeringDir to 0.
}

Function SteeringPIDs { Parameter MaxSpeed is 80.
  Local NorthVec is Ship:North:ForeVector. Local UpVec is Ship:Up:Vector. Local EastVec is VCRS(UpVec, NorthVec).
  Local NorthSpeed is VDOT(NorthVec, Ship:Velocity:Surface). Local UpSpeed is VDOT(UpVec, Ship:Velocity:Surface). Local EastSpeed is VDOT(EastVec, Ship:Velocity:Surface).
  Set GSVectorCached to V(EastSpeed, UpSpeed, NorthSpeed).

  Local DistLAT to GeoPositionDistanceLAT(Ship:GeoPosition, LandingPad:LAT). Local DistLNG to GeoPositionDistanceLNG(Ship:GeoPosition, LandingPad:LNG). Set OtherSpeed to 0.
  If DistLAT >= DistLNG { Set OtherSpeed to (DistLNG * MaxSpeed) / DistLAT. Set NorthPosPID:MINOUTPUT to -MaxSpeed. Set NorthPosPID:MAXOUTPUT to MaxSpeed. Set EastPosPID:MINOUTPUT to -OtherSpeed. Set EastPosPID:MAXOUTPUT to OtherSpeed.
  } Else { Set OtherSpeed to (DistLAT * MaxSpeed) / DistLNG. Set NorthPosPID:MINOUTPUT to -OtherSpeed. Set NorthPosPID:MAXOUTPUT to OtherSpeed. Set EastPosPID:MINOUTPUT to -MaxSpeed. Set EastPosPID:MAXOUTPUT to MaxSpeed. }

  Set EastVelPID:SetPoint to EastPosPID:Update (Time:Seconds, Ship:GeoPosition:LNG). Local EastVelPIDOut is EastVelPID:Update (Time:Seconds, GSVectorCached:X).
  Set NorthVelPID:SetPoint to NorthPosPID:Update (Time:Seconds, Ship:GeoPosition:LAT). Local NorthVelPIDOut is NorthVelPID:Update (Time:Seconds, GSVectorCached:Z).
  Local SteeringDirNonNorm is ArcTan2(EastVelPID:Output, NorthVelPID:Output). If SteeringDirNonNorm >= 0 { Set SteeringDir to SteeringDirNonNorm. } Else { Set SteeringDir to 360 + SteeringDirNonNorm. }
  Set SteeringPitch to 90 - Max(ABS(EastVelPIDOut), ABS(NorthVelPIDOut)).
}

// .========================.
// | FORMAT DISTANCE / TIME |
// |========================|

Function FormatDistance { Parameter Value, Decimals is 0.
  If Value < 1000 { Return Max(Round(Value), 0) + " m.".
  } Else If Value < 100000 {
    Local Result to Max(Round(Value / 1000, Decimals), 0) + "".
    If Decimals > 0 { If Result:Contains(".") = False { Return Result + "." + "0000000000":SubString(0, Decimals) + " km.". } Else { Return Result + " km.". }} Else { Return Result + " km.". }
  } Else { Return Max(Round(Value / 1000), 0) + " km.". }
}

Function FormatTime { Parameter PSeconds. Parameter Parentesis is True. Parameter NoNegative is False. If NoNegative = True and PSeconds < 0 Set PSeconds to 0.
  Set d to Floor(PSeconds / 21600). Set h to Floor((PSeconds - 21600 * d) / 3600). Set m to Floor((PSeconds - 3600 * h - 21600 * d) / 60).
  If m < 10 { Set sm to "0" + m. } Else { Set sm to m. } Set s to Round(PSeconds) - m * 60 - h * 3600 - 21600 * d. If s < 10 { Set ss to "0" + s. } Else { Set ss to s. }
  If d = 1 { Set fdays to d + " day - ". } Else { Set fdays to d + " days - ". } Set h to h + ((d * 21600) / 3600). Set d to 0.
  If Parentesis = True { If d = 0 { Return "(" + h + ":" + sm + ":" + ss + ")". } Else { Return "(" + fdays + h + ":" + sm + ":" + ss + ")". }} Else { If d = 0 { Return h + ":" + sm + ":" + ss. } Else { Return fdays + h + ":" + sm + ":" + ss. }}
}

// .=========.
// | GET TWR |
// |=========|

Function GetTWR {
  Parameter Mode is "CUR". Parameter Numeric is False. Parameter cAlt is Ship:Altitude.	// "CUR" -> Current | "MAX" -> Maximum | [Number] -> Set TWR
  If Mode = "CUR" or Mode = "MAX" {
    Set mThrust to 0. Set cThrust to 0.
    List Engines in EngList.
    For Eng in EngList {
      Set cThrust to cThrust + Eng:Thrust.
      If Eng:Ignition = True and Eng:Flameout = False Set mThrust to mThrust + Eng:MaxThrust * (Eng:ThrustLimit / 100).
    }
    If Numeric = True {
      Set cThrust to Round(cThrust / ((Ship:Body:MU / (Ship:Body:Radius + cAlt)^2) * Ship:Mass), 2).
      Set mThrust to Round(mThrust / ((Ship:Body:MU / (Ship:Body:Radius + cAlt)^2) * Ship:Mass), 2).
    } Else {
      Set cThrust to Round(cThrust / ((Ship:Body:MU / (Ship:Body:Radius + cAlt)^2) * Ship:Mass), 2) + "". If cThrust:Length = 3 Set cThrust to cThrust + "0". If cThrust:Length = 1 Set cThrust to cThrust + ".00".
      Set mThrust to Round(mThrust / ((Ship:Body:MU / (Ship:Body:Radius + cAlt)^2) * Ship:Mass), 2) + "". If mThrust:Length = 3 Set mThrust to mThrust + "0". If mThrust:Length = 1 Set mThrust to mThrust + ".00".
    } If Mode = "CUR" Return cThrust. If Mode = "MAX" Return mThrust.
  } Else { Return (Mode * (Constant:G * ((Mass * Body:Mass) / ((cAlt + Body:Radius)^2)))) / (AvailableThrust + 0.001). }
}

// .=============.
// | SHIP HEIGHT |
// |=============|

Function GetShipHeight { Parameter cVessel. Set LowestPart to 0. Set HighestPart to 0. Lock R3 to cVessel:Facing:ForeVector. Set PartList to cVessel:Parts.
  For Part in PartList{ Set V to Part:Position. Set CurrentPart to R3:X * V:X + R3:Y * V:Y + R3:Z * V:Z. If CurrentPart > HighestPart Set HighestPart to CurrentPart. Else If CurrentPart < LowestPart Set LowestPart to CurrentPart. }
  Return HighestPart - LowestPart.
}

// .========.
// | CHUTES |
// |========|

Function Chutes { Parameter Action is "True", IgnoreTag is "Ignore".
  If Action = "True" {
    List Parts in PartList. For Part in PartList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "RealChuteFAR" { If Part:GetModule("RealChuteFAR"):HasAction("Arm Parachute") = True Part:GetModule("RealChuteFAR"):DoAction("Arm Parachute", True). } If Module = "RealChuteModule" { If Part:GetModule("RealChuteModule"):HasAction("Arm Parachute") = True Part:GetModule("RealChuteModule"):DoAction("Arm Parachute", True). }}}
    List Parts in PartList. For Part in PartList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "RealChuteFAR" { If Part:GetModule("RealChuteFAR"):HasAction("Deploy Chute") = True Part:GetModule("RealChuteFAR"):DoAction("Deploy Chute", True). } If Module = "RealChuteModule" { If Part:GetModule("RealChuteModule"):HasAction("Deploy Chute") = True Part:GetModule("RealChuteModule"):DoAction("Deploy Chute", True). }}}
  } Else If Action = "False" {
    List Parts in PartList. For Part in PartList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "RealChuteFAR" { If Part:GetModule("RealChuteFAR"):HasAction("Disarm Parachute") = True Part:GetModule("RealChuteFAR"):DoAction("Disarm Parachute", True). } If Module = "RealChuteModule" { If Part:GetModule("RealChuteModule"):HasAction("Disarm Parachute") = True Part:GetModule("RealChuteModule"):DoAction("Disarm Parachute", True). }}}
    List Parts in PartList. For Part in PartList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "RealChuteFAR" { If Part:GetModule("RealChuteFAR"):HasAction("Disarm chute") = True Part:GetModule("RealChuteFAR"):DoAction("Disarm chute", True). } If Module = "RealChuteModule" { If Part:GetModule("RealChuteModule"):HasAction("Disarm chute") = True Part:GetModule("RealChuteModule"):DoAction("Disarm chute", True). }}}
  } Else If Action = "Exist" {
    List Parts in PartList. For Part in PartList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "RealChuteModule" or Module = "RealChuteFAR" Return True. }} Return False.
  } Else If Action = "Deployed" {
    List Parts in PartList. For Part in PartList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "RealChuteModule" If Part:GetModule("RealChuteModule"):HasEvent("Cut Chute") = True Return True. If Module = "RealChuteFAR" If Part:GetModule("RealChuteFAR"):HasEvent("Cut Chute") = True Return True.  }} Return False.
  }
}

// .==============.
// | PREPARE SHIP |
// |==============|

Function PrepareShip { Parameter Name, cMode, IgnoreTag is "Ignore".
  If Name = "All" {
    PrepareShip("Solar", cMode, IgnoreTag). PrepareShip("Radiator", cMode, IgnoreTag). PrepareShip("Antenna", cMode, IgnoreTag).
  } Else If cMode = True {
    If Name = "Solar" { List Parts in PartsList. For Part in PartsList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "ModuleDeployableSolarPanel" { If Part:GetModule("ModuleDeployableSolarPanel"):HasEvent("Extend Solar Panel") = True Part:GetModule("ModuleDeployableSolarPanel"):DoEvent("Extend Solar Panel"). }}}}
    If Name = "Solar" { List Parts in PartsList. For Part in PartsList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "ModuleCurvedSolarPanel" { If Part:GetModule("ModuleCurvedSolarPanel"):HasEvent("Deploy Panels") = True Part:GetModule("ModuleCurvedSolarPanel"):DoEvent("Deploy Panels"). }}}}
    If Name = "Radiator" { List Parts in PartsList. For Part in PartsList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "ModuleDeployableRadiator" { If Part:GetModule("ModuleDeployableRadiator"):HasEvent("Extend Radiator") = True Part:GetModule("ModuleDeployableRadiator"):DoEvent("Extend Radiator"). }}}}
    If Name = "Antenna" { List Parts in PartsList. For Part in PartsList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "ModuleRTAntenna" { If Part:GetModule("ModuleRTAntenna"):HasEvent("Activate") = True Part:GetModule("ModuleRTAntenna"):DoEvent("Activate"). }}}}
  } Else If cMode = False {
    If Name = "Solar" { List Parts in PartsList. For Part in PartsList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "ModuleDeployableSolarPanel" { If Part:GetModule("ModuleDeployableSolarPanel"):HasEvent("Retract Solar Panel") = True Part:GetModule("ModuleDeployableSolarPanel"):DoEvent("Retract Solar Panel"). }}}}
    If Name = "Solar" { List Parts in PartsList. For Part in PartsList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "ModuleCurvedSolarPanel" { If Part:GetModule("ModuleCurvedSolarPanel"):HasEvent("Retract Panels") = True Part:GetModule("ModuleCurvedSolarPanel"):DoEvent("Retract Panels"). }}}}
    If Name = "Radiator" { List Parts in PartsList. For Part in PartsList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "ModuleDeployableRadiator" { If Part:GetModule("ModuleDeployableRadiator"):HasEvent("Retract Radiator") = True Part:GetModule("ModuleDeployableRadiator"):DoEvent("Retract Radiator"). }}}}
    If Name = "Antenna" { List Parts in PartsList. For Part in PartsList { Set isAntenna to False. Set CloseAntenna to False. If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "ModuleDeployableAntenna" or Module = "ModuleAnimateGeneric" Set CloseAntenna to True. If Module = "ModuleRTAntenna" Set isAntenna to True. } If isAntenna = True and CloseAntenna = True { If Part:GetModule("ModuleRTAntenna"):HasEvent("Deactivate") = True Part:GetModule("ModuleRTAntenna"):DoEvent("Deactivate"). }}}
  }
}

// .=======================.
// | GEO-POSITION DISTANCE |
// |=======================|

Function GeoPositionDistance { Parameter GeoPos1, GeoPos2, Alt is 0. Set Alt to Alt + Body:Radius.
  Local A is SIN((GeoPos1:LAT - GeoPos2:LAT) / 2)^2 + COS(GeoPos1:LAT) * COS(GeoPos2:LAT) * SIN((GeoPos1:LNG - GeoPos2:LNG) / 2)^2.
  Return Alt * Constant:PI * ArcTan2(SQRT(A), SQRT(1 - A)) / 90.
}
Function GeoPositionDistanceLNG { Parameter GeoPos1, GeoPosLNG, Alt is 0. Set Alt to Alt + Body:Radius.
  Local A is SIN((GeoPos1:LAT - GeoPos1:LAT) / 2)^2 + COS(GeoPos1:LAT) * COS(GeoPos1:LAT) * SIN((GeoPos1:LNG - GeoPosLNG) / 2)^2.
  Return Alt * Constant:PI * ArcTan2(SQRT(A), SQRT(1 - A)) / 90.
}
Function GeoPositionDistanceLAT { Parameter GeoPos1, GeoPosLAT, Alt is 0. Set Alt to Alt + Body:Radius.
  Local A is SIN((GeoPos1:LAT - GeoPosLAT) / 2)^2 + COS(GeoPos1:LAT) * COS(GeoPosLAT) * SIN((GeoPos1:LNG - GeoPos1:LNG) / 2)^2.
  Return Alt * Constant:PI * ArcTan2(SQRT(A), SQRT(1 - A)) / 90.
}
Function GeoDir { Parameter Geo1, Geo2. Return ArcTan2 (Geo1:LNG - Geo2:LNG, Geo1:LAT - Geo2:LAT). }

// .===================.
// | GEO-POSITION FROM |
// |===================|

Function GeoPositionFrom { Parameter GeoPos, cDistance, cBearing is Mod(360 - LatLng(90,0):Bearing, 360).
  Local Lat is ArcSin(Sin(GeoPos:Lat) * Cos((cDistance * 180) / (Body:Radius * Constant:PI)) + Cos(GeoPos:Lat) * Sin((cDistance * 180) / (Body:Radius * Constant:PI)) * Cos(cBearing)).
  Local Lng is 0. If ABS(Lat) <> 90 Local Lng is GeoPos:Lng + ArcTan2(Sin(cBearing) * Sin((cDistance * 180) / (Body:Radius * Constant:PI)) * Cos(GeoPos:Lat), Cos((cDistance * 180)/(Body:Radius * Constant:PI)) - Sin(GeoPos:Lat) * Sin(Lat)).
  Return LatLng(Lat, Lng).
}

// .======================.
// | GEO-POSITION BEARING |
// |======================|

Function GeoPositionBearing { Parameter GeoPos1, GeoPos2. Return ArcTan2(GeoPos1:LNG - GeoPos2:LNG, GeoPos1:LAT - GeoPos2:LAT). }

// .=============.
// | GET HEADING |
// |=============|

Function GetHeading { Parameter cVector is Ship:SRFPrograde:Vector.
  Return MOD(ArcTan2(VDot(Heading(90, 0):Vector, cVector), VDot(Heading(0, 0):Vector, cVector)) + 360, 360).
}

// .==========.
// | SLOPE AT |
// |==========|

Function SlopeAt { Parameter GeoPos is Ship:GeoPosition, Distance is 1.
  Local NorthVec is VXCL((GeoPos:Position - GeoPos:Body:Position):Normalized, LATLNG(90, 0):Position - GeoPos:Position):Normalized * Distance.
  Local EastVec is VCRS((GeoPos:Position - GeoPos:Body:Position):Normalized, NorthVec):Normalized * Distance.
  Local aPos is GeoPos:Body:GeoPositionOf(GeoPos:Position - NorthVec + EastVec):Position - GeoPos:Position.
  Local bPos is GeoPos:Body:GeoPositionOf(GeoPos:Position - NorthVec - EastVec):Position - GeoPos:Position.
  Local cPos is GeoPos:Body:GeoPositionOf(GeoPos:Position + NorthVec):Position - GeoPos:Position.
  Return VANG((GeoPos:Position - GeoPos:Body:Position):Normalized, VCRS(aPos - cPos, bPos - cPos):Normalized).
}

// .==============.
// | ACTION GROUP |
// |==============|

Function AG { Parameter Number, Action is "Toggle".
  If Number =  1 { If Action = "On" {  AG1 On. } Else If Action = "Off" {  AG1 Off. } Else If Action = "Toggle" { Set  AG1 to Not  AG1.  }}
  If Number =  2 { If Action = "On" {  AG2 On. } Else If Action = "Off" {  AG2 Off. } Else If Action = "Toggle" { Set  AG2 to Not  AG2.  }}
  If Number =  3 { If Action = "On" {  AG3 On. } Else If Action = "Off" {  AG3 Off. } Else If Action = "Toggle" { Set  AG3 to Not  AG3.  }}
  If Number =  4 { If Action = "On" {  AG4 On. } Else If Action = "Off" {  AG4 Off. } Else If Action = "Toggle" { Set  AG4 to Not  AG4.  }}
  If Number =  5 { If Action = "On" {  AG5 On. } Else If Action = "Off" {  AG5 Off. } Else If Action = "Toggle" { Set  AG5 to Not  AG5.  }}
  If Number =  6 { If Action = "On" {  AG6 On. } Else If Action = "Off" {  AG6 Off. } Else If Action = "Toggle" { Set  AG6 to Not  AG6.  }}
  If Number =  7 { If Action = "On" {  AG7 On. } Else If Action = "Off" {  AG7 Off. } Else If Action = "Toggle" { Set  AG7 to Not  AG7.  }}
  If Number =  8 { If Action = "On" {  AG8 On. } Else If Action = "Off" {  AG8 Off. } Else If Action = "Toggle" { Set  AG8 to Not  AG8.  }}
  If Number =  9 { If Action = "On" {  AG9 On. } Else If Action = "Off" {  AG9 Off. } Else If Action = "Toggle" { Set  AG9 to Not  AG9.  }}
  If Number = 10 { If Action = "On" { AG10 On. } Else If Action = "Off" { AG10 Off. } Else If Action = "Toggle" { Set AG10 to Not AG10.  }}
}

// .=========.
// | VARIOUS |
// |=========|

Function ApproachingLNG { Parameter Vessel, GeoPosLNG. If ABS(GetHeading() - GetHeading(LATLNG(Vessel:GeoPosition:LAT, GeoPosLNG):Position)) > 90 { Return False. } Else { Return True. }}
Function MaxVertDecel { If Velocity:Surface:MAG = 0 or AvailableThrust = 0 { Return 0. } Else { Return VerticalSpeed^2 / (2 * ((AvailableThrust / Mass) * (2 * (-VerticalSpeed / Velocity:Surface:MAG) + 1) / 3 - (Body:MU / Body:Radius^2))). }}
Function ShipStatus { Parameter cVessel is Ship. If cVessel:Status = "Landed" or cVessel:Status = "PreLaunch" { Return "Landed". } Else If cVessel:Status = "Splashed" { Return "Splashed". } Else { Return "Flying". }}
Function GetImpactTime { If VerticalSpeed < 0 { Return Round(ABS(TrueAltitude / VerticalSpeed)). } Else { Return 9999999. }}
Function GetStopDistance { Local cStopDistance to (((SIN(VANG(Ship:Up:Vector, Ship:Velocity:Surface * -1)) * AvailableThrust) / Mass) * ((GroundSpeed - SQRT(ABS(VerticalSpeed))) / ((SIN(VANG(Ship:Up:Vector, Ship:Velocity:Surface * -1)) * AvailableThrust) / Mass))^2) / 2. Return cStopDistance + (cStopDistance / 10). }
Function Spacer { Parameter StringLength, SpaceLength. Local Spaces is "                                                  ":Substring(0, Max(Min(SpaceLength, 50), 0)). If StringLength >= SpaceLength Return "". Return Spaces:Substring(StringLength, Spaces:Length - StringLength). }
Function HasEngines { Local NoEngines is True. List Engines in Engs. For Eng in Engs { If Eng:FlameOut = False { If Eng:Ignition = False and Eng:AllowRestart = True and Eng:Stage < Stage:Number Set NoEngines to False. }} Return Not NoEngines. }