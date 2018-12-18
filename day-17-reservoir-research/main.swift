import Foundation

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

extension String {
    func extractInts() -> [Int] {
        return self.split(whereSeparator: { !"-1234567890".contains($0) }).compactMap { Int($0) }
    }
}

struct Point: Hashable, Equatable {
    var x: Int
    var y: Int
    
    var up: Point { return Point(x: x, y: y-1) }
    var left: Point { return Point(x: x-1, y: y) }
    var right: Point { return Point(x: x+1, y: y) }
    var down: Point { return Point(x: x, y: y+1) }
}

func parse(line: String) -> (x: ClosedRange<Int>, y: ClosedRange<Int>) {
    var ints = line.extractInts()
    let a = (ints[0]...ints[0])
    let b = (ints[1]...ints[2])
    return line.starts(with: "x") ? (a,b) : (b,a)
}

let ranges = input.components(separatedBy: .newlines)
    .map(parse)

let points = ranges.flatMap { range in
    range.x.flatMap { x in
        range.y.map { y in
            Point(x: x, y: y)
        }
    }
}

let minmax = points.reduce((Point(x: Int.max, y: Int.max), Point(x: Int.min, y: Int.min))) { (minmax, point) in
    let minPoint = Point(x: min(minmax.0.x, point.x), y: min(minmax.0.y, point.y))
    let maxPoint = Point(x: max(minmax.1.x, point.x), y: max(minmax.1.y, point.y))
    return (minPoint, maxPoint)
}

var clay = Set<Point>(points)
let startPoint = Point(x: 500, y: minmax.0.y).up
var springs = [Point]()
var water = Set<Point>()
var currentSpring = startPoint

func out(filename: String) {
    let debug = (minmax.0.y-1...minmax.1.y+1)
        .map { y in
            (minmax.0.x-1...minmax.1.x+1).map { x in
                let point = Point(x: x, y: y)
                if startPoint == point {
                    return "+"
                } else if point == currentSpring {
                    return "X"
                } else if clay.contains(point) && water.contains(point) {
                    return "~"
                } else if springs.contains(point) {
                    return "0"
                } else if water.contains(point) {
                    return "|"
                } else {
                    return clay.contains(point) ? "#" : "."
                }
                }.joined()
        }.joined(separator: "\r\n")
    
    // mind you: running from Xcode will put the file in the build-folder. Perhaps useful to append the path with
    // some known folder before running
    try! debug.write(toFile: filename, atomically: true, encoding: .ascii)
}

func down(point: Point) -> Bool {
    let p = Point(x: point.x, y: point.y+1)
    return p.y <= minmax.1.y
        && !clay.contains(p)
}

func leftEdge(point: Point) -> (point: Point, isSpring: Bool) {
    var edge = point
    while true {
        if !clay.contains(edge.down) {
            return (edge, true)
        } else if clay.contains(edge.left) {
            return (edge, false)
        }
        edge = edge.left
    }
}

func rightEdge(point: Point) -> (point: Point, isSpring: Bool) {
    var edge = point
    while true {
        if !clay.contains(edge.down) {
            return (edge, true)
        } else if clay.contains(edge.right) {
            return (edge, false)
        }
        edge = edge.right
    }
}

var current = startPoint
currentSpring = current
springs.append(startPoint)
while true {
    
    while(down(point: current)) {
        current = Point(x: current.x, y: current.y + 1)
        water.insert(current)
    }
    
    let left = leftEdge(point: current)
    let right = rightEdge(point: current)
    
    if current.down.y > minmax.1.y {
        springs.removeFirst()
    }
    else if left.point == right.point {
        
        clay.insert(current)
        if current == currentSpring {
            springs.removeFirst()
        }
    }
    else if !(left.point.x...right.point.x).allSatisfy({water.contains(Point(x: $0, y: current.y))}) {
        
        (left.point.x...right.point.x).forEach { x in
            let p = Point(x: x, y: current.y)
            water.insert(p)
            // make clay
            if !(left.isSpring || right.isSpring) {
                clay.insert(p)
            }
        }
        // make wells
        if left.isSpring {
            springs.insert(left.point, at: 0)//.append(left.point)
        }
        if right.isSpring {
            springs.insert(right.point, at: 0)//.append(right.point)
        }
        
    } else {
        springs.removeFirst()
    }
    
    if springs.isEmpty {
        print("no more springs")
        break
    }
    current = springs.first!
    currentSpring = current
}

print("Part 1:")
print(water.count)
//out(filename: "END.txt")

print("Part 2:")
print(clay.intersection(water).count)
