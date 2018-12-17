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

let clay = Set<Point>(points)
let startPoint = Point(x: 500, y: minmax.0.y)
var joints = [Point]()
var water = [Point: Bool]()
var currentJoint = startPoint

func out(filename: String) {
    let debug = (minmax.0.y-1...minmax.1.y+1)
        .map { y in
            (minmax.0.x-1...minmax.1.x+1).map { x in
                let point = Point(x: x, y: y)
                if startPoint == point {
                    return "V"
                } else if point == currentJoint {
                    return "X"
                } else if joints.contains(point) {
                    return "0"
                } else if let _ = water[point] {
                    return "|"
                } else {
                    return clay.contains(point) ? "#" : "."
                }
                }.joined()
        }.joined(separator: "\r\n")
    
    //print(debug)
    try! debug.write(toFile: "/Users/frank/Workspace/bitbucket/fguchelaar/AdventOfCode2018/day-17-reservoir-research/\(filename)", atomically: true, encoding: .ascii)
}

func down(point: Point) -> Bool {
    let p2 = Point(x: point.x, y: point.y+1)
    return p2.y <= minmax.1.y && !clay.contains(p2) && !water.contains { $0.key == p2}
}

func left(point: Point) -> Bool {
    let p2 = Point(x: point.x-1, y: point.y)
    let p3 = Point(x: point.x-1, y: point.y+1)
    let p4 = Point(x: point.x, y: point.y+1)
    let p5 = Point(x: point.x-1, y: point.y+1)
    return
        !clay.contains(p2)
            && !water.contains { $0.key == p2}
            && ((clay.contains(p3) || water.contains { $0.key == p3})
                    || (clay.contains(p4) && !water.contains { $0.key == p5}))
}

func right(point: Point) -> Bool {
    let p2 = Point(x: point.x+1, y: point.y)
    let p3 = Point(x: point.x+1, y: point.y+1)
    let p4 = Point(x: point.x, y: point.y+1)
    let p5 = Point(x: point.x+1, y: point.y+1)
    return
        !clay.contains(p2)
            && !water.contains { $0.key == p2}
            && ((clay.contains(p3) || water.contains { $0.key == p3})
                || (clay.contains(p4) && !water.contains { $0.key == p5}))
}

var current = startPoint
outer: for i in 0...1000 {

//    print(joints)
//    out(filename: "after.\(i).txt")

    while(down(point: current)) {
        current = Point(x: current.x, y: current.y + 1)
        water[current] = true
    }

    if left(point: current) || right(point: current) {
        joints.insert(current, at: 0)
    
//    out(filename: "step.1.txt")
    while(left(point: current)) {
        current = Point(x: current.x-1, y: current.y)
        water[current] = true
        if (down(point: current)) {
            continue outer
        }
    }
    
//    out(filename:"step.2.txt")
    current = joints.first!
    currentJoint = current

    while(right(point: current)) {
        current = Point(x: current.x+1, y: current.y)
        water[current] = true
        if (down(point: current)) {
            continue outer
        }
    }
    
//    out(filename: "step.3.txt")
    }
    else {
//        out(filename: "no option \(i).txt")
    }

    current = joints.first!
    if current == startPoint {
        break
    }
    current = Point(x: current.x, y: current.y - 1)
    water[current] = true
    currentJoint = current
    joints.remove(at: 0)
}

out(filename: "after 100 steps.txt")
