func findFixpoint(f: Double -> Double, inDomain domain: ClosedInterval<Double>) -> Double? {
    let tolerance = 1e-8
    let optimization = optimize({ abs(f($0) - $0) }, domain: (domain.start, domain.end), tolerance: tolerance)
    if optimization.valueAtExtrema > tolerance { return nil }
    return optimization.extrema
}
