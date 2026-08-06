import PDFKit
import UIKit
import XCTest
@testable import PedidoFacil

final class PDFPriceListExtractorTests: XCTestCase {
    func testExtractsTableColumnsAndDetectsWholesaleChannel() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("ATACADO \(UUID().uuidString).pdf")
        defer { try? FileManager.default.removeItem(at: url) }
        let page = CGRect(x: 0, y: 0, width: 600, height: 840)
        let data = UIGraphicsPDFRenderer(bounds: page).pdfData { context in
            context.beginPage()
            draw("FRANGOS E CORTES", at: CGPoint(x: 120, y: 40))
            draw("PESO", at: CGPoint(x: 380, y: 40))
            draw("VENDA", at: CGPoint(x: 470, y: 40))
            draw("ASA INTERFOLHADA", at: CGPoint(x: 40, y: 70))
            draw("PERDIGÃO", at: CGPoint(x: 255, y: 70))
            draw("15kg", at: CGPoint(x: 370, y: 70))
            draw("R$ 10,49", at: CGPoint(x: 430, y: 70))
        }
        try data.write(to: url)

        let extraction = try PDFPriceListExtractor().extract(from: url)

        XCTAssertEqual(extraction.salesChannel, "Atacado")
        XCTAssertEqual(extraction.sourceName, url.lastPathComponent)
        XCTAssertTrue(extraction.text.contains("FRANGOS E CORTES:"), extraction.text)
        XCTAssertTrue(extraction.text.contains("ASA INTERFOLHADA"), extraction.text)
        XCTAssertTrue(extraction.text.contains("R$ 10,49"), extraction.text)
    }

    private func draw(_ text: String, at point: CGPoint) {
        text.draw(
            at: point,
            withAttributes: [.font: UIFont.systemFont(ofSize: 10)]
        )
    }
}
