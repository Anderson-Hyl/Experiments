import ArgumentParser
@preconcurrency import PathKit

extension Path: @retroactive ExpressibleByArgument {
    public init(argument: String) {
        self = Path(argument)
    }
}

@main
struct Tree: ParsableCommand {
    @Argument
    var path: Path = .current
    
    mutating func run() throws {
        print(path.absolute().string)
        try path.listChildren()
    }
    
    mutating func validate() throws {
        guard path.exists else {
            throw Tree.Error.invalidPath(path)
        }
        guard path.isDirectory else {
            throw Tree.Error.notADirectory(path)
        }
    }
}

extension Tree {
    enum Error: Swift.Error {
        case invalidPath(Path)
        case notADirectory(Path)
    }
}

extension Tree.Error: CustomStringConvertible {
    var description: String {
        switch self {
        case let .invalidPath(path):
            "The path \(path.absolute().string) does not exist."
        case let .notADirectory(path):
            "The path \(path.absolute().string) is not a directory."
        }
    }
}

extension Path {
    func listChildren(ancestors: [Bool] = []) throws {
        let children = try children().sorted()
        let lastIndex = children.count - 1
        
        let enumeratedChildren = children.enumerated()
        try enumeratedChildren.forEach { tuple in
            let (index, child) = tuple
            let lastComponent = child.lastComponent
            guard !lastComponent.hasPrefix(".") else {
                return
            }
            let indentation = String.indentation(isLast: index == lastIndex, ancestors: ancestors)
            if child.isFile {
                print(indentation, lastComponent)
            } else {
                print(indentation, lastComponent)
                var updatedAncestors = ancestors
                updatedAncestors.append(index == lastIndex)
                try child.listChildren(ancestors: updatedAncestors)
            }
        }
    }
}

extension String {
    static let lastChildSpacing = "    "
    static let levelLine = "│   "
    static let child = "├──"
    static let lastChild = "└──"
    
    static func indentation(isLast: Bool, ancestors: [Bool]) -> String {
        var indentation = ""
        ancestors.forEach { isLastAncestor in
            if isLastAncestor {
                indentation.append(lastChildSpacing)
            } else {
                indentation.append(levelLine)
            }
        }
        if isLast {
            indentation.append(lastChild) // └──
        } else {
            indentation.append(child)     // ├──
        }
        return indentation
    }
}

/* demo from Apple documentation of `ParasableCommand`
@main
struct Repeat: ParsableCommand {
    @Argument(help: "The phrase to repeat")
    var phrase: String
    
    @Option(help: "The number of times to repeat 'phrase'.")
    var count: Int?
    
    mutating func run() throws {
        let repeatCount = count ?? 2
        for _ in 0..<repeatCount {
            print(phrase)
        }
    }
}
*/
