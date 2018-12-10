import Foundation

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

struct Point {
    var x, y, dx, dy: Int

    func position(after n: Int) -> (x: Int, y: Int) {
        return (x + (n*dx), y + (n*dy))
    }
}

let points = input
    .components(separatedBy: .newlines)
    .map { $0.components(separatedBy: CharacterSet(charactersIn: "<>,")) }
    .map { $0.map({ $0.trimmingCharacters(in: .whitespaces) }) }
    .map { Point(x: Int($0[1])!, y: Int($0[2])!, dx: Int($0[4])!, dy: Int($0[5])!) }


extension Array where Element == Point {
    func after(n: Int) -> [(x: Int, y: Int)] {
        return self.map { $0.position(after: n) }
    }
}

extension Array where Element == (x: Int, y: Int) {
    
    func rectangle() -> (x1: Int, y1: Int, x2: Int, y2: Int) {
        var minx = Int.max, miny = Int.max
        var maxx = Int.min, maxy = Int.min

        for c in self {
            minx = Swift.min(minx, c.x)
            miny = Swift.min(miny, c.y)
            
            maxx = Swift.max(maxx, c.x)
            maxy = Swift.max(maxy, c.y)
        }
        return (minx, miny, maxx, maxy)
    }
    
    func size() -> Int {
        let rect = rectangle()
        return abs(rect.x2 - rect.x1) * abs(rect.y2 - rect.y1)
    }
}

var size = Int.max
var time = 0
while points.after(n: time+1).size() < size {
    time += 1
    size = points.after(n: time).size()
}

// translate all coordinates to 0,0 by finding the top-left one
let rect = points.after(n: time).rectangle()

var result = points.after(n: time)
    .map { (x: $0.x - rect.x1, y: $0.y - rect.y1) }
    .sorted { ($0.y < $1.y) }
    .sorted { ($0.x < $1.x) }

// now we can draw from 0,0 to the bottom right, which we can get after the translation
let translatedRect = result.rectangle()

// Fill an array with dots
var output = Array(repeating: Array(repeating: ".", count: translatedRect.x2 + 1), count: translatedRect.y2 + 1)

// then replace each location of a point with a hashtag
result.forEach {
    output[$0.y][$0.x] = "#"
}

print("Part 1:")
output.forEach {
    print ($0.joined())
}

print("Part 2:")
print("\(time)")
