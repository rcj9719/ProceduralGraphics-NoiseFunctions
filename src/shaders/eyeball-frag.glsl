#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;
uniform vec4 u_Color;

in vec4 fs_Col;
in vec4 fs_Pos;
out vec4 out_Col;

float random3D( vec3 p ) {
    return fract(sin((dot(p, vec3(127.1,
                                  311.7,
                                  191.999)))) *         
                 43758.5453);
}

float cosineInterpolate(float a, float b, float t)
{
    float cos_t = (1.f - cos(t * 3.14)) * 0.5f;
    return mix(a, b, cos_t);
}

float interpNoise3D(vec3 p) {
    int intX = int(floor(p.x));
    float fractX = fract(p.x);
    int intY = int(floor(p.y));
    float fractY = fract(p.y);
    int intZ = int(floor(p.z));
    float fractZ = fract(p.z);

    float v1 = random3D(vec3(intX, intY, intZ));
    float v2 = random3D(vec3(intX, intY, intZ + 1));
    float v3 = random3D(vec3(intX, intY + 1, intZ));
    float v4 = random3D(vec3(intX, intY + 1, intZ + 1));

    float v5 = random3D(vec3(intX + 1, intY, intZ));
    float v6 = random3D(vec3(intX + 1, intY, intZ + 1));
    float v7 = random3D(vec3(intX + 1, intY + 1, intZ));
    float v8 = random3D(vec3(intX + 1, intY + 1, intZ + 1));

    float i1 = mix(v1, v2, fractX);
    float i2 = mix(v3, v4, fractX);
    float i3 = mix(i1, i2, fractY);
    
    float i4 = mix(v5, v6, fractX);
    float i5 = mix(v7, v8, fractX);
    float i6 = mix(i4, i5, fractY);

    return mix(i3, i6, fractZ);
}

float fbm(vec3 p) {
    float total = 0.f;
    float persistence = 0.5f;
    int octaves = 8;
    float freq = 2.f;
    float amp = 0.5f;
    for(int i = 1; i <= octaves; i++) {
        total += interpNoise3D(p.xyz * freq) * amp;
        freq *= 2.f;
        amp *= persistence;
    }
    return total;
}



void main() {
  out_Col = u_Color * fbm(vec3(fs_Pos.xyz));
}
