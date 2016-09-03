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
        str = s.lightCyan + "\n\nForce the completion of pending disk writes (flush the cache)\n".yellow
    case .Error:
        str = s.red.bold
    case .OptionFlag:
        str = s.green.underline
    case .OptionHelp:
        str = s.lightBlue
    }
    
    return cli.defaultFormat(s: str, type: type)
}

let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Display this help and exit")

cli.addOptions(help)

do {
    try cli.parse(strict: true)
} catch {
    cli.printUsage(error)
    exit(EXIT_FAILURE)
}

// These argument counts include how the command was launched
if help.value {
    cli.printUsage()
} else if Process().arguments!.count == 1 {
    // Is this really it? Just this?
    sync()
} else {
    print(error: "Sync does not take any arguments.")
}
