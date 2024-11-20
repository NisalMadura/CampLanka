//
//  ChatView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-11.
//

import SwiftUI


struct Message: Identifiable {
    let id = UUID()
    let content: String
    let sender: User
    let timestamp: Date
    let isLiked: Bool
}

struct User: Identifiable {
    let id = UUID()
    let name: String
    let avatar: String
}


class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = [
        Message(content: "Hey team, how's the project going?", sender: User(name: "Michael Tran", avatar: "person.circle"), timestamp: Date().addingTimeInterval(-300), isLiked: false),
        Message(content: "Hi Madura, we're making good progress!", sender: User(name: "Chris", avatar: "person.circle"), timestamp: Date().addingTimeInterval(-200), isLiked: false),
        Message(content: "Great to hear! Let me know if you need any help.", sender: User(name: "Michael Tran", avatar: "person.circle"), timestamp: Date().addingTimeInterval(-150), isLiked: false),
        Message(content: "Thanks! We’re just working on the final touches now.", sender: User(name: "Kristen Decastro", avatar: "person.circle"), timestamp: Date().addingTimeInterval(-100), isLiked: false),
        Message(content: "Sounds perfect. Let’s aim to finish by Friday.", sender: User(name: "You", avatar: "person.circle"), timestamp: Date().addingTimeInterval(-50), isLiked: false)
    ]
    @Published var currentMessage: String = ""
    
    func sendMessage(_ content: String, sender: User) {
        let message = Message(content: content,
                              sender: sender,
                              timestamp: Date(),
                              isLiked: false)
        messages.append(message)
        currentMessage = ""
    }
}



struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var showingImagePicker = false
    
    let groupName: String
    let participants: [User]
    
    var body: some View {
        VStack(spacing: 0) {
            
            ChatNavigationBar(groupName: groupName, participants: participants)
            
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            
            MessageInputBar(
                message: $viewModel.currentMessage,
                onSend: {
                    guard !viewModel.currentMessage.isEmpty else { return }
                    viewModel.sendMessage(
                        viewModel.currentMessage,
                        sender: User(name: "You", avatar: "person.circle")
                    )
                },
                onAttachment: { showingImagePicker.toggle() }
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(isShown: $showingImagePicker)
        }
        // .navigationBarBackButtonHidden(true)
    }
}

struct ChatNavigationBar: View {
    let groupName: String
    let participants: [User]
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                
            }
            
            Spacer()
            
            Text(groupName)
                .font(.headline)
            
            Spacer()
            
            NavigationLink(destination: GroupSettingsView()) {
                HStack(spacing: -8) {
                    ForEach(participants.prefix(3)) { participant in
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text(participant.name.prefix(1))
                                    .foregroundColor(.gray)
                            )
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .shadow(radius: 1)
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .bottom) {
            if message.sender.name != "You" {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(message.sender.name.prefix(1))
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if message.sender.name != "You" {
                    Text(message.sender.name)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(message.content)
                    .padding(12)
                    .background(message.sender.name == "You" ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(message.sender.name == "You" ? .white : .black)
                    .cornerRadius(16)
                
                Text(formatDate(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if message.sender.name == "You" {
                Spacer()
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct MessageInputBar: View {
    @Binding var message: String
    let onSend: () -> Void
    let onAttachment: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onAttachment) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            }
            
            TextField("iMessage", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: onSend) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var isShown: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.isShown = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isShown = false
        }
    }
}


struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(
            groupName: "Office Group",
            participants: [
                User(name: "Michael Tran", avatar: "person.circle"),
                User(name: "Chris", avatar: "person.circle"),
                User(name: "Kristen Decastro", avatar: "person.circle")
            ]
        )
    }
}
