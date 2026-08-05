import XCTest
@testable import PedidoFacil

final class PriceListParserTests: XCTestCase {
    func testParsesKnownBrandBrazilianPriceAndCategoryWithoutChangingSource() throws {
        let source = """
        Frios:
        Mussarela São Leopoldo — R$ 36,49 kg
        """
        let parser = PriceListParser(
            knownBrands: ["São Leopoldo"],
            knownCategories: ["Frios"]
        )

        let list = parser.parse(source, now: Date(timeIntervalSince1970: 123))
        let item = try XCTUnwrap(list.items.first)

        XCTAssertEqual(list.sourceText, source)
        XCTAssertEqual(item.originalLine, "Mussarela São Leopoldo — R$ 36,49 kg")
        XCTAssertEqual(item.name, "Mussarela")
        XCTAssertEqual(item.brand, "São Leopoldo")
        XCTAssertEqual(item.price, Decimal(string: "36.49"))
        XCTAssertEqual(item.rawPriceText, "R$ 36,49")
        XCTAssertEqual(item.unit, "kg")
        XCTAssertEqual(item.category, "Frios")
        XCTAssertTrue(item.issues.isEmpty)
    }

    func testUnknownBrandIsNotInventedAndRequiresReview() throws {
        let item = try XCTUnwrap(
            PriceListParser().parse("Presunto Rezende R$ 18,79").items.first
        )

        XCTAssertEqual(item.name, "Presunto Rezende")
        XCTAssertNil(item.brand)
        XCTAssertTrue(item.issues.contains(.missingBrand))
        XCTAssertTrue(item.issues.contains(.ambiguousDescriptor))
    }

    func testExplicitSeparatorAllowsBrandWithoutKnownCatalog() throws {
        let item = try XCTUnwrap(
            PriceListParser().parse("Batata | Lar | R$ 7,99 pct").items.first
        )

        XCTAssertEqual(item.name, "Batata")
        XCTAssertEqual(item.brand, "Lar")
        XCTAssertEqual(item.price, Decimal(string: "7.99"))
        XCTAssertEqual(item.unit, "pct")
        XCTAssertFalse(item.issues.contains(.missingBrand))
    }

    func testMissingPriceIsKeptAsReviewableItem() throws {
        let item = try XCTUnwrap(
            PriceListParser(knownBrands: ["Seara"]).parse("Sassami Seara").items.first
        )

        XCTAssertEqual(item.name, "Sassami")
        XCTAssertEqual(item.brand, "Seara")
        XCTAssertNil(item.price)
        XCTAssertTrue(item.issues.contains(.missingPrice))
    }

    func testDuplicatesMarkBothItems() {
        let list = PriceListParser(knownBrands: ["Lar"]).parse("""
        Batata Lar R$ 7,99 pct
        Batata Lar R$ 8,19 pct
        """)

        XCTAssertEqual(list.items.count, 2)
        XCTAssertTrue(list.items.allSatisfy { $0.issues.contains(.duplicate) })
    }
}
