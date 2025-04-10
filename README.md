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
  - [ ] Begin Flutter project setup
  - [ ] Design UI wireframes and audio flow logic

## Progress Log
<details>
<summary>View complete progress history</summary>

### 2025-04-10
- Phase: Phase 1 - Project Initialization and App Planning
- Work completed:
  - Defined primary goals of the birdsong training app
  - Decided to use Flutter for web and mobile support
  - Established key features including playback modes, species/group filtering, and audio randomization
- Next steps:
  - Set up initial Flutter app structure
  - Create placeholder UI for species selection and audio control
  - Import and test audio playback with just_audio
- Notes/Challenges:
  - Considering backend storage for sounds and playlists
  - Will explore Xeno-canto API and local file caching
</details>

## Development Guide
<details>
<summary>Quick Start Guide</summary>

### Dependencies

#### Core Flutter Packages (planned)
```yaml
  just_audio: ^0.9.33
  provider: ^6.1.0
  flutter_riverpod: ^2.3.6
  flutter_sound: ^9.2.13
  path_provider: ^2.1.1
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

4. Run app on desired platform:
   ```bash
   flutter run -d chrome   # for web
   flutter run -d android  # for Android device
   flutter run -d ios      # for iOS
   ```
</details>

## Project Roadmap
<details>
<summary>View complete project phases</summary>

### Phase 1: Foundation & Planning
- [✅] Project idea and scope definition
- [✅] Tool and framework selection (Flutter)
- [ ] App skeleton creation (routing, state management)
- [ ] Audio playback proof-of-concept
- [ ] Create example dataset of 5 bird calls

### Phase 2: Core Functionality
- [ ] Audio Player UI
  - Play/pause, skip, replay
  - Show species name
- [ ] Playback Modes
  - Single sound
  - Pairs (A then B)
  - Triplets
- [ ] Snippet Logic
  - Full song or 10s clip
  - Store/preprocess snippets

### Phase 3: Bird List & User Controls
- [ ] Species/group selector UI
- [ ] User playlist creation
- [ ] Shuffle/repeat logic

### Phase 4: Progress and Testing
- [ ] Feedback buttons ("I got it right", "wrong")
- [ ] Mark birds as "known" or "practice more"
- [ ] Log response time and accuracy
- [ ] Optional scorekeeping mode

### Phase 5: Media & Offline Support
- [ ] Cloud audio (Xeno-canto or Firebase)
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
- Clickable “Correct / Incorrect” tracker
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

