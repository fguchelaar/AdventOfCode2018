import Foundation

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

struct Point: Hashable, Equatable {
    var x, y: Int
    
    func n8() -> [Point] {
        return (x-1...x+1).flatMap { x in
            (y-1...y+1).map { y in
                    Point(x: x, y: y)
                }
            }
            .filter { $0 != self}
    }
}
var area = input.components(separatedBy: .newlines).enumerated()
    .reduce(into: [Point: Character]()) { map, line in
        line.element.enumerated().forEach { row in
            map[Point(x: row.offset, y: line.offset)] = row.element
        }
}

func loop(area: [Point: Character], for minutes: Int) -> [Point: Character] {
    var area = area
    for _ in 0..<minutes {
        let copy = area.keys.reduce(into:[Point: Character]()) { map, point in
            let neighbors = point.n8().filter { area.keys.contains($0) }
            switch (area[point]) {
            case ".":
                map[point] = neighbors.reduce(0) { $0 + (area[$1] == "|" ? 1 : 0) } >= 3 ? "|" : "."
            case "|":
                map[point] = neighbors.reduce(0) { $0 + (area[$1] == "#" ? 1 : 0) } >= 3 ? "#" : "|"
            case "#":
                let l = neighbors.contains { area[$0] == "#" }
                let t = neighbors.contains { area[$0] == "|" }
                map[point] = (l && t) ? "#" : "."
            default:
                print("that's some weird input, you've got going on")
            }
        }
        area = copy
    }
    return area
}

let part1 = loop(area: area, for: 10)

let l1 = part1.reduce(0) { $0 + ($1.value == "#" ? 1 : 0) }
let t1 = part1.reduce(0) { $0 + ($1.value == "|" ? 1 : 0) }

print ("Part 1:")
print (l1 * t1)

//let part2 = loop(area: area, for: 1000000000)
//
//let l2 = part1.reduce(0) { $0 + ($1.value == "#" ? 1 : 0) }
//let t2 = part1.reduce(0) { $0 + ($1.value == "|" ? 1 : 0) }
//
//print ("Part 2:")
//print (l2 * t2)

print ("Part 2:")
print ("""
Yeah... whatever. After inspecting the results after _n_ minutes, the pattern seemed
to repeat every 28 minutes. So did some Excel magic to come up with:

210160
""")
