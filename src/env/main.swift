import Foundation
import CommandLine
import Rainbow

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

let ignore = BoolOption(shortFlag: "i", longFlag: "ignore-enviornment", helpMessage: "Start with an empty enviornment")

// TODO: Change short flag back to 0, CommandLine throws an assertion failure
let null = BoolOption(shortFlag: "n", longFlag: "null", helpMessage: "End each output line with NUL, not newline. Should be changed to a short flag of 0 in the future.")

let unset = MultiStringOption(shortFlag: "u", longFlag: "unset", helpMessage: "Remove variable from the enviornment")

let help = BoolOption(shortFlag: "H", longFlag: "help", helpMessage: "Display this help and exit")

cli.addOptions(ignore, null, unset, help)

do {
    try cli.parse(strict: true)
} catch {
    cli.printUsage(error)
    exit(EXIT_FAILURE)
}

struct Flags {
    static var Ignore = ignore.value
    static var Null = null.value
    static var Help = help.value
}



if help.value {
    cli.printUsage()
    exit(EXIT_SUCCESS)
}

// Clear if necessary

var envvars = ProcessInfo.processInfo().environment

if Flags.Ignore {
    for var envvar in envvars {
        unsetenv(envvar.0)
    }
}

// Set enviornmental variables that the user specified

var command = ""

for arg : String in cli.unparsedArguments {
    // TODO: Check that the env var is more valid
    if arg.components(separatedBy: "=").count == 2  && command.isEmpty {
        setenv(arg.components(separatedBy: "=")[0], arg.components(separatedBy: "=")[1], 1)
    } else {
        command += arg + ""
    }

    if !command.isEmpty {
        // FIXME: The C fucntion system() is unavailable in Swift 3.0???
        //exit(system(command))
    }
}

// TODO: Sort them alphabetically
for env in ProcessInfo.processInfo().environment {
    var seperator = "\n"
    if Flags.Null {
        seperator = "\0"
    }
    print(env.0.green + "=".cyan + env.1.magenta, separator: "", terminator: seperator)
}
