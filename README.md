# FOV Finder
<img src="/images/2.png" alt="Image2"/>

## Overview
Vanilla shader that finds screen FOV and draw distance in realtime using MC's exposed transparency shaders. Requires "Fabulous" graphics setting. Supports FOV 14.0 - 150.0 and draw distances 4.0 - 32.0. The shader is more reliable at mid range FOV and draw distances. Extremes can produce inconsistent values. FOV is calculated using world tbn information and inferring orientations of faces of the diffuse target. Draw distance is calculated on a reactionary basis using the approximate standard deviation of calculated FOV on the screen.

### What it does:
- realtime screen FOV calculation pipeline using **no markers or other datapack aids**
- low performance impact
- no intrusion on lower graphics settings
- requires visible blocky terrain in `minecraft:main` target
- good for coarse FOV accurate to 0.1 degrees most of the time (use 0.5 degrees to be extra safe)
- very approximate draw distance (usually +- 2 chunks)

### What it does not do:
- guarantee correct FOV and draw distance in all senarios
- calculate FOV in void
- calculate FOV when orthogonal to two axes (generally one is okay)
- calculate FOV with excessive angled faces (screen full of tall grass, screen full of mobs, etc.)

### What is achievable:
<table>
  <tr>
    <th width="50%">
      <img src="/images/0.png" alt="Image1"/>
      FOV 70 with 16 chunks
    </th>
    <th width="50%">
      <img src="/images/1.gif" alt="Image2"/>
      FOV 90 with 16 chunks
    </th>
  </tr>
</table>

## Design and Performance
This shader is composed of multiple passes in three main stages: finding FOV at each pixel, filtering and condensing FOV information, correct distance for next frame. Good performance is achieved through downsampling FOV data and copying to 256x256 texture. This reduces memory and compute overhead vs dealing with full frames. On average, I reach around 165 FPS at 16 chunks render distance graphics maxed on GTX 1070.

## Usage
See License.md for license info. This utility is a resourcepack. Set to graphics Fabulous. No additional setup is required. This is a proof of concept and should rather be used in larger shader packs that require FOV information.

## Shading Passes and Descriptions
#### fov_calc
- Most of the magic happens here. Using world tbn and `minecraft:main` to calculate the focal distance of the camera. Focal distance can directly be translated to FOV given the screen size.
#### consensus0
- Removes outliers by searching the 8 surrounding pixels and removing the pixel if it is not within a tolerance of surrounding FOV pixels.
#### consensus1
- Removes incorrect FOV values from diagonals (grass, mobs ...) by sampling randomly and checking if FOV is majority. Also preforms a 2x downsample.
#### consensus2
- Horizontal downsample pass while still taking consensus. Scale can be specified.
#### consensus3
- Vertical downsample pass while still taking consensus. Scale can be specified.
#### consensus4
- Takes final consensus value and stores it in `temporal` targets.
#### dist_calc
- Takes random samples of FOV calculation and computes standard deviation. This value coupled with deviation from the previous frame can be used to find which direction to search draw distances.
#### textoverlay
- Apply text overlay for convenience. Not actually needed for shader to function.
#### transparency
- Vanilla transparency.


## Credits
- big brain math by me
