import CommandLine

#if os(OSX)
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

let help = BoolOption(shortFlag: "H", longFlag: "help",
                      helpMessage: "Display this help and exit")

cli.addOptions(help)

do {
    try cli.parse(true)
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if help.value {
    cli.printUsage()
    exit(0)
} else if cli.unparsedArguments.count > 0 {
    print("Invalid argument: \(cli.unparsedArguments[0])".red.bold + "\n")
    cli.printUsage()
    exit(1)
}

let pwuid = getpwuid(getuid())

let userString = String.fromCString(pwuid.memory.pw_name)

guard let userString = String.fromCString(pwuid.memory.pw_name) else {
    print("Error: could not get username".red.bold)
    exit(1)
}

print(userString)

exit(0)
