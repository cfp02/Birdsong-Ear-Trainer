# Birdsong Trainer

## 🚨 Project Management Instructions
<details>
<summary>Click to expand project management guidelines</summary>

**IMPORTANT**: This README is a living document managed by Projectify and Cursor.
To maintain compatibility and effectiveness:
1. Do not modify the structure of special sections (marked with 🚨)
2. Keep all Cursor-specific metadata intact
3. Update the Progress Log with every significant change
4. Use the provided section templates for new content
5. Maintain the established heading hierarchy
</details>

## Current Focus
- [✅] Phase 1: Project Initialization and App Planning
  - [✅] Define initial feature set and app purpose
  - [✅] Choose Flutter as the core framework
  - [✅] Begin Flutter project setup
  - [✅] Design UI wireframes and audio flow logic
- [🔄] Phase 2: Core Functionality
  - [✅] Implement eBird API integration
  - [✅] Create bird data models and providers
  - [✅] Build bird selection and filtering UI
  - [✅] Implement bird list management system
  - [🔄] Implement audio playback system
  - [🔄] Add training mode logic
    - [ ] Fix bird selection persistence
    - [ ] Add next/previous bird navigation
    - [ ] Implement automatic progression
    - [ ] Add progress tracking
    - [ ] Fix audio playback functionality

## Progress Log
<details>
<summary>View complete progress history</summary>

### 2025-04-11 (Evening)
- Phase: Phase 2 - Core Functionality
- Work completed:
  - Fixed critical API integration issues
    - Resolved CSV parsing errors in eBird API responses
    - Updated taxonomy endpoint handling to properly parse CSV data
    - Implemented proper error handling for API responses
    - Added detailed logging for debugging API calls
  - Enhanced Audio Player System
    - Converted AudioPlayerProvider to use AsyncValue for better state management
    - Implemented proper loading and error states
    - Added robust error handling for audio playback
    - Updated UI to handle async states with loading indicators
  - Updated Learning Mode Screen
    - Integrated with new AsyncValue-based AudioPlayerProvider
    - Added proper error handling and loading states
    - Improved user feedback during audio playback
    - Fixed method name inconsistencies (playBirdSong → playBirdAudio)
  - Technical Improvements:
    - Standardized method names across providers
    - Enhanced error handling throughout the app
    - Improved state management consistency
    - Added comprehensive logging for debugging
- Challenges encountered:
  - CSV parsing issues with eBird API responses
  - State management synchronization between providers
  - Method name inconsistencies across components
  - Async state handling in UI components
- Next steps:
  - Implement proper audio caching system
  - Add offline support for bird data
  - Enhance error recovery mechanisms
  - Begin implementing training mode logic

### 2025-04-11 (Afternoon)
- Phase: Phase 2 - Core Functionality
- Work completed:
  - Fixed bird list management system
    - Removed predefined lists in favor of user-created lists
    - Updated region selection to use dropdown picker
    - Fixed bird data fetching to use taxonomy endpoint
    - Improved UI layout for search and filter functionality
  - Enhanced Bird Data Handling
    - Fixed species code mapping issues
    - Implemented proper taxonomy data parsing
    - Added robust error handling for API responses
    - Improved bird family filtering
  - UI/UX Improvements
    - Fixed layout issues in bird list editor
    - Added proper spacing and styling
    - Improved search and filter interface
    - Enhanced error feedback
  - Technical improvements:
    - Proper state management with Riverpod
    - Efficient bird data fetching and caching
    - Robust error handling for API calls
    - Clean separation of concerns between models and UI
- Challenges encountered:
  - eBird API response format inconsistencies
  - Layout issues with family dropdown
  - Species code mapping problems
  - Region-based filtering limitations
- Next steps:
  - Implement proper region-based filtering
  - Add bird data caching
  - Enhance search functionality
  - Improve family filtering performance

### 2025-04-10 (Evening)
- Phase: Phase 2 - Core Functionality
- Work completed:
  - Implemented comprehensive bird list management system
    - Created `BirdList` model with support for predefined and custom lists
    - Implemented `BirdListsNotifier` for state management
    - Built full-screen bird list editor with tabbed interface
    - Added region-based bird filtering
    - Implemented list creation, editing, and deletion
  - Enhanced UI/UX for bird list management
    - Converted edit dialog to full-screen view for better usability
    - Added tabbed interface for managing birds in list
    - Implemented loading states and error handling
    - Added refresh functionality for region changes
  - Technical improvements:
    - Proper state management with Riverpod
    - Efficient bird data fetching and caching
    - Robust error handling for API calls
    - Clean separation of concerns between models and UI
