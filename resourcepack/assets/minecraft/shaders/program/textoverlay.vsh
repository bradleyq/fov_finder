#version 110

attribute vec4 Position;

uniform mat4 ProjMat;
uniform vec2 InSize;
uniform vec2 FontDim;

varying vec2 texCoord;
varying vec2 oneTexel;
varying float aspectRatio;
varying float fontAspectRatio;

void main(){
    vec4 outPos = ProjMat * vec4(Position.xy, 0.0, 1.0);
    gl_Position = vec4(outPos.xy, 0.2, 1.0);

    oneTexel = 1.0 / InSize;
    aspectRatio = InSize.x / InSize.y;
    fontAspectRatio = FontDim.x / FontDim.y;
    texCoord = outPos.xy * 0.5 + 0.5;
}
