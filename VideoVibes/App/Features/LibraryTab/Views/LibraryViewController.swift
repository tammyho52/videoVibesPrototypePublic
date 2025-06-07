//
//  LandingViewController.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  View controller to display the library of videos.

import UIKit
import AVFoundation

final class LibraryViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: LibraryViewModel
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<LibrarySection, URL>!
    
    private enum LibrarySection {
        case main
    }
    
    // MARK: - Initializers
    init(viewModel: LibraryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBarWithLogo()
        setupCollectionView()
        configureDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            let updatedVideoURLs = await viewModel.loadAllVideoURLs()
            updateLibrary(with: updatedVideoURLs)
        }
    }
    
    // MARK: - Setup Methods
    /// Sets up the collection view with a grid layout.
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 10
        let itemsPerRow: CGFloat = 3
        let totalSpacing = spacing * (itemsPerRow - 1) + spacing * 4
        
        let itemWidth = (view.bounds.width - totalSpacing) / itemsPerRow
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: 0, bottom: spacing, right: 0)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.reuseIdentifier)
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: spacing),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -spacing),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -spacing)
        ])
    }
    
    /// Configures the data source for the collection view using a diffable data source.
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<LibrarySection, URL>(
            collectionView: collectionView
        ) { [weak self] (collectionView, indexPath, videoURL) in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: VideoCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? VideoCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            // Display a placeholder loading spinner initially
            cell.configure(with: nil)
            
            // Use cached thumbnail if available, otherwise generate it
            if let cachedThumbnail = self?.viewModel.fetchCachedThumbnail(for: videoURL) {
                cell.configure(with: cachedThumbnail)
            } else {
                Task.detached {
                    let asset = AVAsset(url: videoURL)
                    let maxSize = await cell.bounds.size
                    let thumbnail = generateFirstFrameThumbnail(from: asset, maxSize: maxSize)
                    
                    await MainActor.run {
                        if self?.dataSource.itemIdentifier(for: indexPath) == videoURL {
                            cell.configure(with: thumbnail)
                        }
                    }
                }
            }
            
            return cell
        }
            
        // Initial snapshot loading
        Task {
            let videoURLs = await viewModel.loadAllVideoURLs()
            var snapshot = NSDiffableDataSourceSnapshot<LibrarySection, URL>()
            snapshot.appendSections([.main])
            snapshot.appendItems(videoURLs, toSection: .main)
            await MainActor.run {
                dataSource.apply(snapshot, animatingDifferences: false)
            }
        }
    }
    
    /// Updates the library with the provided video URLs.
    private func updateLibrary(with videoURLs: [URL]) {
        var snapshot = NSDiffableDataSourceSnapshot<LibrarySection, URL>()
        snapshot.appendSections([.main])
        snapshot.appendItems(videoURLs, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension LibraryViewController: UICollectionViewDelegateFlowLayout {
    /// Handles tap events on collection view items.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedVideoURL = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.didSelectVideo(selectedVideoURL)
    }
}

// MARK: - Preview
#if DEBUG
import SwiftUI

#Preview {
    UIViewControllerPreview {
        UINavigationController(rootViewController:
            LibraryViewController(
                viewModel: LibraryViewModel(
                    coordinator: LibraryCoordinator(
                        navigationController: UINavigationController(),
                        permissionService: PermissionService()
                    )
                )
            )
        )
    }
    .edgesIgnoringSafeArea(.all)
    .preferredColorScheme(.dark)
}
#endif
