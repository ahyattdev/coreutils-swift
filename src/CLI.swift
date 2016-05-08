//
//  CLI.swift
//  coreutils-swift
//
//  Created by Andrew Hyatt on 5/7/16.
//  Copyright © 2016 Andrew Hyatt. All rights reserved.
//

import Foundation
import CommandLine
import Rainbow

class CLI : CommandLine {
    
    override init(arguments: [String] = Process.arguments) {
        super.init(arguments: arguments)
        
        formatOutput = { s, type in
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
            
            return self.defaultFormat(str, type: type)
        }
    }
    
    func safeParse() {
        do {
            try parse(true)
        } catch {
            printUsage(error)
            exit(EX_USAGE)
        }
    }
}