import Foundation

let input = 5791

func power(at pos: (x: Int, y: Int)) -> Int {
    let rackId = pos.x + 10
    var power = rackId * pos.y
    power += input
    power *= rackId
    power = (power % 1000) / 100
    power -= 5
    return power
}

func valueOfSquare(of size: Int, in grid: [[Int]], at pos: (x: Int, y: Int)) -> Int {
    return grid[(pos.y)..<(pos.y)+size]
        .map { $0[(pos.x)..<(pos.x)+size] }
        .flatMap { $0 }
        .reduce(0, +)
}

// initialize the grid
var grid = Array(repeating: Array(repeating: 0, count: 300), count: 300)
for y in 0..<grid.count {
    for x in 0..<grid[y].count {
        grid[y][x] = power(at: (x+1, y+1))
    }
}

func maxValue(with size: Int) -> (x: Int, y: Int) {
    let positions = (0..<grid.count-size)
        .map { y in (0..<grid.count-size).map { ($0, y)} }
        .flatMap { $0 }
    
    return positions.max {
        valueOfSquare(of: size, in: grid, at: $0) < valueOfSquare(of: size, in: grid, at: $1)
        }!
}

let max = maxValue(with: 3)
print("Part 1:")
print("\(max.0 + 1),\(max.1 + 1)")

print("Part 2:")
for s in (16...16) { // solution is at #16, doing them all takes long, found it by printing the subtotals
    let maximum = maxValue(with: s)
    let value = valueOfSquare(of: s, in: grid, at: maximum)
    print ("\(value) = \(maximum.0 + 1),\(maximum.1 + 1),\(s)")
}
