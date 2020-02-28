precision highp float;

uniform sampler2D Texture;
varying vec2 varyTextureCoord;

void main (void) {
    vec4 mask = texture2D(Texture, varyTextureCoord);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
