#version 120

uniform sampler2D DiffuseSampler;
uniform vec2 InSize;
uniform vec2 OutSize;
uniform vec2 Amount;
uniform float ChunkSize;
uniform float Tolerance;

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
    vec4 outColor = vec4(0.0);
    vec2 pixCoord = texCoord * OutSize - 0.5;
    if (pixCoord.x < ceil(InSize.x * Amount.x) && pixCoord.y < ceil(InSize.y * Amount.y / ChunkSize)) {
        float oneSamp = 0.0;
        float agg = 0.0;
        float count = 0.0;
        for (int i = 0; i < ChunkSize; i += 1) {
            vec4 tmpCol = texture2D(DiffuseSampler, vec2(pixCoord.x * oneTexel.x, (pixCoord.y * ChunkSize + 0.5 + float(i)) * oneTexel.y));
            if (tmpCol.a > 0.0) {
                oneSamp = decodeInt(tmpCol.rgb);
                agg += oneSamp;
                count += 1.0;
            }
        }

        if (count > 0.0) {
            agg /= count;
            if (abs(agg - oneSamp) < Tolerance) {
                outColor = vec4(encodeInt(int(floor(agg + 0.5))), 1.0);
            }
        }
    }
    

    gl_FragColor = outColor;
}
