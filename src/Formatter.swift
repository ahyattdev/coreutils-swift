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
        
        // With Swift 3 we will be able to use ioctl()
        // It is a variadic function and Swift 2.2 does not support it
        var size: winsize = winsize()
        size.ws_row = 25
        size.ws_col = 80
        
        
        return representation
    }
    
}