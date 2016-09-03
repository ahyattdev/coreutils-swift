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
        str = "Usage: \(Process().arguments![0]) [OPTIONS] [FILE ...]".lightCyan + "\n\nConcatenate and print files\n".yellow
    case .Error:
        str = s.red.bold
    case .OptionFlag:
        str = s.green.underline
    case .OptionHelp:
        str = s.lightBlue
    }
    
    return cli.defaultFormat(s: str, type: type)
}

let fullDomain = BoolOption(shortFlag: "f", helpMessage: "Include domain information in the printed name. This is the default behavior.")

let trimDomain = BoolOption(shortFlag: "s", helpMessage: "Trim off any domain information from the printed name.")

let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Display this help and exit")

cli.addOptions(fullDomain, trimDomain, help)

do {
    try cli.parse(strict: true)
} catch {
    cli.printUsage(error)
    exit(EXIT_FAILURE)
}

if help.value {
    cli.printUsage()
} else if cli.unparsedArguments.count == 1 {
    // We should set the host name if we are root
    let hostName = Process().arguments![1]
    if sethostname(hostName, Int32(hostName.characters.count)) == -1 {
        switch errno {
        case EPERM:
            print(error: "You must run this command as superuser.")
        case EINVAL:
            // The sethostname(3) does not list EINVAL, but it sets EINVAL if the given
            // host name is too long
            print(error: "The given host name is too long or is otherwise invalid")
        default:
            print(error: "An unknown error occurred.")
        }
        exit(EXIT_FAILURE)
    }
} else if cli.unparsedArguments.count == 0 {
    // We should print the host name
    var buf = [Int8]()
    let returnVal = gethostname(&buf, Int(MAXHOSTNAMELEN))
    if returnVal != 0 {
        exit(EXIT_FAILURE)
    }
    guard var hostName = String(validatingUTF8: buf) else {
        print(error: "Could not get the host name.")
        exit(EXIT_FAILURE)
    }
    
    if trimDomain.value {
        let hostOnly = hostName.components(separatedBy: ".")[0]
        print(hostOnly.lightGreen)
    } else {
        print(hostName.lightGreen)
    }
} else {
    // Specified 2 or more arguments
    cli.printUsage()
    exit(EXIT_FAILURE)
}
