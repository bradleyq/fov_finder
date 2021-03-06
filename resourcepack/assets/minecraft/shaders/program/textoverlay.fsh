#version 120

uniform sampler2D DiffuseSampler;
uniform sampler2D FOVSampler;
uniform sampler2D NumberTex;
uniform vec2 InSize;
uniform float FontHeight;

varying vec2 texCoord;
varying vec2 oneTexel;
varying float aspectRatio;
varying float fontAspectRatio;

#define X_OFFSET 3.0
#define PT_OFFSET 2.0
#define N_OFFSET 0.0
#define V_OFFSET 1.0
  
int decodeInt(vec3 ivec) {
    ivec *= 255.0;
    int num = 0;
    num += int(ivec.r);
    num += int(ivec.g) * 255;
    num += int(ivec.b) * 255 * 255;
    return num;
}

void main() {
    
    vec4 outcolor = texture2D(DiffuseSampler, texCoord);
    float chartexwidth = FontHeight * fontAspectRatio / aspectRatio;
    vec2 pixCoord = texCoord - vec2(0.5);
    vec2 screenCoord = pixCoord * vec2(aspectRatio, 1.0);

    pixCoord += vec2(-1.0 * chartexwidth, 3.0 * FontHeight);
    pixCoord.y *= -1.0;
    vec4 tmpcol = vec4(0.0);
    float chartexY = mod(pixCoord.y / FontHeight, 1.0);
    float chartexX = mod(pixCoord.x / chartexwidth, 1.0);
    if (pixCoord.y > 0.0 && pixCoord.y < FontHeight) {
        if (pixCoord.x > 0.0 && pixCoord.x < chartexwidth * 5.0) {
            float fov = float(decodeInt(texture2D(FOVSampler, vec2(0.05, 0.5)).rgb));
            float offset = 0.0;
            float d1 = mod(fov, 10.0);
            fov = (fov - d1) / 10.0;
            float d2 = mod(fov, 10.0);
            fov = (fov - d2) / 10.0;
            float d3 = mod(fov, 10.0);
            fov = (fov - d3) / 10.0;
            float d4 = mod(fov, 10.0);
            fov = (fov - d4) / 10.0;
            float d5 = mod(fov, 10.0);

            if (pixCoord.x < chartexwidth) {
                offset = d5;
            } else if (pixCoord.x < 2.0 * chartexwidth) {
                offset = d4;
            } else if (pixCoord.x < 3.0 * chartexwidth) {
                offset = d3;
            } else if (pixCoord.x < 4.0 * chartexwidth) {
                offset = d2;
            } else {
                offset = d1;
            }

            tmpcol = texture2D(NumberTex, vec2((chartexX + offset) / 10.0, chartexY));
        } 
    } 
    else if (pixCoord.y > FontHeight && pixCoord.y < 2.0 * FontHeight) {
        if (pixCoord.x > 0.0 && pixCoord.x < chartexwidth * 2.0) {
            float dist = float(decodeInt(texture2D(FOVSampler, vec2(0.25, 0.5)).rgb));
            float offset = 0.0;
            float d1 = mod(dist, 10.0);
            dist = (dist - d1) / 10.0;
            float d2 = mod(dist, 10.0);

            if (pixCoord.x < chartexwidth) {
                offset = d2;
            } else {
                offset = d1;
            } 

            tmpcol = texture2D(NumberTex, vec2((chartexX + offset) / 10.0, chartexY));
        } 
    } 
    else if (pixCoord.y > 2.0 * FontHeight && pixCoord.y < 3.0 * FontHeight) {
        if (pixCoord.x > 0.0 && pixCoord.x < chartexwidth * 4.0) {
            float fov = floor(float(decodeInt(texture2D(FOVSampler, vec2(0.15, 0.5)).rgb)) / 10.0 + 0.5);
            float offset = 0.0;
            float d1 = mod(fov, 10.0);
            fov = (fov - d1) / 10.0;
            float d2 = mod(fov, 10.0);
            fov = (fov - d2) / 10.0;
            float d3 = mod(fov, 10.0);
            fov = (fov - d3) / 10.0;
            float d4 = mod(fov, 10.0);

            if (pixCoord.x < chartexwidth) {
                offset = d4;
            } else if (pixCoord.x < 2.0 * chartexwidth) {
                offset = d3;
            } else if (pixCoord.x < 3.0 * chartexwidth) {
                offset = d2;
            } else {
                offset = d1;
            }

            tmpcol = texture2D(NumberTex, vec2((chartexX + offset) / 10.0, chartexY));
        } 
    } 
    else if (pixCoord.y > 3.0 * FontHeight && pixCoord.y < 4.0 * FontHeight) {
        if (pixCoord.x > 0.0 && pixCoord.x < chartexwidth * 2.0) {
            float dist = floor(float(decodeInt(texture2D(FOVSampler, vec2(0.35, 0.5)).rgb)) / 100.0 + 0.5);
            float offset = 0.0;
            float d1 = mod(dist, 10.0);
            dist = (dist - d1) / 10.0;
            float d2 = mod(dist, 10.0);

            if (pixCoord.x < chartexwidth) {
                offset = d2;
            } else {
                offset = d1;
            } 

            tmpcol = texture2D(NumberTex, vec2((chartexX + offset) / 10.0, chartexY));
        } 
    } 
    
    outcolor.rgb = mix(outcolor.rgb, tmpcol.rgb, tmpcol.a);
    outcolor.a = max(outcolor.a, tmpcol.a);



    gl_FragColor = outcolor;
}