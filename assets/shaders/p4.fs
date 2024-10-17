#version 330

precision mediump float;


// // Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// uniform vec2 u_resolution;
uniform float u_time;

// Output fragment color
out vec4 finalColor;

vec4 permute(vec4 x) {
    return mod(((x * 34.0) + 1.0) * x, 289.0);
}

//	Classic Perlin 2D Noise 
//	by Stefan Gustavson
//
vec2 fade(vec2 t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float cnoise(vec2 P) {
    vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
    vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;
    vec4 i = permute(permute(ix) + iy);
    vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
    vec4 gy = abs(gx) - 0.5;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;
    vec2 g00 = vec2(gx.x, gy.x);
    vec2 g10 = vec2(gx.y, gy.y);
    vec2 g01 = vec2(gx.z, gy.z);
    vec2 g11 = vec2(gx.w, gy.w);
    vec4 norm = 1.79284291400159 - 0.85373472095314 * vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;
    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));
    vec2 fade_xy = fade(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}

float rect(float x, float y, float w, float h, vec2 st) {
    float px = step(x, st.x) * (1.0 - step(x + w, st.x));
    st.y = 1.0 - st.y;
    float py = step(y, st.y) * (1.0 - step(y + h, st.y));

    return (px * py);
}

float rectOutline(float x, float y, float w, float h, float th, vec2 st) {

    float ox = rect(x, y, w, th, st);
    ox += rect(x, y + h, w, th, st);

    float oy = rect(x, y, th, h, st);
    oy += rect(x + w, y, th, h + th, st);
    return ox + oy;

}

float plot(vec2 st, float pct) {
    return smoothstep(pct - 0.02, pct, st.y) -
        smoothstep(pct, pct + 0.02, st.y);
}

float plotFill(vec2 st, float pct) {
    float s = 0.2;
    return (1.0 -
        // step(pct, st.y));
        smoothstep(pct, pct + 0.02, st.y));
}

float sineWave(vec2 st, float f, float a, float th, float xs, float ys) {
    float s = step(sin(st.x * f - xs - th) * a + ys, st.y);
    s = s - step(sin(st.x * f - xs) * a + ys + th, st.y);
    return s;
}

vec4 image(vec2 fragCoord) {
    vec2 st = fragCoord.st;

    vec3 bgColor = vec3(0.282, 0.235, 0.337);
    vec3 fgColor1 = vec3(0.09, 0.243, 0.239);
    vec3 bgGradiant = (bgColor * ((st.x / 2.0 + st.y) / 1.2));
    vec3 color = vec3(0.0);

    float amplitude = 1.25;
    float frequency = 20.0;

    float strength = mod(distance(st, vec2(0.5)) * 10.0, 1.0);

    float p = st.x * 10.0 * sin(sin(u_time * 0.5));

    float t = (u_time / 2.0);
    float ss = sin(t / 2.0) / 3.5;
    st.x += sin(st.y * ss * 30.0) * 0.2;
    st.y += sin(st.x / ss * 30.0) * 0.2;

    st.x += sin(st.y * sin(u_time / 20.0) * 30.0) * 0.2;
    st.y += sin(st.x / sin(u_time / 20.0) * 30.0) * 0.2;

    strength = sineWave(st, 15.0, 0.2, 0.05, 0.0, 0.5);

    color += vec3(strength) * vec3(1.0, 0.0, 1.0);

    return vec4(color, 1.0);

}

void main() {
    finalColor = image(fragTexCoord);
}

