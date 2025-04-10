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
  - [🔄] Implement audio playback system
  - [ ] Add training mode logic

## Progress Log
<details>
<summary>View complete progress history</summary>

### 2024-03-21
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

### 2024-03-20
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

### 2024-03-19
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

### Phase 3: Bird List & User Controls 🔄
- [✅] Species/group selector UI
- [✅] User playlist creation
- [🔄] Shuffle/repeat logic
- [ ] Region-based filtering
- [ ] Family-based filtering

### Phase 4: Progress and Testing
- [ ] Feedback buttons ("I got it right", "wrong")
- [ ] Mark birds as "known" or "practice more"
- [ ] Log response time and accuracy
- [ ] Optional scorekeeping mode

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

### Custom List Creation
- Add/remove birds to practice playlist
- Save/load training sets

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

