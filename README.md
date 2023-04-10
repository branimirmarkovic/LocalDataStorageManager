# LocalDataStorageManager

A Swift package that simplifies the process of managing local file storage on iOS devices with additional data validation policy support. The package provides an easy-to-use API for reading, writing, and deleting files in a specified directory within the app's document directory. The package also includes comprehensive unit tests to ensure its reliability and stability.

## Features

- Automatically creates and manages a main directory for local file storage.
- Provides asynchronous read, write, and delete operations for better performance and user experience.
- Uses Swift's Result type for clean and safe error handling.
- Adds a data validation policy to ensure data freshness and avoid using stale data.
- Covered by comprehensive unit tests to ensure reliability and stability.

## Usage

1. Initialize a `LocalDataStorageManager` instance:

   ```swift
   let storageManager: LocalDataStorageManager
   do {
       storageManager = try LocalDataStorageManager(rootDirectoryName: "YourRootDirectory")
   } catch {
       // Handle initialization error
   }
2. Read data from a file:
   ```swift
   storageManager.read(from: "path/to/your/file.ext") { result in
       switch result {
       case .success(let data):
           // Handle the data
       case .failure(let error):
           // Handle the error
       }
   }
   ```
3. Write data to a file:
   ```swift
   let data = Data("Your data".utf8)
   storageManager.write(data: data, to: "path/to/your/file.ext") { result in
       switch result {
       case .success:
           // Handle successful write
       case .failure(let error):
           // Handle the error
       }
   }
   ```
4. Delete a file:
   ```swift
   storageManager.delete(at: "path/to/your/file.ext") { result in
       switch result {
       case .success:
           // Handle successful deletion
       case .failure(let error):
           // Handle the error
       }
   }
   ```
   
## Usage with data validation policy

1. Initialize a LocalDataStorageManagerWithDataValidationPolicyDecorator instance:
   ```swift
   let dataCachePolicy = DefaultCachePolicy(.tenMinutes)
   let dataStorageManagerWithDataValidationPolicy = LocalDataStorageManagerWithDataValidationPolicyDecorator(dataCachePolicy: dataCachePolicy, dataStorageManager: storageManager)
   ```
2. Follow the same usage instructions for the LocalDataStorageManager for read, write, and delete operations using the **dataStorageManagerWithDataValidationPolicy** instance.


## Requirements

- Swift 5.0 or later
- iOS 10.0 or later

## Installation

To add LocalDataStorageManager to your project, follow these steps:

1. Open your project in Xcode.
2. Go to `File` > `Swift Packages` > `Add Package Dependency`.
3. Enter the URL of this repository (https://github.com/branimirmarkovic/LocalDataStorageManager.git) and click `Next`.
4. Choose the latest version or a specific version, then click `Next`.
5. Select the target you want to add the package to, then click `Finish`.
