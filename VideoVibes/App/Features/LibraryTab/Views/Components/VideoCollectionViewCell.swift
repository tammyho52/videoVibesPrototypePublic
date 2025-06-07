//
//  VideoCollectionViewCell.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  A UICollectionViewCell that displays a video thumbnail and a loading spinner during loading.

import UIKit

final class VideoCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let reuseIdentifier = "VideoCollectionViewCell"
    
    // MARK: - UI Components
    /// A spinner that indicates loading state when the thumbnail is being fetched.
    private let progressSpinner = UIActivityIndicatorView(style: .medium)
    
    /// An image view that displays the video thumbnail.
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add and layout the thumbnail image
        contentView.addSubview(thumbnailImageView)
        
        // Add and layout the progress spinner
        progressSpinner.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(progressSpinner)
        
        // Layout constraints for subviews
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            progressSpinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            progressSpinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    /// Configures the cell with a video thumbnail image.
    /// - Parameter thumbnail: The thumbnail image to display. If nil, the spinner will be shown.
    func configure(with thumbnail: UIImage?) {
        if let thumbnail {
            thumbnailImageView.image = thumbnail
            progressSpinner.stopAnimating()
            progressSpinner.isHidden = true
        } else {
            thumbnailImageView.image = nil
            progressSpinner.isHidden = false
            progressSpinner.startAnimating()
        }
    }
}
