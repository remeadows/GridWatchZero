# TestFlight Upload - Step-by-Step Guide

**Ready to Upload**: ✅ YES
**Build Status**: ✅ Clean build succeeded (13.7s)
**Current Version**: 1.0 (Build 2)
**Next Build**: 1.0 (Build 3) - for this TestFlight submission

---

## 🚀 Quick Start (5 Steps to TestFlight)

### Step 1: Increment Build Number (2 → 3)
1. Open `GridWatchZero.xcodeproj` in Xcode
2. Select the **GridWatchZero** project in the navigator (blue icon at top)
3. Select the **GridWatchZero** target
4. Click **General** tab
5. Find **Identity** section
6. Change **Build** from `2` to `3`
7. Save (Cmd+S)

### Step 2: Select Device Target
1. In Xcode toolbar (top left), click the device/simulator dropdown
2. Select **"Any iOS Device (arm64)"**
   - Must NOT be a simulator
   - Must NOT be a specific device (unless connected)
   - Must be the generic "Any iOS Device" option

### Step 3: Archive the Build
1. Menu: **Product → Archive** (or Cmd+Shift+B won't work - must use Archive menu)
2. Wait for archive to complete (~2-5 minutes)
3. Xcode Organizer window opens automatically when done

### Step 4: Distribute to App Store Connect
In the Organizer window:

1. **Select your archive** (should be selected already - newest one)
2. Click **"Distribute App"** button (blue, on right side)
3. Choose **"App Store Connect"**
4. Click **"Next"**
5. Choose **"Upload"** (not Export)
6. Click **"Next"**

**Build Options Screen**:
- ✅ Upload your app's symbols... (YES - for crash reports)
- ❌ Include bitcode (NO - deprecated by Apple)
- ✅ Manage Version and Build Number (Automatic)
7. Click **"Next"**

**Signing Screen**:
- Should automatically select your provisioning profile
- If error: Check Developer Team is set correctly
8. Click **"Next"**

**Review Screen**:
- Review all settings
9. Click **"Upload"**

**Upload Progress**:
- Watch progress bar (~5-15 minutes depending on connection)
- ✅ Success message when complete

### Step 5: Wait for Processing
1. **Check email** - Apple sends notification when processing starts
2. **Go to App Store Connect**: https://appstoreconnect.apple.com
3. Navigate to **"My Apps"** → **"Grid Watch Zero"** → **"TestFlight"** tab
4. Build will show "Processing" for 15-90 minutes
5. **Email notification** when processing completes
6. Build becomes available for testing

---

## 📋 After Upload: Configure TestFlight

Once processing completes:

### Add Test Information
1. In App Store Connect → TestFlight tab
2. Select Build 3
3. Click **"Test Details"**
4. Fill out **"What to Test"**:
```
Please test the following in this build:

✅ FIXED: Level 9 balance - now completable!
✅ FIXED: Full-screen brand intro video
✅ FIXED: Smooth audio transitions

Please focus testing on:
- Campaign progression through Levels 9-10
- Save/resume functionality (close app, reopen)
- Audio experience during screen transitions
- Video display on your device model

Known issues being investigated:
- Auto-upgrade button may trigger multiple upgrades
- Checkpoint resume system being refined

Please report any crashes, bugs, or balance issues!
```

5. Click **"Save"**

### Add Internal Testers
1. Click **"Internal Testing"** on left sidebar
2. Click **"+"** to add testers
3. Enter email addresses
4. Click **"Add"**
5. Testers receive email with TestFlight invitation

### Submit for Beta App Review (Optional - For External Testers)
If you want external testers (not just your team):
1. Click **"Submit for Review"** button
2. Fill out beta review information
3. Wait 24-48 hours for Apple approval
4. Then add external testers

---

## ✅ Success Checklist

After upload, verify:

- [ ] Build appears in App Store Connect → TestFlight tab
- [ ] Build status shows "Ready to Submit" or "Ready to Test"
- [ ] Version shows: **1.0**
- [ ] Build number shows: **3**
- [ ] "What to Test" notes added
- [ ] Internal testers invited (if ready)
- [ ] Email notifications received from Apple

---

## 🔧 Troubleshooting

### "No Accounts with App Store Connect Access"
**Solution**:
1. Xcode → Settings → Accounts
2. Add Apple ID if not present
3. Select your Apple ID → View Details
4. Click "Download Manual Profiles"

### "Failed to Archive"
**Solution**:
1. Product → Clean Build Folder (Cmd+Shift+K)
2. Close Xcode
3. Delete `~/Library/Developer/Xcode/DerivedData/*`
4. Reopen Xcode
5. Try again

### "No Matching Provisioning Profile"
**Solution**:
1. Select GridWatchZero target → Signing & Capabilities
2. Verify Team is selected
3. Check "Automatically manage signing" is enabled
4. Xcode will create/download profile automatically

### "Archive Succeeds but Upload Fails"
**Solution**:
- Check internet connection
- Try uploading from Organizer again (Window → Organizer)
- Or use Application Loader (if you have archive exported)
- Check App Store Connect status: https://developer.apple.com/system-status/

### "Upload Takes Too Long"
**Solution**:
- App size: ~20-30MB with videos
- Upload time: 5-15 minutes typical
- If >30 minutes: Cancel and retry
- Check WiFi connection speed

---

## 📱 Testing on Physical Device (Before Upload)

Recommended: Test on real iPhone before uploading:

1. **Connect iPhone** via USB
2. **Select your iPhone** as deployment target in Xcode
3. **Run** (Cmd+R)
4. **Test critical path**:
   - Launch app
   - Watch intro video
   - Navigate to Level 1
   - Play for 2-3 minutes
   - Background app (home button)
   - Return to app
   - Close app completely
   - Reopen (test checkpoint resume)

If all works well → proceed with upload!

---

## 🎯 After TestFlight Testing

### Collect Feedback (1-2 weeks)
- Invite 5-10 testers minimum
- Ask for specific feedback on known issues
- Monitor crash reports in Xcode Organizer

### Iterate Based on Feedback
- Fix critical bugs
- Adjust balance if needed
- Polish UI/UX

### Prepare for App Store Release
- Create marketing screenshots
- Write App Store description
- Set pricing (Free with IAP potential later)
- Choose categories
- Set age rating
- Submit for App Store Review

---

## 📞 Need Help?

**Apple Developer Support**: 1-800-633-2152
**Developer Forums**: https://developer.apple.com/forums/
**App Store Connect**: https://appstoreconnect.apple.com

---

**Current Status**: ✅ Ready to Archive and Upload
**Next Action**: Open Xcode and follow Step 1 above

Good luck! 🚀
