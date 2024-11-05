//
//  ReviewSubmissionScreen.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-05.
//

import SwiftUI
import PhotosUI

// MARK: - Review Submission Model
struct ReviewSubmission {
    var rating: Int = 0
    var comment: String = ""
    var images: [UIImage] = []
}

// MARK: - Review Submission Screen
struct ReviewSubmissionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reviewSubmission = ReviewSubmission()
    @State private var showImagePicker = false
    @State private var isSubmitting = false
    
    // For text input height calculation
    @State private var textHeight: CGFloat = 100
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .medium))
                    }
                    Spacer()
                    Text("Give a Review")
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Color.clear
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Star Rating
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { star in
                                Button(action: { reviewSubmission.rating = star }) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(star <= reviewSubmission.rating ? .yellow : .gray.opacity(0.3))
                                }
                            }
                        }
                        .padding(.top, 8)
                        .centered()
                        
                        // Review Text Area
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Detail Review")
                                .font(.system(size: 16, weight: .medium))
                            
                            TextEditor(text: $reviewSubmission.comment)
                                .frame(height: max(100, textHeight))
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .overlay(
                                    Text("A peaceful and scenic spot! Loved waking up to misty mornings and exploring the nearby trails. Make sure to bring all your supplies as it's quite remote.")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .opacity(reviewSubmission.comment.isEmpty ? 1 : 0)
                                )
                        }
                        .padding(.horizontal)
                        
                        // Image Section
                        VStack(spacing: 12) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(reviewSubmission.images.indices, id: \.self) { index in
                                        ImageThumbnail(image: reviewSubmission.images[index]) {
                                            reviewSubmission.images.remove(at: index)
                                        }
                                    }
                                    
                                    AddPhotoButton {
                                        showImagePicker = true
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer()
                    }
                }
                
                // Submit Button
                Button(action: submitReview) {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Send Review")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0/255, green: 100/255, blue: 60/255))
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom, 16)
                .disabled(isSubmitting || reviewSubmission.rating == 0)
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(images: $reviewSubmission.images)
            }
        }
    }
    
    private func submitReview() {
        isSubmitting = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            dismiss()
        }
    }
}

// MARK: - Image Thumbnail View
struct ImageThumbnail: View {
    let image: UIImage
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .offset(x: 6, y: -6)
        }
    }
}

// MARK: - Add Photo Button
struct AddPhotoButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 24))
                Text("Add Photo")
                    .font(.system(size: 12))
            }
            .foregroundColor(.gray)
            .frame(width: 80, height: 80)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard !results.isEmpty else { return }
            
            results.forEach { result in
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.images.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - View Extension
extension View {
    func centered() -> some View {
        HStack {
            Spacer()
            self
            Spacer()
        }
    }
}

// MARK: - Preview Provider
struct ReviewSubmissionScreen_Previews: PreviewProvider {
    static var previews: some View {
        ReviewSubmissionScreen()
    }
}
