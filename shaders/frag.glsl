#version 330 core

out vec4 FragColor;

#define MAX_DISTANCE sqrt(3)
#define MAX_DEPTH 64

#define AMBIENT 0.2f
#define LIGHT_SCALE 0.8f
#define FREQ_SCALE 0.5f

#define SCALE_P p = freq * 2 * 3.1415926535897932 * p

#define SPLIT_P

in vec3 rayDirection;

uniform sampler2D ourTexture;
uniform mat4 transInv;
uniform vec4 cameraPos;
uniform vec4 lightPos;
uniform float freq;

in vec4 fragPosView;

struct fresult {
    vec3 solution;
    bool increasing;
    bool solutionFound;
};

#ifdef GYROID
// gyroid tpms
float f(vec3 p) {
    SCALE_P;
    return cos(p.x) * sin(p.y) + cos(p.y) * sin(p.z) + cos(p.z) * sin(p.x);
}

// gyroid surface normal (surface gradient)
vec3 df(vec3 p) {
    SCALE_P;
    return vec3(
        -sin(p.x) * sin(p.y) + cos(p.z) * cos(p.x),
        cos(p.x) * cos(p.y) - sin(p.y) * sin(p.z),
        cos(p.y) * cos(p.z) - sin(p.z) * sin(p.x)
    );
}
#endif

#ifdef DIAMOND
// diamond definition
float f(vec3 p) {
    SCALE_P;
    return sin(p.x) * sin(p.y) * sin(p.z)
        + sin(p.x) * cos(p.y) * cos(p.z)
        + cos(p.x) * sin(p.y) * cos(p.z)
        + cos(p.x) * cos(p.y) * sin(p.z);
}

// diamond surface normal
vec3 df(vec3 p) {
    SCALE_P;
    return vec3(
        cos(p.x) * sin(p.y) * sin(p.z)
            + cos(p.x) * cos(p.y) * cos(p.z)
            - sin(p.x) * sin(p.y) * cos(p.z)
            - sin(p.x) * cos(p.y) * sin(p.z),
        sin(p.x) * cos(p.y) * sin(p.z)
            - sin(p.x) * sin(p.y) * cos(p.z)
            + cos(p.x) * cos(p.y) * cos(p.z)
            - cos(p.x) * sin(p.y) * sin(p.z),
        sin(p.x) * sin(p.y) * cos(p.z)
            - sin(p.x) * cos(p.y) * sin(p.z)
            - cos(p.x) * sin(p.y) * sin(p.z)
            + cos(p.x) * cos(p.y) * cos(p.z)
    );
}
#endif

#ifdef SCHWARZ_P
float f(vec3 p) {
    SCALE_P;
    return cos(p.x) + cos(p.y) + cos(p.z);
}

vec3 df(vec3 p) {
    SCALE_P;
    return vec3(-sin(p.x), -sin(p.y), -sin(p.z));
}
#endif

#ifdef SPLIT_P
float f(vec3 p) {
    SCALE_P;
    return 1.1 * sin(2 * p.x) * sin(p.z) * cos(p.y)
        + 1.1 * sin(2 * p.y) * sin(p.x) * cos(p.z)
        + 1.1 * sin(2 * p.z) * sin(p.y) * cos(p.x)
        - 0.2 * cos(2 * p.x) * cos(2 * p.y)
        - 0.2 * cos(2 * p.y) * cos(2 * p.z)
        - 0.2 * cos(2 * p.z) * cos(2 * p.x)
        - 0.4 * cos(p.x)
        - 0.4 * cos(p.y)
        - 0.4 * cos(p.z);
}

