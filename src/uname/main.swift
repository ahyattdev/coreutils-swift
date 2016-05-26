// FIXME: Implement uname without Foundation
#if !os(Linux)

import CommandLine
import Rainbow
import Foundation

#if os(OSX) || os(iOS)
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
    exit(EXIT_FAILURE)
}

if help.value {
    cli.printUsage()
    exit(EXIT_SUCCESS)
} else if cli.unparsedArguments.count > 0 {
    fputs("Invalid argument: \(cli.unparsedArguments[0])".red.bold + "\n", stderr)
    cli.printUsage()
    exit(EXIT_FAILURE)
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

// Configure -a
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

// Default to -s
if !(Options.Kernel || Options.Nodename || Options.Release || Options.Version || Options.Machine || Options.Processor || Options.Hardware || Options.OS) {
    Options.Kernel = true
}

// Stores the final info string to be printed
var info = ""

// Just adds the string to info and appends a space
// The point is to cut down on repetetive code
func addInfo(str: String) {
    info += str + " ".green.bold
}

let pi = NSProcessInfo.processInfo()
var unameInfo: utsname = utsname()
uname(&unameInfo)

if Options.Kernel {
    guard let kernelName = withUnsafePointer(&unameInfo.sysname, {
        String.fromCString(UnsafePointer($0))
    }) else {
        fputs("Failed to get the kernel name\n", stderr)
        exit(EXIT_FAILURE)
    }
    addInfo(kernelName)
}

if Options.Nodename {
    guard let hostname = NSHost.currentHost().localizedName else {
        fputs("Failed to get the network node name\n", stderr)
        exit(EXIT_FAILURE)
    }
    addInfo(hostname)
}

if Options.Release {
    guard let kernelRelease = withUnsafePointer(&unameInfo.release, {
        String.fromCString(UnsafePointer($0))
    }) else {
        fputs("Failed to get the kernel release\n", stderr)
        exit(EXIT_FAILURE)
    }
    addInfo(kernelRelease)
}

if Options.Version {
    guard let kernelVersion = withUnsafePointer(&unameInfo.version, {
        String.fromCString(UnsafePointer($0))
    }) else {
        fputs("Failed to get the kernel version\n", stderr)
        exit(EXIT_FAILURE)
    }
    addInfo(kernelVersion)
}

if Options.Machine {
    guard let machine = withUnsafePointer(&unameInfo.machine, {
        String.fromCString(UnsafePointer($0))
    }) else {
        fputs("Failed to get the machine description\n", stderr)
        exit(EXIT_FAILURE)
    }
    addInfo(machine)
}

if Options.Processor {
    // TODO: Implement fetching the processor description
    guard let processor: String = "unimplemented" else {
        fputs("Failed to get the processor description\n", stderr)
        exit(EXIT_FAILURE)
    }

    addInfo(processor)
}

if Options.Hardware {
    var cputype: cpu_type_t = cpu_type_t()
    var cs: size_t = sizeof(cpu_type_t)
   // var ai: UnsafeMutablePointer<NXArchInfo>

    sysctlbyname("hw.cputype", &cputype, &cs, nil, 0)
    guard let ai: UnsafePointer<NXArchInfo> = NXGetArchInfoFromCpuType(cputype, CPU_SUBTYPE_INTEL_MODEL_ALL),

        let name = String.fromCString(ai.memory.name) else {
        fputs("Failed to get the CPU type\n", stderr)
        exit(EXIT_FAILURE)
    }
    addInfo(name)
}

// The GNU Coreutils uname command determines this at compiler time
// with an autotools variable.

// Since Swift deployment is limited now, we can return an OS string
// based on the Swift OS compiler directive
if Options.OS {
    // Default to what NSProcessInfo returns, it is NSMachOperatingSystem on Darwin
    var osname: String = pi.operatingSystemName()

    #if os(OSX)
        osname = "Mac OS X"
    #elseif os(iOS)
        osname = "iOS"
    #elseif os(Linux)
        osname = "Linux"
    #endif

    addInfo(osname)
}

print(info)

exit(EXIT_SUCCESS)

#endif