- Challenges encountered:
  - Managing state updates in the list editor
  - Handling API response data conversion
  - Ensuring proper cleanup of resources
  - Maintaining list consistency during edits
- Next steps:
  - Implement audio playback system
  - Add training mode logic
  - Add data persistence for custom lists
  - Implement bird call playback

### 2025-04-10 (Afternoon)
- Phase: Phase 2 - Core Functionality
- Work completed:
  - Implemented eBird API integration with secure key handling
  - Created comprehensive bird data models (Bird, BirdList)
  - Built bird selection screen with region filtering
  - Implemented Riverpod state management
  - Added error handling and logging for API calls
- Challenges encountered:
  - Species code mismatches between our lists and eBird
  - API endpoint structure required adjustments
  - Region code format differences needed resolution
- Next steps:
  - Fix species code mismatches
  - Implement proper error recovery
  - Add data persistence
  - Begin audio playback implementation

### 2025-04-10 (Morning)
- Phase: Phase 1 - Project Initialization
- Work completed:
  - Set up Flutter project structure
  - Implemented basic bird data models
  - Created initial UI wireframes
  - Added core dependencies
- Next steps:
  - Begin eBird API integration
  - Implement state management
  - Create bird selection UI

### 2025-04-10 (Early Morning)
- Phase: Phase 1 - Project Initialization
- Work completed:
  - Defined project scope and features
  - Selected Flutter as development framework
  - Created initial project structure
- Next steps:
  - Set up development environment
  - Create basic app structure
  - Begin implementing core features
</details>

## Development Guide
<details>
<summary>Quick Start Guide</summary>

### Dependencies

#### Core Flutter Packages
```yaml
  just_audio: ^0.9.36
  flutter_riverpod: ^2.4.9
  path_provider: ^2.1.1
  http: ^1.1.0
  flutter_dotenv: ^5.1.0
```

#### Setup
1. Install Flutter SDK and run:
   ```bash
   flutter doctor
   ```

2. Create new Flutter app:
   ```bash
   flutter create birdsong_trainer
   cd birdsong_trainer
   ```

3. Add dependencies to `pubspec.yaml`

4. Set up eBird API key:
   - Create `.env` file in project root
   - Add `EBIRD_API_KEY=your_key_here`

5. Run app on desired platform:
   ```bash
   flutter run -d chrome   # for web
   flutter run -d android  # for Android device
   flutter run -d ios      # for iOS
   ```
</details>

## Project Roadmap
<details>
<summary>View complete project phases</summary>

### Phase 1: Foundation & Planning ✅
- [✅] Project idea and scope definition
- [✅] Tool and framework selection (Flutter)
- [✅] App skeleton creation (routing, state management)
- [✅] Create example dataset of 5 bird calls

### Phase 2: Core Functionality 🔄
- [✅] Audio Player UI
  - Play/pause, skip, replay
  - Show species name
- [✅] Playback Modes
  - Single sound
  - Pairs (A then B)
  - Triplets
- [✅] Snippet Logic
  - Full song or 10s clip
  - Store/preprocess snippets
- [✅] Bird List Management
  - Predefined lists (e.g., Northeast Warblers)
  - Custom list creation and editing
  - Region-based bird filtering
  - Full-screen list editor with tabbed interface
- [🔄] Training Mode Implementation
  - [ ] Bird Selection Fixes
    - Fix persistence of selected birds
    - Add validation for empty selections
    - Implement proper state management
  - [ ] Training Flow Improvements
    - Add next/previous navigation
    - Implement automatic progression
    - Add progress indicators
    - Add pause/resume functionality
  - [ ] Audio Playback
    - Fix current playback issues
    - Add volume control
    - Add replay functionality
    - Add visual indicators
  - [ ] UI/UX Improvements
    - Add bird images
    - Show family information
    - Add difficulty indicators
    - Add progress tracking
  - [ ] Training Modes
    - Random mode
    - Difficulty-based mode
    - Family-based mode
    - Quiz mode
  - [ ] Progress Tracking
    - Session progress
    - Learning status
    - Performance statistics
  - [ ] Settings
    - Progression timing
    - Audio preferences
    - Training mode preferences
    - Difficulty settings

