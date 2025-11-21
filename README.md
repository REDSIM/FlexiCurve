# FlexiCurve

This is a free open-source Unity asset for procedural generating curve-based meshes, such as fairy lights, garlands, wires, tinsels and more. This asset is perfect to decorate scenes without going to Blender or any other 3rd party software.

If you liked this asset, I would be very happy if you **[Support me on Patreon](https://www.patreon.com/red_sim/ "Support me on Patreon")**, there is a bunch of other cool assets you will get there.

If you want to buy extra FlexiCurve presets and support my work **[Check my Booth store.](https://redsim.booth.pm/)**

## Main features
- Creating fairy lights
- Creating wires or pipes
- Creating garlands
- Creating tinsel garlands
- Creating other curve-based meshes
- Free editing and placing curve points
- Scattering any mesh all over the wire and using it as light-bulbs
- Custom materials, custom light animations
- Wire shape customizing
- Baking lights with auto-generated lightmap UVs
- More features coming soon...

**Video showcase of this asset: [FlexiCurve Video Demo](https://www.youtube.com/watch?v=oX5XQQi6D1Y "FlexiCurve Video Demo")**

## Installation Through VRChat Creator Companion
1. Go to my VPM Listing web page: https://redsim.github.io/vpmlisting/
2. Press "Add to VCC"
3. Confirm adding in the popup dialog window
> [!WARNING]
> If it didn't work and you don't see a popup, try again, it's a VCC bug!
4. Add the package to your project by pressing "Manage Project" and selecting **FlexiCurve** there.

## Installation Through Unity Package Manager
1. On the top bar in Unity click `Window > Package Manager`
2. Click the `[+]` icon in the top left of the Package Manager window
3. Select "Add package from git URL..." in the dropdown menu
4. Paste this link: `https://github.com/REDSIM/flexicurve.git?path=/Packages/red.sim.flexicurve`
5. Press Enter on your keyboard or Click the "Add" button on the right side of the input field

## How to use this asset

1. Press right mouse button in hierarchy and choose "FlexiCurve Mesh"
2. In FlexiCurve component that was created, select and use a **Curve Preset** provided in the package.
> [!IMPORTANT]
> In the presets pop-up window, disable the "crossed eye" button at the right top to see the default presets that comes with this package! Otherwise, you'll only see the presets which are in your Assets folder.
3. **Ctrl+LMB adds or removes** a new curve point
4. **Ctrl+LMB also splits** a curve if you click at the sag control handle
> [!WARNING]
> Be sure that you have **gizmos shown** in editor, otherwise you'll not be able to see the gizmos and handles to edit the curve.

All generated meshes are stored in *Assets/FlexiCurveMeshes/*

Full FlexiCurve usage explained here: **[FlexiCurve video tutorial](https://www.youtube.com/watch?v=Fiy1kxU3ymo "Video tutorial")**

## Asset preview

This is not a skinned mesh made of bones or blend shapes, this is a static mesh, which can be batched, lightmapped and can only be changed in editor.

![](https://raw.githubusercontent.com/REDSIM/flexicurve/refs/heads/main/ReadmePreviews/preview0.webp)

You can use included presets or even create your own to fast switch between different types of fairy lights.

![](https://raw.githubusercontent.com/REDSIM/flexicurve/refs/heads/main/ReadmePreviews/preview1.webp)

You can fast add new points to curves by **LMB** clicking at the middle gizmo with the **Ctrl** button held, or fast remove points by clicking on existing ones with **Ctrl** button held too.

![](https://raw.githubusercontent.com/REDSIM/flexicurve/refs/heads/main/ReadmePreviews/preview2.webp)

You can fast snap new points to world geometry by **LMB** clicking with the **Ctrl** button held.

There are lots of ways to customize your procedural curve mesh, including direction randomizations, scales, offsets, decimation and more.

