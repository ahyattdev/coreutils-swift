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

let byteCount = BoolOption(shortFlag: "c", longFlag: "bytes", helpMessage: "Print the byte counts")

let charCount = BoolOption(shortFlag: "m", longFlag: "chars", helpMessage: "Print the character counts")
let lineCount = BoolOption(shortFlag: "l", longFlag: "lines", helpMessage: "Print the newline counts")

let longestLine = BoolOption(shortFlag: "L", longFlag: "mas-line-length", helpMessage: "Print the maximum line width of the files")

let wordCount = BoolOption(shortFlag: "w", longFlag: "words", helpMessage: "Print the word counts")

let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Display this help and exit")

cli.addOptions(byteCount, charCount, lineCount, longestLine, wordCount, help)

do {
    try cli.parse(true)
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if help.value {
    cli.printUsage()
    exit(EX_OK)
} else if cli.unparsedArguments.count > 0 {
    // Remove this if block if the command will use extra arguments
    print("Invalid argument: \(cli.unparsedArguments[0])".red.bold + "\n")
    cli.printUsage()
    // Exit with a code > 0 to indicate that an error occured
    exit(EX_USAGE)
}

// Most program logic will go after here

let fm = NSFileManager.defaultManager()

WCOptions.ByteCount = byteCount.value
WCOptions.CharCount = charCount.value
WCOptions.LineCount = lineCount.value
WCOptions.LongestLine = longestLine.value
WCOptions.WordCount = wordCount.value

for fileName in cli.unparsedArguments {
    guard fm.fileExistsAtPath(fileName) else {
        fputs("wc: \(fileName): No such file or directory\n".red.bold, stderr)
        break
    }
    
    guard fm.isReadableFileAtPath(fileName) else {
        fputs("wc: \(fileName): Permission denied\n".red.bold, stderr)
        break
    }
    
    // TODO: Dynamically determine the encoding
    guard let contents = fm.contentsAtPath(fileName) else {
        fputs("wc: \(fileName): Failed to load contents of file\n".red.bold, stderr)
        break
    }
    
    let str: String = String(bytes: contents., encoding: NSUTF8StringEncoding)
}


// This is unecessary because the compiler adds it automatically,
// but it is included for clarity

exit(EX_OK)
