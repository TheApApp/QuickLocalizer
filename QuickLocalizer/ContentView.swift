//
//  ContentView.swift
//  QuickLocalizer
//
//  Created by Michael Rowe1 on 1/4/25.
//

import SwiftUI
import Translation

struct ContentView: View {
    enum TranslationState {
        case waiting, creating, done
    }
    
    @State private var input = "Hello, world!"
    @State private var translationState = TranslationState.waiting
    
    @State private var configuration = TranslationSession.Configuration(
        source: Locale.Language(identifier: "en"),
        target: Locale.Language(identifier: "de")
    )
    
    @State private var languages = [
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
    
    @State private var translatingLanguages = [Language]()
    @State private var languageIndex = Int.max
    
    @State private var showingExporter = false
    @State private var document = TranslationDocument(sourceLanguage: "en")
    
    var body: some View {
        NavigationSplitView {
            ScrollView {
                Form {
                    ForEach($languages) { $language in
                        Toggle(language.name, isOn: $language.isSelected)
                    }
                }
            }
        } detail: {
            VStack(spacing: 0) {
                TextEditor(text: $input)
                    .font(.largeTitle)
                    .translationTask(configuration, action: translate)
                Group {
                    switch translationState {
                    case .waiting:
                        Button("Create Translation") {
                            createAllTranslations()
                        }
                    case .creating:
                        ProgressView()
                    case .done:
                        Button("Export") {
                            showingExporter.toggle()
                        }
                    }
                }
                .frame(height: 60)
            }

            .onChange(of: input) {
                translationState = .waiting
            }
            .onChange(of: languages, updateLanguages)
            .fileExporter(isPresented: $showingExporter, document: document, contentType: .xcStrings, defaultFilename: "Localizable.strings", onCompletion: handleSaveResult)
        }
    }
    
    func createAllTranslations() {
        translatingLanguages = languages.filter(\.isSelected)
        languageIndex = 0
        translationState = .creating
        document.strings.removeAll()
        doNextTranslation()
    }
    
    func translate(using session: TranslationSession) async {
        do {
            if translationState == .waiting {
                try await session.prepareTranslation()
            } else {
                let inputStings = input.components(separatedBy: .newlines)
                let requests = inputStings.map {
                    TranslationSession.Request(sourceText: $0)
                }
                for response in try await session.translations(from: requests) {
                    let translationUnit = TranslationUnit(value: response.targetText)
                    
                    var currentTranslationString = document.strings[response.sourceText] ?? TranslationString()
                    
                    currentTranslationString.localizations[response.targetLanguage.minimalIdentifier] = TranslationLanguage(stringUnit: translationUnit)
                    
                    document.strings[response.sourceText] = currentTranslationString
                    
                }
                
                languageIndex += 1
                doNextTranslation()
            }
        } catch  {
            print(error.localizedDescription)
            translationState = .waiting
        }
    }
    
    func doNextTranslation() {
        guard languageIndex < translatingLanguages.count else {
            translationState = .done
            return
        }
        
        let language = translatingLanguages[languageIndex]
        configuration.source = Locale.Language(identifier: "en")
        configuration.target = Locale.Language(identifier: language.id)
        configuration.invalidate()
    }
    
    func updateLanguages(oldValue: [Language], newValue: [Language]) {
        let oldSet = Set(oldValue.filter(\.isSelected))
        let newSet = Set(newValue.filter(\.isSelected))
        let difference = newSet.subtracting(oldSet)
        
        if let newLanguage = difference.first {
            configuration.source = Locale.Language(identifier: newLanguage.id)
            configuration.invalidate()
        }
        translationState = .waiting
    }
    
    func handleSaveResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            print("Saved file to \(url)")
        case .failure(let error):
            print("Error saving file: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
}
