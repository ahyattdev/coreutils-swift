import Foundation

#if os(OSX)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

class Formatter {
    
    var elements: [String]
    
    init(elements: [String]) {
        self.elements = elements
    }
    
    func columnsRepresentation() -> String {
        var representation = ""
        
        var size: winsize
        
        ioctl(STDOUT_FILENO, TIOCGWINSZ, &winsize)
        
        return representation
    }
    
}