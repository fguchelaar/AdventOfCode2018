import Foundation

extension String {
    func extractInts() -> [Int] {
        return self.split(whereSeparator: { !"-1234567890".contains($0) }).compactMap { Int($0) }
    }
    
    func match(pattern: String) -> String? {
        let re = try! NSRegularExpression(pattern: pattern, options: .init(rawValue: 0))
        guard let match = re.firstMatch(in: self, options: .init(rawValue: 0), range: NSRange(location: 0, length: self.count)) else {
            return nil
        }
        
        guard let range = Range(match.range(at: 1), in: self) else {
            return nil
        }
        
        return String(self[range])
    }
}

enum AttackType: String {
    case radiation
    case fire
    case slashing
    case cold
    case bludgeoning
}

enum Army: String {
    case ImmuneSystem
    case Infection
}

var immuneGroupId = 1
var infectionGroupId = 1

class Group: Hashable, CustomStringConvertible {
    
    static func from(string: String, in army: Army) -> Group {
        let ints = string.extractInts()
        let units = ints[0]
        let hitPoints = ints[1]
        let attackDamage = ints[2]
        let initiative = ints[3]
        
        let attackType = AttackType(rawValue: string.match(pattern: "\\d+ (\\w+) damage")!)!
        
        let immunities = string.match(pattern: "immune to ((\\w+|\\s|\\,)+)(\\)|\\;)")?
            .components(separatedBy: CharacterSet(charactersIn: ", "))
            .filter { !$0.isEmpty }
            .map { AttackType(rawValue: $0)! }
        
        let weaknesses = string.match(pattern: "weak to ((\\w+|\\s|\\,)+)(\\)|\\;)")?
            .components(separatedBy: CharacterSet(charactersIn: ", "))
            .filter { !$0.isEmpty }
            .map { AttackType(rawValue: $0)! }
        
        return Group(army: army, units: units, hitPoints: hitPoints, attackDamage: attackDamage, attackType: attackType, initiative: initiative, weaknesses: weaknesses, immunities: immunities)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(army)
        hasher.combine(id)
    }
    static func == (lhs: Group, rhs: Group) -> Bool {
        return lhs.id == rhs.id && lhs.army == rhs.army
    }
    
    var id = -1
    
    var army: Army
    var units: Int
    var originalUnits: Int = 0
    var hitPoints: Int
    var attackDamage: Int
    var boost: Int = 0
    var attackType: AttackType
    var initiative: Int
    var weaknesses: [AttackType]
    var immunities: [AttackType]
    
    var effectivePower: Int {
        return units * (attackDamage + boost)
    }
    
    init(army: Army, units: Int, hitPoints: Int, attackDamage: Int, attackType: AttackType, initiative: Int, weaknesses: [AttackType]?, immunities: [AttackType]?) {
        
        if army == .ImmuneSystem {
            self.id = immuneGroupId
            immuneGroupId += 1
        } else {
            self.id = infectionGroupId
            infectionGroupId += 1
        }
        
        self.army = army
        self.originalUnits = units
        self.units = units
        self.hitPoints = hitPoints
        self.attackDamage = attackDamage
        self.attackType = attackType
        self.initiative = initiative
        self.weaknesses = weaknesses ?? []
        self.immunities = immunities ?? []
    }
    
    func reset() {
        units = originalUnits
    }
    
    func damage(to other: Group) -> Int {
        if other.immunities.contains(attackType) {
            return 0
        } else if other.weaknesses.contains(attackType) {
            return effectivePower * 2
        } else {
            return effectivePower
        }
    }
    
    func take(damage: Int) -> Int {
        let killed = damage / hitPoints
        units = max(units - killed, 0)
        return killed
    }
    
    var description: String {
        let a = army == .ImmuneSystem ? "😷" : "🤢"
        return "[\(a) \(id)]\t💂‍♂️:\(units)\t❤️:\(hitPoints)\t⚔️:\(attackDamage)"
    }
}

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

let immuneSystem = input
    .components(separatedBy: "\n\n").first!
    .components(separatedBy: .newlines)
    .dropFirst()
    .map { Group.from(string: $0, in: .ImmuneSystem) }

let infection = input
    .components(separatedBy: "\n\n").last!
    .components(separatedBy: .newlines)
    .dropFirst()
    .map { Group.from(string: $0, in: .Infection) }


func solve(boost: Int) -> Set<Group> {
    immuneSystem.forEach { $0.boost = boost }
    var groups = Set<Group>(immuneSystem + infection)
    groups.forEach { $0.reset() }
    
    while Dictionary(grouping: groups, by: { $0.army }).keys.count > 1 {
        
        // Target Selection
        let selectionOrder = groups
            .sorted { $0.effectivePower > $1.effectivePower || ($0.effectivePower == $1.effectivePower && $0.initiative > $1.initiative) }
        
        var targets = Set<Group>(groups)
        var pairs = [(Group, Group)]()
        
        selectionOrder.forEach { group in
            
            let eligible = targets
                .filter { t in
                    t.army != group.army
                }
                .map { t in
                    (group: t, damage: group.damage(to: t))
                }
                .filter { t in
                    t.damage > 0
            }
            
            if let target = eligible
                .max(by: { a, b in
                    return a.damage < b.damage
                        || (a.damage == b.damage && a.group.effectivePower < b.group.effectivePower)
                        || ((a.damage == b.damage && a.group.effectivePower == b.group.effectivePower) && a.group.initiative < b.group.initiative )
                }) {
                
                targets.remove(target.group)
                pairs.append((group, target.group))
            }
        }
        
        // Attack fase
        let attackingOrder = pairs
            .sorted { $0.0.initiative > $1.0.initiative }
        
        var stalemate = true
        attackingOrder.forEach { gt in
            if gt.0.units > 0 {
                let damage = gt.0.damage(to: gt.1)
                let killed = gt.1.take(damage: damage)
                if gt.1.units == 0 {
                    groups.remove(gt.1)
                }
                if killed != 0 {
                    stalemate = false
                }
            }
        }
        
        if stalemate {
            break
        }
    }
    return groups
}

print("Part 1:")
print(solve(boost: 0).map { $0.units }.reduce(0, +))

var boost = 1
var aftermath = Set<Group>()
while true {
    aftermath = solve(boost: boost)
    if aftermath.allSatisfy ({ $0.army == .ImmuneSystem }) {
        break
    }
    boost += 1
}

print("Part 2:")
print(aftermath.map { $0.units }.reduce(0, +))
