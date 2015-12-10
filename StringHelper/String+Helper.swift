//
//  String+Helper.swift
//  StringHelper
//
//  Created by Hong Wei Zhuo on 7/12/15.
//  Copyright © 2015 ___zhuohongwei___. All rights reserved.
//

import Foundation

extension String {
    
    struct Lookup {
        static let Codes:Dictionary = {
            return [
                "&nbsp;":160,"&iexcl;":161,"&cent;":162,"&pound;":163,"&curren;":164,"&yen;":165,"&brvbar;":166,"&sect;":167,"&uml;":168,"&copy;":169,"&ordf;":170,"&laquo;":171,"&not;":172,"&shy;":173,"&reg;":174,"&macr;":175,"&deg;":176,"&plusmn;":177,"&sup2;":178,"&sup3;":179,"&acute;":180,"&micro;":181,"&para;":182,"&middot;":183,"&cedil;":184,"&sup1;":185,"&ordm;":186,"&raquo;":187,"&frac14;":188,"&frac12;":189,"&frac34;":190,"&iquest;":191,"&Agrave;":192,"&Aacute;":193,"&Acirc;":194,"&Atilde;":195,"&Auml;":196,"&Aring;":197,"&AElig;":198,"&Ccedil;":199,"&Egrave;":200,"&Eacute;":201,"&Ecirc;":202,"&Euml;":203,"&Igrave;":204,"&Iacute;":205,"&Icirc;":206,"&Iuml;":207,"&ETH;":208,"&Ntilde;":209,"&Ograve;":210,"&Oacute;":211,"&Ocirc;":212,"&Otilde;":213,"&Ouml;":214,"&times;":215,"&Oslash;":216,"&Ugrave;":217,"&Uacute;":218,"&Ucirc;":219,"&Uuml;":220,"&Yacute;":221,"&THORN;":222,"&szlig;":223,"&agrave;":224,"&aacute;":225,"&acirc;":226,"&atilde;":227,"&auml;":228,"&aring;":229,"&aelig;":230,"&ccedil;":231,"&egrave;":232,"&eacute;":233,"&ecirc;":234,"&euml;":235,"&igrave;":236,"&iacute;":237,"&icirc;":238,"&iuml;":239,"&eth;":240,"&ntilde;":241,"&ograve;":242,"&oacute;":243,"&ocirc;":244,"&otilde;":245,"&ouml;":246,"&divide;":247,"&oslash;":248,"&ugrave;":249,"&uacute;":250,"&ucirc;":251,"&uuml;":252,"&yacute;":253,"&thorn;":254,"&yuml;":255,"&amp;":38,"&lt;":60,"&gt;":62,"&apos;":39,"&quot;":34
            ]
            }()
    }
    
    /* Decodes HTML character entities in string */
    func decodeHTMLCharacterEntities() -> String {
    
        guard !self.isEmpty else {
            return self
        }
        
        return self.decodeHTMLCharacterEntities(self.startIndex)
        
    }
    
    func decodeHTMLCharacterEntities(startIndex: Index) -> String {
        
        guard startIndex < self.endIndex else {
            return self
        }
        
        var i = startIndex
        var c: Character = "\0"
        
        let ampersand:Character = "&"
        
        while i < self.endIndex {
            
            c = self[i]
            if c == ampersand {
                break
            }
            
            i++
            
        }
        
        if c != ampersand {
            return self
        }
        
        var j: Index = i
        var numberOfCharactersConsumed = 0
        
        c = "\0"
        
        let semicolon: Character = ";"
        
        while ++j < self.endIndex && ++numberOfCharactersConsumed <= 16 {
            
            c = self[j]
            
            if c == ampersand || c == semicolon {
                break
            }
            
        }
        
        if c != semicolon {
            return self.decodeHTMLCharacterEntities(j)
        }
        
        let range = Range<Index>(start: i, end: i.advancedBy(numberOfCharactersConsumed+1))
        let entity = self.substringWithRange(range)
        
        var decoded = self
        
        if let value = Lookup.Codes[entity] {
            let replacement = Character(UnicodeScalar(value))
            decoded = decoded.stringByReplacingCharactersInRange(range, withString: "\(replacement)")
            
        } else if entity.hasPrefix("&#x") {
            var hex = entity.stringByReplacingOccurrencesOfString("&#x", withString: "")
            hex = hex.stringByReplacingOccurrencesOfString(";", withString: "")
            let value = Int(strtoul(hex, nil, 16))
            let replacement = Character(UnicodeScalar(value))
            decoded = decoded.stringByReplacingCharactersInRange(range, withString: "\(replacement)")
            
        } else if entity.hasPrefix("&#") {
            var decimal = entity.stringByReplacingOccurrencesOfString("&#", withString: "")
            decimal = decimal.stringByReplacingOccurrencesOfString(";", withString: "")
            let value = Int(strtoul(decimal, nil, 10))
            let replacement = Character(UnicodeScalar(value))
            decoded = decoded.stringByReplacingCharactersInRange(range, withString: "\(replacement)")
            
        } else {
            i = i.advancedBy(range.count)
        }
        
        if i == decoded.endIndex {
            return decoded
        }
        
        return decoded.decodeHTMLCharacterEntities(i.advancedBy(1))
    }
    
    /* Formats a number like 10989 into a string like 10.9K */
    static func shortStringFromInt(n: Int) -> String {
        
        var value = Float(n)
        var sign: Character = "\0"
        
        if value < 0 {
            sign = "-"
            value *= -1
        }
        
        var distance:Int = 0
        
        let suffixes = "\0KMGTPE"
        
        while value >= 1000 {
            value /= 1000
            distance++
        }
        
        let lifted = Int(value * 10)
        let idx = suffixes.startIndex.advancedBy(distance)
        let suffix = suffixes[idx]
        
        value = Float(lifted)/Float(10)
        
        let valueString:String!
        
        if lifted % 10 > 0 {
            valueString = String.localizedStringWithFormat("%.1f", value)
            
        } else {
            valueString = String.localizedStringWithFormat("%.f", value)
        }
        
        return "\(sign)\(valueString)\(suffix)"
        
    }
    
    func matches(expression: String) -> Bool {
        let p = NSPredicate(format: "SELF MATCHES %@", expression)
        return p.evaluateWithObject(self)
    }
    
    func isEmail() -> Bool {
        return self.matches("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
    }
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    /* Removes html tags from string */
    func stringByStrippingHTML() -> String {
        return self.stringByReplacingOccurrencesOfString("<[^<>]+?>", withString: "", options: [.RegularExpressionSearch])
    }
    
}
