//
//  WCLDirectoryWatcherTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/20/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

@testable import Web_Console

class WCLDirectoryWatcherEventManager: NSObject, WCLDirectoryWatcherDelegate {
    var fileWasCreatedOrModifiedAtPathHandlers: Array<((_ path: String) -> Void)>
    var directoryWasCreatedOrModifiedAtPathHandlers: Array<((_ path: String) -> Void)>
    var itemWasRemovedAtPathHandlers: Array<((_ path: String) -> Void)>

    override init() {
        self.fileWasCreatedOrModifiedAtPathHandlers = Array<((_ path: String) -> Void)>()
        self.directoryWasCreatedOrModifiedAtPathHandlers = Array<((_ path: String) -> Void)>()
        self.itemWasRemovedAtPathHandlers = Array<((_ path: String) -> Void)>()
    }

    func directoryWatcher(_ directoryWatcher: WCLDirectoryWatcher, fileWasCreatedOrModifiedAtPath path: String) {
        assert(fileWasCreatedOrModifiedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (fileWasCreatedOrModifiedAtPathHandlers.count > 0) {
            let handler = fileWasCreatedOrModifiedAtPathHandlers.remove(at: 0)
            handler(path)
        }
    }
    
    func directoryWatcher(_ directoryWatcher: WCLDirectoryWatcher, directoryWasCreatedOrModifiedAtPath path: String) {
        assert(directoryWasCreatedOrModifiedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (directoryWasCreatedOrModifiedAtPathHandlers.count > 0) {
            let handler = directoryWasCreatedOrModifiedAtPathHandlers.remove(at: 0)
            handler(path)
        }
    }
    
    func directoryWatcher(_ directoryWatcher: WCLDirectoryWatcher, itemWasRemovedAtPath path: String) {
        assert(itemWasRemovedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (itemWasRemovedAtPathHandlers.count > 0) {
            let handler = itemWasRemovedAtPathHandlers.remove(at: 0)
            handler(path)
        }
    }

    func add(fileWasCreatedOrModifiedAtPathHandler handler: @escaping (_ path: String) -> Void) {
        fileWasCreatedOrModifiedAtPathHandlers.append(handler)
    }

    func add(directoryWasCreatedOrModifiedAtPathHandler handler: @escaping (_ path: String) -> Void) {
        directoryWasCreatedOrModifiedAtPathHandlers.append(handler)
    }

    func add(itemWasRemovedAtPathHandler handler: @escaping (_ path: String) -> Void) {
        itemWasRemovedAtPathHandlers.append(handler)
    }
}

class WCLDirectoryWatcherTestCase: TemporaryDirectoryTestCase {
    var directoryWatcher: WCLDirectoryWatcher!
    var directoryWatcherEventManager: WCLDirectoryWatcherEventManager!
    
    override func setUp() {
        super.setUp()
        directoryWatcher = WCLDirectoryWatcher(url: temporaryDirectoryURL as URL!)
        directoryWatcherEventManager = WCLDirectoryWatcherEventManager()
        directoryWatcher.delegate = directoryWatcherEventManager
    }
    
    override func tearDown() {
        directoryWatcherEventManager = nil
        directoryWatcher.delegate = nil
        directoryWatcher = nil
        super.tearDown()
    }

    // MARK: Create
    func createFileWithConfirmation(atPath path: String) {
        let fileWasCreatedOrModifiedExpectation = expectation(description: "File was created")
        directoryWatcherEventManager?.add(fileWasCreatedOrModifiedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == path) {
                fileWasCreatedOrModifiedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.createFile(atPath: path)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    func createDirectoryWithConfirmation(atPath path: String) {
        let directoryWasCreatedOrModifiedExpectation = expectation(description: "Directory was created")
        directoryWatcherEventManager?.add(directoryWasCreatedOrModifiedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == path) {
                directoryWasCreatedOrModifiedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.createDirectory(atPath: path)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    
    // MARK: Modify
    func modifyFileWithConfirmation(atPath path: String) {
        let fileWasModifiedExpectation = expectation(description: "File was modified")
        directoryWatcherEventManager?.add(fileWasCreatedOrModifiedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == path) {
                fileWasModifiedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.writeToFile(atPath: path, contents: testFileContents)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    
    // MARK: Remove
    func removeFileWithConfirmation(atPath path: String) {
        let fileWasRemovedExpectation = expectation(description: "File was removed")
        directoryWatcherEventManager?.add(itemWasRemovedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == path) {
                fileWasRemovedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.removeFile(atPath: path)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    func removeDirectoryWithConfirmation(atPath path: String) {
        let directoryWasRemovedExpectation = expectation(description: "Directory was removed")
        directoryWatcherEventManager?.add(itemWasRemovedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == path) {
                directoryWasRemovedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.removeDirectory(atPath: path)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    
    // MARK: Move
    func moveFileWithConfirmation(atPath path: String, destinationPath: String) {
        // Remove original
        let fileWasRemovedExpectation = expectation(description: "File was removed with move")
        directoryWatcherEventManager?.add(itemWasRemovedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == path) {
                fileWasRemovedExpectation.fulfill()
            }
        })
        // Create new
        let fileWasCreatedExpectation = expectation(description: "File was created with move")
        directoryWatcherEventManager?.add(fileWasCreatedOrModifiedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == destinationPath) {
                fileWasCreatedExpectation.fulfill()
            }
        })
        // Move
        SubprocessFileSystemModifier.moveItem(atPath: path, toPath: destinationPath)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    func moveDirectoryWithConfirmation(atPath path: String, destinationPath: String) {
        // Remove original
        let directoryWasRemovedExpectation = expectation(description: "Directory was removed with move")
        directoryWatcherEventManager?.add(itemWasRemovedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == path) {
                directoryWasRemovedExpectation.fulfill()
            }
        })
        // Create new
        let directoryWasCreatedExpectation = expectation(description: "Directory was created with move")
        directoryWatcherEventManager?.add(directoryWasCreatedOrModifiedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == destinationPath) {
                directoryWasCreatedExpectation.fulfill()
            }
        })
        // Move
        SubprocessFileSystemModifier.moveItem(atPath: path, toPath: destinationPath)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
}

class WCLDirectoryWatcherDirectoryTests: WCLDirectoryWatcherTestCase {

    func testCreateWriteAndRemoveDirectory() {
        let testDirectoryPath = temporaryDirectoryURL.path.appendingPathComponent(testDirectoryName)
        let testFilePath = testDirectoryPath.appendingPathComponent(testFilename)

        // Test Create Directory
        createDirectoryWithConfirmation(atPath: testDirectoryPath)
        
        // Test Create File
        createFileWithConfirmation(atPath: testFilePath)

        // Test Modify File
        modifyFileWithConfirmation(atPath: testFilePath)

        // Test Remove File
        removeFileWithConfirmation(atPath: testFilePath)
        
        // Test Remove Directory
        removeDirectoryWithConfirmation(atPath: testDirectoryPath)

        // Test Create Directory Again
        createDirectoryWithConfirmation(atPath: testDirectoryPath)
        
        // Clean up

        // Test Remove Directory Again
        removeDirectoryWithConfirmation(atPath: testDirectoryPath)
    }

    func testMoveDirectory() {
        let testDirectoryPath = temporaryDirectoryURL.path.appendingPathComponent(testDirectoryName)
            
        // Test Create
        createDirectoryWithConfirmation(atPath: testDirectoryPath)

        // Test Move
        let testDirectoryPathTwo = testDirectoryPath.deletingLastPathComponent.appendingPathComponent(testDirectoryNameTwo)
        moveDirectoryWithConfirmation(atPath: testDirectoryPath, destinationPath: testDirectoryPathTwo)
        
        // Test Move Again
        moveDirectoryWithConfirmation(atPath: testDirectoryPathTwo, destinationPath: testDirectoryPath)

        // Clean up
            
        // Test Remove
        removeDirectoryWithConfirmation(atPath: testDirectoryPath)
    }

    func testMoveDirectoryContainingFile() {
        let testDirectoryPath = temporaryDirectoryURL.path.appendingPathComponent(testDirectoryName)
        let testFilePath = testDirectoryPath.appendingPathComponent(testFilename)

        // Test Create Directory
        createDirectoryWithConfirmation(atPath: testDirectoryPath)
        
        // Test Create File
        createFileWithConfirmation(atPath: testFilePath)
        
        // Test Move
        let testDirectoryPathTwo = testDirectoryPath.deletingLastPathComponent.appendingPathComponent(testDirectoryNameTwo)
        moveDirectoryWithConfirmation(atPath: testDirectoryPath, destinationPath: testDirectoryPathTwo)
        
        // Test Modify File
        let testFilePathTwo = testDirectoryPathTwo.appendingPathComponent(testFilename)
        modifyFileWithConfirmation(atPath: testFilePathTwo)
        
        // Test Move Again
        moveDirectoryWithConfirmation(atPath: testDirectoryPathTwo, destinationPath: testDirectoryPath)
        
        // Clean up

        // Test Remove File
        removeFileWithConfirmation(atPath: testFilePath)

        // Test Remove
        removeDirectoryWithConfirmation(atPath: testDirectoryPath)
    }

    func testReplaceDirectoryWithFile() {
        let testDirectoryPath = temporaryDirectoryURL.path.appendingPathComponent(testDirectoryName)
            
        // Test Create Directory
        createDirectoryWithConfirmation(atPath: testDirectoryPath)

        // Remove Directory
        removeDirectoryWithConfirmation(atPath: testDirectoryPath)
        
        // Test Create File
        createFileWithConfirmation(atPath: testDirectoryPath)

        // Remove File
        removeFileWithConfirmation(atPath: testDirectoryPath)
    }

    func testReplaceFileWithDirectory() {
        let testDirectoryPath = temporaryDirectoryURL.path.appendingPathComponent(testDirectoryName)
        
        // Test Create File
        createFileWithConfirmation(atPath: testDirectoryPath)
        
        // Remove File
        removeFileWithConfirmation(atPath: testDirectoryPath)
        
        // Test Create Directory
        createDirectoryWithConfirmation(atPath: testDirectoryPath)
        
        // Remove Directory
        removeDirectoryWithConfirmation(atPath: testDirectoryPath)
    }

}


class WCLDirectoryWatcherFileTests: WCLDirectoryWatcherTestCase {
    var testFilePath: String!
    
    override func setUp() {
        super.setUp()
        testFilePath = temporaryDirectoryURL.path.appendingPathComponent(testFilename)
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testCreateWriteAndRemoveFile() {
        // Test Create
        createFileWithConfirmation(atPath: testFilePath)
        
        // Test Modify
        modifyFileWithConfirmation(atPath: testFilePath)
        
        // Test Remove
        removeFileWithConfirmation(atPath: testFilePath)

        // Test Create again
        createFileWithConfirmation(atPath: testFilePath)
        
        // Clean up

        // Test Remove again
        removeFileWithConfirmation(atPath: testFilePath)
    }

    func testMoveFile() {
        // Test Create With Write
        modifyFileWithConfirmation(atPath: testFilePath)

        // Test Move
        let testFilePathTwo = testFilePath.deletingLastPathComponent.appendingPathComponent(testFilenameTwo)
        moveFileWithConfirmation(atPath: testFilePath, destinationPath: testFilePathTwo)
        
        // Test Modify
        modifyFileWithConfirmation(atPath: testFilePathTwo)
        
        // Test Move Again
        moveFileWithConfirmation(atPath: testFilePathTwo, destinationPath: testFilePath)

        // Modify Again
        modifyFileWithConfirmation(atPath: testFilePath)
        
        // Clean up
            
        // Test Remove
        removeFileWithConfirmation(atPath: testFilePath)
    }
    
    func testFileManager() {
        // Test Create
        
        // Create expectation
        let fileWasCreatedOrModifiedExpectation = expectation(description: "File was created at \(testFilePath)")
        directoryWatcherEventManager?.add(fileWasCreatedOrModifiedAtPathHandler: { path -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path as NSString) ==  self.testFilePath) {
                fileWasCreatedOrModifiedExpectation.fulfill()
            }
        })
        
        // Test create a second file with NSFileManager
        let testFilePathTwo = testFilePath.deletingLastPathComponent.appendingPathComponent(testFilenameTwo)
        let contentsData = testFileContents.data(using: String.Encoding.utf8)
        FileManager.default.createFile(atPath: testFilePathTwo, contents: contentsData, attributes: nil)
        
        // Create file
        SubprocessFileSystemModifier.createFile(atPath: testFilePath)
        
        // Wait for expectation
        waitForExpectations(timeout: defaultTimeout, handler: nil)


        // Test Remove
        
        // Remove Expectation
        let fileWasRemovedExpectation = expectation(description: "File was removed")
        directoryWatcherEventManager?.add(itemWasRemovedAtPathHandler: { path -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path as NSString) ==  self.testFilePath) {
                fileWasRemovedExpectation.fulfill()
            }
        })
            
        // Test remove the second file with NSFileManager
        do {
            try FileManager.default.removeItem(atPath: testFilePathTwo)
        } catch {
            XCTAssertTrue(false, "The remove should succeed")
        }
        
        // Remove file
        SubprocessFileSystemModifier.removeFile(atPath: testFilePath)
        
        // Wait for expectation
        waitForExpectations(timeout: defaultTimeout, handler: nil)

    }
    
    func testFileManagerAsync() {

        
        // Test Create

        // Create expectation
        let fileWasCreatedOrModifiedExpectation = expectation(description: "File was created")
        directoryWatcherEventManager?.add(fileWasCreatedOrModifiedAtPathHandler: { path -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path as NSString) == self.testFilePath) {
                fileWasCreatedOrModifiedExpectation.fulfill()
            }
        })
            
        // Test create a second file with NSFileManager
        let testFilePathTwo = testFilePath.deletingLastPathComponent.appendingPathComponent(testFilenameTwo)
        let fileManagerCreateExpectation = expectation(description: "File manager created file")
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            let contentsData = testFileContents.data(using: String.Encoding.utf8)
            FileManager.default.createFile(atPath: testFilePathTwo, contents: contentsData, attributes: nil)
            fileManagerCreateExpectation.fulfill()
        }
            
        // Create file
        SubprocessFileSystemModifier.createFile(atPath: testFilePath)
            
        // Wait for expectation
        waitForExpectations(timeout: defaultTimeout, handler: nil)
            
            
        // Test Remove
        
        // Remove Expectation
        let fileWasRemovedExpectation = expectation(description: "File was removed")
        directoryWatcherEventManager?.add(itemWasRemovedAtPathHandler: { path -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path as NSString) ==  self.testFilePath) {
                fileWasRemovedExpectation.fulfill()
            }
        })
        
        // Test remove the second file with NSFileManager
        let fileManagerRemoveExpectation = expectation(description: "File manager created file")
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            do {
                try FileManager.default.removeItem(atPath: testFilePathTwo)
            } catch {
                XCTAssertTrue(false, "The remove should succeed")
            }

            fileManagerRemoveExpectation.fulfill()
        }
        
        // Remove file
        SubprocessFileSystemModifier.removeFile(atPath: testFilePath)
        
        // Wait for expectation
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
}
