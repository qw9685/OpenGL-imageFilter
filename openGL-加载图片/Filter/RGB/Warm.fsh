precision highp float;

uniform sampler2D Texture;
varying highp vec2 varyTextureCoord;

void main() {
    vec4 mask = texture2D(Texture, varyTextureCoord);
    gl_FragColor = mask + vec4(0.3,0.3,0.0,0.0);
}
