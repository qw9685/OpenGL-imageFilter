precision highp float;

uniform sampler2D Texture;
varying highp vec2 varyTextureCoord;

void main() {
    
    vec2 uv = varyTextureCoord.xy;
    float y;
    if (uv.y >= 0.0 && uv.y <= 0.5) {
        y = uv.y + 0.25;
    }else {
        y = uv.y - 0.25;
    }
    
    
    gl_FragColor = texture2D(Texture, vec2(uv.x, y));
}
