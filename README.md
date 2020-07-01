# ios-dev
This is the iOS Development repository for Project Lego.

## Project Setup

#### 1. Clone the git repository onto your local machine. 
```
git clone https://github.com/Proj-Lego/ios-dev.git
```

#### 2. Navigate into the directory and install all dependencies.
```
cd ios-dev
pod install
```

#### 3. Download `GoogleService-Info.plist`.

It can be obtained from Firebase by navigating to:

Project Overview > iOS Lego Button > Settings (gear button) > General

Under "Your Apps", download `GoogleService-Info.plist` and drag it directly into `ios-dev/Lego`.

#### 4. Create a file called `Keys.plist` and add all API keys.

API keys can be obtained by contacting an administrator.

#### 5. Open the file named ```Lego.xcworkspace``` and verify successful setup by running the project.

Note: You should ALWAYS use the ```Lego.xcworkspace``` file for future development.
