import CommandLine
import Rainbow

// The system C library
#if os(OSX) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

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
    
    return cli.defaultFormat(str, type: type)
}

// Add additional options here

let noNewline = BoolOption(shortFlag: "n", longFlag: "no-newline", helpMessage: "Do not print a newline")

let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Display this help and exit")

cli.addOptions(noNewline, help)

do {
    try cli.parse(true)
} catch {
    cli.printUsage(error)
    exit(EXIT_FAILURE)
}

if help.value {
    cli.printUsage()
    exit(EXIT_SUCCESS)
}

var output = ""

var i = 0

// This is what happens when Swift does not have legacy for loops
// They even got rid of the "++" operator!
while i < cli.unparsedArguments.count - 2 {
    output += "\(cli.unparsedArguments[i]) "
    i += 1
}

if cli.unparsedArguments.count > 0 {
    output += cli.unparsedArguments[cli.unparsedArguments.count-1]
}

if !noNewline.value {
    output += "\n"
}

fputs(output, stdout)

exit(EXIT_SUCCESS)
