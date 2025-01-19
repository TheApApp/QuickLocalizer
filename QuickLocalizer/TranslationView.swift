//
//  TranslationView.swift
//  QuickLocalizer
//
//  Created by Michael Rowe1 on 1/5/25.
//

import SwiftUI

struct TranslationView: View {
    @Binding var translationDocument: TranslationDocument
    let targetLocalization: [Language]
    
    @State private var selectedLocalization: String
    
    init(translationDocument: Binding<TranslationDocument>, targetLocalization: [Language]) {
        _translationDocument = translationDocument
        self.targetLocalization = targetLocalization
        _selectedLocalization = State(initialValue: targetLocalization.first(where: { $0.isSelected })?.id ?? "")
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $selectedLocalization) {
                    ForEach(targetLocalization.filter { $0.isSelected }, id: \.id) { localization in
                        List {
                            ForEach(sortedKeys(), id: \.self) { key in
                                // Map targetLocalization ID to a possible key in TranslationDocument
                                let translationKey = mapToTranslationKey(localization.id)
                                if let translationValue = translationDocument.strings[key]?.localizations?[translationKey]?.stringUnit?.value, !translationValue.isEmpty {
                                    VStack(alignment: .leading) {
                                        Text("Key: \(key)")
                                            .font(.headline)
                                        
                                        TextField(
                                            "Translation",
                                            text: Binding(
                                                get: {
                                                    translationValue
                                                },
                                                set: { newValue in
                                                    translationDocument.strings[key]?.localizations?[translationKey]?.stringUnit?.value = newValue
                                                }
                                            )
                                        )
                                        .textFieldStyle(.roundedBorder)
                                    }
                                    .padding(.vertical, 5)
                                } else {
                                    VStack(alignment: .leading) {
                                        Text("Key: \(key)")
                                            .font(.headline)
                                        Text("No translation available")
                                            .font(.body)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                        .tag(localization.id)
                        .tabItem {
                            Text(localization.name)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Localization Results")
    }
    
    private func sortedKeys() -> [String] {
        return Array(translationDocument.strings.keys).sorted()
    }
    
    private func mapToTranslationKey(_ localizationID: String) -> String {
        // Add logic to map `ar` to `ar-AE` or other similar mappings
        // Note currently only Arabic causes an issue but any new cases can
        // be added in the future.
        switch localizationID {
        case "ar": return "ar-AE"
        // Add other mappings as needed
        default: return localizationID
        }
    }
}

// Preview
#Preview {
    @Previewable @State var sampleDocument = TranslationDocument(
        sourceLanguage: "en",
        strings: [
            "greeting": TranslationString(localizations: [
                "en": TranslationLanguage(stringUnit: TranslationUnit(value: "Hello")),
                "fr": TranslationLanguage(stringUnit: TranslationUnit(value: "Bonjour")),
                "es": TranslationLanguage(stringUnit: TranslationUnit(value: "Hola")),
                "ar": TranslationLanguage(stringUnit: TranslationUnit(value: "مرحبا"))
            ]),
            "farewell": TranslationString(localizations: [
                "en": TranslationLanguage(stringUnit: TranslationUnit(value: "Goodbye")),
                "fr": TranslationLanguage(stringUnit: TranslationUnit(value: "Au revoir")),
                "es": TranslationLanguage(stringUnit: TranslationUnit(value: "Adiós")),
                "ar": TranslationLanguage(stringUnit: TranslationUnit(value: "مع السلامة"))
            ])
        ]
    )
    
    let languages = [
        Language(id: "ar", name: "Arabic", isSelected: true), // Ensure Arabic is selected
        Language(id: "fr", name: "French", isSelected: true),
        Language(id: "de", name: "German", isSelected: false),
        Language(id: "zh", name: "Chinese", isSelected: false),
        Language(id: "es", name: "Spanish", isSelected: true)
    ]
    
    NavigationView {
        TranslationView(translationDocument: $sampleDocument, targetLocalization: languages)
    }
}
