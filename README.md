
<div align="center">

![WIP](https://img.shields.io/badge/work%20in%20progress-yellow?style=for-the-badge)
![KerboScript](https://img.shields.io/badge/Kerbo%20Script-brown?style=for-the-badge)
![kOS](https://img.shields.io/badge/kOS-Autopilot-blue?style=for-the-badge)
![KSP](https://img.shields.io/badge/Kerbal-Space%20Program-orange?style=for-the-badge)

*Automated reentry and landing script*

</div>

<div align="center">
  <img src="/Reentry.png">
</div>

# Reentry

[README en Español](README_es.md)

`Reentry` is a deorbit and landing autopilot for `Kerbal Space Program` (KSP) written in `kOS` (Kerbal Operating System). It plans deorbit burns, uses `Trajectories` to correct impact points, and lands with either engine suicide burn or parachute mode.

`NOTES`: This README is only a template and does not represent the current state of the project. It is also not finished.

## ✨ Features

- `Deorbit Planning`: Aligns and burns to target a pad or coordinates
- `Trajectory Correction`: Uses Trajectories impact prediction during descent
- `Landing Modes`: Engine suicide burn or chute-assisted descent
- `Pad Selection`: Built-in pads, custom pads, targets, and waypoints
- `Auto-Slope`: Optional slope scan around the target
- `Automation`: Auto-warp, auto-stage, auto-retract, gear and brakes
- `Post-Landing Actions`: Toggle antennas, lights, solar, drills, SAS, and more

## 🖥️ Requirements

- `Kerbal Space Program` with `kOS mod` installed
- `Trajectories mod` (for accurate impact prediction)
- `Biome mod` (for biome information display. Optional)

## 🔧 Installation

1. Install `kOS` mod for Kerbal Space Program
2. Install `Trajectories` mod
3. Clone or download this repository
4. Copy all `.ks` files to your KSP `Ships/Script` folder or load them onto your craft's kOS processor

## 🎮 Usage

```kerboscript
run reentry.
```

### Parameters
1. `Pad` (string): Landing pad name, "Target", or "lat, lng"
2. `ShowInfo` (boolean): Show UI in the terminal
3. `ExtraAlt` (number): Extra altitude margin (m)
4. `Efficiency` (number): Suicide burn safety margin (0-1000)
5. `AutoSlope` (string): "Yes"/"No" slope scan
6. `MaxSlope` (number): Max slope allowed
7. `AutoWarp` (string): "Yes"/"No" auto warp
8. `AutoStage` (number): 0=Auto, 1=No, 2=Once
9. `AutoRetract` (string): "Yes"/"No" retract parts before reentry
10. `GEAR_ON` (string): "Yes"/"No" auto gear
11. `BRAKES_ON` (string): "Yes"/"No" auto brakes
12. `RCS_ON` (string): "Yes"/"No" auto RCS
13. `LMODE` (string): "Engine" or "Chute"

### Interactive Controls

- `Left/Right Arrow Keys`: Cycle pads
- `M`: Toggle landing mode (Engine/Chute)
- `A` / `Shift+A`: Adjust extra altitude
- `E` / `Shift+E`: Adjust efficiency
- `P`: Toggle auto-slope (only for Anywhere)
- `S`: Cycle auto-stage mode
- `R`, `G`, `B`: Toggle RCS, gear, brakes
- `W`, `T`: Toggle auto-warp and auto-retract
- `L`: Open landing settings
- `Enter`: Start

### Landing Settings

In the landing settings screen, use `1-0` to toggle antennas, lights, solar panels, drills, radiators, ladder, brakes, SAS, RCS, and an action group.

## ⚙️ Configuration

### Custom Pad List

Pads are stored in `Pads.ks` as triplets: name, coordinates, body name.

```kerboscript
cPads:Add("My Custom Pad").
cPads:Add("12.345678, -98.765432").
cPads:Add("Kerbin").
```

## 📚 Troubleshooting

### Trajectories Not Found
- Ensure the `Trajectories` mod is installed and active
- The script exits if `Trajectories` is not available

### No Pad Selected
- Use the menu to pick a pad or set a target/waypoint
- For free landing, choose `Anywhere`

## 📄 License

This project is licensed under the WTFPL – [Do What the Fuck You Want to Public License](http://www.wtfpl.net/about/).

---

<div align="center">

**🚀 Developed by Kobayashi82 🚀**

*"Lithobraking is NOT an option this time"*

</div>
