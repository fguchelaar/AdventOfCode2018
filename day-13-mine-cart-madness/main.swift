import Foundation

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .newlines)

enum Direction: Int {
    case left = 0
    case up
    case right
    case down
    
    func turnLeft() -> Direction {
        return Direction(rawValue: (self.rawValue + 4 - 1) % 4)!
    }
    
    func turnRight() -> Direction {
        return Direction(rawValue: (self.rawValue + 1) % 4)!
    }
    
    var velocity: Point {
        switch self {
        case .up:
            return Point(x: 0, y: -1)
        case .left:
            return Point(x: -1, y: 0)
        case .right:
            return Point(x: 1, y: 0)
        case .down:
            return Point(x: 0, y: 1)
        }
    }
}

struct Point: Hashable, Equatable {
    var x: Int
    var y: Int
    
    static func + (lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

class Cart {
    var point: Point
    var direction: Direction
    
    var crashed = false
    var rotateCount = 0
    
    init(point: Point, direction: Direction) {
        self.point = point
        self.direction = direction
    }
    
    func processTrackPart(_ char: Character) {
        if crashed { return }
        
        if char == "/" {
            if self.direction == .up || self.direction == .down {
                self.direction = self.direction.turnRight()
            } else {
                self.direction = self.direction.turnLeft()
            }
        } else if char == "\\" {
            if self.direction == .up || self.direction == .down {
                self.direction = self.direction.turnLeft()
            } else {
                self.direction = self.direction.turnRight()
            }
        } else if char == "+" {
            if rotateCount % 3 == 0 {
                self.direction = self.direction.turnLeft()
            } else if rotateCount % 3 == 2 {
                self.direction = self.direction.turnRight()
            }
            rotateCount += 1
        }
        self.point = self.point + self.direction.velocity
    }
}

func cart(in array: [Cart], at: Point) -> Cart? {
    return array.first { $0.point == at }
}

func parseCart(_ point: Point, _ char: Character) -> Cart {
    switch char {
    case "<":
        return Cart(point: point, direction: .left)
    case "^":
        return Cart(point: point, direction: .up)
    case ">":
        return Cart(point: point, direction: .right)
    case "v":
        return Cart(point: point, direction: .down)
    default:
        fatalError()
    }
}

func parseTrackPart(_ char: Character) -> Character {
    switch char {
    case "<", ">":
        return "-"
    case "^", "v":
        return "|"
    default:
        return char
    }
}

var cartArray = [Cart]()
let trackMap: [Point: Character] = input
    .components(separatedBy: .newlines).enumerated()
    .reduce(into: [Point: Character](), { (map, line) in
        line.element.enumerated().forEach { char in
            let point = Point(x: char.offset, y: line.offset)
            map[point] = parseTrackPart(char.element)
            if "<>v^".contains(char.element) {
                cartArray.append(parseCart(point, char.element))
            }
        }
    })

var didCrash = false
while cartArray.count > 1 {
    cartArray
        .sorted { $0.point.y < $1.point.y || ($0.point.y == $1.point.y && $0.point.x < $1.point.x) }
        .forEach { cart in
            cart.processTrackPart(trackMap[cart.point]!)
            
            let atThisLocation = cartArray.filter { $0.point == cart.point }
            
            if atThisLocation.count > 1 {
                atThisLocation.forEach { $0.crashed = true }
                if !didCrash {
                    didCrash = true
                    print("Part 1:")
                    print("\(cart.point.x),\(cart.point.y)")
                }
            }
            cartArray = cartArray.filter { !$0.crashed }
    }
}

print("Part 2:")
print("\(cartArray.first!.point.x),\(cartArray.first!.point.y)")