vec3 df(vec3 p) {
    SCALE_P;
    return vec3(
        2.2 * cos(2 * p.x) * sin(p.z) * cos(p.y)
            + 1.1 * sin(2 * p.y) * cos(p.x) * cos(p.z)
            - 1.1 * sin(2 * p.z) * sin(p.y) * sin(p.x)
            + 0.4 * sin(2 * p.x) * cos(2 * p.y)
            + 0.4 * cos(2 * p.z) * sin(2 * p.x)
            + 0.4 * sin(p.x),

        -1.1 * sin(2 * p.x) * sin(p.z) * sin(p.y)
            + 2.2 * cos(2 * p.y) * sin(p.x) * cos(p.z)
            + 1.1 * sin(2 * p.z) * cos(p.y) * sin(p.x)
            + 0.4 * cos(2 * p.x) * sin(2 * p.y)
            + 0.4 * sin(2 * p.y) * cos(2 * p.z)
            + 0.4 * sin(p.y),

        1.1 * sin(2 * p.x) * cos(p.z) * cos(p.y)
            - 1.1 * sin(2 * p.y) * sin(p.x) * sin(p.z)
            + 2.2 * cos(2 * p.z) * sin(p.y) * cos(p.x)
            + 0.4 * cos(2 * p.y) * sin(2 * p.z)
            + 0.4 * sin(2 * p.z) * cos(2 * p.x)
            + 0.4 * sin(p.z)
    );
}
#endif

fresult solve_f(vec3 direction, vec4 startPos) {
    float d = 0.f;
    float delta = 0.002f;
    float prevF = 9999.f;
    float newF = 9999.f;
    int depth = 0;
    bool firstIter = true;

    vec3 currPos = startPos.xyz;
    vec3 prevPos;

    fresult r;
    r.solutionFound = false;

    const float EPS = 0.0001;

    while (d < sqrt(3)) {
        if (abs(currPos.x) - 0.5f > EPS ||
                abs(currPos.y) - 0.5f > EPS ||
                abs(currPos.z) - 0.5f > EPS) {
            return r;
        }

        newF = f(currPos);

        if (firstIter) {
            firstIter = false;
        } else {
            if (prevF * newF < 0.f) {
                // chatgpt-esque solution...
                vec3 left = prevPos;
                vec3 right = currPos;

                for (int i = 0; i < MAX_DEPTH; i++) {
                    vec3 mid = left + (right - left) * 0.5;
                    if (f(left) * f(mid) < 0.f) {
                        right = mid;
                    } else {
                        left = mid;
                    }
                }

                r.solution = left;

                // chatgpt solution
                float slope = dot(df(r.solution), direction);
                r.increasing = slope > 0.0;

                // say we found a solution
                r.solutionFound = true;
                return r;
            }
        }

        // march along ray (note that this step may fail for very fine geometries)
        d += delta;
        prevPos = currPos;
        currPos += direction * delta;
        prevF = newF;
    }

    return r;
}

void main() {
    vec4 fragPosModel = transInv * fragPosView;
    vec3 dirModel = normalize((transInv * vec4(rayDirection, 0.0)).xyz);

    // "fill in" half the volume by drawing a flat surface
    if (f(fragPosModel.xyz) > 0.f) {
        vec3 lightDirection = normalize(fragPosModel.xyz - lightPos.xyz);
        vec3 normal = cross(dFdx(fragPosView.xyz), dFdy(fragPosView.xyz));
        normal = normalize(normal * sign(normal.z));
        float lightMag = max(dot(normal, lightDirection), 0);
        lightMag = lightMag * lightMag;
        float lightVal = AMBIENT + LIGHT_SCALE * lightMag;
        FragColor = vec4(lightVal, 0.f, 0.f, 1.f);
    }
    // for the rest, raytrace to surface
    else {
        fresult solution = solve_f(dirModel, fragPosModel);

        // draw a hole
        if (!solution.solutionFound) {
            FragColor = vec4(0.2f, 0.3f, 0.3f, 1.0f);
        }
        // draw the surface
        else {
            vec3 lightDirection = normalize(lightPos.xyz - solution.solution);
            vec3 normal = df(solution.solution);
            float lightMag = max(dot(normal, lightDirection), 0);
            lightMag = lightMag * lightMag;
            float lightVal = AMBIENT + LIGHT_SCALE * lightMag;
            FragColor = vec4(0.f, 0.f, lightVal, 1.f);
        }
    }
}
