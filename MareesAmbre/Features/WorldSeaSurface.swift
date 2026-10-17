import SpriteKit

@MainActor
enum WorldSeaSurface {
    static func make(motion: Float) -> SKSpriteNode {
        let sea = SKSpriteNode(imageNamed: "ArchipelMer")
        sea.size = CGSize(width: 12_000, height: 12_000)
        sea.position = CGPoint(x: 2400, y: -2400)
        sea.name = "sea"
        sea.zPosition = -1
        sea.shader = SKShader(source: """
        void main() {
            vec2 uv = v_tex_coord * 30.0;
            float time = u_time * u_motion;
            // Regional zoom needs a readable swell, rather than subpixel shimmer.
            float swell = sin(uv.x * 7.0 + uv.y * 11.0 - time * 1.25
                              + sin(uv.y * 2.5 + time * 0.4) * 0.55);
            vec2 flow = vec2(sin(uv.y * 6.283 + time * 1.15),
                             sin(uv.x * 4.712 - time * 0.85));
            vec2 displaced = uv + flow * 0.035 * u_motion
                + vec2(time * 0.008, -time * 0.004);
            vec3 water = texture2D(u_texture, fract(displaced)).rgb;
            water = mix(vec3(0.025, 0.24, 0.38), water, 0.72);
            water *= 0.97 + 0.06 * swell;
            gl_FragColor = vec4(water, 1.0);
        }
        """)
        sea.shader?.addUniform(SKUniform(name: "u_motion", float: motion))
        return sea
    }
}
