import Foundation

struct Point: Hashable, Equatable {
    var x, y: Int
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    func n4() -> [Point] {
        return [
            Point(x-1, y),
            Point(x+1, y),
            Point(x, y-1),
            Point(x, y+1)
            ].filter { $0.x >= 0 && $0.y >= 0 }
    }
}

let depth =  5355
let target = Point(14, 796)

var cache = [
    Point(0, 0): 0,
    target: 0
]

func geoIndex(for point: Point) -> Int {
    if let cached = cache[point] {
        return cached
    }

    if point.y == 0 {
        cache[point] = point.x * 16807
    } else if point.x == 0 {
        cache[point] = point.y * 48271
    } else {
        cache[point] = erosionLevel(for: Point(point.x-1, point.y)) * erosionLevel(for: Point(point.x, point.y-1))
    }

    return cache[point]!
}

func erosionLevel(for point: Point) -> Int {
    return (geoIndex(for: point) + depth) % 20183
}

func regionType(for point: Point) -> RegionType {
    return RegionType(rawValue: erosionLevel(for: point) % 3)!
}

enum RegionType: Int {
    case rocky = 0
    case wet
    case narrow
}

enum Tool {
    case climbingGear
    case torch
    case neither
}

let p1 = (0...target.y).flatMap { y in
    (0...target.x).lazy.map { x in
        regionType(for: Point(x, y))
        }
        .map { $0.rawValue }
}

print ("Part 1:")
print (p1.reduce(0, +))

func a🌟(start: Point, goal: Point) -> Int {

    struct State: Hashable, Equatable {
        var point: Point
        var tool: Tool

        func neighbors() -> [State] {
            return point.n4().map { neighbor in

                let currentType = regionType(for: point)
                let neighborType = regionType(for: neighbor)

                var newTool = tool
                if neighborType == .rocky {
                    if tool == .neither {
                        newTool = (currentType == .wet ? .climbingGear : .torch)
                    }
                } else if neighborType == .wet {
                    if tool == .torch {
                        newTool = (currentType == .rocky ? .climbingGear : .neither)
                    }
                } else if neighborType == .narrow {
                    if tool == .climbingGear {
                        newTool = (currentType == .wet ? .neither : .torch)
                    }
                }
                return State(point: neighbor, tool: newTool)
            }
        }
    }

    func cost(_ from: State, to: State) -> Int {
        return from.tool == to.tool ? 1 : 8
    }

    func heuristic(_ from: Point, _ to: Point) -> Int {
        // Let's try manhattan
        return abs(from.x - to.x) + abs(from.y - to.y)
    }

    var closed = Set<State>()
    let startState = State(point: start, tool: .torch)

    var open = [(state: startState, cost: 0)]

    var gScore = [State: Int]()
    gScore[startState] = 0

    var current: (state: State, cost: Int)
    while !open.isEmpty {

        current = open.removeFirst()

        if current.state.point == goal {
            return gScore[current.state]! + (current.state.tool == .torch ? 0 : 7)
        }

        closed.insert(current.state)

        current.state.neighbors()
            .filter { !closed.contains($0) }
            .forEach { neighbor in

                let g = gScore[current.state, default: Int.max] + cost(current.state, to: neighbor)

                if g >= gScore[neighbor, default: Int.max] {
                    return
                }

                gScore[neighbor] = g
                let f = heuristic(neighbor.point, goal) + g

                // find insert-point
                var idx = 0
                for _ in 0..<open.count {
                    if open[idx].cost >= f {
                        break
                    }
                    idx += 1
                }
                open.insert((neighbor, f), at: idx)
        }
    }
    return -1
}

print ("Part 2:")
print (a🌟(start: Point(0, 0), goal: target))
