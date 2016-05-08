import Foundation
import CommandLine

//#if os(OSX)
//    import Darwin
//#elseif os(Linux)
//    import Glibc
//#endif

var cli = CLI()

let help = BoolOption(shortFlag: "h", longFlag: "help",
                      helpMessage: "Display this help and exit")

cli.addOptions(help)

cli.safeParse()

if help.value {
    cli.printUsage()
    exit(0)
}

let fm = NSFileManager.defaultManager()
let listPaths = cli.unparsedArguments

for path in listPaths {
    guard fm.fileExistsAtPath(path) else {
        print("ls: no such path \(path)")
        exit(1)
    }
}

exit(0)
