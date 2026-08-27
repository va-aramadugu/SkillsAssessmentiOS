//
//  ContentView.swift
//  SkillsAssessmentiOS
//
//  Main screen of a small VA health-care copay statement viewer.
//
//  This file has grown organically over several releases and now owns
//  nearly everything: the model, data loading, filtering and sorting,
//  formatting, the balance header, the list, and the add-copay form.
//
//  Suggested reading order:
//    1. Model and state (top of file)
//    2. Data loading and derived collections
//    3. Formatting helpers
//    4. The body and its sections
//    5. The add-copay sheet (bottom of file)
//
//  Treat this like a real file you have just inherited on a team.
//

import SwiftUI

// MARK: - Model

struct Copay: Codable {
    var id: Int
    var description: String
    var amount: Double
    var careType: String
    var date: String        // "yyyy-MM-dd"
    var facility: String?
}

struct Statement: Codable {
    var statementDate: String   // "yyyy-MM-dd"
    var charges: [Copay]
}

// MARK: - View

struct ContentView: View {

    // MARK: State

    @State private var copays: [Copay] = []
    @State private var statementDate = ""
    @State private var isLoading = false
    @State private var selectedCareType = "All"
    @State private var searchText = ""
    @State private var showStatementMonthOnly = false
    @State private var sortByAmount = false
    @State private var isShowingAddSheet = false

    // Add-copay form
    @State private var newDescription = ""
    @State private var newAmount = ""
    @State private var newCareType = "Primary Care"
    @State private var newFacility = ""
    @State private var addError = ""

    let careTypes = ["All", "Primary Care", "Specialty", "Mental Health", "Pharmacy", "Urgent Care", "Inpatient"]

    // MARK: Data loading

    /// Reads the bundled `copays.json` and populates `copays` and
    /// `statementDate`. Called when the screen first appears.
    func loadCopays() {
        isLoading = true
        DispatchQueue.global().async {
            let url = Bundle.main.url(forResource: "copays", withExtension: "json")!
            let data = try! Data(contentsOf: url)
            let decoded = try! JSONDecoder().decode(Statement.self, from: data)
            copays = decoded.charges
            statementDate = decoded.statementDate
        }
    }

    // MARK: Derived data

    /// The copays currently shown in the list, after applying the
    /// care type, search and "statement month" filters and the chosen sort.
    var filteredCopays: [Copay] {
        var result = copays

        if selectedCareType != "All" {
            result = result.filter { $0.careType == selectedCareType }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.description.contains(searchText) }
        }

        if showStatementMonthOnly {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let statementMonth = Calendar.current.component(.month, from: formatter.date(from: statementDate)!)
            result = result.filter { copay in
                let date = formatter.date(from: copay.date)!
                return Calendar.current.component(.month, from: date) == statementMonth
            }
        }

        if sortByAmount {
            result = result.sorted { $0.amount >= $1.amount }
        } else {
            result = result.sorted { $0.date >= $1.date }
        }

