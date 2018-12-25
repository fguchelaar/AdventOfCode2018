import Foundation

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

extension String {
    func extractInts() -> [Int] {
        return self.split(whereSeparator: { !"-1234567890".contains($0) }).compactMap { Int($0) }
    }
}

struct Nanobot {
    var x, y, z, r: Int
    
    func distance(to other: Nanobot) -> Int {
        return abs(x - other.x) + abs(y - other.y) + abs(z - other.z)
    }
    
    func isInRange(other: Nanobot) -> Bool {
        return distance(to: other) <= r
    }
}

let nanobots: [Nanobot] = input.components(separatedBy: .newlines)
    .map { line in
        let ints = line.extractInts()
        return Nanobot(x: ints[0], y: ints[1], z: ints[2], r: ints[3])
}

let strongestNanobot = nanobots.max { $0.r < $1.r }!

let inRange = nanobots
    .filter { strongestNanobot.isInRange(other: $0) }
    .count

print ("Part 1:")
print (inRange)
