//
//  ChatView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-11.
//

import SwiftUI
import FirebaseFirestore
//import FirebaseFirestoreSwift
import FirebaseAuth


struct ChatRoom: Identifiable, Codable {
    @DocumentID var id: String?
    let planId: String
    let participants: [String]
    let createdAt: Date
    let lastMessage: String?
    let lastMessageTimestamp: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, planId, participants, createdAt, lastMessage, lastMessageTimestamp
    }
}

struct ChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    let content: String
    let senderId: String
    let senderName: String
    let timestamp: Date
    var isRead: Bool
    let messageType: MessageType
    
    enum MessageType: String, Codable {
        case text
        case image
        case file
    }
}

struct ChatUser: Identifiable, Codable {
    let id: String
    var name: String
    var email: String
    var avatarURL: String?
    var isOnline: Bool
    var lastSeen: Date?
}


class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var participants: [ChatUser] = []
    
    private var db = Firestore.firestore()
    private var messagesListener: ListenerRegistration?
    private var participantsListener: ListenerRegistration?
    
    let planId: String
    let currentUser: ChatUser
    
    init(planId: String, currentUser: ChatUser) {
        self.planId = planId
        self.currentUser = currentUser
        setupListeners()
    }
    
    deinit {
        messagesListener?.remove()
        participantsListener?.remove()
    }
    
    private func setupListeners() {
        setupMessagesListener()
        setupParticipantsListener()
    }
    
    private func setupMessagesListener() {
        let messagesRef = db.collection("plans")
            .document(planId)
            .collection("chats")
            .order(by: "timestamp", descending: false)
        
        messagesListener = messagesRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                self.error = error.localizedDescription
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            self.messages = documents.compactMap { document -> ChatMessage? in
                try? document.data(as: ChatMessage.self)
            }
        }
    }
    
    private func setupParticipantsListener() {
        
        db.collection("plans").document(planId).getDocument { [weak self] document, error in
            guard let self = self,
                  let document = document,
                  let chatRoom = try? document.data(as: ChatRoom.self) else { return }
            
            
            for userId in chatRoom.participants {
                self.db.collection("users").document(userId)
                    .addSnapshotListener { [weak self] document, error in
                        guard let document = document,
                              let user = try? document.data(as: ChatUser.self) else { return }
                        
                        self?.updateParticipant(user)
                    }
            }
        }
    }
    
    private func updateParticipant(_ user: ChatUser) {
        if let index = participants.firstIndex(where: { $0.id == user.id }) {
            participants[index] = user
        } else {
            participants.append(user)
        }
    }
    
    func sendMessage(_ content: String, type: ChatMessage.MessageType = .text) {
        guard !content.isEmpty else { return }
        isLoading = true
        
        let message = ChatMessage(
            content: content,
            senderId: currentUser.id,
            senderName: currentUser.name,
            timestamp: Date(),
            isRead: false,
            messageType: type
        )
        
        do {
            try db.collection("plans")
                .document(planId)
                .collection("chats")
                .addDocument(from: message) { [weak self] error in
                    guard let self = self else { return }
                    
                    self.isLoading = false
                    if let error = error {
                        self.error = error.localizedDescription
                        return
                    }
                    
                    
                    self.updateChatRoomLastMessage(content)
                    self.currentMessage = ""
                }
        } catch {
            self.error = error.localizedDescription
            self.isLoading = false
        }
    }
    
    private func updateChatRoomLastMessage(_ content: String) {
        let data: [String: Any] = [
            "lastMessage": content,
            "lastMessageTimestamp": Date()
        ]
        
        db.collection("plans")
            .document(planId)
            .updateData(data)
    }
}


struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @State private var showingImagePicker = false
    @State private var showingError = false
    
    init(planId: String, currentUser: ChatUser) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(planId: planId, currentUser: currentUser))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ChatHeaderView(participants: viewModel.participants)
            MessageListView(
                messages: viewModel.messages,
                currentUserId: viewModel.currentUser.id
            )
            MessageInputView(
                message: $viewModel.currentMessage,
                isLoading: viewModel.isLoading,
                onSend: {
                    viewModel.sendMessage(viewModel.currentMessage)
                },
                onAttachment: { showingImagePicker.toggle() }
            )
        }
        .alert("Error", isPresented: $showingError, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(viewModel.error ?? "Unknown error occurred")
        })
        .onChange(of: viewModel.error) { error in
            showingError = error != nil
        }
    }
}

struct ChatHeaderView: View {
    let participants: [ChatUser]
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(participants.prefix(3)) { user in
                    UserAvatarView(user: user)
                }
                
                if participants.count > 3 {
                    Text("+\(participants.count - 3)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            Divider()
        }
        .padding(.top)
        .background(Color.white)
    }
}

struct UserAvatarView: View {
    let user: ChatUser
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(user.name.prefix(1).uppercased())
                        .foregroundColor(.gray)
                )
            
            if user.isOnline {
                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
        }
    }
}

struct MessageListView: View {
    let messages: [ChatMessage]
    let currentUserId: String
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(messages) { message in
                    MessageBubbleView(
                        message: message,
                        isCurrentUser: message.senderId == currentUserId
                    )
                }
            }
            .padding()
        }
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(alignment: .bottom) {
            if !isCurrentUser {
                UserAvatarView(user: ChatUser(
                    id: message.senderId,
                    name: message.senderName,
                    email: "",
                    isOnline: false
                ))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if !isCurrentUser {
                    Text(message.senderName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(message.content)
                    .padding(12)
                    .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .cornerRadius(16)
                
                HStack {
                    Text(formatDate(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    if message.isRead {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption2)
                    }
                }
            }
            
            if isCurrentUser {
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

struct MessageInputView: View {
    @Binding var message: String
    let isLoading: Bool
    let onSend: () -> Void
    let onAttachment: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onAttachment) {
                Image(systemName: "paperclip")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
            }
            
            TextField("Type a message", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: onSend) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
            }
            .disabled(message.isEmpty || isLoading)
        }
        .padding()
        .background(Color.white)
        .shadow(radius: 1)
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
            planId: "C25097C5-A6BC-49FA-B77C-4E7332907FF5",
            currentUser: ChatUser(
                id: "mockUserId",
                name: "Mock User",
                email: "mock@example.com",
                avatarURL: nil,
                isOnline: true
            )
        )
    }
}

