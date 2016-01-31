import Spectre
@testable import Negotiator

describe("ContentType") {
	$0.describe("Parsing a Mimetype without a parameter") {
		let sut = ContentType(fromMimetype: "text/html")

		$0.it("Should correctly parse the type") {
			try expect(sut?.type) == "text"
		}

		$0.it("Should correctly parse the subtype") {
			try expect(sut?.subtype) == "html"
		}

		$0.it("Should correctly set params to nil") {
			try expect(sut?.params).beNil()
		}
	}

	$0.describe("Parsing a Mimetype with a parameter") {
		let sut = ContentType(fromMimetype: "text/html; q=0")

		$0.it("Should correctly parse the type") {
			try expect(sut?.type) == "text"
		}

		$0.it("Should correctly parse the subtype") {
			try expect(sut?.subtype) == "html"
		}

		$0.it("Should correctly parse the params") {
			try expect(sut!.params! == ("q", ContentTypeParameterValue.Number(0))).beTrue()
		}
	}

	$0.describe("ContentType matching") {
		$0.it("Should match when both ContentTypes are identical") {
			let a = ContentType(fromMimetype: "text/html")
			let b = ContentType(fromMimetype: "text/html")

			try expect(a == b).beTrue()
			try expect(b == a).beTrue()
		}

		$0.it("Should match when both ContentTypes are identical and have params") {
			let a = ContentType(fromMimetype: "text/html;q=1.0")
			let b = ContentType(fromMimetype: "text/html;q=1.0")

			try expect(a == b).beTrue()
			try expect(b == a).beTrue()
		}

		$0.it("Should match a wildcard Type") {
			let a = ContentType(fromMimetype: "*/jpg")
			let b = ContentType(fromMimetype: "image/jpg")

			try expect(a == b).beTrue()
			try expect(b == a).beTrue()
		}

		$0.it("Should match a wildcard Subtype") {
			let a = ContentType(fromMimetype: "image/*")
			let b = ContentType(fromMimetype: "image/jpg")

			try expect(a == b).beTrue()
			try expect(b == a).beTrue()
		}

		$0.it("Should match when type and subtype match, but only one has a param") {
			let a = ContentType(fromMimetype: "text/html;q=1.0")
			let b = ContentType(fromMimetype: "text/html")

			try expect(a == b).beTrue()
			try expect(b == a).beTrue()
		}
	}
}

describe("Negotiator") {
	let supportedContentTypes = [ContentType(fromMimetype: "text/html")!, ContentType(fromMimetype: "application/json")!]
	let sut = Negotiator(availableContentTypes: supportedContentTypes)

	$0.it("Should return nil if you search for only unsupported content types") {
		let requestedContentTypes = [ContentType(fromMimetype: "fairy/dust")!]
		let type = sut.negotiate(requestedContentTypes)

		try expect(type).beNil()
	}

	$0.it("Should provide the highest priority requested content type") {
		let requestedContentTypes = [ContentType(fromMimetype: "fairy/dust")!, ContentType(fromMimetype: "application/json")!, ContentType(fromMimetype: "text/html")!]
		let type = sut.negotiate(requestedContentTypes)

		try expect(type?.type) == "application"
		try expect(type?.subtype) == "json"
	}

	$0.it("Should not return types with a 0.0 quality param") {
		let requestedContentTypes = [ContentType(fromMimetype: "text/html;q=0.0")!]
		let type = sut.negotiate(requestedContentTypes)

		try expect(type).beNil()
	}
}
