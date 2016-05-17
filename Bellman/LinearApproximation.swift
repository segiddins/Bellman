public func linearApproximation(points: [Double], values: [Double]) -> (Double) -> Double {
    return { x in
        if x <= points.first! { return values.first! }
        if x >= points.last! { return values.last! }
        var left = 0
        var right = points.count - 1
        while left < right - 1 {
            let pivot = (left + right) / 2
            if x < points[pivot] { right = pivot }
            else { left = pivot }
        }
        
        let leftEndpoint = points[left]
        let rightEndpoint = points[left + 1]
        let leftValue = values[left]
        let rightValue = values[left + 1]
        
        if x == leftEndpoint { return leftValue }
        if x == rightEndpoint { return rightValue }
        
        return leftValue + (rightValue - leftValue) / (rightEndpoint - leftEndpoint) * (x - leftEndpoint)
    }
}
