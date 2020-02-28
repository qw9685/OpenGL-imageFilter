precision highp float;

uniform sampler2D Texture;
varying highp vec2 varyTextureCoord;
const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);

void main() {
    vec4 mask = texture2D(Texture, varyTextureCoord);
    float temp = dot(mask.rgb, W);
    gl_FragColor = vec4(vec3(temp), 1.0);
}
