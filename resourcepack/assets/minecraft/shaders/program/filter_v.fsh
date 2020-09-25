#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D CentersSampler;

varying vec2 texCoord;

#define NEAR 0.1 
#define FAR 1000.0

void main() {
    vec4 candidate = texture2D(DiffuseSampler, texCoord);

    if (candidate == vec4(0.0, 0.0, 0.0, 1.0)) {
        candidate = vec4(0.0);
    }

    gl_FragColor = candidate;
}