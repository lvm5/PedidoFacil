import Foundation
import PDFKit

enum PDFPriceListExtractorError: LocalizedError {
    case unreadableDocument
    case noTableRows

    var errorDescription: String? {
        switch self {
        case .unreadableDocument: "Não foi possível abrir o PDF."
        case .noTableRows: "Nenhuma linha de tabela foi encontrada no PDF."
        }
    }
}

struct PDFPriceListExtraction {
    let text: String
    let sourceName: String
    let salesChannel: String?
}

struct PDFPriceListExtractor {
    func extract(from url: URL) throws -> PDFPriceListExtraction {
        guard let document = PDFDocument(url: url) else {
            throw PDFPriceListExtractorError.unreadableDocument
        }

        var rows: [String] = []
        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else { continue }
            rows.append(contentsOf: extractRows(from: page))
        }
        guard !rows.isEmpty else { throw PDFPriceListExtractorError.noTableRows }

        let filename = url.deletingPathExtension().lastPathComponent
        let channel = detectedChannel(in: filename)
        return PDFPriceListExtraction(
            text: rows.joined(separator: "\n"),
            sourceName: url.lastPathComponent,
            salesChannel: channel
        )
    }

    private func extractRows(from page: PDFPage) -> [String] {
        let bounds = page.bounds(for: .mediaBox)
        guard let lines = page.selection(for: bounds)?.selectionsByLine() else { return [] }

        let fragments = lines.compactMap { selection -> Fragment? in
            guard let text = selection.string?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else { return nil }
            return Fragment(text: text, bounds: selection.bounds(for: page))
        }
        let grouped = Dictionary(grouping: fragments) { fragment in
            Int((fragment.bounds.midY / 2).rounded())
        }

        return grouped.values
            .sorted { ($0.first?.bounds.midY ?? 0) > ($1.first?.bounds.midY ?? 0) }
            .compactMap { makeRow(from: $0, on: page, pageBounds: bounds) }
    }

    private func makeRow(from fragments: [Fragment], on page: PDFPage, pageBounds: CGRect) -> String? {
        let sorted = fragments.sorted { $0.bounds.minX < $1.bounds.minX }
        let texts = sorted.map(\.text)
        let uppercase = texts.joined(separator: " ").uppercased()
        let pageWidth = pageBounds.width

        if uppercase.contains("PESO"), uppercase.contains("VENDA") {
            var category = sorted
                .filter { $0.bounds.minX < pageWidth * 0.62 }
                .map(\.text)
                .filter { !["PESO", "VENDA"].contains($0.uppercased()) }
                .joined(separator: " ")
            category = category.replacingOccurrences(of: "PESO", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "VENDA", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return category.isEmpty ? nil : "\(category):"
        }

        let rowBounds = sorted.map(\.bounds).reduce(CGRect.null) { $0.union($1) }
        let yRange = (rowBounds.minY - 1)..<(rowBounds.maxY + 1)
        let product = columnText(on: page, xRange: 0..<(pageWidth * 0.40), yRange: yRange)
        let brand = columnText(on: page, xRange: (pageWidth * 0.40)..<(pageWidth * 0.59), yRange: yRange)
        let weight = columnText(on: page, xRange: (pageWidth * 0.59)..<(pageWidth * 0.70), yRange: yRange)
        let price = columnText(on: page, xRange: (pageWidth * 0.70)..<pageWidth, yRange: yRange)

        guard !product.isEmpty else { return nil }
        let columns = [product, brand, weight, price].filter { !$0.isEmpty }
        guard columns.count >= 2 else { return nil }
        return columns.joined(separator: " | ")
    }

    private func columnText(
        on page: PDFPage,
        xRange: Range<CGFloat>,
        yRange: Range<CGFloat>
    ) -> String {
        let rect = CGRect(
            x: xRange.lowerBound,
            y: yRange.lowerBound,
            width: xRange.upperBound - xRange.lowerBound,
            height: yRange.upperBound - yRange.lowerBound
        )
        return (page.selection(for: rect)?.string ?? "")
            .components(separatedBy: .newlines)
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func detectedChannel(in filename: String) -> String? {
        let normalized = filename.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .lowercased()
        if normalized.contains("atacado") { return "Atacado" }
        if normalized.contains("varejo") { return "Varejo" }
        return nil
    }

    private struct Fragment {
        let text: String
        let bounds: CGRect
    }
}
