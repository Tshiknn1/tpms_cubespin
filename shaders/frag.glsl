#version 330 core

out vec4 FragColor;

#define MAX_DISTANCE sqrt(3)
#define MAX_DEPTH 128

#define AMBIENT 0.2f
#define LIGHT_SCALE 0.8f
#define FREQ_SCALE 0.5f

#define DIAMOND

//in vec3 ourColor;
//in vec2 TexCoord;
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
    p = freq * 2 * 3.1415926535897932 * p;
    return cos(p.x) * sin(p.y) + cos(p.y) * sin(p.z) + cos(p.z) * sin(p.x);
}

// gyroid surface normal (surface gradient)
vec3 df(vec3 p) {
    p = freq * 2 * 3.1415926535897932 * p;
    return vec3(
        -sin(p.x) * sin(p.y) + cos(p.z) * cos(p.x),
        cos(p.x) * cos(p.y) - sin(p.y) * sin(p.z),
        cos(p.y) * cos(p.z) - sin(p.z) * sin(p.x)
    );
}
#endif

#ifdef DIAMOND
// diamond
float f(vec3 p) {
    p = freq * 2 * 3.1415926535897932 * p;
    return sin(p.x) * sin(p.y) * sin(p.z)
        + sin(p.x) * cos(p.y) * cos(p.z)
        + cos(p.x) * sin(p.y) * cos(p.z)
        + cos(p.x) * cos(p.y) * sin(p.z);
}

// diamond surface normal
vec3 df(vec3 p) {
    p = freq * 2 * 3.1415926535897932 * p;
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
    p = freq * 2 * 3.1415926535897932 * p;
    return cos(p.x) + cos(p.y) + cos(p.z);
}

vec3 df(vec3 p) {
    p = freq * 2 * 3.1415926535897932 * p;
    return vec3(-sin(p.x), -sin(p.y), -sin(p.z));
}
#endif

//fresult solve_f(vec3 direction, vec4 startPos)
//{
//    fresult r;
//    r.solutionFound = false;
//
//    vec3 ro = startPos.xyz;
//    vec3 rd = normalize(direction); // important
//
//    float tEnter, tExit;
//    if (!rayBox(ro, rd, vec3(-0.5), vec3(0.5), tEnter, tExit))
//        return r;
//
//    // start just inside the box to avoid immediate "outside" due to precision
//    const float EPS_IN = 1e-4;
//    float t = max(tEnter, 0.0) + EPS_IN;
//
//    float delta = 0.002; // consider scaling with (tExit - tEnter) / N
//
//    float prevF = 0.0;
//    bool first = true;
//
//    vec3 prevPos = ro + rd * t;
//    vec3 currPos = prevPos;
//
//    while (t <= tExit)
//    {
//        currPos = ro + rd * t;
//
//        float newF = f(currPos);
//
//        if (!first)
//        {
//            if (prevF == 0.0) {
//                r.solutionFound = true;
//                r.solution = prevPos;
//                return r;
//            }
//            if (prevF * newF < 0.0)
//            {
//                // bisection between prevPos (t-delta) and currPos (t)
//                float a = t - delta, b = t;
//                for (int i = 0; i < MAX_DEPTH; i++) {
//                    float m = 0.5 * (a + b);
//                    float fa = f(ro + rd * a);
//                    float fm = f(ro + rd * m);
//                    if (fa * fm < 0.0) b = m; else a = m;
//                }
//                r.solution = ro + rd * (0.5 * (a + b));
//                r.increasing = dot(df(r.solution), rd) > 0.0;
//                r.solutionFound = true;
//                return r;
//            }
//        }
//
//        first = false;
//        prevF = newF;
//        prevPos = currPos;
//        t += delta;
//    }
//
//    return r;
//}

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

    //float maxDistance = calcMaxDistance(direction, startPos);

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

    if (f(fragPosModel.xyz) > 0.f) {
        vec3 lightDirection = normalize(fragPosModel.xyz - lightPos.xyz);
        vec3 normal = cross(dFdx(fragPosView.xyz), dFdy(fragPosView.xyz));
        normal = normalize(normal * sign(normal.z));
        float lightMag = max(dot(normal, lightDirection), 0);
        lightMag = lightMag * lightMag;
        float lightVal = AMBIENT + LIGHT_SCALE * lightMag;
        FragColor = vec4(lightVal, 0.f, 0.f, 1.f);
    } else {
        fresult solution = solve_f(dirModel, fragPosModel);

        if (!solution.solutionFound) {
            FragColor = vec4(0.2f, 0.3f, 0.3f, 1.0f);
            //FragColor = vec4(0.f, 0.f, 0.f, 1.f);
        }
        else {
            vec3 lightDirection = normalize(lightPos.xyz - solution.solution);
            vec3 normal = df(solution.solution);
            float lightMag = max(dot(normal, lightDirection), 0);
            lightMag = lightMag * lightMag;
            float lightVal = AMBIENT + LIGHT_SCALE * lightMag;
            FragColor = vec4(0.f, 0.f, lightVal, 1.f);
            //if (solution.increasing) {
            //    FragColor = vec4(0.f, 0.f, lightVal, 1.f);
            //} else {
            //    FragColor = vec4(lightVal, 0.f, 0.f, 1.f);
            //}
        }
        //if (!solution.increasing) {
        //    float lightVal = AMBIENT + LIGHT_SCALE * lightMag;
        //    FragColor = vec4(0.f, 0.f, lightVal, 1.f);
        //} else {
        //    float lightVal = AMBIENT + LIGHT_SCALE * (lightMag);
        //    FragColor = vec4(lightVal, 0.f, 0.f, 1.f);
        //}
        //FragColor = vec4(0.f, 0.f, lightVal, 1.f);
    }
}
