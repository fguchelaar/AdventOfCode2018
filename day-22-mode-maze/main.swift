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

//let depth =  5355
//let target = Point(14, 796)

let depth =  510
let target = Point(10, 10)


var cache = [
    Point(0,0): 0,
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

enum RegionType: Int {
    case rocky = 0
    case wet
    case narrow
}

func regionType(for point: Point) -> RegionType {
    return RegionType(rawValue: erosionLevel(for: point) % 3)!
}

let p1 = (0...target.y).flatMap { y in
    (0...target.x).lazy.map { x in
        regionType(for: Point(x, y))
        }
        .map { $0.rawValue }
}

print ("Part 1:")
print (p1.reduce(0, +))

enum Tool: CaseIterable {
    case climbingGear
    case torch
    case neither
}

func a🌟(start: Point, goal: Point) -> (path: [Point], time: Int) {
    
    func heuristic(_ from: Point, _ to: Point) -> Int {
        // Let's try manhattan
        return abs(from.x - to.x) + abs(from.y - to.y)
    }
    
    func reconstruct(cameFrom: [Point: Point], point: Point) -> [Point] {
        var path = [point]
        var crnt = point
        while let p = cameFrom[crnt] {
            path.insert(p, at: 0)
            crnt = p
        }
        return path
    }
    
    var closed = Set<Point>()
    var open = [start: Tool.torch]
    
    var prev = [Point: Point]()
    
    var gScore = [Point: Int]()
    gScore[start] = 0
    
    var fScore = [Point: Int]()
    fScore[start] = heuristic(start, goal)
    
    var current: Point
    while !open.isEmpty {
        
        current = fScore
            .filter { open.keys.contains($0.key) }
            .min { $0.value < $1.value }!
            .key
        
        if current == goal {
            let cost = gScore[current]! + (open[current]! == .torch ? 0 : 7)
            return (reconstruct(cameFrom: prev, point: current), cost)
        }
        
        let currentTool = open[current]
        open.removeValue(forKey: current)
        closed.insert(current)
        
        current.n4()
            .filter { !closed.contains($0) }
            .forEach { neighbor in
                
                var cost = Int.max
                
                let cType = regionType(for: current)
                let rType = regionType(for: neighbor)
                var newTool = currentTool
                if rType == .rocky {
                    if currentTool == .neither {
                        cost = 8
                        newTool = (cType == .wet ? .climbingGear : .torch)
                    } else {
                        cost = 1
                    }
                } else if rType == .wet {
                    if currentTool == .torch {
                        cost = 7
                        newTool = (cType == .rocky ? .climbingGear : .neither)
                    } else {
                        cost = 8
                    }
                } else if rType == .narrow {
                    if currentTool == .climbingGear {
                        cost = 8
                        newTool = (cType == .wet ? .torch : .neither)
                    } else {
                        cost = 1
                    }
                }
                
                let g = gScore[current, default: Int.max] + cost
                
                if !open.keys.contains(neighbor) {
                    open[neighbor] = newTool
                } else if g >= gScore[neighbor, default: Int.max] {
                    return
                }
                
                prev[neighbor] = current
                gScore[neighbor] = g
                fScore[neighbor] = heuristic(neighbor, goal) + g
        }
    }
    
    return ([Point](), -1)
}

print ("Part 2:")
print (a🌟(start: Point(0, 0), goal: target).time)

//1106 H
//1105 H
//1099 H
