import Foundation

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

struct Point: Hashable, Equatable, Comparable {
    static func < (lhs: Point, rhs: Point) -> Bool {
        return lhs.y < rhs.y || (lhs.y == rhs.y && lhs.x < rhs.x)
    }
    
    var x, y: Int
    
    var N: Point { return Point(x: x, y: y-1 ) }
    var E: Point { return Point(x: x+1, y: y ) }
    var S: Point { return Point(x: x, y: y+1 ) }
    var W: Point { return Point(x: x-1, y: y ) }
}

var maze = [Point: Set<Point>]()

func printMaze() {
    typealias MinMax = (Point, Point)
    let minmax = maze.keys.reduce((Point(x: Int.max, y: Int.max),Point(x: Int.min, y: Int.min))) {
        (Point(x: min($0.0.x, $1.x), y: min($0.0.y, $1.y)),Point(x: max($0.1.x, $1.x), y: max($0.1.y, $1.y)))
    }
    
    let str = (minmax.0.y...minmax.1.y).map { y in
        (minmax.0.x...minmax.1.x).map { x in
            let point = Point(x: x, y: y)
            guard let nb = maze[point] else {
                return " "
            }
            if point == Point(x: 0, y: 0) {
                return "X"
            }
            if nb.count == 4 {
                return "\(UnicodeScalar(0x253c)!)"
            } else if nb.count == 3 {
                if !nb.contains(point.N) {
                    return "\(UnicodeScalar(0x252c)!)"
                } else if !nb.contains(point.E) {
                    return "\(UnicodeScalar(0x2524)!)"
                } else if !nb.contains(point.S) {
                    return "\(UnicodeScalar(0x2534)!)"
                } else {
                    return "\(UnicodeScalar(0x251c)!)"
                }
            } else if nb.count == 2 {
                if nb.contains(point.N) && nb.contains(point.S) {
                    return "\(UnicodeScalar(0x2502)!)"
                } else if nb.contains(point.E) && nb.contains(point.W) {
                    return "\(UnicodeScalar(0x2500)!)"
                } else if nb.contains(point.N) && nb.contains(point.E) {
                    return "\(UnicodeScalar(0x2514)!)"
                } else if nb.contains(point.E) && nb.contains(point.S) {
                    return "\(UnicodeScalar(0x250c)!)"
                } else if nb.contains(point.S) && nb.contains(point.W) {
                    return "\(UnicodeScalar(0x2510)!)"
                } else {
                    return "\(UnicodeScalar(0x2518)!)"
                }
            } else if nb.count == 1 {
                if nb.contains(point.N) {
                    return "\(UnicodeScalar(0x257d)!)"
                } else if nb.contains(point.E) {
                    return "\(UnicodeScalar(0x257e)!)"
                } else if nb.contains(point.S) {
                    return "\(UnicodeScalar(0x257f)!)"
                } else {
                    return "\(UnicodeScalar(0x257c)!)"
                }
            }
            return "."
            }.joined()
        }.joined(separator: "\n")
    print(str)
}

func dijkstra(source: Point) -> (dist: [Point: Int], prev: [Point: Point]) {
    
    var dist = maze.keys.reduce(into: [Point: Int]()) { $0[$1] = Int.max }
    var prev = [Point: Point]()
    var unvisited = Set<Point>(maze.keys)
    
    dist[source] = 0
    
    while !unvisited.isEmpty {
        
        let current = dist
            .filter { unvisited.contains($0.key) }
            .min { $0.value < $1.value }!
            .key
        unvisited.remove(current)
        
        maze[current]!.forEach { nb in
            let distance = dist[current]! + 1
            if distance < dist[nb]! {
                dist[nb] = distance
                prev[nb] = current
            }
        }
    }
    
    return (dist, prev)
}

struct Stack<T> {
    private var inner = [T]()
    
    mutating func pop() -> T {
        return inner.removeLast()
    }
    
    mutating func push(element: T) {
        inner.append(element)
    }
}

func parse(string: String, position: Point) {
    var stack = Stack<Point>()
    var current = position
    var str = string
    
    while !str.isEmpty {
        // ensures presence of the current position
        maze[current] = maze[current, default: Set<Point>()]
        
        let char = str.removeFirst()
        switch char {
            
        case "N","E","S","W":
            let next = char == "N" ? current.N
                : char == "E" ? current.E
                : char == "S" ? current.S
                : current.W
            
            maze[next] = maze[next, default: Set<Point>()]
            maze[current] = maze[current, default: Set<Point>()]
            maze[current]!.insert(next)
            maze[next]!.insert(current)
            current = next
        case "(":
            stack.push(element: current)
        case "|":
            current = stack.pop()
            stack.push(element: current)
        case ")":
            current = stack.pop()
        default:
            print("what shall we do here...")
        }
    }
}

parse(string: input.trimmingCharacters(in: CharacterSet(charactersIn: "^$")), position: Point(x: 0, y: 0))
//printMaze()

let dp = dijkstra(source: Point(x: 0, y: 0))

print("Part 1:")
print(dp.0.values.max()!)

print("Part 2:")
print(dp.0.values.filter { $0 >= 1000 }.count)
