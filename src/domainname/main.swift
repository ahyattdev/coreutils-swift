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
        str = s.lightCyan + "\n\nSet or print the current YP/NIS domain.\n\nThe domain name will be printed if no arguments are specified.\n\nIf an argument is specified and this command is running as root, the YP/NIS domain will be set to that argument.\n".yellow
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
} else if Process.arguments.count == 2 {
    // We should set the domain name if we are root
    let domainName = Process.arguments[1]
    if setdomainname(domainName, Int32(domainName.characters.count)) == -1 {
        switch errno {
        case EPERM:
            print(error: "You must run this command with superuser privileges.")
        case EINVAL:
            // The setdomainname(3) does not list EINVAL, but it sets EINVAL if the given
            // domain name is too long
            print(error: "The given domain name is too long or is otherwise invalid")
        default:
            print(error: "An unknown error occurred.")
        }
        exit(EXIT_FAILURE)
    }
} else if Process.arguments.count == 1 {
    // We should print the domain name
    var buf = [Int8]()
    let returnVal = getdomainname(&buf, MAXDOMNAMELEN)
    guard let domainName = String(validatingUTF8: buf) where returnVal == 0 else {
        fputs("\("Could not get the domain name".red)\n", stderr)
        exit(EXIT_FAILURE)
    }
    print(domainName.lightGreen)
} else {
    // Specified 2 or more arguments
    cli.printUsage()
    exit(EXIT_FAILURE)
}
