public typealias ParameterType = (String, ContentTypeParameterValue)

public func ==(lhs: ParameterType, rhs: ParameterType) -> Bool {
	guard lhs.0 == rhs.0 else { return false }
	guard lhs.1 == rhs.1 else { return false }

	return true
}

public struct ContentType: Equatable {
	public let mimetype: String
	public let type: String
	public let subtype: String
	public let params: ParameterType?

	public init?(fromMimetype mimetype: String) {
		let parts = mimetype.characters.split(";")

		guard let typing = parts.first?.split("/").map(String.init) else { return nil } 

		self.mimetype = mimetype
		self.type = typing[0]
		self.subtype = typing[1]

		if parts.count == 2 {
			let _params = parts[1].split("=").map(String.init)
			guard _params.count == 2 else { return nil }
			let key = String(_params[0].characters.filter { $0 != " " })

			guard !key.characters.isEmpty else { return nil }

			self.params = (key, ContentTypeParameterValue.from(_params[1]))
		}
		else {
			self.params = nil
		}
	}
}

public func ==(rhs: ContentType, lhs: ContentType) -> Bool {
	let typeMatch = rhs.type == lhs.type || fuzzyMatch(rhs.type, lhs.type)
	let subtypeMatch = rhs.subtype == lhs.subtype || fuzzyMatch(rhs.subtype, lhs.subtype)

	/**
	FIXME: there is some ambiguity in mime as to whether the omission of the params part is the same as
	a wildcard.  For the purposes of convenience we have assumed here that it is, otherwise a request for
	wildcard/wildcard will not match any content type which has parameters
	*/
	var paramsMatch: Bool
	switch (rhs.params, lhs.params) {
	case (.Some, .None):
		paramsMatch = true
	case (.None, .Some):
		paramsMatch = true
	case (.Some(let a), .Some(let b)):
		paramsMatch = a == b
	case (.None, .None):
		paramsMatch = true
	}

	return typeMatch && subtypeMatch && paramsMatch
}

public enum ContentTypeParameterValue: Equatable {
	case Number(Swift.Double)
	case String(Swift.String)

	public static func from(string: Swift.String) -> ContentTypeParameterValue {
		if let double = Double(string) {
			return .Number(double)
		}

		return .String(string)
	}

	public var isNumber: Bool {
		return numberValue != nil
	}

	public var isString: Bool {
		return stringValue != nil
	}

	public var stringValue: Swift.String? {
		switch self {
			case .String(let s): return s
			default: return nil
		}
	}

	public var numberValue: Double? {
		switch self {
			case .Number(let n): return n
			default: return nil
		}
	}
}

public func ==(lhs: ContentTypeParameterValue, rhs: ContentTypeParameterValue) -> Bool {
	switch (lhs, rhs) {
	case (.Number(let a), .Number(let b)):
		return a == b
	case (.String(let a), .String(let b)):
		return a == b
	default:
		return false
	}	
}

public final class Negotiator {
	public let availableContentTypes: [ContentType]

	public init(availableContentTypes: [ContentType]) {
		self.availableContentTypes = availableContentTypes
	}

	func negotiate(requestedContentTypes: [ContentType]) -> ContentType? {
		for contentType in requestedContentTypes {
			for ac in availableContentTypes {
				if contentType == ac {
					return contentType
				}
			}
		}

		return nil
	}
}



private func fuzzyMatch(first: String, _ second: String) -> Bool {
	switch (first, second) {
	case ("*", _):
		return true
	case (_, "*"):
		return true
	default:
		return false
	}
}

