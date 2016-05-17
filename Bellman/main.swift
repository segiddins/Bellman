import Darwin

let beta = 0.95
let initialValue = 1.0
let maximumValue = 2.0
let gridPoints = 200

let p = 0.6

let delta = 0.05
let alpha = 0.3
let g = 0.02
let A = 1.0
let L = 1.0

let gamma = 1.0
let epsilon = 0.3

let grid = (1...gridPoints).map { 2 * 3.4001031088831821 * Double($0) / Double(gridPoints) }
//let grid = (0...gridPoints).map { maximumValue * Double($0) / Double(gridPoints) }

let guess: Double -> Double = sqrt
let tolerance = 1e-8

let result = iterateValueFunctions(update_ncgSocialPlannerWithLabor, grid: grid, values: grid.map(guess))

let data: Array<Double> -> String = { "$DATA << EOD\n\(zip(grid, $0).map { "\($0) \($1)\n" }.joinWithSeparator("\n"))\nEOD" }

let k_bar = findFixpoint(linearApproximation(grid, values: result.policy.map { $0.k_t1 } ), inDomain: ClosedInterval(grid.first!, grid.last!))
print("k_bar = \(k_bar)")

gnuplot("Labor", args: ["set title \"Labor\"",
    "set zeroaxis",
    "set xlabel 'k'",
    "set ylabel 'l(k)'",
    data(result.policy.map {$0.l_t}),
    "plot $DATA with line lt -1 lw 2 notitle"])

gnuplot("Consumption", args: ["set title \"Consumption\"",
    "set zeroaxis",
    "set xlabel 'k'",
    "set ylabel 'c(k)'",
    data(result.policy.map {$0.c_t}),
    "plot $DATA with line lt -1 lw 2 notitle"])

gnuplot("Capital", args: ["set title \"Capital\"",
    "set zeroaxis",
    "set xlabel 'k_t'",
    "set ylabel 'k_{t+1}(k_t)'",
    data(result.policy.map {$0.k_t1}),
    "plot $DATA with line lt -1 lw 2 notitle, x title 'k_{t+1} = k_t'"])

gnuplot("Value", args: ["set title \"Value Function\"",
    "set zeroaxis",
    "set xlabel 'k'",
    "set ylabel 'v(k)'",
    data(result.values),
    "plot $DATA with line lt -1 lw 2 notitle"])
