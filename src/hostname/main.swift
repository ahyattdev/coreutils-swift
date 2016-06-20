import Darwin.C
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

let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Display this help and exit")

cli.addOptions(numberWithoutBlanks, nonPrinting, number, singleSpaced, nonPrintingWithTabs, displayOutputBuffering, nonPrintingVerbose, help)

do {
    try cli.parse(strict: true)
} catch {
    cli.printUsage(error)
    exit(EXIT_FAILURE)
}

if help.value {
    cli.printUsage()
} else if Process.arguments.count == 2 {
    // We should set the domain name if we are root
    let domainName = Process.arguments[1]
    if setdomainname(domainName, Int32(domainName.characters.count)) == -1 {
        switch errno {
        case EPERM:
            print(error: "You must run this command as superuser.")
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
    // We should print the host name
    var buf = [Int8]()
    let returnVal = gethostname(&buf, MAXHOSTNAMELEN)
    guard let hostName = String(validatingUTF8: buf) where returnVal == 0 else {
        print(error: "Could not get the host name")
        exit(EXIT_FAILURE)
    }
    print(hostName.lightGreen)
} else {
    // Specified 2 or more arguments
    cli.printUsage()
    exit(EXIT_FAILURE)
}
