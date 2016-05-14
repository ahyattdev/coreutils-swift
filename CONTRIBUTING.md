# Contrubuting to coreutils-swift

## Adding new commands

1. Create a new file in Xcode of the type `Swift`

    * Put it in the folder `src/<command name>`

    * Name the file `main.swift`

    * Check the checkbox for membership in the `blank` target while creating the file, this is to enable code completion in Xcode

2. Edit `Makefile` and add your command to the line starting with `BINARIES` with all the other commands

3. Copy over the template below to your `main.swift` and add your functionality to it

## How to use Xcode with this project

We are looking into improving our Xcode integration

* Compile with ⌘ + B, while having the `coreutils-swift` target selected
* Products of commands will go in `build/bin`
* Run the command from a terminal, not Xcode

## Template

```swift
// Remove this if your command will not use Foundation
import Foundation

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

let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Display this help and exit")

cli.addOptions(help)

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
    // Remove this if block if the command will use extra arguments
    print("Invalid argument: \(cli.unparsedArguments[0])".red.bold + "\n")
    cli.printUsage()
    // Exit with a code > 0 to indicate that an error occured
    exit(1)
}

// Most program logic will go after here

print("Template command!")
fputs("Print text to stderr this way", stderr)

// This is unecessary because the compiler adds it automatically,
// but it is included for clarity

exit(0)
```
