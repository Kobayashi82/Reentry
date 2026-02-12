
<div align="center">

![WIP](https://img.shields.io/badge/work%20in%20progress-yellow?style=for-the-badge)
![KerboScript](https://img.shields.io/badge/Kerbo%20Script-brown?style=for-the-badge)
![kOS](https://img.shields.io/badge/kOS-Autopilot-blue?style=for-the-badge)
![KSP](https://img.shields.io/badge/Kerbal-Space%20Program-orange?style=for-the-badge)

*Script de reentrada y aterrizaje automatizado*

</div>

<div align="center">
  <img src="/images/W_Reentry.jpg">
</div>

# Reentry

[README in English](README.md)

`Reentry` es un piloto automatico de deorbitado y aterrizaje para `Kerbal Space Program` (KSP) escrito en `kOS` (Kerbal Operating System). Planifica la maniobra de reentrada, corrige el punto de impacto con `Trajectories` y aterriza con motor o paracaidas.

`NOTAS`: Este README es solo una plantilla y no representa el estado actual del proyecto. Además, no está terminado.

## ✨ Caracteristicas

- `Plan de deorbitado`: Alinea y quema hacia una plataforma o coordenadas
- `Correccion de trayectoria`: Usa Trajectories durante el descenso
- `Modos de aterrizaje`: Suicide burn con motor o descenso con paracaidas
- `Seleccion de plataforma`: Pads integrados, personalizados, objetivos y waypoints
- `Auto-Slope`: Busqueda opcional de pendiente segura
- `Automatizacion`: Auto-warp, auto-stage, auto-retract, tren y frenos
- `Acciones post-aterrizaje`: Antenas, luces, paneles, drills, SAS y mas

## 🖥️ Requisitos

- `Kerbal Space Program` con `mod kOS` instalado
- `Mod Trajectories` (para predicción precisa de impacto)
- `Mod de Biomas` (para mostrar información de biomas. Opcional)

## 🔧 Instalacion

1. Instala el mod `kOS` para Kerbal Space Program
2. Instala el mod `Trajectories`
3. Clona o descarga este repositorio
4. Copia todos los archivos `.ks` a tu carpeta `Ships/Script` de KSP o cargalos en el procesador kOS de tu nave

## 🎮 Uso

```kerboscript
run reentry.
```

### Parametros
1. `Pad` (string): Nombre de plataforma, "Target" o "lat, lng"
2. `ShowInfo` (boolean): Mostrar UI en el terminal
3. `ExtraAlt` (number): Margen de altitud extra (m)
4. `Efficiency` (number): Margen de seguridad del burn (0-1000)
5. `AutoSlope` (string): "Yes"/"No" para pendiente
6. `MaxSlope` (number): Pendiente maxima permitida
7. `AutoWarp` (string): "Yes"/"No" auto warp
8. `AutoStage` (number): 0=Auto, 1=No, 2=Once
9. `AutoRetract` (string): "Yes"/"No" retraer piezas
10. `GEAR_ON` (string): "Yes"/"No" tren automatico
11. `BRAKES_ON` (string): "Yes"/"No" frenos automaticos
12. `RCS_ON` (string): "Yes"/"No" RCS automatico
13. `LMODE` (string): "Engine" o "Chute"

### Controles interactivos

- `Flechas Izquierda/Derecha`: Cambiar plataforma
- `M`: Alternar modo (Engine/Chute)
- `A` / `Shift+A`: Ajustar altitud extra
- `E` / `Shift+E`: Ajustar eficiencia
- `P`: Alternar auto-slope (solo en Anywhere)
- `S`: Cambiar modo de auto-stage
- `R`, `G`, `B`: Alternar RCS, tren, frenos
- `W`, `T`: Alternar auto-warp y auto-retract
- `L`: Abrir ajustes de aterrizaje
- `Enter`: Iniciar

### Ajustes de aterrizaje

En la pantalla de ajustes, usa `1-0` para alternar antenas, luces, paneles, drills, radiadores, escalera, frenos, SAS, RCS y un action group.

## ⚙️ Configuracion

### Lista de plataformas personalizadas

Las plataformas se guardan en `Pads.ks` como tripletas: nombre, coordenadas, cuerpo.

```kerboscript
cPads:Add("My Custom Pad").
cPads:Add("12.345678, -98.765432").
cPads:Add("Kerbin").
```

## 📚 Solucion de problemas

### Trajectories no encontrado
- Asegurate de que el mod `Trajectories` este instalado y activo
- El script se cierra si `Trajectories` no esta disponible

### No hay plataforma seleccionada
- Usa el menu para elegir una plataforma o un objetivo/waypoint
- Para aterrizaje libre, elige `Anywhere`

## 📄 Licencia

Este proyecto esta licenciado bajo la WTFPL – [Do What the Fuck You Want to Public License](http://www.wtfpl.net/about/).

---

<div align="center">

**🚀 Desarrollado por Kobayashi82 🚀**

*"Lithobraking is NOT an option this time"*

</div>
