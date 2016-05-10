//
//  env.swift
//  coreutils-swift
//
//  Created by Andrew Hyatt on 5/9/16.
//  Copyright © 2016 Andrew Hyatt. All rights reserved.
//

import Foundation

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
let null = BoolOption(shortFlag: "n", longFlag: "null", helpMessage: "End each output line with NUL, not newline")

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
} else if cli.unparsedArguments.count > 0 {
    fputs("Invalid argument: \(cli.unparsedArguments[0])".red.bold + "\n", stderr)
    cli.printUsage()
    exit(1)
}

// Clear if necessary

let envvars = NSProcessInfo.processInfo().environment

if Flags.Ignore {
    for var envvar in envvars {
        unsetenv(envvar.0)
    }
}

for env in NSProcessInfo.processInfo().environment {
    print(env.0.green + "=".cyan + env.1.magenta)
}

exit(0)
