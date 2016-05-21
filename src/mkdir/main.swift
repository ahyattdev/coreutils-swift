#if os(OSX) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

import CommandLine
import Rainbow

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
    
    return cli.defaultFormat(str, type: type)
}

let mode = StringOption(shortFlag: "m", longFlag: "mode", helpMessage: "Set file mode (as in chmod), not a=rwx - umask")
let parents = BoolOption(shortFlag: "p", longFlag: "parents", helpMessage: "No error if existing, make parent directories as needed")
let verbose = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "Print a message for each created directory")
let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Display this help and exit")

cli.addOptions(mode, parents, verbose, help)

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

var paths = cli.unparsedArguments

if mode.value != nil {
    // TODO: Implement permissions
}

// TODO: Implement creating parent directories

var mask: mode_t = 0o0755
var defaultMask = mode_t()
umask(defaultMask)

mask -= defaultMask

for path in paths {
    var st = stat()
    if stat(path, &st) == -1 {
        mkdir(path, mask)
        if verbose.value {
            print("\(Process.arguments[0]): Created directory: ".lightGreen + path.lightBlue)
        }
    } else {
        fputs("\(Process.arguments[0]): Failed to create directory: \(path)".red.bold + "\n", stderr)
        exit(EXIT_FAILURE)
    }
}

exit(EXIT_SUCCESS)
