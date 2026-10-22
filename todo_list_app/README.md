# Project 03 — To-Do List App

## Features
- Add tasks using the text field or Enter key
- Mark tasks as completed / active
- Delete tasks, with an Undo option
- Filter All, Active, and Completed tasks
- Live total, active, and completed counters
- Clear completed tasks
- Responsive layout for Chrome

## Run on Windows using Chrome

1. Extract `todo_list_app.zip`.
2. Open the extracted `todo_list_app` folder in VS Code using **File → Open Folder**.
3. Select **Terminal → New Terminal**. Confirm the terminal is inside the folder containing `pubspec.yaml` and `lib`.
4. Generate Flutter platform files:
   ```cmd
   "C:\Users\praga\Downloads\flutter_windows_3.47.7-stable\flutter\bin\flutter.bat" create .
   ```
   If prompted about existing files, preserve `lib/main.dart` and `pubspec.yaml`.
5. Install dependencies:
   ```cmd
   "C:\Users\praga\Downloads\flutter_windows_3.47.7-stable\flutter\bin\flutter.bat" pub get
   ```
6. Run in Chrome:
   ```cmd
   "C:\Users\praga\Downloads\flutter_windows_3.47.7-stable\flutter\bin\flutter.bat" run -d chrome
   ```

If your Flutter SDK is installed elsewhere, replace the path with your actual Flutter `bin\flutter.bat` path.

## Important
- Open `lib/main.dart` to view/edit the app code.
- Run commands in the extracted project folder, not your Project 01 or Project 02 folder.
- Paste only Dart source code into `main.dart`; do not include Markdown code fences.
- Tasks are held in memory and will reset when the app is restarted; persistent storage is not included in this beginner project.
