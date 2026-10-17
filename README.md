# Veya

**AI-powered dance coaching: get accuracy scores and timestamped feedback on your choreography, plus built-in stretching to prevent injuries.**

**Best Design** · **MLH Best Use of Gemini API** at SproutGT (Apr 2026)

[![Veya demo video](https://github.com/user-attachments/assets/63eb4275-aeaa-4358-acf3-e0f1fab6b878)](https://www.youtube.com/watch?v=ttDCLCY4abA)

▶️ [Watch the demo](https://www.youtube.com/watch?v=ttDCLCY4abA) · 📄 [Devpost](https://devpost.com/software/veya)

## The problem
In dance classes, especially big groups, feedback is often limited or delayed, so dancers don't know exactly what to fix. Stretching and recovery also get skipped, which leads to soreness and preventable injuries.

## What it does
Veya gives dancers objective, immediate feedback on their practice. It analyzes both **motion and expression** in an uploaded video, scores accuracy against the choreography, and points to the exact moments where the dancer differs from it. Choreographers stay in charge of the artistic direction, and Veya helps dancers close the gap faster.

## How it works
1. **Upload:** the dancer records or selects a practice video in the app
2. **Keyframe extraction:** Gemini identifies the key poses and moments in the routine
3. **Motion + expression analysis:** Gemini 2.5 Flash compares the dancer's movement and expression to the choreography
4. **Scoring + timestamped feedback:** returns an accuracy score and notes tied to specific moments
5. **Review:** the SwiftUI feedback screen maps notes onto a video timeline with markers and an accuracy indicator

## Features
- **AI feedback + accuracy scoring:** video playback synced with timeline markers, an accuracy indicator, and written coaching notes
- **Stretching + injury prevention:** genre-specific routines (hip hop, ballet, and more) for general flexibility and targeted muscle work
- **Coaching chatbot:** Gemini-powered assistant for personalized practice questions
- **Home dashboard:** card-based layout inspired by Apple Health for quick access to every feature

## Tech stack
| Layer | Tools |
|---|---|
| App / UI | Swift, SwiftUI, Xcode |
| AI | Gemini API (Gemini 2.5 Flash): keyframe extraction, motion and expression analysis, chatbot |
| Design | Canva (wireframes, personas, final designs) |

## Technical challenges
- **API access:** the free tier returned `429 RESOURCE_EXHAUSTED` errors, so we moved to the paid tier to use Gemini 2.5 Flash
- **Model compatibility:** worked through several model version issues before finding one that fit our use case
- **Response handling:** fixed truncated and badly formatted API responses so feedback displayed correctly in the app
- **Rate limits:** repeated testing hit our own rate limits, so we spaced out test runs and rotated to a secondary API key

## What's next
- Login system with role-based access (dancers vs. choreographers)
- Choreographer tools: gallery uploads and task assignment through notifications
- Training our own accuracy model instead of relying on the Gemini API
- Testing with our dance team and local studios

## Team
- **Prathithi Nellaiappan:** built the SwiftUI interface and Gemini integration for keyframe extraction, motion analysis, and timestamped feedback; UI/UX design and user personas
- **Sunidhi:** UI/UX design and user personas; created low-fi and high-fi prototypes
- **Sheona:** UI/UX design and user personas; crafted a pitch video and business model
