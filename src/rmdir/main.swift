import Foundation
import CommandLine
import Rainbow

func print(error: String) {
    fputs("\(Process().arguments![0].yellow): \(error.red)\n", stderr)
}

let cli = CommandLine()

cli.formatOutput = { s, type in
    var str: String
    switch(type) {
    case .About:
        str = s.lightCyan + "\n\nRemoves the directory entry specified by each argument,\nas long as it is empty.\n".yellow
    case .Error:
        str = s.red.bold
    case .OptionFlag:
        str = s.green.underline
    case .OptionHelp:
        str = s.lightBlue
    }
    
    return cli.defaultFormat(s: str, type: type)
}

let recursive = BoolOption(shortFlag: "p", helpMessage: "Each directory argument is treated as a pathname of which all components will be removed,\nif they are empty, starting with the last most component.")

let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Display this help and exit")

cli.addOptions(recursive, help)

do {
    try cli.parse(strict: true)
} catch {
    cli.printUsage(error)
    exit(EXIT_FAILURE)
}

if help.value {
    cli.printUsage()
}

let paths = cli.unparsedArguments
let fm = FileManager.default

if paths.isEmpty {
    print(error: "You must specify a directory to remove")
    exit(EXIT_FAILURE)
}

func rm(dir: String) {
    do {
        if try fm.contentsOfDirectory(atPath: dir).isEmpty {
            try fm.removeItem(atPath: dir)
        } else {
            print(error: "Directory is not empty: \(dir)")
            exit(EXIT_FAILURE)
        }
    } catch let error as NSError {
        print("Error: \(error.domain)")
        exit(EXIT_FAILURE)
    }
}

for path in paths {
    if recursive.value {
        // TODO: Implement recursive directory removal
    } else {
        rm(dir: path)
    }
}
