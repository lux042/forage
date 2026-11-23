# Forage screenshots

This folder will hold **actual captures of the running app**. Do not replace these with mockups that imply unimplemented features.

## Suggested gallery

1. **Explore** — map with restaurant markers and the redesigned result cards.
2. **Saved spots** — bookmarked restaurants.
3. **Restaurant details** — information and visit history.
4. **Log a visit** — rating, notes, and selected photo previews.

## How to capture

1. Run Forage in Xcode's iPhone Simulator.
2. Navigate to the screen and use **File → Save Screen Shot** in Simulator (or press **Cmd + S**).
3. Rename captures to `explore.png`, `saved.png`, `details.png`, and `journal.png`.
4. Put them in `docs/screenshots/` and commit the image files.
5. Replace the placeholder table in the root README with:
   ```markdown
   | Explore | Saved | Details | Journal |
   | --- | --- | --- | --- |
   | ![Explore](docs/screenshots/explore.png) | ![Saved](docs/screenshots/saved.png) | ![Details](docs/screenshots/details.png) | ![Journal](docs/screenshots/journal.png) |
   ```

Before capturing, use demo data rather than personal locations, notifications, or photos you don't want to publish.
