#version 110

uniform sampler2D DiffuseSampler;

varying vec2 texCoord;
varying vec2 oneTexel;

float v3max(vec3 v) {
    return max(max(v.r, max(v.g, v.b)), 0.01);
}

void main() {
    vec4 outColor = texture2D(DiffuseSampler, texCoord);
    if (outColor.a == 1.0) {
        outColor.rgb /= v3max(outColor.rgb);
        vec4 c1 = texture2D(DiffuseSampler, texCoord + vec2(oneTexel.x, 0.0));
        vec4 c2 = texture2D(DiffuseSampler, texCoord + vec2(0.0, oneTexel.y));
        vec4 c3 = texture2D(DiffuseSampler, texCoord + vec2(oneTexel.x, -oneTexel.y));
        vec4 c4 = texture2D(DiffuseSampler, texCoord + vec2(oneTexel.x, oneTexel.y));
        if (c1.a == 1.0 && dot(outColor.rgb - c1.rgb / v3max(c1.rgb), vec3(1.0)) < 0.02
         || c2.a == 1.0 && dot(outColor.rgb - c2.rgb / v3max(c2.rgb), vec3(1.0)) < 0.02
         || c3.a == 1.0 && dot(outColor.rgb - c3.rgb / v3max(c3.rgb), vec3(1.0)) < 0.02
         || c4.a == 1.0 && dot(outColor.rgb - c4.rgb / v3max(c4.rgb), vec3(1.0)) < 0.02) {
            outColor = vec4(0.0);
        }
    }
    gl_FragColor = outColor;
}