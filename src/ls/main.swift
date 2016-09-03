import Foundation
import CommandLine
import Rainbow

let fm = FileManager.default

enum Mode {
    case Auto
    case MultiColumn
    case Details
}

let cli = CommandLine()

cli.formatOutput = { s, type in
    var str: String
    switch(type) {
    case .Error:
        str = s.red.bold
    case .OptionFlag:
        str = s.green.underline
    case .OptionHelp:
        str = s.blue
    default:
        str = s
    }

    return cli.defaultFormat(s: str, type: type)
}

let showDotFiles = BoolOption(shortFlag: "a", longFlag: "all",
                              helpMessage: "Do not ignore dotfiles")

let showDotFilesWithoutImplied = BoolOption(shortFlag: "A", longFlag: "almost-all",
                              helpMessage: "Do not ignore dotfiles, excluding the implied . and ..")

let humanReadable = BoolOption(shortFlag: "h", longFlag: "human-readable",
                               helpMessage: "Print human readable sizes")
let showColumns = BoolOption(shortFlag: "C", longFlag: "columns", helpMessage: "Use the columned listing format")

let showDetails = BoolOption(shortFlag: "l", longFlag: "details", helpMessage: "Use the detailed listing format")

let help = BoolOption(shortFlag: "H", longFlag: "help",
                      helpMessage: "Display this help and exit")


cli.addOptions(showDotFiles, showDotFilesWithoutImplied, humanReadable, showColumns, showDetails, help)



func columnLabel(path: String) -> String {
    return fm.displayName(atPath: path)
}

func list(path: String) {
    do {
        let contents = try fm.contentsOfDirectory(atPath: path)

        let formatter = Formatter(elements: contents)

        print(formatter.columnsRepresentation(), terminator: "")
    } catch {
        print("error getting contents of directory")
        exit(EXIT_FAILURE)
    }
}

do {
    try cli.parse(strict: true)
} catch {
    cli.printUsage(error)
    exit(EXIT_FAILURE)
}


var mode : Mode

if help.value {
    cli.printUsage()
    exit(EXIT_SUCCESS)
}

if showColumns.value {
    mode = .MultiColumn
} else if showDetails.value {
    mode = .Details
} else {
    mode = .Auto
}

var listPaths = cli.unparsedArguments

if listPaths.count == 0 {
    listPaths.append(".")
}

for path in listPaths {
    guard fm.fileExists(atPath: path) else {
        print("ls: no such path \(path)")
        exit(EXIT_FAILURE)
    }
}

for path in listPaths {
    var isDirectory: ObjCBool = false
    fm.fileExists(atPath: path, isDirectory: &isDirectory)
    if isDirectory.boolValue {
        if listPaths.count > 1 {
            print(fm.displayName(atPath: path) + ":")
        }
        list(path: path)
        if listPaths.count > 1 && path != listPaths.last {
            print("")
        }
    } else {
        print(columnLabel(path: path))
    }
}

