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

        for (offset, rawLine) in sourceText.components(separatedBy: .newlines).enumerated() {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }

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
        let priceMatch = firstPriceMatch(in: line)
        let rawPrice = priceMatch.map { String(line[$0]) }
        let price = rawPrice.flatMap(parseDecimal)
        let descriptor = priceMatch.map { String(line[..<$0.lowerBound]) } ?? line
        let normalizedDescriptor = descriptor
            .trimmingCharacters(in: descriptorBoundaryCharacters)
        let unit = extractUnit(from: line, after: priceMatch?.upperBound)
        let identity = extractIdentity(from: normalizedDescriptor)
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
        guard let priceEnd else { return nil }
        let suffix = line[priceEnd...]
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .lowercased()
        let units = ["kg", "quilo", "quilos", "un", "unidade", "unidades", "cx", "caixa", "pct", "pacote"]
        return units.first { suffix == $0 || suffix.hasPrefix("\($0) ") }
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
}
