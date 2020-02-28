precision mediump float;

uniform sampler2D Texture;

const float uD = 60.0;
const float uR = 0.5;

varying vec2 varyTextureCoord;

void main () {
    float Res = float(256);
    
    vec2 st = varyTextureCoord;
    float Radius = Res * uR;
    
    vec2 xy = Res * st;
    
    vec2 dxy = xy - vec2(Res/2.0, Res/2.0);
    float r = length(dxy);
    
    float beta = atan(dxy.y, dxy.x) + radians(uD) * 2.0 * (-(r/Radius)*(r/Radius) + 1.0);
    
    vec2 xy1 = xy;
    if(r<=Radius)
    {
        xy1 = vec2(Res/2.0, Res/2.0) + r*vec2(cos(beta), sin(beta));
    }
    
    st = xy1/Res;
    
    vec3 irgb = texture2D(Texture, st).rgb;
    
    gl_FragColor = vec4( irgb, 1.0);
    
    
}
