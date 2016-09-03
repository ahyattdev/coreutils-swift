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

let numberWithoutBlanks = BoolOption(shortFlag: "b", helpMessage: "Number the non-blank output lines, starting at one")

let nonPrinting = BoolOption(shortFlag: "e", helpMessage: "Display non-printing characters (see the -v option), and display a dollar sign at the end of each line.)")

let number = BoolOption(shortFlag: "n", helpMessage: "Number the output lines, starting at one")

let singleSpaced = BoolOption(shortFlag: "s", helpMessage: "Squeeze multiple adjacent empty lines, causing the output to be single spaced")

let nonPrintingWithTabs = BoolOption(shortFlag: "t", helpMessage: "Display non-printing characters (see the -v option), and display tab characters as '^I'")

let displayOutputBuffering = BoolOption(shortFlag: "u", helpMessage: "Disable output buffering")

let nonPrintingVerbose = BoolOption(shortFlag: "v", helpMessage: "Display non-printing characters so they are visible.  Control characters print as `^X' for control-X; the delete character (octal 0177) prints as `^?'.  Non-ASCII characters (with the high bit set) are printed as `M-' (for meta) followed by the character for the low 7 bits.")

let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Display this help and exit")

cli.addOptions(numberWithoutBlanks, nonPrinting, number, singleSpaced, nonPrintingWithTabs, displayOutputBuffering, nonPrintingVerbose, help)

do {
    try cli.parse(strict: true)
} catch {
    cli.printUsage(error)
    exit(EXIT_FAILURE)
}

// These argument counts include how the command was launched
if help.value {
    cli.printUsage()
    exit(EXIT_SUCCESS)
} else if Process().arguments!.count == 1 {
    // TODO: Implement reading from stdin
    print(error: "Reading from stdin has not been implemented yet")
    exit(EXIT_FAILURE)
}

func number(contents: String, countBlanks: Bool) -> String {
    let lines = contents.components(separatedBy: CharacterSet.newlines)
    var lineCount = 0
    var numberedContents = ""
    for fileLine in lines {
        var line = fileLine
        if !line.isEmpty || countBlanks {
            lineCount += 1
            line = "    \(lineCount)  " + line
        }
        numberedContents += line + "\n"
    }
    return numberedContents
}

func parse(string: String) -> String {
    var parsedString = string
    // Put the stuff identifying non-printing characters before the numbering
    if numberWithoutBlanks.value {
        parsedString = number(contents: parsedString, countBlanks: false)
    } else if number.value {
        parsedString = number(contents: parsedString, countBlanks: true)
    }
    
    return parsedString
}

let files = cli.unparsedArguments

for file in files {
    var isDirectory: ObjCBool = false
    if !FileManager.default.fileExists(atPath: file, isDirectory: &isDirectory) {
        print(error: "File does not exist: \(file.lightRed)")
        exit(EXIT_FAILURE)
    } else if isDirectory.boolValue {
        print(error: "The path specified is a directory: \(file.lightRed)")
        exit(EXIT_FAILURE)
    } else if !FileManager.default.isReadableFile(atPath: file) {
        print(error: "File is not readable: \(file.lightRed)")
        exit(EXIT_FAILURE)
    }
    do {
        let fileContent = try String(contentsOfFile: file)
        let parsedContent = parse(string: fileContent)
        // Do not print an extra line at the end
        print(parsedContent, terminator: "")
    } catch {
        print(error: "An unknown error occured: \(file.lightRed)")
        exit(EXIT_FAILURE)
    }
}
