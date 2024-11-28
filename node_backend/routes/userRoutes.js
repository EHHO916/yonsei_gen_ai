const express = require('express');
const router = express.Router();
const UserProfile = require('../models/UserProfile');

// Create or update user profile
router.post('/profile', async (req, res) => {
  try {
    const updateData = {
      user_id: req.body.googleId,
      googleId: req.body.googleId,
    };

    // Only include MBTI result if it exists in the request
    if (req.body.mbti_result) {
      updateData.mbti_result = req.body.mbti_result;
    }

    // Include other fields if they exist
    if (req.body.email) updateData.email = req.body.email;
    if (req.body.displayName) updateData.displayName = req.body.displayName;
    if (req.body.photoUrl) updateData.photoUrl = req.body.photoUrl;

    const userProfile = await UserProfile.findOneAndUpdate(
      { googleId: req.body.googleId },
      updateData,
      { upsert: true, new: true }
    );
    
    console.log('User profile updated:', userProfile);
    res.json(userProfile);
  } catch (error) {
    console.error('Error updating user profile:', error);
    res.status(500).json({ error: error.message });
  }
});

// Add a GET route to fetch all users
router.get('/', async (req, res) => {
  try {
    const users = await UserProfile.find();
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;