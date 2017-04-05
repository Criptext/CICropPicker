# Installation

## Cocoapods
```
pod 'CICropPicker'
```

# Usage

First import the Pod
```swift
import CICropPicker
```

Then import the module Photos to ask for permissions
```swift
import Photos
```

Then in your `info.plist` you need to specify these properties which will be shown alongside the alert requesting access

- NSPhotoLibraryUsageDescription - for the camera roll
- NSCameraUsageDescription - for the camera

If you don't specify these properties, your app will crash upon requesting access.

## Showing the camera roll
You need to ask permission to access the Camera Roll
```swift

PHPhotoLibrary.requestAuthorization({ (status) in
                //Response comes in a background thread, we need to go to the main thread
                DispatchQueue.main.async {
                    sheet.dismiss(animated: true, completion: nil)
                    switch status {
                    case .authorized:
                        let imagePicker = CICropPicker()
                        imagePicker.presentGalleryPicker(from: self)
                        break
                    default:
                        //handle access denied to camera roll
                        break
                    }
                    
                    
                }
})
```

## Showing the camera
You need to ask permission to access the Camera
```swift
AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                //Response comes in a background thread, we need to go to the main thread
                DispatchQueue.main.async {
                    sheet.dismiss(animated: true, completion: nil)
                    
                    if !granted {
                        //handle access denied to camera roll
                        return
                    }
                    let imagePicker = CICropPicker()
                    imagePicker.presentCameraPicker(from: self)
                }
})
```

## Implement the delegate `CICropPickerDelegate`
- `imagePicker(_ imagePicker: UIImagePickerController!, pickedImage image: UIImage!)` to handle image picked
- `imagePickerDidCancel(_ imagePicker: UIImagePickerController!)` to handle picker cancellation
