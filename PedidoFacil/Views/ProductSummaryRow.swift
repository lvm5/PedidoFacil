import SwiftUI
import SwiftData

struct ProductSummaryRow: View {
    var product: String
    var totalRequested: Decimal
    var capacities: [BoxCapacity]
    var modelContext: ModelContext

    private var boxCapacityObj: BoxCapacity {
        if let found = capacities.first(where: { $0.productName == product }) {
            return found
        } else {
            let newCap = BoxCapacity(productName: product, capacity: 0)
            modelContext.insert(newCap)
            return newCap
        }
    }

    private var capacityBinding: Binding<Decimal> {
        Binding<Decimal>(
            get: { boxCapacityObj.capacity },
            set: { newValue in
                boxCapacityObj.capacity = newValue
            }
        )
    }

    var body: some View {
        let (boxesNeeded, missing) = Calculations.calculateBoxesAndMissing(
            total: totalRequested,
            capacity: boxCapacityObj.capacity
        )

        HStack(spacing: 8) {
            Text(product)
                .font(.caption2)
                .frame(width: 120, alignment: .leading)

            Text("\(totalRequested, specifier: "%.2f")kg")
                .font(.caption2)
                .frame(width: 60, alignment: .center)

            TextField("Caixa", value: capacityBinding, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(width: 60, alignment: .center)

            Text("\(boxesNeeded)cx-\(missing, specifier: "%.2f")kg")
                .font(.caption2)
                .frame(width: 70, alignment: .center)
                .foregroundColor(missing == 0 ? .gray : .green)
        }
    }
}