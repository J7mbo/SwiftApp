//
//  NSMutableAttributedStringExtensions.swift
//  GithubBusApp
//
//  Created by James Mallison on 17/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import UIKit

// Thanks https://stackoverflow.com/a/37992022/736809
extension NSMutableAttributedString
{
    @discardableResult func bold(_ text: String, _ withSystemFontOfSize: CGFloat) -> NSMutableAttributedString
    {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: withSystemFontOfSize, weight: .bold)]
        
        append(NSMutableAttributedString(string:text, attributes: attrs))
        
        return self
    }
    
    @discardableResult func normal(_ text: String, _ withSystemFontOfSize: CGFloat) -> NSMutableAttributedString
    {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: withSystemFontOfSize)]
        
        append(NSAttributedString(string: text, attributes: attrs))
        
        return self
    }
}
