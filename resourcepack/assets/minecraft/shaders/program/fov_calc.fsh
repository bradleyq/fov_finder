#version 120

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform vec2 OutSize;
uniform float Range;

varying vec2 texCoord;
varying vec2 oneTexel;
varying vec3 normal;
varying vec3 tangent;
varying vec3 bitangent;
varying float aspectRatio;

#define BIGNEG -100000.0
#define NEAR 0.1
// #define FAR 2048.0 //1536.0
#define STEP 128.0 
#define FUDGE 0.001
#define MAXSLOPE 60.0 //12.0
#define MINSLOPE 5.0 //12.0
#define MAXDELTA 1.0
#define FIXEDPOINT 100.0
#define MAXFOV 150.0 * FIXEDPOINT // 166.0
#define MINFOV 14.0 * FIXEDPOINT // 14.0
#define DEGCONVERT 180.0 / 3.14159268535 * FIXEDPOINT

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
  
float LinearizeDepth(float depth, float mult) {
    float z = depth * 2.0 - 1.0;
    return (NEAR * STEP * mult) / (STEP * mult + NEAR - z * (STEP * mult - NEAR));    
}

float depthLerp(sampler2D tex, vec2 coord, float mult) {
    vec2 resids = coord - floor(coord);
    coord = floor(coord) + 0.5;
    float deptha = LinearizeDepth(texture2D(tex, (coord) * oneTexel).r, mult);
    float depthb = LinearizeDepth(texture2D(tex, (coord + vec2(1.0, 0.0)) * oneTexel).r, mult);
    float depthc = LinearizeDepth(texture2D(tex, (coord + vec2(0.0, 1.0)) * oneTexel).r, mult);
    float depthd = LinearizeDepth(texture2D(tex, (coord + vec2(1.0, 1.0)) * oneTexel).r, mult);

    deptha = mix(deptha, depthb, resids.x);
    depthc = mix(depthc, depthd, resids.x);
    return mix(deptha, depthc, resids.y);
}

