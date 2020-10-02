#version 120

uniform sampler2D DiffuseSampler;
uniform sampler2D FOVSampler;
uniform float Smoothing;

varying vec2 texCoord;
varying vec2 oneTexel;

int intmod(int i, int base) {
    return i - (i / base * base);
}

vec3 encodeInt(int i) {
    int r = intmod(i, 255);
    i = i / 255;
    int g = intmod(i, 255);
    i = i / 255;
    int b = intmod(i, 255);
    return vec3(float(r) / 255.0, float(g) / 255.0, float(b) / 255.0);
}

int decodeInt(vec3 ivec) {
    ivec *= 255.0;
    int num = 0;
    num += int(ivec.r);
    num += int(ivec.g) * 255;
    num += int(ivec.b) * 255 * 255;
    return num;
}

void main() {
    vec4 outColor = texture2D(DiffuseSampler, texCoord);
    if (texCoord.x < 0.2) {
        float oldFOV = float(decodeInt(outColor.rgb));
        vec4 tmpColor = texture2D(FOVSampler, vec2(0.0));
        if (tmpColor.a > 0.0) {
            float newFOV = float(decodeInt(tmpColor.rgb));
            outColor = vec4(encodeInt(int(floor(mix(newFOV, oldFOV, float(texCoord.x > 0.1) * Smoothing * float(abs(newFOV - oldFOV) < 100.0)) + 0.5))), 1.0);
        }
        
    }
    
    gl_FragColor = outColor;
}
