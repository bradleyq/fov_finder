#version 120

uniform sampler2D DiffuseSampler;
uniform sampler2D FOVSampler;
uniform vec2 Amount;
uniform float Smoothing;

varying vec2 texCoord;

#define STEP 128.0 
#define MAXDIST 32.0
#define MINDIST 4.0
#define DEFAULTDIST 12.0
#define STDMIN 1.2
#define STDTOL 0.3
#define TAPS 128
#define MINTAPS 32
#define INERTIA 0.0
#define BIG 100000.0


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
    vec2 poissonDisk[64];
    poissonDisk[0] = vec2(-0.613392, 0.617481);
    poissonDisk[1] = vec2(0.170019, -0.040254);
    poissonDisk[2] = vec2(-0.299417, 0.791925);
    poissonDisk[3] = vec2(0.645680, 0.493210);
    poissonDisk[4] = vec2(-0.651784, 0.717887);
    poissonDisk[5] = vec2(0.421003, 0.027070);
    poissonDisk[6] = vec2(-0.817194, -0.271096);
    poissonDisk[7] = vec2(-0.705374, -0.668203);
    poissonDisk[8] = vec2(0.977050, -0.108615);
    poissonDisk[9] = vec2(0.063326, 0.142369);
    poissonDisk[10] = vec2(0.203528, 0.214331);
    poissonDisk[11] = vec2(-0.667531, 0.326090);
    poissonDisk[12] = vec2(-0.098422, -0.295755);
    poissonDisk[13] = vec2(-0.885922, 0.215369);
    poissonDisk[14] = vec2(0.566637, 0.605213);
    poissonDisk[15] = vec2(0.039766, -0.396100);
    poissonDisk[16] = vec2(0.751946, 0.453352);
    poissonDisk[17] = vec2(0.078707, -0.715323);
    poissonDisk[18] = vec2(-0.075838, -0.529344);
    poissonDisk[19] = vec2(0.724479, -0.580798);
    poissonDisk[20] = vec2(0.222999, -0.215125);
    poissonDisk[21] = vec2(-0.467574, -0.405438);
    poissonDisk[22] = vec2(-0.248268, -0.814753);
    poissonDisk[23] = vec2(0.354411, -0.887570);
    poissonDisk[24] = vec2(0.175817, 0.382366);
    poissonDisk[25] = vec2(0.487472, -0.063082);
    poissonDisk[26] = vec2(-0.084078, 0.898312);
    poissonDisk[27] = vec2(0.488876, -0.783441);
    poissonDisk[28] = vec2(0.470016, 0.217933);
    poissonDisk[29] = vec2(-0.696890, -0.549791);
    poissonDisk[30] = vec2(-0.149693, 0.605762);
    poissonDisk[31] = vec2(0.034211, 0.979980);
    poissonDisk[32] = vec2(0.503098, -0.308878);
    poissonDisk[33] = vec2(-0.016205, -0.872921);
    poissonDisk[34] = vec2(0.385784, -0.393902);
    poissonDisk[35] = vec2(-0.146886, -0.859249);
    poissonDisk[36] = vec2(0.643361, 0.164098);
    poissonDisk[37] = vec2(0.634388, -0.049471);
    poissonDisk[38] = vec2(-0.688894, 0.007843);
    poissonDisk[39] = vec2(0.464034, -0.188818);
    poissonDisk[40] = vec2(-0.440840, 0.137486);
    poissonDisk[41] = vec2(0.364483, 0.511704);
    poissonDisk[42] = vec2(0.034028, 0.325968);
    poissonDisk[43] = vec2(0.099094, -0.308023);
    poissonDisk[44] = vec2(0.693960, -0.366253);
    poissonDisk[45] = vec2(0.678884, -0.204688);
    poissonDisk[46] = vec2(0.001801, 0.780328);
    poissonDisk[47] = vec2(0.145177, -0.898984);
    poissonDisk[48] = vec2(0.062655, -0.611866);
    poissonDisk[49] = vec2(0.315226, -0.604297);
    poissonDisk[50] = vec2(-0.780145, 0.486251);
    poissonDisk[51] = vec2(-0.371868, 0.882138);
    poissonDisk[52] = vec2(0.200476, 0.494430);
    poissonDisk[53] = vec2(-0.494552, -0.711051);
    poissonDisk[54] = vec2(0.612476, 0.705252);
    poissonDisk[55] = vec2(-0.578845, -0.768792);
    poissonDisk[56] = vec2(-0.772454, -0.090976);
    poissonDisk[57] = vec2(0.504440, 0.372295);
    poissonDisk[58] = vec2(0.155736, 0.065157);
    poissonDisk[59] = vec2(0.391522, 0.849605);
    poissonDisk[60] = vec2(-0.620106, -0.328104);
    poissonDisk[61] = vec2(0.789239, -0.419965);
    poissonDisk[62] = vec2(-0.545396, 0.538133);
    poissonDisk[63] = vec2(-0.178564, -0.596057);

    vec4 outColor = texture2D(DiffuseSampler, texCoord);


    if (texCoord.x > 0.2) {
        float fovAvg = float(decodeInt(texture2D(DiffuseSampler, vec2(0.05, 0.5)).rgb));

        vec4 distVec = texture2D(DiffuseSampler, vec2(0.25, 0.5));

        float fovDist = float(decodeInt(distVec.rgb));
        float fovStdL = float(decodeInt(texture2D(DiffuseSampler, vec2(0.45, 0.5)).rgb));
        float fovDir = float(texture2D(DiffuseSampler, vec2(0.55, 0.5)).r);

        if (distVec.a != 1.0 || fovDist > MAXDIST || fovDist < MINDIST) {
            fovStdL = BIG;
            fovDir = 1.0;
        }
        
        float fovStd = 0.0;
        float count = 0.0;
        for (int i = 0; i < TAPS; i += 1) {
            vec2 psample = i > 64 ? poissonDisk[i - 64].yx : poissonDisk[i]; 
            vec4 tmp = texture2D(FOVSampler, (0.5 * psample + 0.5) * Amount * vec2(1.0, 0.7));
            if (tmp.a > 0.0) {
                float delta = (float(decodeInt(tmp.rgb)) - fovAvg)/ 100.0;
                if (delta > -5.0 && delta < 5.0) {
                    fovStd += pow(delta, 2.0);
                    count += 1.0;
                }
            }
        }
        if (count > MINTAPS) {
            fovStd = pow(fovStd / count, 0.5) * 100.0;
        } else {
            fovStd = fovStdL;
        }

        if (fovStd <= STDMIN + INERTIA && fovStdL <= STDMIN) {
            fovStd = STDMIN;
        }

        if (fovStd > STDMIN && (fovStd > fovStdL * (1.0 + STDTOL) || fovDist == MINDIST || fovDist == MAXDIST)) {
            fovDir = 1.0 - fovDir;
        }

        if (texCoord.x > 0.5) {
            outColor = vec4(fovDir, 0.0, 0.0, 1.0);
        } else if (texCoord.x > 0.4) {
            outColor = vec4(encodeInt(int(floor(fovStd + 0.5))), 1.0);
        } else if (texCoord.x > 0.3) {
            outColor = vec4(encodeInt(int(floor(mix(fovDist * 100.0, float(decodeInt(texture2D(DiffuseSampler, vec2(0.35, 0.5)).rgb)), Smoothing)) + 0.5)), 1.0);
        } else if (count > MINTAPS && fovStd > STDMIN || fovDist > MAXDIST || fovDist < MINDIST) {
            outColor = vec4(encodeInt(int(floor(clamp(fovDist + (fovDir - 0.5) * 2.0, MINDIST, MAXDIST) + 0.5))), 1.0);
        } 
    }

    gl_FragColor = outColor;
}
