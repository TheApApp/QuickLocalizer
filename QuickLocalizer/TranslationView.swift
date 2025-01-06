//
//  TranslationView.swift
//  QuickLocalizer
//
//  Created by Michael Rowe1 on 1/5/25.
//

import SwiftUI

import SwiftUI

struct TranslationView: View {
    let translationDocument: TranslationDocument
    let targetLocalization: [Language]
    
    @State private var selectedLocalization: String = "de"
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Select Localization", selection: $selectedLocalization) {
                    ForEach(targetLocalization, id: \.self) { localization in
                        Text(localization.name).tag(localization.id)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                
                List {
                    ForEach(sortedKeys(), id: \.self) { key in
                        if let localizedString = translationDocument.strings[key]?.localizations![selectedLocalization]?.stringUnit?.value {
                            VStack(alignment: .leading) {
                                Text("Key: \(key)")
                                    .font(.headline)
                                Text(localizedString)
                                    .font(.body)
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
            }
        }
        .navigationTitle("Localization Results")
    }
    
    private func sortedKeys() -> [String] {
        Array(translationDocument.strings.keys).sorted()
    }
}

// Preview
#Preview {
    
    let sampleStrings: [String: TranslationString] = [
        "greeting": TranslationString(localizations: [
            "en": TranslationLanguage(stringUnit: TranslationUnit(value: "Hello")),
            "fr": TranslationLanguage(stringUnit: TranslationUnit(value: "Bonjour")),
            "es": TranslationLanguage(stringUnit: TranslationUnit(value: "Hola"))
        ]),
        "farewell": TranslationString(localizations: [
            "en": TranslationLanguage(stringUnit: TranslationUnit(value: "Goodbye")),
            "fr": TranslationLanguage(stringUnit: TranslationUnit(value: "Au revoir")),
            "es": TranslationLanguage(stringUnit: TranslationUnit(value: "Adiós"))
        ])
    ]
    
    let languages = [
        Language(id: "ar", name: "Arabic", isSelected: false),
        Language(id: "fr", name: "French", isSelected: false),
        Language(id: "de", name: "German", isSelected: true),
        Language(id: "zh", name: "Chinses", isSelected: false),
        Language(id: "nl", name: "Dutch", isSelected: false),
        Language(id: "it", name: "Italian", isSelected: false),
        Language(id: "hi", name: "Hindi", isSelected: false),
        Language(id: "es", name: "Spanish", isSelected: false),
        Language(id: "ja", name: "Japanese", isSelected: false),
        Language(id: "ko", name: "Korean", isSelected: false),
        Language(id: "ru", name: "Russian", isSelected: false),
        Language(id: "pt", name: "Portuguese", isSelected: false),
        Language(id: "uk", name: "Ukrainian", isSelected: false)
    ]
    
    let sampleDocument = TranslationDocument(sourceLanguage: "en", strings: sampleStrings)
    
    NavigationView {
        TranslationView(translationDocument: sampleDocument, targetLocalization: languages)
    }
    
}
