#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform float Range;

varying vec2 texCoord;

#define NEAR 0.1 
#define FAR 1000.0

float LinearizeDepth(float depth) {
    float z = depth * 2.0 - 1.0;
    return (NEAR * FAR) / (FAR + NEAR - z * (FAR - NEAR));    
}

void main() {
    vec2 poissonDisk[16];
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

    
    int successCount = 0;
    successCount += int(texture2D(DiffuseSampler, vec2(0.5) + 0.1 * poissonDisk[0]) == vec4(0.0, 0.0, 0.0, 3.0 / 255.0));
    successCount += int(texture2D(DiffuseSampler, vec2(0.5) + 0.1 * poissonDisk[1]) == vec4(0.0, 0.0, 0.0, 3.0 / 255.0));
    successCount += int(texture2D(DiffuseSampler, vec2(0.5) + 0.1 * poissonDisk[2]) == vec4(0.0, 0.0, 0.0, 3.0 / 255.0));
    successCount += int(texture2D(DiffuseSampler, vec2(0.5) + 0.1 * poissonDisk[3]) == vec4(0.0, 0.0, 0.0, 3.0 / 255.0));
    successCount += int(texture2D(DiffuseSampler, vec2(0.5) + 0.1 * poissonDisk[4]) == vec4(0.0, 0.0, 0.0, 3.0 / 255.0));
    successCount += int(texture2D(DiffuseSampler, vec2(0.5) + 0.1 * poissonDisk[5]) == vec4(0.0, 0.0, 0.0, 3.0 / 255.0));
    successCount += int(texture2D(DiffuseSampler, vec2(0.5) + 0.1 * poissonDisk[6]) == vec4(0.0, 0.0, 0.0, 3.0 / 255.0));
    successCount += int(texture2D(DiffuseSampler, vec2(0.5) + 0.1 * poissonDisk[7]) == vec4(0.0, 0.0, 0.0, 3.0 / 255.0));
    successCount += int(texture2D(DiffuseSampler, vec2(0.5) + 0.1 * poissonDisk[8]) == vec4(0.0, 0.0, 0.0, 3.0 / 255.0));
    successCount += int(texture2D(DiffuseSampler, vec2(0.5) + 0.1 * poissonDisk[9]) == vec4(0.0, 0.0, 0.0, 3.0 / 255.0));
    successCount += int(texture2D(DiffuseSampler, vec2(0.5) + 0.1 * poissonDisk[10]) == vec4(0.0, 0.0, 0.0, 3.0 / 255.0));
    successCount += int(texture2D(DiffuseSampler, vec2(0.5) + 0.1 * poissonDisk[11]) == vec4(0.0, 0.0, 0.0, 3.0 / 255.0));
    successCount += int(texture2D(DiffuseSampler, vec2(0.5) + 0.1 * poissonDisk[12]) == vec4(0.0, 0.0, 0.0, 3.0 / 255.0));
    successCount += int(texture2D(DiffuseSampler, vec2(0.5) + 0.1 * poissonDisk[13]) == vec4(0.0, 0.0, 0.0, 3.0 / 255.0));
    successCount += int(texture2D(DiffuseSampler, vec2(0.5) + 0.1 * poissonDisk[14]) == vec4(0.0, 0.0, 0.0, 3.0 / 255.0));
    successCount += int(texture2D(DiffuseSampler, vec2(0.5) + 0.1 * poissonDisk[15]) == vec4(0.0, 0.0, 0.0, 3.0 / 255.0));

    vec4 candidate =  texture2D(DiffuseSampler, texCoord);
    vec4 outColor = vec4(0.0);

    if (successCount > 8 && candidate == vec4(0.0, 0.0, 0.0, 1.0)) {
        float depth = LinearizeDepth(texture2D(DiffuseDepthSampler, texCoord).r);
        if (depth < Range) {
            outColor = candidate;
        }
    }

    gl_FragColor = outColor;
}