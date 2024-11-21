//
//  HelpDetailView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-17.
//

import SwiftUI

struct HelpCenterView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedSection: String?
    
    private let helpSections = [
        HelpSection(
            title: "Account & Profile",
            items: [
                HelpItem(title: "How to change profile picture", content: "To change your profile picture:\n1. Go to Profile\n2. Tap the Edit button\n3. Select 'Change Photo'\n4. Choose a new photo from your gallery"),
                HelpItem(title: "Update personal information", content: "You can update your name and other personal details through the Edit Profile screen.")
            ]
        ),
        HelpSection(
            title: "Security",
            items: [
                HelpItem(title: "Password reset", content: "To reset your password:\n1. Go to Account & Password\n2. Select 'Change Password'\n3. Follow the verification steps"),
                HelpItem(title: "Account privacy", content: "We take your privacy seriously. Your personal information is encrypted and securely stored.")
            ]
        ),
        HelpSection(
            title: "Contact Support",
            items: [
                HelpItem(title: "Email Support", content: "For additional help, contact us at: support@example.com"),
                HelpItem(title: "Report an Issue", content: "If you've encountered a problem, please provide details about the issue and we'll get back to you within 24 hours.")
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(helpSections, id: \.title) { section in
                    Section(header: Text(section.title)) {
                        ForEach(section.items, id: \.title) { item in
                            NavigationLink(destination: HelpDetailView(helpItem: item)) {
                                Text(item.title)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Help Center")
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct HelpDetailView: View {
    let helpItem: HelpItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(helpItem.content)
                    .padding()
            }
        }
        .navigationTitle(helpItem.title)
    }
}

struct HelpSection {
    let title: String
    let items: [HelpItem]
}

struct HelpItem {
    let title: String
    let content: String
}


struct HelpCenterView_Previews: PreviewProvider {
    static var previews: some View {
        HelpCenterView()
    }
}
