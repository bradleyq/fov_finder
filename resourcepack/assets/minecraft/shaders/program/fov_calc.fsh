#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D CentersSampler;
uniform sampler2D DiffuseDepthSampler;
uniform float SideLength;

varying vec2 texCoord;
varying vec2 oneTexel;
varying float aspectRatio;

#define NEAR 0.1 
#define FAR 1000.0

vec3 points[8];

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
  
float LinearizeDepth(float depth) {
    float z = depth * 2.0 - 1.0;
    return (NEAR * FAR) / (FAR + NEAR - z * (FAR - NEAR));    
}

float fCalc(vec3 p1, vec3 p2, float sls) {
    float k1 = p1.x * p1.z - p2.x * p2.z;
    float k2 = p1.y * p1.z - p2.y * p2.z;
    float k3 = p1.z - p2.z;
    return pow((k1 * k1 + k2 * k2) / abs(sls - k3 * k3), 0.5);
}

void main() {
    vec4 outColor = texture2D(DiffuseSampler, texCoord);

    vec4 tmpCount = texture2D(CentersSampler, vec2(1.0, 0.0));
    int count = decodeInt(tmpCount.rgb) * int(tmpCount.a == 69.0 / 255.0);

    if (count == 8) {
        int q1 = 0;
        int q2 = 0;
        int q3 = 0;
        int q4 = 0;

        for (int i = 0; i < 8; i += 1) {
            vec3 xvec = texture2D(CentersSampler, (vec2(float(i), 0.0) + 0.5) * oneTexel).rgb;
            vec3 yvec = texture2D(CentersSampler, (vec2(float(i), 1.0) + 0.5) * oneTexel).rgb;
            vec2 pos = (vec2(decodeInt(xvec), decodeInt(yvec)) + 0.5) * oneTexel;
            float depth = LinearizeDepth(texture2D(DiffuseDepthSampler, pos).r);
            pos = (pos - 0.5) * vec2(aspectRatio, 1.0);
            if (pos.x < 0.0 && pos.y < 0.0) {
                points[q1] = vec3(pos, depth);
                q1 += 1;
            }
            else if (pos.x > 0.0 && pos.y < 0.0) {
                points[2 + q2] = vec3(pos, depth);
                q2 += 1;
            }
            else if (pos.x > 0.0 && pos.y > 0.0) {
                points[4 + q3] = vec3(pos, depth);
                q3 += 1;
            }
            else {
                points[6 + q4] = vec3(pos, depth);
                q4 += 1;
            }
        }

        if (q1 == 2 && q2 == 2 && q3 == 2 && q4 == 2) {
            vec3 tmp = vec3(0.0);
            if (points[0].z > points[1].z) {
                tmp = points[0];
                points[0] = points[1];
                points[1] = tmp;
            }
            if (points[2].z > points[3].z) {
                tmp = points[2];
                points[2] = points[3];
                points[3] = tmp;
            }
            if (points[4].z > points[5].z) {
                tmp = points[4];
                points[4] = points[5];
                points[5] = tmp;
            }
            if (points[6].z > points[7].z) {
                tmp = points[6];
                points[6] = points[7];
                points[7] = tmp;
            }

            float fov = 0.0;
            float sls = SideLength * SideLength;
            fov += fCalc(points[0], points[5], sls * 3.0);
            fov += fCalc(points[2], points[7], sls * 3.0);
            fov += fCalc(points[4], points[1], sls * 3.0);
            fov += fCalc(points[6], points[3], sls * 3.0);
            fov += fCalc(points[0], points[2], sls);
            fov += fCalc(points[2], points[4], sls);
            fov += fCalc(points[4], points[6], sls);
            fov += fCalc(points[6], points[0], sls);
            fov += fCalc(points[1], points[3], sls);
            fov += fCalc(points[3], points[5], sls);
            fov += fCalc(points[5], points[7], sls);
            fov += fCalc(points[7], points[1], sls);
            fov /= 12.0;
            fov =  abs(2.0 * atan(0.5, fov)) * 180.0 / 3.14159268535 * 100.0;

            outColor = vec4(encodeInt(int(floor(mix(float(decodeInt(outColor.rgb)), fov, 0.95) + 0.5))), 1.0);
        }
    }

    gl_FragColor = outColor;
}
