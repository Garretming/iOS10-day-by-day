//
//  SourceEditorExtension.swift
//  Emojificator_Extension
//
//  Created by Samuel Burnstone on 10/08/2016.
//  Copyright © 2016 ShinobiControls. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    //如果在info.plist中配置了相关项，则这里可以不进行代码上的配置
    /*
    func extensionDidFinishLaunching() {
        // If your extension needs to do any work at launch, implement this optional method.
    }
    */

    /*
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: AnyObject]] {
        //         If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
        return [[
            .classNameKey : "Emojificator_Extension.EmojificateCommand",
            .identifierKey : "com.shinobicontrols.Emojificator_Extension.EmojificateCommand",
            .nameKey : "Emojificate!"
        ]]
    }
    */
}
