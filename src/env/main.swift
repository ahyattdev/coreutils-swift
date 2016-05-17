import Foundation
import Rainbow

#if os(OSX)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

import CommandLine

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

let ignore = BoolOption(shortFlag: "i", longFlag: "ignore-enviornment", helpMessage: "Start with an empty enviornment")

// TODO: Change short flag back to 0, CommandLine throws an assertion failure
let null = BoolOption(shortFlag: "n", longFlag: "null", helpMessage: "End each output line with NUL, not newline. Should be changed to a short flag of 0 in the future.")

let unset = MultiStringOption(shortFlag: "u", longFlag: "unset", helpMessage: "Remove variable from the enviornment")

let help = BoolOption(shortFlag: "H", longFlag: "help", helpMessage: "Display this help and exit")

cli.addOptions(ignore, null, unset, help)

do {
    try cli.parse(true)
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

struct Flags {
    static var Ignore = ignore.value
    static var Null = null.value
    static var Help = help.value
}



if help.value {
    cli.printUsage()
    exit(0)
}

// Clear if necessary

var envvars = NSProcessInfo.processInfo().environment

if Flags.Ignore {
    for var envvar in envvars {
        unsetenv(envvar.0)
    }
}

// Set enviornmental variables that the user specified

var command = ""

for arg : String in cli.unparsedArguments {
    // TODO: Check that the env var is more valid
    if arg.componentsSeparatedByString("=").count == 2  && command.isEmpty {
        setenv(arg.componentsSeparatedByString("=")[0], arg.componentsSeparatedByString("=")[1], 1)
    } else {
        command += arg + ""
    }
    
    if !command.isEmpty {
        exit(system(command))
    }
}

// TODO: Sort them alphabetically
for env in NSProcessInfo.processInfo().environment {
    var seperator = "\n"
    if Flags.Null {
        seperator = "\0"
    }
    print(env.0.green + "=".cyan + env.1.magenta, separator: "", terminator: seperator)
}

exit(0)
