shader_type canvas_item;

// === UNIFORMS ===
uniform float blur_size : hint_range(0.0, 400.0) = 0.0;       // Radius
uniform float directions : hint_range(1.0, 32.0) = 16.0;     // Anzahl der Blur-Richtungen
uniform float quality : hint_range(1.0, 10.0) = 3.0;          // Anzahl der Samples pro Richtung
uniform float zoom : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    float Pi = 6.28318530718; // 2π
    vec2 uv_offset = 0.5*vec2(1.0-zoom,1.0-zoom );
    vec2 uv = (UV*zoom)+uv_offset; // Normalisierte Texture-Koordinaten
    vec4 color = texture(TEXTURE, uv); // Basisfarbe
    
    vec2 radius = blur_size * SCREEN_PIXEL_SIZE; // Radius an Bildschirmauflösung angepasst
    
    // === Blur-Berechnung ===
    for (float d = 0.0; d < Pi; d += Pi / directions) {
        for (float i = 1.0 / quality; i <= 1.0; i += 1.0 / quality) {
            vec2 offset = vec2(cos(d), sin(d)) * radius * i;
            color += texture(TEXTURE, uv + offset);
        }
    }
    
    // Mittelwert
    color /= (quality * directions) + 1.0;
    
    COLOR = color;
}