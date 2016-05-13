// Used for parsing arguments
import CommandLine

// The system C library
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


// Add additional options here
let description = "Format: sleep <duration>[s|m|h|d]\ns: Seconds\nm: Minutes\nh: Hours\nd: Days".green

let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Display this help and exit")

cli.addOptions(help)

do {
    try cli.parse(true)
} catch {
    print(description)
    cli.printUsage(error)
    exit(EX_USAGE)
}

if help.value {
    print(description)
    cli.printUsage()
    exit(0)
} else if cli.unparsedArguments.count != 1 {
    fputs("sleep: No time specified".red.bold + "\n", stderr)
    print(description)
    cli.printUsage()
    // Exit with a code > 0 to indicate that an error occured
    exit(1)
}

// Multipliers
enum Unit : UInt32 {
    case Seconds = 1
    case Minutes = 60
    case Hours = 3600
    case Days = 86400
}

var duration: String = cli.unparsedArguments[0]

var unit = Unit.Seconds

if duration.hasSuffix("s") {
    unit = .Seconds
    duration = String(duration.characters.dropLast())
} else if duration.hasSuffix("m") {
    unit = .Minutes
    duration = String(duration.characters.dropLast())
} else if duration.hasSuffix("h") {
    unit = .Hours
    duration = String(duration.characters.dropLast())
} else if duration.hasSuffix("d") {
    unit = .Days
    duration = String(duration.characters.dropLast())
}

guard var numericDuration = UInt32(duration) else {
    fputs("sleep: Invalid duration: \(duration)\n".red.bold, stderr)
    exit(1)
}

// Apply the multiplier
numericDuration *= unit.rawValue

// System C library call
sleep(numericDuration)

exit(0)

