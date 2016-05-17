import CommandLine
import Rainbow

#if os(OSX) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

let cli = CommandLine()

cli.formatOutput = { s, type in
    var str: String
    switch(type) {
    case .About:
        str = s.lightCyan + "\n\nRepeatedly output a line with all specified strings, or 'y'".yellow
    case .Error:
        str = s.red.bold
    case .OptionFlag:
        str = s.green.underline
    case .OptionHelp:
        str = s.lightBlue
    }
    
    return cli.defaultFormat(str, type: type)
}

// Add additional options here

let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Display this help and exit")

cli.addOptions(help)

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

var str = ""

if cli.unparsedArguments.count == 0 {
    str = "y"
} else {
    for i in 0 ..< cli.unparsedArguments.count - 1 {
        str += cli.unparsedArguments[i] + " "
    }
    str += cli.unparsedArguments[cli.unparsedArguments.count - 1]
}

while true {
    fputs(str + "\n", stdout)
}
