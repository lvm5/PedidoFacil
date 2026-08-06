import Foundation

struct PriceListParser {
    private let knownBrands: [String]
    private let knownCategories: [String]
    private let locale: Locale

    init(
        knownBrands: [String] = [],
        knownCategories: [String] = [],
        locale: Locale = Locale(identifier: "pt_BR")
    ) {
        self.knownBrands = knownBrands
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .sorted { $0.count > $1.count }
        self.knownCategories = knownCategories
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        self.locale = locale
    }

    func parse(_ sourceText: String, now: Date = Date()) -> DailyPriceList {
        var category: String?
        var items: [PriceListItem] = []

        let sourceLines = expandedSourceLines(from: sourceText)
        for (offset, rawLine) in sourceLines.enumerated() {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }
            guard !isNonProductLine(line) else { continue }

            if let detectedCategory = categoryHeader(from: line) {
                category = detectedCategory
                continue
            }

            items.append(parseItem(line, lineNumber: offset + 1, category: category))
        }

        markDuplicates(in: &items)
        return DailyPriceList(
            sourceText: sourceText,
            createdAt: now,
            updatedAt: now,
            items: items
        )
    }

    private func parseItem(
        _ line: String,
        lineNumber: Int,
        category: String?
    ) -> PriceListItem {
        let pipeParts = line.components(separatedBy: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        if pipeParts.count >= 4 {
            return parseTableItem(
                pipeParts,
                originalLine: line,
                lineNumber: lineNumber,
                category: category
            )
        }

        let priceMatch = firstPriceMatch(in: line)
        let rawPrice = priceMatch.map { String(line[$0]) }
        let price = rawPrice.flatMap(parseDecimal)
        let descriptor = priceMatch.map { String(line[..<$0.lowerBound]) } ?? line
        let normalizedDescriptor = descriptor
            .trimmingCharacters(in: descriptorBoundaryCharacters)
        let unit = extractUnit(from: line, after: priceMatch?.upperBound)
        var identity = extractIdentity(from: normalizedDescriptor)
        if identity.brand == nil,
           let trailingBrand = trailingBrand(in: line, after: priceMatch?.upperBound) {
            identity = (identity.name, trailingBrand, false)
        }
        var issues: Set<PriceListItemIssue> = []

        if identity.name.isEmpty { issues.insert(.missingName) }
        if identity.brand == nil { issues.insert(.missingBrand) }
        if price == nil { issues.insert(.missingPrice) }
        if identity.isAmbiguous { issues.insert(.ambiguousDescriptor) }

        return PriceListItem(
            sourceLineNumber: lineNumber,
            originalLine: line,
            name: identity.name,
            brand: identity.brand,
            price: price,
            rawPriceText: rawPrice,
            unit: unit,
            category: category,
            issues: issues
        )
    }

    private func parseTableItem(
        _ columns: [String],
        originalLine: String,
        lineNumber: Int,
        category: String?
    ) -> PriceListItem {
        let name = columns[0]
        let brand = columns[1].isEmpty ? nil : columns[1]
        let unit = columns[2].isEmpty ? nil : columns[2].lowercased()
        let priceColumn = columns.dropFirst(3).joined(separator: " ")
        let priceRange = firstPriceMatch(in: priceColumn)
        let rawPrice = priceRange.map { String(priceColumn[$0]) }
        let price = rawPrice.flatMap(parseDecimal)
        var issues: Set<PriceListItemIssue> = []
        if name.isEmpty { issues.insert(.missingName) }
        if brand == nil { issues.insert(.missingBrand) }
        if price == nil { issues.insert(.missingPrice) }

        return PriceListItem(
            sourceLineNumber: lineNumber,
            originalLine: originalLine,
            name: name,
            brand: brand,
            price: price,
            rawPriceText: rawPrice,
            unit: unit,
            category: category,
            issues: issues
        )
    }

    private func categoryHeader(from line: String) -> String? {
        let withoutColon = line.trimmingCharacters(in: CharacterSet(charactersIn: ":"))
        if line.hasSuffix(":"), firstPriceMatch(in: line) == nil {
            return withoutColon.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return knownCategories.first {
            $0.compare(line, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }
    }

    private func extractIdentity(from descriptor: String) -> (name: String, brand: String?, isAmbiguous: Bool) {
        let pipeParts = descriptor.components(separatedBy: "|")
            .map { $0.trimmingCharacters(in: descriptorBoundaryCharacters) }
            .filter { !$0.isEmpty }
        if pipeParts.count >= 2 {
            return (pipeParts[0], pipeParts[1], false)
        }

        let explicitSeparators = [" | ", " — ", " – ", ";"]
        for separator in explicitSeparators {
            let parts = descriptor.components(separatedBy: separator)
                .map { $0.trimmingCharacters(in: descriptorBoundaryCharacters) }
                .filter { !$0.isEmpty }
            if parts.count == 2 {
                return (parts[0], parts[1], false)
            }
        }

        if let brand = knownBrands.first(where: { descriptorHasSuffix(descriptor, suffix: $0) }) {
            let brandStart = descriptor.index(descriptor.endIndex, offsetBy: -brand.count)
            let name = descriptor[..<brandStart]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return (name, brand, false)
        }

        return (descriptor, nil, descriptor.split(separator: " ").count > 1)
    }

    private func descriptorHasSuffix(_ descriptor: String, suffix: String) -> Bool {
        guard descriptor.count >= suffix.count else { return false }
        let start = descriptor.index(descriptor.endIndex, offsetBy: -suffix.count)
        return descriptor[start...].compare(
            suffix,
            options: [.caseInsensitive, .diacriticInsensitive]
        ) == .orderedSame
    }

    private func firstPriceMatch(in line: String) -> Range<String.Index>? {
        let pattern = #"(?:R\$\s*)?\d+(?:\.\d{3})*(?:[,.]\d{2})"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(line.startIndex..., in: line)
        guard let match = regex.firstMatch(in: line, range: range) else { return nil }
        return Range(match.range, in: line)
    }

    private func parseDecimal(_ rawValue: String) -> Decimal? {
        let sanitized = rawValue
            .replacingOccurrences(of: "R$", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        if let value = formatter.number(from: sanitized) as? NSDecimalNumber {
            return value.decimalValue
        }

        return Decimal(string: sanitized.replacingOccurrences(of: ",", with: "."))
    }

    private func extractUnit(from line: String, after priceEnd: String.Index?) -> String? {
        if let pipeUnit = line.components(separatedBy: "|")
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() })
            .first(where: { $0.range(of: #"^\d+(?:[,.]\d+)?\s*(kg|g|und?|unid|cx|pct)$"#, options: .regularExpression) != nil }) {
            return pipeUnit
        }
        let prefix = priceEnd.map { String(line[..<$0]) } ?? line
        if let range = prefix.range(
            of: #"\b\d+(?:[,.]\d+)?\s*(?:kg|g|und?|unid|cx|pct)\b"#,
            options: [.regularExpression, .caseInsensitive]
        ) {
            return String(prefix[range]).lowercased()
        }
        guard let priceEnd else { return nil }
        let suffix = line[priceEnd...]
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .lowercased()
        let units = ["kg", "quilo", "quilos", "un", "unidade", "unidades", "cx", "caixa", "pct", "pacote"]
        return units.first { suffix == $0 || suffix.hasPrefix("\($0) ") }
    }

    private func trailingBrand(in line: String, after priceEnd: String.Index?) -> String? {
        guard let priceEnd else { return nil }
        let suffix = String(line[priceEnd...])
        return knownBrands.first { brand in
            suffix.range(
                of: #"(?<![\p{L}\p{N}])\#(NSRegularExpression.escapedPattern(for: brand))(?![\p{L}\p{N}])"#,
                options: [.regularExpression, .caseInsensitive, .diacriticInsensitive]
            ) != nil
        }
    }

    private func markDuplicates(in items: inout [PriceListItem]) {
        var firstIndexByKey: [String: Int] = [:]
        for index in items.indices {
            let key = [items[index].name, items[index].brand ?? "", items[index].unit ?? ""]
                .joined(separator: "|")
                .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: locale)
                .lowercased()
            guard !key.replacingOccurrences(of: "|", with: "").isEmpty else { continue }

            if let firstIndex = firstIndexByKey[key] {
                items[firstIndex].issues.insert(.duplicate)
                items[index].issues.insert(.duplicate)
            } else {
                firstIndexByKey[key] = index
            }
        }
    }

    private var descriptorBoundaryCharacters: CharacterSet {
        CharacterSet.whitespacesAndNewlines
            .union(.punctuationCharacters)
            .union(CharacterSet(charactersIn: "|—–"))
    }

    private func expandedSourceLines(from sourceText: String) -> [String] {
        sourceText.components(separatedBy: .newlines).flatMap { rawLine -> [String] in
            let cleaned = cleanDecorations(in: rawLine)
                .replacingOccurrences(of: "/ /", with: "//")
                .replacingOccurrences(of: " / ", with: "//")
            let alternatives = cleaned.components(separatedBy: "//")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            guard alternatives.count > 1, let first = alternatives.first else { return [cleaned] }

            let inheritedName = productNameForAlternative(from: first)
            return alternatives.enumerated().map { index, alternative in
                guard index > 0, !inheritedName.isEmpty else { return alternative }
                if let priceRange = firstPriceMatch(in: alternative), priceRange.lowerBound == alternative.startIndex {
                    let price = alternative[priceRange]
                    let suffix = alternative[priceRange.upperBound...]
                        .trimmingCharacters(in: descriptorBoundaryCharacters)
                    return "\(inheritedName) \(suffix) R$ \(price)"
                }
                return firstPriceMatch(in: alternative) == nil
                    ? alternative
                    : "\(inheritedName) \(alternative)"
            }
        }
    }

    private func cleanDecorations(in line: String) -> String {
        line.replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(
                of: #"^[\s\p{So}\p{Sk}\p{P}]+"#,
                with: "",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func productNameForAlternative(from line: String) -> String {
        guard let priceRange = firstPriceMatch(in: line) else { return line }
        var descriptor = String(line[..<priceRange.lowerBound])
            .trimmingCharacters(in: descriptorBoundaryCharacters)
        if let brand = knownBrands.first(where: { descriptorHasSuffix(descriptor, suffix: $0) }) {
            descriptor = String(descriptor.dropLast(brand.count))
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return descriptor
    }

    private func isNonProductLine(_ line: String) -> Bool {
        let folded = line.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: locale)
            .lowercased()
        if firstPriceMatch(in: line) != nil { return false }
        return folded == "bom dia"
            || folded.hasPrefix("pedido ate")
            || folded.hasPrefix("oferta especial")
    }
}
