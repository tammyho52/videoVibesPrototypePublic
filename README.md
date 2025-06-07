 <img src="https://github.com/tammyho52/videoVibesPrototypeAssets/blob/e8641e9afe7fba4779eccde6d3b16b18c293d848/AppIcon.png" width="100px" height="auto" style="border-radius:50%"> 
 
# VideoVibes App Prototype
A UIKit-based AVFoundation app prototype to record, filter, and preview videos — built to demonstrate iOS multimedia engineering skills including real-time processing, capture session management, and video rendering.

![swift-badge](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![figma-badge](https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white)

<div style="display: flex; gap: 10px; flex-wrap: wrap;">
  <img src="https://github.com/tammyho52/videoVibesPrototypeAssets/blob/e8641e9afe7fba4779eccde6d3b16b18c293d848/Screenshot1.png" width="150px" height="auto" style="border-radius: 15px;">
  <img src="https://github.com/tammyho52/videoVibesPrototypeAssets/blob/e8641e9afe7fba4779eccde6d3b16b18c293d848/Screenshot2.PNG" width="150px" height="auto" style="border-radius: 15px;">
  <img src="https://github.com/tammyho52/videoVibesPrototypeAssets/blob/e8641e9afe7fba4779eccde6d3b16b18c293d848/Screenshot3.PNG" width="150px" height="auto" style="border-radius: 15px;">
  <img src="https://github.com/tammyho52/videoVibesPrototypeAssets/blob/e8641e9afe7fba4779eccde6d3b16b18c293d848/Screenshot4.PNG" width="150px" height="auto" style="border-radius: 15px;">
  <img src="https://github.com/tammyho52/videoVibesPrototypeAssets/blob/e8641e9afe7fba4779eccde6d3b16b18c293d848/Screenshot5.PNG" width="150px" height="auto" style="border-radius: 15px;">
</div>

[Youtube: Watch Video of VideoVibes App Prototype functionalities here](https://youtu.be/5mjRzSP2tgA?si=pu31j9B2ZvUiukbJ)

## Requirements

This project requires Xcode 16.0+, Swift 6.0+, and targets iOS 17.6+ or later.

## Overview & Goals

Capture and edit videos with real-time filters using VideoVibes - an app prototype designed to make video editing fun and accessible. Whether capturing moments on the go or creating social media content, VideoVibes offers a seamless experience with intuitive controls and powerful filters.

**Goals**: Demonstrate expertise in Swift, UIKit, Combine, AVFoundation, and CoreImage, as well as proficiency in handling multimedia assets. This prototype prioritizes AVFoundation-based UI and camera/video workflows.

## Prototype Features
- **Library**: Browse videos in a gallery view.
- **Create**: Edit videos with live filters applied in real-time, including switching filters and adjusting filter intensity.
- **Record**: Capture videos with real-time previews.

## Limitations
This is a prototype app for skill demonstration purposes and is not a production-ready application. Features are built to demonstrate functionality and may not cover all edge cases. Please see the "Prototype Scope & Engineering Tradeoffs" section for additional detail on known limitations and areas for improvement.

---

## Architecture Overview
- This is a fully programmatic UIKit-based app. 
- The app follows a Model-View-ViewModel (MVVM) architecture with Services and Utilities for better separation of concerns and maintainability.
- The Coordinator pattern is used for navigation management, ensuring a clean separation of navigation logic from view controllers.
- Dependency injection and protocol-oriented design are employed to facilitate testing and maintainability.
- Combine is used extensively for reactive state management and data binding between View Models and View Controllers. 
- Services include `PermissionService`, `VideoFilterService`, and `VideoRecordingService` for handling permissions, video filtering, and video capture functionalities.

## Design Decisions
- **UIKit**: Chosen for its flexibility and familiarity, allowing for custom navigation bar, UI components, and animations.
- **App Logo with Custom Animation**: Designed and implemented a visually engaging animation where five hexagons are stroked in sequence with timed delays, creating a dynamic loading effect on the landing page. A static version of the logo is displayed in the navigation bar throughout the app for consistent branding.
- **Combine**: Allows view models to handle state with view controllers reactively updating UI based on data changes.
- **Coordinator Pattern**: A `BaseCoordinator` sets up reusable navigation logic (mainly popping view controllers and popping to root), while tab-specific coordinators handle push view controller navigation flows and transitions. Protocols are used to define tab coordinators and navigation destinations for each tab, allowing for better testability and separation of concerns.
- **AVFoundation**: 
    - The Library tab uses `AVQueuePlayer` + `AVPlayerLooper` for video playback looping and `AVVideoComposition` for media composition in real-time. Video player assets are fetched from URLs and played back using `AVPlayer`. `ImageGenerator` is used to create thumbnails for video assets with focus on ensuring image resolution is retained when scaling the thumbnail.
    - The Create tab uses `AVCaptureSession` for video recording and `AVCaptureVideoPreviewLayer` for video playbacks. Capture sessions are initialized once and maintained throughout the app lifecycle with start/stop of recording output instead of starting/stopping the whole capture session. `NotificationCenter` observers are used to check for app state system notifications and stop the capture session.
    - Permissions for camera, microphone, and photo library access are handled using `PermissionService`.
- **CoreImage**: All filters provided by the app at this time are `CIFilters` with optional filter intensity control using a filter input key. `CIContext` facilitates image rendering and applying filters to video frames in real-time, leveraging the GPU for efficient processing.
- **Caching**: The app uses a cache for video thumbnails to avoid redundant thumbnail generation.
- **Debugging**: Instruments was used to profile the app, ensuring smooth performance and identifying any bottlenecks during video processing and playback. Print statements and breakpoints were used during development to trace issues and verify functionality.

## Concurrency Considerations
AVFoundation was designed before Swift's modern concurrency model and remains heavily callback-based. To work with these APIs in a more readable, async/await-friendly way, this prototype app leverages:
- `DispatchQueue` for camera and recording workflows to avoid blocking the main thread. For example, camera configuration and video processing tasks are dispatched to a background queue.
- `NotificationCenter` observers are registered to monitor app lifecycle transitions to pause or clean up capture sessions. This helps manage resources effectively and avoid memory leaks.
- `@MainActor` annotations to ensure UI-bound tasks are safely executed on the main thread.
- `withCheckedContinuation` to wrap legacy completion-handler APIs into structured concurrency.

## Prototype Scope & Engineering Tradeoffs
- **Media Metadata Handling**: The app does not implement comprehensive media metadata handling, such as accounting for video duration, resolution, or orientation.
- **Video Referencing**: Videos are referenced using URLs for playback and editing, but the preferred storage solution would be `PHAsset`'s `localIdentifier` for better integration with the user's photo library. This would allow for better handling of video assets, including saving video edits.
- **Video Playback**: The app does not implement advanced features like adaptive bitrate streaming or offline caching. Edge cases for video playback and recording are also not fully implemented, such as handling interruptions or errors during video capture.
- **Protocol-Oriented Design**: Protocol-oriented design is not fully utilized across the app, but files are structured with separation of concerns in mind and allows for easy refactoring.
- **Data Persistence**: The app currently saves videos using `FileManager` to the user's temporary directory, with video files removed when the app enters a background state.
- **Caching**: The app does not implement caching for video assets and provides limited in-memory caching for thumbnails, which are discarded when the app is terminated. Caching optimizations can improve performance and reduce loading times. 
- **Error Handling**: The app includes basic UI for loading indicators, alert toasts, and error messages with custom app errors thrown. However, it does not cover comprehensive error handling and edge cases.
- **Testing**: The app does not include unit tests or UI tests due to time constraints. However, the architecture is designed to facilitate testing with protocol-oriented architecture and dependency injection. Please see other GitHub Projects for unit and UI test examples.
- **Mock Data**: The app uses mock data stored directly in the app bundle for previews and testing purposes, allowing for quick iteration without needing to set up a backend or external data source.

---

## Future Development
- Custom filters and additional adjustments like brightness, contrast, saturation, etc. Video previews and processing for custom edits will require MetalKit for performance optimizations.
- Video trimming and exporting capabilities allowing users to cut videos to their desired length and save videos after edits.
- Custom text and logo overlays in videos, enabling users to customize video assets further.

---

## Setup Instructions
By default, the app is configured to use mock data for previews. No external setup is required, and you can get started immediately.
1. Clone the repository.
2. Open the project in Xcode.
3. Build and run the app on a physical device (simulator does not support camera functionality).

## License
This project is licensed under a **private license**. It is **not open source**. Unauthorized distribution, modification, or commercial use is prohibited. For inquiries about usage rights, please contact the author.  

