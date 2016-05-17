#if os(OSX)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

class Formatter {
    
    let paddingWidth = 2
    
    var screenWidth = 80
    
    var elements: [String]
    
    init(elements: [String]) {
        self.elements = elements
    }
    
    func columnsRepresentation() -> String {
        
        // With Swift 3 we will be able to use ioctl()
        // It is a variadic function and Swift 2.2 does not support it
        //var size: winsize = winsize()
        //size.ws_row = 25
        //size.ws_col = 80
        
        var initialColumns = screenWidth
        if elements.count < initialColumns {
            initialColumns = elements.count
        }
        
        let columnData = findColumnsRecursive(initialColumns)
        
        let spacedElements = appendSpaceToElements(elements, widths: columnData.columnWidths, columns: columnData.columns)
        
        let representation = arrayToString(spacedElements)
        
        return representation
    }
    
    func findColumnsRecursive(columns: Int) -> (columns: Int, columnWidths: [Int]) {
        let widths = columnSizes(columns)
        
        // Get a sum
        var sum = 0
        for width in widths {
            sum += width
        }
        
        if sum > screenWidth {
            return findColumnsRecursive(columns - 1)
        } else {
            return (columns, widths)
        }
    }
    
    func columnSizes(columns: Int) -> [Int] {
        var widths = [Int]()
        
        for i in 0 ..< elements.count {
            var element = (column: i % columns, size: elements[i].characters.count)
            
            if element.column != columns - 1 {
                element.size += paddingWidth
            }
            
            if element.column == widths.count {
                widths.append(element.size)
            }
            
            if widths[element.column] < element.size {
                widths[element.column] = element.size
            }
        }
        
        return widths
    }
    
    func appendSpace(spaces: Int, string: String) -> String {
        var string = string
        for _ in 1 ... spaces {
            string += " "
        }
        return string
    }
    
    func appendSpaceToElements(elements: [String], widths: [Int], columns: Int) -> [String] {
        var spacedElements = [String]()
        
        for i in 0 ..< elements.count {
            let element = elements[i]
            let columnForElement = i % columns
            let widthForElement = widths[columnForElement]
            let padding = widthForElement - element.characters.count
            
            var spacedElement: String
            
            if padding != 0 {
                spacedElement = appendSpace(padding, string: element)
            } else {
                spacedElement = element
            }
            
            if columnForElement == columns - 1 {
                spacedElement += "\n"
            }
            
            spacedElements.append(spacedElement)
        }
        
        return spacedElements
    }
    
    func arrayToString(array: [String]) -> String {
        var combinedString = ""
        for string in array {
            combinedString += string
        }
        return combinedString
    }
}
