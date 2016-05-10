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

let all = BoolOption(shortFlag: "a", longFlag: "all", helpMessage: "Print all unformation in the folling order, without -p and -i if they are unknown")

let kernel = BoolOption(shortFlag: "s", longFlag: "kernel-name", helpMessage: "Print the kernel name")

let nodename = BoolOption(shortFlag: "n", longFlag: "nodename", helpMessage: "Print the network node hostname")

let release = BoolOption(shortFlag: "r", longFlag: "kernel-release", helpMessage: "Print the kernel release")

let version = BoolOption(shortFlag: "v", longFlag: "kernel-version", helpMessage: "Print the kernel version")

let machine = BoolOption(shortFlag: "m", longFlag: "machine", helpMessage: "Print the machine hardware name")

let processor = BoolOption(shortFlag: "p", longFlag: "processor", helpMessage: "Print the processor type (non-portable)")

let hardware = BoolOption(shortFlag: "i", longFlag: "hardware-platform", helpMessage: "Print the hardware platform (non-portable)")

let os = BoolOption(shortFlag: "o", longFlag: "operating-system", helpMessage: "Print the operatirg system")

let help = BoolOption(shortFlag: "H", longFlag: "help", helpMessage: "Display this help and exit")

let options = [all, kernel, nodename, release, version, machine, processor, hardware, os, help]
cli.addOptions(options)

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
    fputs("Invalid argument: \(cli.unparsedArguments[0])".red.bold + "\n", stderr)
    cli.printUsage()
    exit(1)
}

struct Options {
    static var All = all.value
    static var Kernel = kernel.value
    static var Nodename = nodename.value
    static var Release = release.value
    static var Version = version.value
    static var Machine = machine.value
    static var Processor = processor.value
    static var Hardware = hardware.value
    static var OS = os.value
}

if Options.All {
    Options.Kernel = true
    Options.Nodename = true
    Options.Release = true
    Options.Version = true
    Options.Machine = true
    Options.Processor = true
    Options.Hardware = true
    Options.OS = true
}

// TODO: Do this dynamically
if Options.OS {
    print("Darwin".green.bold, separator: "")
}

exit(0)