        return result
    }

    /// Balance displayed in the summary header.
    var balance: Double {
        var sum = 0.0
        for copay in copays {
            sum = sum + copay.amount
        }
        return sum
    }

    /// Average per charge displayed in the summary header.
    var average: Double {
        return balance / Double(filteredCopays.count)
    }

    // MARK: Formatting helpers

    func formatCurrency(_ value: Double) -> String {
        return String(format: "$%.2f", value)
    }

    func formatAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }

    func formatDate(_ string: String) -> String {
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        let date = parser.date(from: string)!
        let output = DateFormatter()
        output.dateFormat = "MMM d"
        return output.string(from: date)
    }

    func icon(for careType: String) -> AnyView {
        switch careType {
        case "Primary Care":
            return AnyView(Image(systemName: "stethoscope"))
        case "Specialty":
            return AnyView(Image(systemName: "waveform.path.ecg"))
        case "Mental Health":
            return AnyView(Image(systemName: "brain.head.profile"))
        case "Pharmacy":
            return AnyView(Image(systemName: "pills.fill"))
        case "Urgent Care":
            return AnyView(Image(systemName: "cross.case.fill"))
        case "Inpatient":
            return AnyView(Image(systemName: "bed.double.fill"))
        default:
            return AnyView(Image(systemName: "questionmark.circle"))
        }
    }

    func color(for careType: String) -> Color {
        if careType == "Primary Care" {
            return Color(red: 0.2, green: 0.55, blue: 0.95)
        } else if careType == "Specialty" {
            return Color(red: 0.55, green: 0.35, blue: 0.85)
        } else if careType == "Mental Health" {
            return Color(red: 0.2, green: 0.75, blue: 0.5)
        } else if careType == "Pharmacy" {
            return Color(red: 0.95, green: 0.6, blue: 0.2)
        } else if careType == "Urgent Care" {
            return Color(red: 0.9, green: 0.3, blue: 0.3)
        } else if careType == "Inpatient" {
            return Color(red: 0.3, green: 0.3, blue: 0.6)
        } else {
            return Color(red: 0.5, green: 0.5, blue: 0.55)
        }
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Balance header
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Balance due")
                        Spacer()
                        if statementDate != "" {
                            Text("Statement " + formatDate(statementDate))
                        }
                    }
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.5))
                    Text(formatCurrency(balance))
                        .font(.system(size: 34, weight: .bold))
                    HStack {
                        Text("\(filteredCopays.count) charges")
                        Spacer()
                        Text("avg " + formatAmount(average))
                    }
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.5))
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 0.95, green: 0.95, blue: 0.97))

                // Care type filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(careTypes, id: \.self) { careType in
                            Button {
                                selectedCareType = careType
                            } label: {
                                Text(careType)
                                    .font(.system(size: 13, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedCareType == careType
                                                ? Color.blue
                                                : Color(red: 0.95, green: 0.95, blue: 0.97))
                                    .foregroundColor(selectedCareType == careType ? .white : .primary)
                                    .cornerRadius(14)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }

                // Filter and sort options
                HStack {
                    Toggle("Statement month", isOn: $showStatementMonthOnly)
                        .toggleStyle(.button)
                    Toggle("By amount", isOn: $sortByAmount)
                        .toggleStyle(.button)
                    Spacer()
                }
                .font(.system(size: 13))
                .padding(.horizontal, 16)
                .padding(.bottom, 6)

                // Copay list
                List {
                    ForEach(0..<filteredCopays.count, id: \.self) { index in
                        let copay = filteredCopays[index]
                        HStack(spacing: 12) {
                            icon(for: copay.careType)
                                .foregroundColor(color(for: copay.careType))
                                .frame(width: 32, height: 32)
                                .background(color(for: copay.careType).opacity(0.15))
                                .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(copay.description)
                                    .font(.system(size: 15, weight: .medium))
                                if copay.facility != nil && copay.facility != "" {
                                    Text(copay.facility!)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.5))
                                }
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                if copay.amount > 100 {
                                    Text("$\(copay.amount)")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.red)
                                } else {
                                    Text(formatCurrency(copay.amount))
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                Text(formatDate(copay.date))
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.5))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { offsets in
                        for offset in offsets {
                            copays.remove(at: offset)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Copays")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                addCopaySheet
            }
            .onAppear {
                loadCopays()
            }
        }
    }

    // MARK: Add-copay sheet

    /// Form presented from the "+" toolbar button.
    var addCopaySheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Description", text: $newDescription)
                    TextField("Amount", text: $newAmount)
                        .keyboardType(.decimalPad)
                    Picker("Care type", selection: $newCareType) {
                        ForEach(careTypes, id: \.self) { careType in
                            if careType != "All" {
                                Text(careType).tag(careType)
                            }
                        }
                    }
                    TextField("Facility", text: $newFacility)
                }
                if addError != "" {
                    Section {
                        Text(addError)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("New Copay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isShowingAddSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNewCopay()
                    }
                }
            }
        }
    }

    /// Validates the form fields and appends a new copay to the list.
    func saveNewCopay() {
        if newDescription == "" {
            addError = "Description is required"
            return
        }

        let amount = Double(newAmount) ?? 0

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let copay = Copay(
            id: copays.count + 1,
            description: newDescription,
            amount: amount,
            careType: newCareType,
            date: formatter.string(from: Date()),
            facility: newFacility
        )
        copays.append(copay)

        isShowingAddSheet = false
        newDescription = ""
        newAmount = ""
        newFacility = ""
        addError = ""
    }
}
