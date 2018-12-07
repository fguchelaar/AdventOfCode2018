import Foundation

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

/// Fill a dictionary with all combined steps: `[Step : Prerequisites]`
func initializeMap(from input: String) -> [String: String] {

    var dict = [String: String]()

    input.components(separatedBy: .newlines).forEach { line in
        var words = line.components(separatedBy: " ")
        let x = words[1]
        let y = words[7]

        // ensure that x is also in the dict, in case it has no prerequisites of it's own
        if !dict.contains(where: { $0.key == x }) {
            dict[x] = ""
        }

        // append the prerequisite step
        dict[y] = (dict[y] ?? "") + x
    }
    return dict
}

/// Returns the steps that have no prerequisites (anymore), sorted
func nextSteps(from map: [String: String]) -> [String] {
    return map
        .filter { $0.value.isEmpty }
        .map { $0.key }
        .sorted()
}

var order = ""

var todo = initializeMap(from: input)
while (!todo.isEmpty) {
    // find the first available step
    let next = nextSteps(from: todo).first!
    
    todo.removeValue(forKey: next)
    
    // remove it from all other steps
    todo.forEach {
        todo[$0.key] = todo[$0.key]?.replacingOccurrences(of: next, with: "")
    }
    
    order.append(next)
}

print("Part 1:")
print(order)

// First, let's reset the requirements map
todo = initializeMap(from: input)

// The order is no longer relevant, but still nice to keep around
order = ""
var totalTime = -1 // -1 because we start a second '0'

let extraCost: Int = 60
let baseCost = Int("A".unicodeScalars.first!.value) - 1

let numberOfWorkers = 5
// dictionary of the step and it's TTL
var activeSteps = [String: Int]()


// continue until all steps are finished
while (!todo.isEmpty || !activeSteps.isEmpty) {
    totalTime += 1

    // Decrement all active steps by one
    activeSteps.forEach {
        activeSteps[$0.key] = activeSteps[$0.key]! - 1
    }

    // For the steps that are now finished, remove them as prereq from all other steps
    let finished = activeSteps
        .filter { $0.value == 0 }
        .map { $0.key }
        .sorted()

    finished.forEach { step in
        // remove it from all other steps
        todo.forEach {
            todo[$0.key] = todo[$0.key]?.replacingOccurrences(of: step, with: "")
        }
        order.append(step)
    }
    
    // Remove all finished steps from the active queue, freeing up room for another step
    activeSteps = activeSteps.filter { $0.value != 0 }
    
    // find the available steps and take as much as we can
    let next = nextSteps(from: todo).prefix(numberOfWorkers - activeSteps.count)

    // Get an elf to work on it!
    next.forEach {
        let ttl = Int($0.unicodeScalars.first!.value) - baseCost + extraCost
        activeSteps[$0] = ttl
        todo.removeValue(forKey: $0)
    }
}

print("Part 2:")
print(totalTime)
print(order) // not necessary for part 2
