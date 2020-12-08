// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import Foundation

/// Can be string-formatted for use by AzureCore.
public protocol RequestStringConvertible {
    var requestString: String { get }
}

extension RequestStringConvertible {
    public static func == (lhs: RequestStringConvertible, rhs: RequestStringConvertible) -> Bool {
        return lhs.requestString == rhs.requestString
    }
}

extension Int: RequestStringConvertible {
    public var requestString: String {
        return String(self)
    }
}

extension Decimal: RequestStringConvertible {
    public var requestString: String {
        // Test server expects 'positive exponent' to have a + sign. i.e. instead of 2.566e10, it expects 2.566e+10}
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .scientific
        numberFormatter.maximumSignificantDigits = 8
        var decimalString = numberFormatter.string(from: self as NSDecimalNumber)
        decimalString = decimalString?.replacingOccurrences(of: "e([0-9])", with: "e+$1", options: .regularExpression)
        return decimalString ?? ""
    }
}

extension Int32: RequestStringConvertible {
    public var requestString: String {
        return String(self)
    }
}

extension Int64: RequestStringConvertible {
    public var requestString: String {
        return String(self)
    }
}

extension Float: RequestStringConvertible {
    public var requestString: String {
        return String(self)
    }
}

extension Double: RequestStringConvertible {
    public var requestString: String {
        return String(self)
    }
}

extension String: RequestStringConvertible {
    public var requestString: String {
        return self
    }
}

extension Bool: RequestStringConvertible {
    public var requestString: String {
        return String(self)
    }
}

extension Data: RequestStringConvertible {
    public var requestString: String {
        guard let dataString = String(bytes: self, encoding: .utf8) else {
            assertionFailure("Unable to encode bytes")
            return ""
        }
        return dataString
    }
}

public struct Base64Data: Codable, RequestStringConvertible {

    public var value: Data

    // MARK: Initializers

    public init?(string: String) {
        if let data = string.data(using: .utf8) {
            self.value = data
            return
        }
        return nil
    }

    public init?(_ data: Data?) {
        guard let unwrapped = data else { return nil }
        self.value = unwrapped
    }

    // MARK: Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(Data.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(requestString)
    }

    // MARK: Request String Convertible

    public var requestString: String {
        return value.base64EncodedString(trimmingEquals: true)
    }
}

extension Array: RequestStringConvertible {
    public var requestString: String {
        var strings = [String]()
        for value in self {
            if let val = value as? RequestStringConvertible {
                strings.append(val.requestString)
            } else {
                strings.append("")
            }
        }
        return strings.joined(separator: ",")
    }
}

extension DateComponents: RequestStringConvertible {
    public var requestString: String {
        return DateComponentsFormatter().string(from: self) ?? "\"\""
    }
}
