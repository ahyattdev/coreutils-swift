import Foundation
import CommandLine
import Rainbow

func print(error: String) {
    fputs("\(Process.arguments[0].yellow): \(error.red)\n", stderr)
}

let cli = CommandLine()

cli.formatOutput = { s, type in
    var str: String
    switch(type) {
    case .About:
        str = "Usage: \(Process.arguments[0]) [OPTION]... [DIRECTORY]...".lightCyan + "\n\nMakes directories at the given paths".yellow
    case .Error:
        str = s.red.bold
    case .OptionFlag:
        str = s.green.underline
    case .OptionHelp:
        str = s.lightBlue
    }
    
    return cli.defaultFormat(s: str, type: type)
}

let mode = StringOption(shortFlag: "m", longFlag: "mode", helpMessage: "Set file mode (as in chmod), not a=rwx - umask")
let parents = BoolOption(shortFlag: "p", longFlag: "parents", helpMessage: "No error if existing, make parent directories as needed")
let verbose = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "Print a message for each created directory")
let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Display this help and exit")

cli.addOptions(mode, parents, verbose, help)

do {
    try cli.parse(strict: true)
} catch {
    cli.printUsage(error)
    exit(EXIT_FAILURE)
}

if help.value {
    cli.printUsage()
    exit(EXIT_SUCCESS)
}

var paths = cli.unparsedArguments

let intermediateDirectories = parents.value

for path in paths {
    do {
        try FileManager.default().createDirectory(atPath: path, withIntermediateDirectories: intermediateDirectories, attributes: nil)
    } catch {
        print(error: "Failed to create directory: \(path)")
        exit(EXIT_FAILURE)
    }
}
