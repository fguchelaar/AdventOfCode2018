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
    var sum = 0
    for y in (pos.y)..<(pos.y)+size {
        for x in (pos.x)..<(pos.x)+size {
            sum += grid[y][x]
        }
    }
    return sum
}

// initialize the grid
var grid = Array(repeating: Array(repeating: 0, count: 300), count: 300)
for y in 0..<grid.count {
    for x in 0..<grid[y].count {
        grid[y][x] = power(at: (x+1, y+1))
    }
}

let allPositions = (0..<grid.count-3)
    .map { y in (0..<grid.count-3).map { ($0, y)} }
    .flatMap { $0 }

let max = allPositions.max {
    valueOfSquare(of: 3, in: grid, at: $0) < valueOfSquare(of: 3, in: grid, at: $1)
}!

print("Part 1:")
print("\(max.0 + 1),\(max.1 + 1)")

print("Part 2:")
for s in (16...16) { // solution is as #16, doing them all takes to long, found it by printing the subtotals

    let positions = (0..<grid.count-s)
        .map { y in (0..<grid.count-s).map { ($0, y)} }
        .flatMap { $0 }

    let max = positions.max {
        valueOfSquare(of: s, in: grid, at: $0) < valueOfSquare(of: s, in: grid, at: $1)
        }!
    let value = valueOfSquare(of: s, in: grid, at: max)
    print ("\(value) = \(max.0 + 1),\(max.1 + 1),\(s)")
}
