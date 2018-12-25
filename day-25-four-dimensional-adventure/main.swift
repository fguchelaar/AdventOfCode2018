import Foundation

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

extension String {
    func extractInts() -> [Int] {
        return self.split(whereSeparator: { !"-1234567890".contains($0) }).compactMap { Int($0) }
    }
}

struct Point: Hashable {
    var x, y, z, t: Int
    init(ints: [Int]) {
        x = ints[0]
        y = ints[1]
        z = ints[2]
        t = ints[3]
    }
    
    func distance(other: Point) -> Int {
        let dx = abs(x - other.x)
        let dy = abs(y - other.y)
        let dz = abs(z - other.z)
        let dt = abs(t - other.t)
        return  dx + dy + dz + dt
    }
}

struct Constellation {
    var points: [Point]
    
    init(point: Point) {
        points = [point]
    }
    
    func doesBelong(point: Point) -> Bool {
        return points.contains { $0.distance(other: point) <= 3 }
    }
    
    mutating func append(point: Point) {
        points.append(point)
    }
    mutating func append(points: [Point]) {
        self.points.append(contentsOf: points)
    }
}

var allPoints = Set<Point>(input.components(separatedBy: .newlines).map({ Point(ints: $0.extractInts()) }))
var constellations = [Constellation]()

while let first = allPoints.first {
    var constellation = Constellation(point: first)
    allPoints.remove(first)
    
    var same: [Point]!
    repeat {
        same = allPoints.filter { constellation.doesBelong(point: $0) }
        constellation.append(points: same)
        same.forEach { allPoints.remove($0) }
    } while !same.isEmpty
    
    constellations.append(constellation)
}

print("Part 1:")
print(constellations.count)
