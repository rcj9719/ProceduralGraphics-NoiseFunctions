#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;
uniform vec4 u_Color;

in vec4 fs_Col;
in vec4 fs_Pos;
out vec4 out_Col;

void main() {
  out_Col = vec4(0.5 * (fs_Pos.xy + vec2(1.0)), 0.5 * (sin(u_Time * 3.14159 * 0.01) + 1.0), 1.0);
  //out_Col = u_Color;
}
