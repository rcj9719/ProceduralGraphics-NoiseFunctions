#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;
uniform vec4 u_Color;

in vec4 fs_Col;
in vec4 fs_Pos;
out vec4 out_Col;

// https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83

// float random3D( vec3 p ) {
//     return fract(sin((dot(p, vec3(127.1,
//                                   311.7,
//                                   191.999)))) *         
//                  43758.5453);
// }

float hash( float n )
{
    return fract(sin(n)*43758.5453);
}

float random3D( vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0 + p.z * 50.0;

    return mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
               mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);
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

    float i1 = mix(v1, v2, fractZ);
    float i2 = mix(v3, v4, fractZ);
    float i3 = mix(i1, i2, fractY);
    
    float i4 = mix(v5, v6, fractZ);
    float i5 = mix(v7, v8, fractZ);
    float i6 = mix(i4, i5, fractY);

    return mix(i3, i6, fractX);
}

float fbm(vec3 p, float freq, float persistence) {
    float total = 0.f;
    //float persistence = 0.5f;
    int octaves = 8;
    //float freq = 2.f;
    float amp = 0.5f;
    for(int i = 1; i <= octaves; i++) {
        total += interpNoise3D(p.xyz * freq) * amp;
        freq *= 2.f;
        amp *= persistence;
    }
    return total;
}



void main() {
    vec4 baseCol = vec4(1.0, 1.0, 0.0, 1.0);
    float theta = atan(fs_Pos.x, fs_Pos.y);
    float r = sqrt(pow(fs_Pos.x, 2.0f) + pow(fs_Pos.y, 2.0f));
    //vec4 blue = vec4(0.0, 0.0, 1.0f, 1.0) * fbm(vec3(fs_Pos.xyz), 2.f, 0.5f);
    out_Col = fs_Pos;
    if(fs_Pos.z >= 0.99f && fs_Pos.z <= 1.0f) {
        // pupil
        out_Col = mix(vec4(0.0, 0.0, 0.0, 1.0), vec4(r, r, r, 1.0), 0.95);
    }
    else if(fs_Pos.z >= 0.9f && fs_Pos.z <= 0.99f) {
        // iris

        // float theta = (fs_Pos.x > -0.01f && fs_Pos.x < 0.01f) ? fs_Pos.x : fs_Pos.y/fs_Pos.x;
        // vec4 eye_blue = vec4(0.0, 0.0, 1.0f, 1.0) * (cos(theta * 70.f)) * cos(fbm(vec3(fs_Pos.xyz), 2.f, 0.5f)) ;
        // vec4 eye_green = vec4(0.0, 1.0, 1.0f, 1.0) * (cos(theta * 50.f + 3.14f/2.f));
        // vec4 eye_green2 = vec4(36.f/255.f, 110.f/255.f, 52.f/255.f, 1.0) * (cos(theta * 100.f + 3.14f/4.f));
        // out_Col = mix(eye_green2, mix(eye_blue, eye_green, fbm(vec3(fs_Pos.xyz), 2.f, 20.5f)), 0.5f);

        vec4 blue = vec4(0.07, 0.0, 1.0, 1.0) * fbm(vec3(fs_Pos.xyz), 2.f, 0.5f);  // blue with low persistence noise function
        vec4 green = vec4(0.14, 0.4, cos(0.22 * r * 90.f), 1.0) * fbm(vec3(fs_Pos.xyz), 2.f, 0.5f);  // increasing blue influence with radius, adjusting green ring position with appropriate multiple 
        green *= abs(cos(theta * 20.f + 3.14f/2.f));    // multiplying with cos(theta) makes cos wave look like rays around the circle
        out_Col = mix(green, blue, 0.5f);
    }
    else {
        // outer white eyeball
        out_Col = vec4(1.0, 0.0, 0.0f, 1.0) * interpNoise3D(vec3(fs_Pos.xyz)) * (0.4 * (-fs_Pos.z + 1.5f));//, 2.0f, 0.5f);
    }

}
