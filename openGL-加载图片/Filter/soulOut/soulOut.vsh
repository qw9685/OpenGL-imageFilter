attribute vec4 Position;
attribute vec2 TextureCoord;
varying vec2 varyTextureCoord;

void main (void) {
    gl_Position = Position;
    varyTextureCoord = TextureCoord;
}