### Phase 3: Bird List & User Controls 🔄
- [✅] Species/group selector UI
- [✅] User playlist creation
- [🔄] Shuffle/repeat logic
- [✅] Region-based filtering
- [✅] Family-based filtering

### Phase 4: Progress and Testing
- [ ] Implement training session types
  - [ ] Quiz Mode with multiple choice and text input
  - [ ] Learning Mode with preview and reinforcement options
  - [ ] Speed ID Mode with timing and scoring
  - [ ] Progressive Mode with adaptive difficulty
- [ ] Feedback system
  - [ ] "Correct/Incorrect" tracking
  - [ ] Time-based scoring
  - [ ] Progress tracking
  - [ ] Performance analytics
- [ ] User progress tracking
  - [ ] Mark birds as "known" or "practice more"
  - [ ] Track response time and accuracy
  - [ ] Generate personalized practice lists
- [ ] Optional scorekeeping mode
  - [ ] Session statistics
  - [ ] Historical performance
  - [ ] Achievement system

### Phase 5: Media & Offline Support
- [🔄] Cloud audio (Xeno-canto or Firebase)
- [ ] Offline caching for audio files
- [ ] Optional spectrogram display

### Phase 6: Advanced Features (Stretch Goals)
- [ ] Mic input for field ID
- [ ] Spectrogram-based guessing
- [ ] Flashcard quiz mode
- [ ] AI-generated hints or descriptions
</details>

## Feature Details
<details>
<summary>Click to expand</summary>

### Training Session Types
- **Quiz Mode**
  - Play bird song
  - User selects from multiple choice options
  - Option for text input identification
  - Timed response tracking
  - Score based on accuracy and speed
  - Difficulty levels (easy, medium, hard)

- **Learning Mode**
  - Two sub-modes:
    1. **Preview Mode**: Show bird name first, then play song
    2. **Reinforcement Mode**: Play song first, then reveal bird name
  - Focus on memorization and recognition
  - No scoring, pure learning experience
  - Option to repeat songs
  - Progress tracking for learned birds
  - Navigation controls:
    - Next/Previous buttons
    - Automatic progression
    - Pause/Resume functionality
  - Visual feedback:
    - Progress indicators
    - Bird images
    - Family information
    - Difficulty indicators

- **Speed ID Mode**
  - Play bird song
  - User can pause/stop playback when they think they know the bird
  - Score based on:
    - Accuracy of identification
    - Time taken to identify
    - Portion of song heard (encourages quick recognition)
  - Leaderboard for fastest correct IDs
  - Difficulty settings (e.g., only show common birds, or include rare ones)

- **Progressive Mode**
  - Start with easy birds
  - Gradually introduce more challenging species
  - Track user's success rate
  - Automatically adjust difficulty based on performance
  - Focus on birds the user struggles with

### Bird List Management
- **Predefined Lists**:
  - Northeast Warblers
  - Spring Migrants
  - Common Thrushes
  - Each list includes species codes, common names, and scientific names
  - Region-specific filtering

- **Custom List Creation**:
  - Create new lists with custom names and descriptions
  - Add/remove birds from available species
  - Region-based bird filtering
  - Full-screen editor with tabbed interface

- **List Editing**:
  - Modify list name and description
  - Add/remove birds from the list
  - Change region to see different available birds
  - Real-time updates and state management

### Modes
- **Single Call Mode**: One song plays, user guesses.
- **Pair Mode**: Two back-to-back songs, user identifies both.
- **Triplet Mode**: Three songs for harder training.

### Clip Control
- User can toggle between full song or 10-second clips
- Randomized clip start (for realism)

### Group & Species Selection
- Filterable by:
  - Region (e.g., Northeast US)
  - Family (e.g., Warblers)
  - Difficulty (custom tag or metadata)

### User Feedback
- Clickable "Correct / Incorrect" tracker
- App adjusts frequency of species based on user accuracy
</details>

## Future Considerations
- Mic recording for live quizzes
- Smart list generation (e.g., "Warblers you're bad at")
- Shareable bird packs or presets
- Embedding training mode in birding apps
- Embedding Xeno-canto license and contributor credits

---

_This README is modeled after the Projectify format. For future projects, replicate this structure to maintain consistent progress tracking, Cursor compatibility, and collaborative potential._

