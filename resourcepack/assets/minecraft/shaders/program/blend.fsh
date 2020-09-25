#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseSampler2;

varying vec2 texCoord;
varying vec2 oneTexel;


void main() {
    vec4 outColor = texture2D(DiffuseSampler, texCoord);
    outColor = mix(outColor, texture2D(DiffuseSampler2, texCoord), 0.5);

    gl_FragColor = outColor;
}