void main() {
    vec4 outColor = vec4(0.0);

    float tDotS = dot(tangent, vec3(0.0, 0.0, -1.0));
    float bDotS = dot(bitangent, vec3(0.0, 0.0, -1.0));
    vec2 projTangent = (tangent - tDotS * vec3(0.0, 0.0, -1.0)).xy;
    vec2 projBitangent = (bitangent - bDotS * vec3(0.0, 0.0, -1.0)).xy;
    float projTangentLen = length(projTangent);
    float projBitangentLen = length(projBitangent);
    projTangent = normalize(projTangent);
    projBitangent = normalize(projBitangent);
    float step = oneTexel.y;

    float distChunks = float(decodeInt(texture2D(DiffuseSampler, vec2(0.25, 0.5)).rgb));
    // distChunks = 12.0;

    float depthM = LinearizeDepth(texture2D(DiffuseDepthSampler, texCoord.xy).r, distChunks);
    float depth1 = LinearizeDepth(texture2D(DiffuseDepthSampler, texCoord.xy - vec2(0.0, step)).r, distChunks);
    float depth2 = LinearizeDepth(texture2D(DiffuseDepthSampler, texCoord.xy + vec2(0.0, step)).r, distChunks);
    float depth3 = depthLerp(DiffuseDepthSampler, texCoord.xy * OutSize - 0.5 - projBitangent, distChunks);
    float depth4 = depthLerp(DiffuseDepthSampler, texCoord.xy * OutSize - 0.5 + projBitangent, distChunks);
    float depth5 = depthLerp(DiffuseDepthSampler, texCoord.xy * OutSize - 0.5 - projTangent, distChunks);
    float depth6 = depthLerp(DiffuseDepthSampler, texCoord.xy * OutSize - 0.5 + projTangent, distChunks);
    float depthV1 = LinearizeDepth(texture2D(DiffuseDepthSampler, texCoord.xy + vec2(step, 0)).r, distChunks);
    float depthV2 = depthLerp(DiffuseDepthSampler, texCoord.xy * OutSize - 0.5 + vec2(projBitangent.y, -projBitangent.x), distChunks);
    float depthV3 = depthLerp(DiffuseDepthSampler, texCoord.xy * OutSize - 0.5 + vec2(projTangent.y, -projTangent.x), distChunks);

    if (((depth1 >= depthM - FUDGE && depthM + FUDGE >= depth2) || (depth1 <= depthM + FUDGE && depthM - FUDGE <= depth2)) 
     && ((depth3 >= depthM - FUDGE && depthM + FUDGE >= depth4) || (depth3 <= depthM + FUDGE && depthM - FUDGE <= depth4)) 
     && ((depth5 >= depthM - FUDGE && depthM + FUDGE >= depth6) || (depth5 <= depthM + FUDGE && depthM - FUDGE <= depth6)) 
     && depth1 < Range 
     && depth2 < Range
     && depth3 < Range
     && depth4 < Range
     && depth5 < Range
     && depth6 < Range
     && depthM < Range) {
        vec2 pos = (texCoord - 0.5) * vec2(aspectRatio, 1.0);
        float x1, x2, m, d1, d2;
        float fov1 = BIGNEG;
        float fov2 = BIGNEG;
        float fov3 = BIGNEG;

        if (abs(depth1 - depth2) > FUDGE && abs(depth1 - depth2) < MAXDELTA && abs(depthM - depthV1) < FUDGE) {
            x1 = pos.y - step;
            x2 = pos.y + step;
            d1 = depth1;
            d2 = depth2;
            m = normal.y / normal.z;
            if (abs(m) < MAXSLOPE && abs(m) > MINSLOPE) {
                fov1 = m * (d1 * x1 - d2 * x2) / (d1 - d2);
                fov1 = abs(2.0 * atan(0.5, fov1)) * DEGCONVERT;
            }
        }

        if (abs(depth3 - depth4) > FUDGE && abs(depth3 - depth4) < MAXDELTA && abs(depthM - depthV2) < FUDGE) {
            float distToAxis = dot(pos, projBitangent);
            x1 = distToAxis - step;
            x2 = distToAxis + step;
            d1 = depth3;
            d2 = depth4;
            m = -projBitangentLen / bDotS;

            if (abs(m) < MAXSLOPE && abs(m) > MINSLOPE) {
                fov2 = m * (d1 * x1 - d2 * x2) / (d1 - d2);
                fov2 = abs(2.0 * atan(0.5, fov2)) * DEGCONVERT;
            }
        }

        if (abs(depth5 - depth6) > FUDGE && abs(depth5 - depth6) < MAXDELTA && abs(depthM - depthV3) < FUDGE) {
            float distToAxis = dot(pos, projTangent);
            x1 = distToAxis - step;
            x2 = distToAxis + step;
            d1 = depth5;
            d2 = depth6;
            m = -projTangentLen / tDotS;

            if (abs(m) < MAXSLOPE && abs(m) > MINSLOPE) {
                fov3 = m * (d1 * x1 - d2 * x2) / (d1 - d2);
                fov3 = abs(2.0 * atan(0.5, fov3)) * DEGCONVERT;
            }
        }

        float oldFov = float(decodeInt(texture2D(DiffuseSampler, vec2(0.05, 0.5)).rgb));

        float fov = fov1;
        float tbn = 3.0;
        if (abs(fov2 - oldFov) < abs(fov - oldFov)) {
            fov = fov2;
            tbn = 2.0;
        }
        if (abs(fov3 - oldFov) < abs(fov - oldFov)) {
            fov = fov3;
            tbn = 1.0;
        }

        if (fov > MINFOV && fov < MAXFOV) {
            outColor = vec4(encodeInt(int(floor(fov + 0.5))), (252.0 + tbn) / 255.0);
        }
    }

    gl_FragColor = outColor;
}
