const express = require('express');
const router = express.Router();
const UserProfile = require('../models/UserProfile');
const debug = true; // Toggle for debug logging

function logDebug(...args) {
  if (debug) console.log('[UserRoutes Debug]:', ...args);
}

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

// Update MBTI result
router.post('/profile/mbti', async (req, res) => {
  // Add detailed request logging
  console.log('Raw request body:', req.body);
  console.log('Google ID type:', typeof req.body.googleId);
  console.log('Google ID value:', req.body.googleId);

  try {
    const { googleId, mbti_result } = req.body;
    
    if (!googleId) {
      return res.status(400).json({ 
        error: 'Missing googleId',
        received: req.body,
        bodyType: typeof req.body,
        googleIdType: typeof googleId
      });
    }

    // Log the query we're about to execute
    console.log('Executing MongoDB query with:', {
      googleId,
      mbti_result
    });

    const updatedUser = await UserProfile.findOneAndUpdate(
      { googleId }, 
      { 
        $set: { 
          mbti_result,
          googleId
        }
      },
      { 
        new: true,
        upsert: true
      }
    );

    console.log('Updated user:', updatedUser);
    res.json(updatedUser);

  } catch (error) {
    console.error('Detailed error:', {
      message: error.message,
      stack: error.stack,
      code: error.code
    });
    res.status(500).json({ 
      error: 'Failed to update MBTI result',
      details: error.message
    });
  }
});

module.exports = router;