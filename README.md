# Veya

**AI-powered dance coaching: upload your practice video and get timestamped, choreography-specific feedback.**
**Best Use of Gemini API** · **Best Design** at Sprout GT Hackathon (Apr 2026)

<img width="556" height="305" alt="Screenshot 2026-10-17 at 2 51 25 PM" src="https://github.com/user-attachments/assets/d6610e92-d35b-416f-b5ee-2a2bfd410944" />

## Overview
Veya streamlines choreography practice by turning a dancer's uploaded video into actionable feedback. It uses the Gemini API to extract keyframes, analyze motion, and return feedback tied to specific timestamps, so dancers know exactly *where* in the routine to improve.

## How it works
1. **Upload:** the dancer records or selects a practice video in the app
2. **Keyframe extraction:** Gemini identifies the key poses and moments in the routine
3. **Motion analysis:** Gemini evaluates the dancer's movement across those keyframes
4. **Timestamped feedback:** results come back as structured, time-linked notes
5. **Review:** the SwiftUI feedback screen maps notes onto a video timeline with markers and an accuracy indicator

## Features
- **AI feedback screen:** video playback synced with timeline markers, an accuracy indicator, and written coaching notes
- **Home dashboard:** card-based layout (inspired by Apple Health) for stretches, uploads, gallery, and chat
- **Stretch library:** exercises organized by dance style (hip hop, ballet, and more)
- **Coaching chat:** ask the AI coaching assistant questions about your practice

## Tech stack
| Layer | Tools |
|---|---|
| App / UI | Swift, SwiftUI |
| AI analysis | Gemini API (keyframe extraction, motion analysis, feedback generation) |
| Design | Canva (wireframes, personas) |

## Screenshots
<img width="558" height="284" alt="Screenshot 2026-10-17 at 2 51 50 PM" src="https://github.com/user-attachments/assets/9e0d70a7-1a3d-4fdd-90a7-94c993597ec3" />

## Getting started
1. Clone the repo and open the `.xcodeproj` in Xcode
2. Add your Gemini API key: [describe where, e.g. a `Secrets.plist` that's in .gitignore]
3. Build and run on an iPhone simulator or device

## Team
- **Prathithi:** built the SwiftUI interface and Gemini integration for keyframe extraction, motion analysis, and timestamped feedback; UI/UX design and user personas
- **Sunidhi:** UI/UX design and user personas
- **Sheona:** UI/UX design and user personas; crafted a pitch video and business model
