//
//  ContentView.swift
//  QuickLocalizer
//
//  Created by Michael Rowe1 on 1/4/25.
//

import AppKit
import os
import SwiftUI
import Translation

struct ContentView: View {
    enum TranslationState {
        case waiting, creating, done
    }
    
    /// Adding a WalkThru launch screen  Will alllow for a reset to do the walkthu again
    @AppStorage("walkthrough") var walkthrough = 1
    @AppStorage("totalViews") var totalViews = 1
    
    @State private var input = "Note the input language must be English(US)\n1) You can import an existing Localization.xcstring\n2) Select the languages you'd like to translate\n3) Then export your translation back to your project."
    @State private var translationState = TranslationState.waiting
    
    @State private var configuration = TranslationSession.Configuration(
        source: Locale.Language(identifier: "en"),
        target: Locale.Language(identifier: "en")
    )
    
    @State private var languages = [
        Language(id: "ar", name: "Arabic", isSelected: false),
        Language(id: "zh", name: "Chinese", isSelected: false),
        Language(id: "nl", name: "Dutch", isSelected: false),
//        Language(id: "en", name: "English", isSelected: false),
        Language(id: "fr", name: "French", isSelected: false),
        Language(id: "de", name: "German", isSelected: false),
        Language(id: "hi", name: "Hindi", isSelected: false),
        Language(id: "id", name: "Indonesian", isSelected: false),
        Language(id: "it", name: "Italian", isSelected: false),
        Language(id: "ja", name: "Japanese", isSelected: false),
        Language(id: "ko", name: "Korean", isSelected: false),
        Language(id: "pl", name: "Polish", isSelected: false),
        Language(id: "pt", name: "Portuguese", isSelected: false),
        Language(id: "ru", name: "Russian", isSelected: false),
        Language(id: "es", name: "Spanish", isSelected: false),
        Language(id: "th", name: "Thai", isSelected: false),
        Language(id: "tr", name: "Turkish", isSelected: false),
        Language(id: "uk", name: "Ukrainian", isSelected: false),
        Language(id: "vi", name: "Vietnamese", isSelected: false),
    ]
    
    @State private var translatingLanguages = [Language]()
    @State private var languageIndex = Int.max
    
    @State private var showingExporter = false
    @State private var showingTranslation = false
    @State private var document = TranslationDocument(sourceLanguage: "en")
    
    let logger=Logger(subsystem: "com.theapapp.QuickLocalizer", category: "Errors")
    
    var body: some View {
        if walkthrough == 1 {
            WalkThroughtView(title: "Easily translate your strings", description: """
            Quick Localizer utilize's Apple's own lanugage translations dictionaries to quickly, and easily, 
            translate your Xcode's projects strings to any supported language.
            
            The dictionaries can be downlaoded via:
            System Settings...Languages and Regions...Translation Languages
            
            Or if you pick a language not already installed, it will 
            download them on demand.
            """
, bgColor: "AccentColor", img: "Welcome_one")
        } else {
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
                            HStack{
                                Button("Load Strings") {
                                    importStrings()
                                }
                                
                                Button("Create Translation") {
                                    createAllTranslations()
                                }
                            }
                        case .creating:
                            ProgressView()
                        case .done:
                            HStack {
                                Button("Show Translations") {
                                    showingTranslation.toggle()
                                }
                                Button("Export") {
                                    showingExporter.toggle()
                                }
                            }
                        }
                    }
                    .frame(height: 60)
                }
                
                .onChange(of: input) {
                    translationState = .waiting
                }
                .onChange(of: languages, updateLanguages)
                
                .onChange(of: showingTranslation) {
                    if showingTranslation {
                        openLocalizationWindow()
                        showingTranslation = false
                    }
                }
                .sheet(isPresented: $showingTranslation) {
                    EmptyView()
                    TranslationView(translationDocument: document, targetLocalization: languages)
                }
                .fileExporter(isPresented: $showingExporter, document: document, contentType: .xcStrings, defaultFilename: "Localizable", onCompletion: handleSaveResult)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button(action: {
                            walkthrough = 1
                        }, label: {
                            Image(systemName: "questionmark.circle")
                                .font(.title2)
                        })
                    }
                }
            }
        }
    }
    
    func createAllTranslations() {
        translatingLanguages = languages.filter(\.isSelected)
        languageIndex = 0
        translationState = .creating
        document.strings.removeAll()
        doNextTranslation()
    }
    
    func importStrings() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.xcStrings]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            do {
                let data = try Data(contentsOf: url)
                let decodedDocument = try JSONDecoder().decode(TranslationDocument.self, from: data)
                document = decodedDocument
                input = decodedDocument.strings.keys.sorted().joined(separator: "\n")
            } catch {
                logger.error("Failed to load document: \(error.localizedDescription)")
            }
        }
    }
    
    private func openLocalizationWindow() {

        let localizationView = TranslationView(
                    translationDocument: document,
                    targetLocalization: languages
                )
                
                let hostingController = NSHostingController(rootView: localizationView)
                let window = NSWindow(
                    contentViewController: hostingController
                )
                window.title = "Localization Viewer"
                window.setContentSize(NSSize(width: 600, height: 400))
                window.makeKeyAndOrderFront(nil)
                
                // Ensure the window stays in scope
                NSApplication.shared.activate(ignoringOtherApps: true)
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
                    
                    currentTranslationString.localizations![response.targetLanguage.minimalIdentifier] = TranslationLanguage(stringUnit: translationUnit)
                    
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
