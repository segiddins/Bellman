import Darwin

let phi: Double = (sqrt(5) + 1)/2
let squaredInversePhi = 0.5 * (3 - sqrt(5))

// Taken from R, since golden-section alone isn't getting us convergence
public func optimize(@noescape value: Double -> Double,
                     domain: (min: Double, max: Double),
                     maximum: Bool = false,
                     tolerance: Double = 1e-3) -> (valueAtExtrema: Double, extrema: Double) {
    let valueScale: Double = maximum ? -1 : 1
    // Local variables
    var a, b, d, e, p, q, r, u, v, w, x: Double
    var t2, fu, fv, fw, fx, xm, eps, tol1, tol3: Double
    
    /*  eps is approximately the square root of the relative machine precision. */
    eps = DBL_EPSILON
    tol1 = eps + 1 // smallest double greater than 1
    eps = sqrt(eps)
    
    a = domain.min
    b = domain.max
    v = a + squaredInversePhi * (b - a)
    w = v
    x = v
    
    d = 0
    e = 0
    fx = value(x) * valueScale
    fv = fx
    fw = fx
    tol3 = tolerance / 3
    
    // main loop start
    while true {
        xm = (a + b) * 0.5
        tol1 = eps * abs(x) + tol3
        t2 = tol1 * 2
        
        // check stopping criterion
        
        if (abs(x - xm) <= t2 - (b - a) * 0.5) { break }
        p = 0
        q = 0
        r = 0
        if abs(e) > tol1 { // fit parabola
            r = (x - w) * (fx - fv)
            q = (x - v) * (fx - fw)
            p = (x - v) * q - (x - w) * r
            q = (q - r) * 2
            if q > 0 { p = -p} else { q = -q }
            r = e
            e = d
        }
        
        if abs(p) >= abs(q * 0.5 * r) || p <= q * (a - x) || p > q * (b - x) { // a golden-section step
            if x < xm { e = b - x } else { e = a - x }
            d = squaredInversePhi * e
        }
        else { // a parabolix-interpolation step
            d = p / q
            u = x + d
            
            // f must not be evaluated too close to ax or bx
            if u - a < t2 || b - u < t2 { d = tol1 }
            if x >= xm { d = -d }
        }
        
        // f must not be evaluated too close to x
        if abs(d) >= tol1 { u = x + d } else if d > 0 { u = x + tol1} else { u = x - tol1 }
        
        fu = value(u) * valueScale
        
        // update  a, b, v, w, and x
        if fu <= fx {
            if u < x { b = x } else { a = x }
            v = w
            w = x
            x = u
            fv = fw
            fw = fx
            fx = fu
        }
        else {
            if u < x { a = u } else { b = u }
            if fu <= fw || w == x {
                v = w
                fv = fw
                w = u
                fw = fu
            }
            else if fu <= fv || v == x || v == w {
                v = u
                fv = fu
            }
        }
    } // end of main loop
    return (value(x), x)
}

//public func optimize(value: Double -> Double,
//                     domain: (min: Double, max: Double),
//                     interiorPoint: Double,
//                     maximum: Bool = false,
//                     tau: Double = 1e-3)
//    -> (valueAtExtrema: Double, extrema: Double) {
//        precondition(interiorPoint <= domain.max && interiorPoint > domain.min, "\(interiorPoint) is not in \(domain)")
//        let x: Double
//        if interiorPoint < domain.max {
//            x = interiorPoint + (2 - phi) * (domain.max - interiorPoint)
//        }
//        else {
//            x = interiorPoint - (2 - phi) * (interiorPoint - domain.min)
//        }
//        if abs(domain.max - domain.min) < tau * (abs(interiorPoint) + abs(x)) {
//            let max = (domain.max + domain.min) / 2
//            return (value(max), max)
//        }
//        if maximum ? value(x) > value(interiorPoint) : value(x) < value(interiorPoint) {
//            // move towards x
//            if interiorPoint < domain.max {
//                return optimize(value, domain: (interiorPoint, domain.max), interiorPoint: x, maximum: maximum)
//            }
//            else {
//                return optimize(value, domain: (domain.min, interiorPoint), interiorPoint: x, maximum: maximum)
//            }
//        }
//        else {
//            // move towards interiorPoint
//            if interiorPoint < domain.max {
//                return optimize(value, domain: (domain.min, x), interiorPoint: interiorPoint, maximum: maximum)
//            }
//            else {
//                return optimize(value, domain: (x, domain.max), interiorPoint: interiorPoint, maximum: maximum)
//            }
//        }
//}