import Foundation

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

struct Point: Hashable {

    var x: Int
    var y: Int
    
    static var zero: Point {
        return Point(x: 0, y: 0)
    }
    
    public var hashValue: Int {
        return x.hashValue << 32 ^ y.hashValue
    }
    
    func distance(to other: Point) -> UInt {
        return (self.x - other.x).magnitude + (self.y - other.y).magnitude
    }
}

var coordinateMap: [Point: [Point]] = input
    .components(separatedBy: .newlines)
    .map {
        let xy = $0.components(separatedBy: ", ").map { Int($0)! }
        let c = Point(x: xy[0], y: xy[1])
        return c
    }
    .reduce(into: [Point: [Point]]()) {
        $0[$1] = [Point]()
}

// find the grid's edges
let minPoint = coordinateMap
    .keys
    .reduce(Point(x: Int.max, y: Int.max)) {
        Point(x: min($0.x, $1.x), y: min($0.y, $1.y))
}
let maxPoint = coordinateMap
    .keys
    .reduce(Point.zero) {
        Point(x: max($0.x, $1.x), y: max($0.y, $1.y))
}

// Keep a list of all coordinates that are on the edge of the grid
var boundaryCoordinates = [Point]()

var grid = [Point: UInt]()

for x in minPoint.x...maxPoint.x {
    for y in minPoint.y...maxPoint.y {
        
        let c = Point(x: x, y: y)
        
        // distance to all coordinates
        let distances = coordinateMap.keys.reduce(into: [Point: UInt]()) {
            $0[$1] = $1.distance(to: c)
        }
        
        // Part 2: fill the grid with the accumulated distances
        grid[c] = distances.values.reduce(0, +)
        
        // find the minimal distance for this c
        let minimal = distances.values.min()!
        
        // what is/are the closest coordinate(s)
        let closest = distances.filter { (arg) -> Bool in
            return arg.value == minimal
        }
        
        if closest.count == 1 {
            // If this c belongs to an edge of the grid, the area is infinite, so we can discard this area's coordinate
            // in the final result.
            if x == minPoint.x || y == minPoint.y || x == maxPoint.x || y == maxPoint.y {
                boundaryCoordinates.append(closest.first!.key)
            } else {
                // Store this c in the array of Points of the coordinate to which this c belongs (the closest one)
                var list = coordinateMap[closest.first!.key] ?? [Point]()
                list.append(c)
                coordinateMap[closest.first!.key] = list
            }
        }
    }
}

// filter out all coordinates that have an infinite area and sort by size
let areas = coordinateMap
    .filter { !boundaryCoordinates.contains($0.key) }
    .map { ($0.key, $0.value.count) }
    .sorted { $0.1 > $1.1 }

print("Part 1:")
print(areas.first!.1)

print("Part 2:")
print(grid.values.filter { $0 < 10000 }.count )
