// FIXME: Implement wc without Foundation
// Or wait until Swift 3.0
#if !os(Linux)

// Remove this if your command will not use Foundation
import Foundation
import Rainbow

// Used for parsing arguments
import CommandLine

// The system C library
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

    return cli.defaultFormat(s: str, type: type)
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
    try cli.parse(strict: true)
} catch {
    cli.printUsage(error)
    exit(EXIT_FAILURE)
}

if help.value {
    cli.printUsage()
    exit(EXIT_SUCCESS)
}

// Most program logic will go after here

func countNewlines(string: String) -> Int {
    var count: Int = 0
    for character in string.unicodeScalars {
        if CharacterSet.newlines.contains(character) {
            count += 1
        }
    }
    return count
}

let fm = FileManager.default

WCOptions.ByteCount = byteCount.value
WCOptions.CharCount = charCount.value
WCOptions.LineCount = lineCount.value
WCOptions.LongestLine = longestLine.value
WCOptions.WordCount = wordCount.value

if !(WCOptions.ByteCount || WCOptions.CharCount || WCOptions.LineCount || WCOptions.LongestLine || WCOptions.WordCount) {
    WCOptions.ByteCount = true
    WCOptions.LineCount = true
    WCOptions.WordCount = true
}

// TODO: Handle a tie for the longest line
var longest = (count: 0, lineNumber: -1, fileName: "")

var total = (chars: 0, lines: 0, words: 0, bytes: 0)

for fileName in cli.unparsedArguments {
    guard fm.fileExists(atPath: fileName) else {
        fputs("wc: \(fileName): No such file or directory".red.bold + "\n", stderr)
        break
    }

    guard fm.isReadableFile(atPath: fileName) else {
        fputs("wc: \(fileName): Permission denied".red.bold + "\n", stderr)
        break
    }

    // TODO: Dynamically determine the encoding
    guard let data = fm.contents(atPath: fileName),
        let contents = String(data: data, encoding: String.Encoding.utf8) else {

        fputs("wc: \(fileName): Failed to load contents of file".red.bold + "\n", stderr)
        break
    }

    let byteCountForFile = data.count
    let charCountForFile = contents.characters.count
    let lineCountForFile = countNewlines(string: contents)
    let wordCountForFile = contents.components(separatedBy: CharacterSet.whitespacesAndNewlines).count

    total.bytes += byteCountForFile
    total.chars += charCountForFile
    total.lines += lineCountForFile
    total.words += wordCountForFile

    // TODO: Clean up this formatting
    var output = ""
    if WCOptions.CharCount {
        output += "\(charCountForFile) ".blue
    }
    if WCOptions.LineCount {
        output += "\(lineCountForFile) ".yellow
    }
    if WCOptions.WordCount {
        output += "\(wordCountForFile) ".cyan
    }
    if WCOptions.ByteCount {
        output += "\(byteCountForFile) ".green
    }
    if cli.unparsedArguments.count > 1 {
        output += fileName.magenta
    }

    print(output)
}

// Print the total if there are more than one files
if cli.unparsedArguments.count > 1 {
    var output = ""
    if WCOptions.CharCount {
        output += "\(total.chars) ".blue
    }
    if WCOptions.LineCount {
        output += "\(total.lines) ".yellow
    }
    if WCOptions.WordCount {
        output += "\(total.words) ".cyan
    }
    if WCOptions.ByteCount {
        output += "\(total.bytes) ".green
    }
    output += "total".lightMagenta
    print(output)
}

// This is unecessary because the compiler adds it automatically,
// but it is included for clarity

exit(EXIT_SUCCESS)

#endif
