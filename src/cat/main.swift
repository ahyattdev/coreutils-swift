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
        str = "Usage: \(Process.arguments[0]) [OPTIONS] [FILE ...]".lightCyan + "\n\nConcatenate and print files\n".yellow
    case .Error:
        str = s.red.bold
    case .OptionFlag:
        str = s.green.underline
    case .OptionHelp:
        str = s.lightBlue
    }
    
    return cli.defaultFormat(s: str, type: type)
}

let numberWithoutBlanks = BoolOption(shortFlag: "b", helpMessage: "Number the non-blank output lines, starting at one")

let nonPrinting = BoolOption(shortFlag: "e", helpMessage: "Display non-printing characters (see the -v option), and display a dollar sign at the end of each line.)")

let number = BoolOption(shortFlag: "n", helpMessage: "Number the output lines, starting at one")

let singleSpaced = BoolOption(shortFlag: "s", helpMessage: "Squeeze multiple adjacent empty lines, causing the output to be single spaced")

let nonPrintingWithTabs = BoolOption(shortFlag: "t", helpMessage: "Display non-printing characters (see the -v option), and display tab characters as '^I'")

let displayOutputBuffering = BoolOption(shortFlag: "u", helpMessage: "Disable output buffering")

let nonPrintingVerbose = BoolOption(shortFlag: "v", helpMessage: "Display non-printing characters so they are visible.  Control characters print as `^X' for control-X; the delete character (octal 0177) prints as `^?'.  Non-ASCII characters (with the high bit set) are printed as `M-' (for meta) followed by the character for the low 7 bits.")

let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Display this help and exit")

cli.addOptions(numberWithoutBlanks, nonPrinting, number, singleSpaced, nonPrintingWithTabs, displayOutputBuffering, nonPrintingVerbose, help)

do {
    try cli.parse(strict: true)
} catch {
    cli.printUsage(error)
    exit(EXIT_FAILURE)
}

// These argument counts include how the command was launched
if help.value {
    cli.printUsage()
    exit(EXIT_SUCCESS)
} else if Process.arguments.count == 1 {
    
}
