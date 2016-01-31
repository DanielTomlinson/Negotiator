import Spectre
@testable import Negotiator

describe("ContentType parsing with simple mimetype") {
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

describe("ContentType parsing with a single parameter") {
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

describe("ContentType matching") {
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
