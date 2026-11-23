# Forage 

**Discover restaurants worth remembering.**

Forage is a native iOS app for finding restaurants, keeping a personal list of places to try, receiving location-aware reminders when you're nearby, and recording the meals and memories that follow.

Built with **SwiftUI**, Forage brings restaurant discovery, saved spots, and a dining journal into one place.

> **Project status:** Active development. Core features are implemented; photo handling, UI polish, and device testing are ongoing.

## Features

- **Explore nearby restaurants:** Search by restaurant name, cuisine, or neighborhood, with results on an interactive map.
- **Save places for later:** Bookmark restaurants and revisit your personal list.
- **Location-aware reminders:** Use geofencing to be reminded about saved restaurants when you are nearby, subject to iOS location and notification permissions.
- **Log your visits:** Record visit dates, ratings, what you ordered, notes, and whether you'd return.
- **Add photos to your journal:** Choose images from your photo library and attach them to a visit.
- **Personal restaurant history:** View past visits alongside restaurant details.

## Screenshots

Screenshots are being prepared. The most useful views to showcase will be:

| Explore | Saved spots | Restaurant details | Visit journal |
| --- | --- | --- | --- |
| Map and discovery cards | Places to try | Restaurant information and visit history | Ratings, notes, and photos |

See [the screenshot guide](docs/SCREENSHOTS.md) for the planned gallery and capture instructions. Screenshots will be embedded here once exported from the simulator.

## Built with

| Technology | Role |
| --- | --- |
| **Swift / SwiftUI** | Native iOS interface |
| **SwiftData** | Local persistence for restaurants and visits |
| **MapKit** | Restaurant search and map display |
| **Core Location** | Location access and geofence monitoring |
| **UserNotifications** | Nearby-restaurant reminders |
| **PhotosUI** | Selecting photos for visit entries |

Restaurant search uses **Apple MapKit**, not a separate Google Places integration.

## Getting started

**Requirements:** A Mac with a compatible version of Xcode and an iOS simulator or device. The exact Xcode and iOS deployment versions should be confirmed against the Xcode project configuration.

1. Clone the repository:
   ```bash
   git clone https://github.com/lux042/forage.git
   cd forage
   ```
2. Open the project's `.xcodeproj` file in Xcode **once it has been added to the repository**.
3. Select an iOS simulator or connected iPhone and run the app.
4. Allow location and notification permissions when prompted if you want to test nearby reminders.

**Current setup limitation:** The Xcode project bundle (`forage1.xcodeproj`) has not yet been verified as committed to this repository. A fresh clone may therefore **not be directly buildable** until the project configuration is added. The Swift source is available for review in the meantime.

### Testing location reminders

In the iOS Simulator, use **Features → Location** to simulate a location near a saved restaurant. Actual geofence delivery is controlled by iOS and can differ between the simulator and a physical device. Background location behavior should be tested on-device before release.

## Roadmap

- [x] Search restaurants and show results on a map
- [x] Save and remove restaurants
- [x] Add location-based reminders
- [x] Create visit entries with ratings and notes
- [x] Add photo selection to visit entries
- [x] Establish a consistent, nature-inspired design system
- [ ] Verify photo import and persistence on device
- [ ] Commit and verify a clean-clone Xcode build
- [ ] Add real screenshots and a short demo
- [ ] Improve accessibility and empty/error states
- [ ] Test notification and geofencing behavior across devices
- [ ] Prepare for a broader release

## Design

Forage uses a warm visual language inspired by forests and natural textures: deep green, sage, cream, clay, and gold. The goal is to make saving a restaurant feel like keeping a small collection of places and experiences, rather than managing another checklist.

## About

An independent iOS development project by [lux042](https://github.com/lux042).

**Source code:** [github.com/lux042/forage](https://github.com/lux042/forage)
