import Darwin

func update_cakesWithBaking(currentValue: Double, valueFunction: Double -> Double) -> (optimumToday: Double, valueFunctionPrime: Double) {
    let ifBakes = beta * (p * valueFunction(currentValue + 1) + (1 - p) * valueFunction(currentValue))
    if currentValue <= 0 {
        return (-p, ifBakes)
    }

    let functionToOptimize: Double -> Double = { nextValue in
        return sqrt(currentValue - nextValue) + beta * valueFunction(nextValue)
    }
    
    let result = optimize(functionToOptimize, domain: (0, currentValue), maximum: true)
    if ifBakes > result.valueAtExtrema { return (-p, ifBakes) }
    return (currentValue - result.extrema, result.valueAtExtrema)
}

func update_ncgSocialPlanner(currentValue: Double, valueFunction: Double -> Double) -> (optimumToday: Double, valueFunctionPrime: Double) {
    if currentValue <= 0 {
        return (0, beta * valueFunction(0))
    }

    func consumption(k_t: Double, k_t1: Double) -> Double {
        return (1 - delta) * k_t + (pow(k_t, alpha) as Double) - (1 + g) * k_t1
    }
    
    func functionToOptimize(nextValue: Double) -> Double {
        return log(consumption(currentValue, k_t1: nextValue)) + beta * valueFunction(nextValue)
    }

    let result = optimize(functionToOptimize, domain: (0, (1 - delta) * currentValue + pow(currentValue, alpha)), maximum: true)
    return (consumption(currentValue, k_t1: result.extrema), result.valueAtExtrema)
}

func update_ncgSocialPlannerWithLabor(currentValue: Double, valueFunction: Double -> Double) -> (optimumToday: (c_t: Double, l_t: Double, k_t1: Double), valueFunctionPrime: Double) {
    if currentValue <= 0 {
        return ((0, 0, 0), beta * valueFunction(0))
    }
    
    func consumption(k_t: Double, k_t1: Double, l_t: Double) -> Double {
        return (1 - delta) * k_t + (pow(k_t, alpha) as Double) * (pow(A * l_t, 1 - alpha) as Double) - (1 + g) * k_t1
    }
    
    func utility(consumption: Double, labor: Double, k_t1: Double) -> Double {
        return log(consumption) - gamma * epsilon / (1 + epsilon) * pow(labor, (1 + epsilon) / epsilon) + beta * valueFunction(k_t1)
    }
    
    func capitalFunctionToOptimize(k_t1: Double) -> Double {
        func laborFunctionToOptimize(l_t: Double) -> Double {
            let consumption = consumption(currentValue, k_t1: k_t1, l_t: l_t)
            return utility(consumption, labor: l_t, k_t1: k_t1)
        }
        let labor = optimize(laborFunctionToOptimize, domain: (0.0, 1.0), maximum: true).extrema
        let consumption = consumption(currentValue, k_t1: k_t1, l_t: labor)
        return utility(consumption, labor: labor, k_t1: k_t1)
    }
    
    let result = optimize(capitalFunctionToOptimize, domain: (0, (1 - delta) * currentValue + pow(currentValue, alpha)), maximum: true)
    let k_t1 = result.extrema
    let l_t = optimize({ utility(consumption(currentValue, k_t1: k_t1, l_t: $0), labor: $0, k_t1: k_t1) }, domain: (0,1), maximum: true).extrema
    let c_t = consumption(currentValue, k_t1: k_t1, l_t: l_t)
    
    return ((c_t, l_t, k_t1), result.valueAtExtrema)
}


public func iterateValueFunctions<Policy>
    (update: (currentValue: Double, valueFunction: Double -> Double) -> (optimumToday: Policy, valueFunctionPrime: Double),
                                  grid: [Double],
                                  values: [Double])
    -> (policy: [Policy], values: [Double]) {
    var values = values
    while true {
        let vfunc = linearApproximation(grid, values: values)
        let result = grid.map { update(currentValue: $0, valueFunction: vfunc) }
        let policy = result.map { $0.optimumToday }
        let newValues = result.map { $0.valueFunctionPrime }
        if zip(values, newValues).map(-).map(abs).maxElement()! < tolerance * (1 - beta) {
            return (policy, values)
        }
        print(zip(values, newValues).enumerate().map { (grid[$0], abs($1.1 - $1.0)) }.maxElement {$1.1>$0.1} )
        values = newValues
    }
}