import Foundation

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

extension CGPoint: Hashable {
    public var hashValue: Int {
        return x.hashValue << 32 ^ y.hashValue
    }
    
    func distance(to other: CGPoint) -> Int {
        return abs(Int(self.x) - Int(other.x)) + abs(Int(self.y) - Int(other.y))
    }
}

var coordinateMap: [CGPoint: [CGPoint]] = input
    .components(separatedBy: .newlines)
    .map {
        let xy = $0.components(separatedBy: ", ").map { Int($0)! }
        let c = CGPoint(x: xy[0], y: xy[1])
        return c
    }
    .reduce(into: [CGPoint: [CGPoint]]()) {
        $0[$1] = [CGPoint]()
}

// find the grid's edges
let minPoint = coordinateMap
    .keys
    .reduce(CGPoint(x: Int.max, y: Int.max)) {
        CGPoint(x: min($0.x, $1.x), y: min($0.y, $1.y))
}
let maxPoint = coordinateMap
    .keys
    .reduce(CGPoint.zero) {
        CGPoint(x: max($0.x, $1.x), y: max($0.y, $1.y))
}

// Keep a list of all coordinates that are on the edge of the grid
var boundaryCoordinates = [CGPoint]()
var contested = [CGPoint]()

var grid = [CGPoint: Int]()

for x in Int(minPoint.x)...Int(maxPoint.x) {
    for y in Int(minPoint.y)...Int(maxPoint.y) {
        
        let c = CGPoint(x: x, y: y)
        
        // distance to all coordinates
        let distances = coordinateMap.keys.reduce(into: [CGPoint: Int]()) {
            $0[$1] = $1.distance(to: c)
        }
        
        // Part 2: fill the grid with distances
        grid[c] = distances.values.reduce(0, +)
        
        // minimal distance
        let minimal = distances.values.min()!
        
        // closest coordinate(s)
        let closest = distances.filter { (arg) -> Bool in
            return arg.value == minimal
        }
        
        if closest.count == 1 {
            if x == Int(minPoint.x) || y == Int(minPoint.y) || x == Int(maxPoint.x) || y == Int(maxPoint.y) {
                boundaryCoordinates.append(closest.first!.key)
            } else {
                var list = coordinateMap[closest.first!.key] ?? [CGPoint]()
                list.append(c)
                coordinateMap[closest.first!.key] = list
            }
        }
        else {
            contested.append(c)
        }
    }
}

let areas = coordinateMap
    .filter { !boundaryCoordinates.contains($0.key) }
    .map { ($0.key, $0.value.count) }
    .sorted { $0.1 > $1.1 }

print("Part 1:")
print(areas)

print("Part 2:")
print(grid.values.filter { $0 < 10000 }.count )
