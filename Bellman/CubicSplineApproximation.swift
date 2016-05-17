import func Darwin.pow

public func cubicSplineApproximation(points: [Double], values: [Double]) -> (Double) -> Double {
    var u = [Double](count: points.count, repeatedValue: 0)
    var z = [Double](count: points.count, repeatedValue: 0)
    
    for i in 1..<(points.count - 1) {
        let p = 0.5 * z[i - 1] + 2.0
        z[i] = -0.5 / p
        u[i] = values[i + 1] + values[i - 1] - 2 * values[i]
        u[i] = (3 * u[i] - 0.5 * u[i - 1]) / p
    }
    
    for i in (1..<points.count - 1).reverse() {
        z[i] = z[i] * z[i + 1] + u[i]
    }
    
    var polynomials = [(Double, Double, Double, Double)]()
    for i in 0..<(points.count - 1) {
        polynomials.append((values[i+1], values[i], z[i+1], z[i]))
    }
    
    return { x in
        var left = 0
        var right = points.count - 1
        while left < right - 1 {
            let pivot = (left + right) / 2
            if x < points[pivot] { right = pivot }
            else { left = pivot }
        }
        
        let leftPoint = points[left]
        let rightPoint = points[left + 1]
        let p = polynomials[left]
        
        if x == leftPoint { return values[left] }
        if x == rightPoint { return values[right] }
        
        let linear = p.0 * (x - leftPoint) + p.1 * (rightPoint - x)
        let cubic: Double =
                p.2 *
                    ((pow(x - leftPoint, 3) as Double)
                        - (x - leftPoint)) / 6
                + p.3 *
                    ((pow(rightPoint - x, 3) as Double)
                        - (rightPoint - x)) / 6
        return (linear + cubic) / (rightPoint - leftPoint)
    }
}