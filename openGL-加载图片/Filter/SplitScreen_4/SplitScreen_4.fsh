precision highp float;

uniform sampler2D Texture;
varying highp vec2 varyTextureCoord;

void main() {
    
    vec2 uv = varyTextureCoord.xy;
    
    if (uv.x <= 0.5) {
        uv.x = uv.x * 2.0;
    }else {
        uv.x = (uv.x - 0.5) * 2.0;
    }
    
    if (uv.y <= 0.5) {
        uv.y = uv.y * 2.0;
    }else {
        uv.y = (uv.y - 0.5) * 2.0;
    }
    
    gl_FragColor = texture2D(Texture, uv);
}

