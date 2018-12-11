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
        .flatMap { $0[(pos.x)..<(pos.x)+size] }
        .reduce(0, +)
}

func maxValue(with size: Int) -> (x: Int, y: Int) {
    let x = (0..<(grid.count - size + 1))
        .flatMap { y in (0..<(grid.count - size + 1)).map { ($0, y)} }
        .map { ($0.0, $0.1, valueOfSquare(of: size, in: grid, at: $0)) }
        .max { $0.2 < $1.2 }!
    return (x.0,x.1)
}

// initialize the grid
var grid = Array(repeating: Array(repeating: 0, count: 300), count: 300)
for y in 0..<grid.count {
    for x in 0..<grid[y].count {
        grid[y][x] = power(at: (x+1, y+1))
    }
}

let maxp1 = maxValue(with: 3)
print("Part 1:")
print("\(maxp1.0 + 1),\(maxp1.1 + 1)")

print("Part 2:")
for s in (16...16) { // solution is at #16, doing them all takes long, found it by printing the subtotals
    let maxp2 = maxValue(with: s)
    let value = valueOfSquare(of: s, in: grid, at: maxp2)
    print ("\(value) = \(maxp2.0 + 1),\(maxp2.1 + 1),\(s)")
}
