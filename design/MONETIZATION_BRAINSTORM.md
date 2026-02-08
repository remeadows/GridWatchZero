# MONETIZATION_BRAINSTORM.md - Grid Watch Zero

## Session Date: 2026-02-01

---

## Overview

This document captures brainstorming discussion around monetization strategies for Grid Watch Zero. The game is currently configured as **Free** on the App Store with no monetization.

---

## Question 1: How to Insert Features That Require Payment

### iOS Payment Options

**1. In-App Purchases (IAP)**
Apple's StoreKit framework provides three IAP types:

| Type | Description | Use Case |
|------|-------------|----------|
| **Consumable** | One-time use, can repurchase | Credit packs, instant boosts |
| **Non-Consumable** | Permanent unlock, one-time purchase | Remove ads, unlock full game, cosmetics |
| **Subscription** | Recurring payment | VIP status, daily rewards multiplier |

**Implementation Requirements:**
- Add StoreKit framework to project
- Create `StoreManager.swift` to handle purchases
- Configure products in App Store Connect
- Implement receipt validation (local or server-side)
- Handle restore purchases (required by Apple)
- Test with Sandbox environment

**Apple's Cut:** 30% (15% for Small Business Program if <$1M/year)

**2. Ad Networks**
Popular options for iOS games:

| Network | Pros | Cons |
|---------|------|------|
| **AdMob (Google)** | Largest network, reliable fill rates | Google dependency |
| **Unity Ads** | Great for games, rewarded video focus | Requires Unity Ads SDK |
| **AppLovin** | High eCPMs, good mediation | Complex setup |
| **ironSource** | Strong rewarded video | Can be intrusive |

**Ad Types:**
- **Banner Ads**: Persistent, low revenue, can hurt UX
- **Interstitial**: Full-screen between levels, moderate revenue
- **Rewarded Video**: User-initiated for rewards, best UX, highest eCPM

---

## Question 2: Ads vs. Paid Unlock Model

### Option A: Free with Ads + Paid Unlock

**Model:** Free to play with occasional ads. One-time purchase ($2.99-$4.99) removes all ads permanently.

**Pros:**
- Low barrier to entry (free download)
- Revenue from both ad viewers and paying users
- "Remove Ads" is a well-understood value proposition
- Good for discoverability (free apps get more downloads)

**Cons:**
- Ads can hurt the immersive cyberpunk atmosphere
- Banner ads especially disruptive on a "dashboard" interface
- Need to balance ad frequency carefully
- Some users have ad blockers

**Recommended Ad Placement for Grid Watch Zero:**
- ❌ NO banner ads (would break NOC aesthetic)
- ⚠️ Interstitials only between campaign levels (not during gameplay)
- ✅ Rewarded video for optional bonuses (see Question 3)

### Option B: Freemium with IAP

**Model:** Free base game, pay for convenience/cosmetics/content.

**Pros:**
- Can generate more revenue from engaged players ("whales")
- No ads to break immersion
- Players pay for what they value

**Cons:**
- Risk of "pay to win" perception
- Requires careful balance design
- More complex to implement
- Can feel predatory if done poorly

### Option C: Premium (Paid Upfront)

**Model:** $2.99-$4.99 one-time purchase, no ads, no IAP.

**Pros:**
- Clean user experience
- No balance concerns
- Simple to implement
- Attracts quality-focused players

**Cons:**
- Fewer downloads (paid apps have 10-50x fewer installs)
- Hard to compete with free alternatives
- No ongoing revenue stream

### Recommendation for Grid Watch Zero

**Hybrid Model: Free + Rewarded Ads + Optional Premium Unlock**

1. Game is **free to download and play completely**
2. **Rewarded video ads** offer optional bonuses (2x credits, etc.)
3. **"Grid Watch Pro" IAP ($3.99)** unlocks:
   - Permanent 2x credit multiplier (no ads needed)
   - Exclusive cosmetic theme ("Pro Operator")
   - Remove all ad prompts
   - Support the developer badge

This respects the player while providing monetization options.

---

## Question 3: "2x Earned Credits" Feature

### Implementation Options

**Option A: Rewarded Video Ad**
- Player taps "Watch Ad for 2x Credits"
- 15-30 second video ad plays
- Credits doubled for next 5-10 minutes (or next X ticks)
- Can watch again after cooldown (30 min - 1 hour)

**UI Placement Ideas:**
```
┌─────────────────────────────────────┐
│  CREDITS: ₵125,430                  │
│  ┌─────────────────────────────┐    │
│  │ 🎬 Watch Ad for 2x Credits  │    │
│  │    (5 minutes)              │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

Or in the Stats Header:
```
┌─────────────────────────────────────┐
│  ₵125,430  │  📊 +2.5K/tick  │ [2x] │
└─────────────────────────────────────┘
                                  ↑
                          Tap for ad boost
```

**Option B: IAP "Permanent 2x Multiplier"**
- One-time purchase ($1.99 - $2.99)
- Credits permanently doubled
- Shows "PRO" badge next to credit display
- Could tier it: 1.5x for $0.99, 2x for $1.99, 3x for $2.99

**Option C: Hybrid (Both)**
- Free players: Watch ad for temporary 2x (5-10 min)
- Paid players: Permanent 2x with single purchase
- This is the **recommended approach**

### Other "Watch Ad" Feature Ideas

| Feature | Ad Reward | Duration/Amount |
|---------|-----------|-----------------|
| 2x Credits | Rewarded Video | 5-10 minutes |
| Instant Repair | Rewarded Video | Full firewall heal |
| Skip Cooldown | Rewarded Video | Reset prestige timer |
| Bonus Intel | Rewarded Video | +50 Intel points |
| Lucky Drop | Rewarded Video | Random data chip |
| Threat Reduction | Rewarded Video | -1 threat level (10 min) |
| Offline Boost | Rewarded Video | 2x offline earnings |

### Balance Considerations

**Without 2x Boost:**
- Level 1: ~15-20 minutes to complete
- Level 7: ~45-60 minutes to complete

**With 2x Boost:**
- Level 1: ~8-10 minutes
- Level 7: ~25-30 minutes

This is acceptable - it's a convenience, not a requirement. Players who don't want to watch ads can still complete all content.

---

## Technical Implementation Notes

### StoreKit 2 (Recommended for iOS 15+)

```swift
// Example structure (DO NOT IMPLEMENT YET)
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []

    private let productIDs = [
        "com.warsignal.gridwatchzero.removeads",
        "com.warsignal.gridwatchzero.pro",
        "com.warsignal.gridwatchzero.credits2x"
    ]

    func loadProducts() async {
        // Load from App Store
    }

    func purchase(_ product: Product) async throws {
        // Handle purchase
    }

    func restorePurchases() async {
        // Restore for new devices
    }
}
```

### Ad Integration (AdMob Example)

```swift
// Example structure (DO NOT IMPLEMENT YET)
import GoogleMobileAds

class AdManager: ObservableObject {
    @Published var isRewardedAdReady = false
    private var rewardedAd: GADRewardedAd?

    func loadRewardedAd() {
        // Load rewarded video
    }

    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        // Show ad, call completion with success/failure
    }
}
```

---

## Revenue Projections (Rough Estimates)

### Assumptions
- 10,000 downloads in first month (modest for free game)
- 5% watch rewarded ads regularly
- 2% convert to paid unlock

### Scenario A: Ads Only
- 500 daily ad views × $0.02 eCPM = $10/day = **$300/month**

### Scenario B: Ads + $3.99 Unlock
- 200 purchases × $3.99 × 0.70 (Apple cut) = **$559 one-time**
- Plus ongoing ad revenue from non-purchasers

### Scenario C: Premium $2.99
- 10,000 × 0.05 conversion × $2.99 × 0.70 = **$1,047 one-time**
- But likely only 500-1,000 downloads at paid tier

---

## Next Steps

1. **Decide on monetization model** (recommend Hybrid: Free + Rewarded Ads + Pro Unlock)
2. **Design ad placement UX** that fits cyberpunk aesthetic
3. **Configure App Store Connect** with IAP products
4. **Integrate ad SDK** (AdMob recommended for simplicity)
5. **Implement StoreManager** for purchases
6. **Test extensively** in Sandbox environment
7. **Update privacy policy** for ad tracking disclosure

---

## ✅ CHOSEN MODEL: Free with Tasteful Rewarded Ads + Pro Unlock

**Decision Date**: 2026-02-06

### Final Strategy

**Base Game**: Completely free, fully playable without spending money
**Rewarded Ads**: Optional bonuses via user-initiated video ads
**Pro Unlock**: One-time IAP ($3.99-$4.99) for permanent benefits

### Why This Model

1. **Maximum Reach**: Free removes barrier to entry, gets game in front of tech audience
2. **Preserves Aesthetic**: No banner ads or interstitials that break NOC dashboard immersion
3. **Respects Players**: Ads are 100% optional, never interrupt gameplay
4. **Revenue Potential**: Dual income streams (ads + Pro conversion)
5. **Insane Mode Justification**: Permanent multipliers help with Insane mode, don't trivialize Normal mode

---

## 🎮 Balance Considerations: Multipliers & Game Progression

### Core Concern
**Risk**: Permanent 2x-3x multipliers could make players "burn through levels" too fast, reducing game longevity and making Normal mode too easy.

**Mitigation**: Insane mode provides endgame challenge where multipliers become valuable rather than trivializing.

### Multiplier Impact Analysis

#### Normal Mode Progression (Without Multipliers)
Based on GAMEPLAY.md and BALANCE.md:
- Level 1: ~15-20 minutes (50K credits required)
- Level 4: ~30-40 minutes (1M credits required)
- Level 7: ~60-90 minutes (25M credits required)
- Level 10: ~2-3 hours (200M credits required)
- Level 20: ~8-12 hours (1T credits required)

**Total Normal Mode Time**: ~25-35 hours to complete all 20 levels

#### With 2x Multiplier (Pro Unlock)
- Level 1: ~8-10 minutes (50% reduction)
- Level 4: ~15-20 minutes
- Level 7: ~30-45 minutes
- Level 10: ~1-1.5 hours
- Level 20: ~4-6 hours

**Total Normal Mode Time with 2x**: ~12-18 hours

#### With Temporary 2x Boost (Rewarded Ad)
- 5-10 minute boost per ad watch
- 30-60 minute cooldown between ads
- Effectively ~20-30% time reduction if watched consistently
- More "active" than passive Pro multiplier

### Recommended Approach: Tiered Multiplier System

**Option A: Conservative (Recommended)**
- **Rewarded Ad**: 1.5x multiplier for 10 minutes (cooldown: 1 hour)
- **Pro Unlock ($3.99)**: Permanent 2x multiplier
- **Rationale**: 2x feels significant without trivializing, Insane mode still challenging

**Option B: Aggressive**
- **Rewarded Ad**: 2x multiplier for 10 minutes (cooldown: 30 min)
- **Pro Unlock ($4.99)**: Permanent 3x multiplier
- **Rationale**: Higher revenue, targets players who value time over challenge

**Option C: Balanced (Alternative)**
- **Rewarded Ad**: 2x multiplier for 5 minutes (cooldown: 45 min)
- **Pro Basic ($2.99)**: Permanent 2x multiplier
- **Pro Plus ($4.99)**: Permanent 2.5x multiplier + all cosmetics + early level access
- **Rationale**: Multiple price tiers capture different willingness to pay

### Balance Testing Protocol

Before finalizing multiplier values, test:

1. **Normal Mode Playtests** (with 2x multiplier):
   - Can Level 1-7 be completed in <30 minutes total?
   - Do players feel "progression satisfaction" or "it's too easy"?
   - Does the multiplier make defense building feel optional?

2. **Insane Mode Validation**:
   - Is Insane mode still challenging with 2x/3x multipliers?
   - Do multipliers feel like "quality of life" or "pay to win"?
   - Are players motivated to replay Normal mode for better grades?

3. **Engagement Metrics**:
   - Average session length (too fast = burned out)
   - Level completion times vs. expected times
   - Retention rate after Level 7 (mid-game check)
   - Insane mode adoption rate (should be >20% of completers)

### Guardrails to Prevent "Burning Through Levels"

**Design Solutions:**

1. **Intel Report Requirements Unchanged**
   - Multipliers affect CREDITS only, not intel collection rate
   - Players still need to survive attacks, collect footprints, send reports
   - This adds "time gate" that multipliers can't bypass

2. **Defense Point Requirements**
   - Multipliers don't affect defense point accumulation speed
   - Players still need to grind defense apps, which have separate upgrade costs
   - Keeps strategic depth even with credit multipliers

3. **Campaign Level Gates**
   - Keep strict tier unlock requirements (must beat Level 6 to access Level 7)
   - Prevent players from "skipping ahead" with credits
   - Forces engagement with each level's story/challenges

4. **Achievement/Grade System**
   - S/A/B/C grades based on time-to-completion
   - Multipliers make it HARDER to get S-rank (faster credits = faster threat escalation)
   - Provides replay incentive for "perfect runs"

5. **Insane Mode as Endgame**
   - Insane mode is where multipliers truly shine
   - Doubles as "New Game+" content
   - Positions Pro unlock as "supporting future content" not "easy mode"

### Ad Frequency Limits (Anti-Abuse)

To prevent "ad spam" ruining balance:
- Maximum 3 ad boosts per hour (even with fast cooldowns)
- Ad boost doesn't stack with Pro multiplier (pick highest)
- Ad boost disabled during Insane mode (preserve difficulty)
- Cooldown persists across app restarts (server timestamp validation if possible)

---

## Implementation Notes

### Pro Unlock Benefits (Finalized)

**"Grid Watch Pro" IAP - $3.99**
- ✅ Permanent 2x credit multiplier
- ✅ Remove all ad prompts (no rewarded ad UI shown)
- ✅ Exclusive "Pro Operator" dashboard theme
- ✅ Support developer badge (visible in profile)
- ✅ Early access to new campaign levels (if released as updates)

### Rewarded Ad Benefits (Finalized)

**Watch Video Ad (15-30 seconds)**
- ✅ 1.5x credit multiplier for 10 minutes
- ✅ Cooldown: 1 hour between ads
- ✅ Maximum 3 ads per hour (abuse prevention)
- ✅ UI shows cooldown timer, doesn't spam prompts
- ✅ Ad UI hidden in Insane mode (preserve challenge)

### UI Placement (Non-Intrusive)

**Rewarded Ad Button Location:**
```
Option 1: Stats Header (Compact)
┌─────────────────────────────────────┐
│  ₵125,430  │  📊 +2.5K/tick  │ [🎬] │
└─────────────────────────────────────┘
                                  ↑
                          Tap for boost info
```

**Option 2: Dashboard Card (Clear)**
```
┌─────────────────────────────────────┐
│  BOOST AVAILABLE                    │
│  Watch ad for 1.5× credits (10 min) │
│  [Watch Video]   Next: 45:23        │
└─────────────────────────────────────┘
```

**Pro Unlock Placement:**
- Settings → "Upgrade to Pro" section (not spammy)
- One-time banner at Level 7 completion (50% campaign point)
- Player Profile → "Support Developer" link

---

## Open Questions

- [x] **Multiplier value**: 2x for Pro, 1.5x for ads (DECIDED)
- [x] **Price point**: $3.99 for Pro (DECIDED - target tech audience)
- [ ] Should cosmetics be separate purchases or bundled with Pro? (Bundled - simpler)
- [x] **Ad frequency**: 10 min boost, 1 hour cooldown, 3/hour max (DECIDED)
- [ ] Should there be a "tip jar" for players who want to support more? (Maybe Pro Plus tier)
- [ ] Consider regional pricing for different markets? (Yes - Apple handles automatically)
- [ ] **CRITICAL**: Playtest with 2x multiplier - does it trivialize Normal mode? (TODO)
- [ ] **CRITICAL**: Validate Insane mode is still challenging with multipliers (TODO)

---

## References

- [Apple StoreKit Documentation](https://developer.apple.com/storekit/)
- [AdMob iOS Quick Start](https://developers.google.com/admob/ios/quick-start)
- [App Store Review Guidelines - IAP](https://developer.apple.com/app-store/review/guidelines/#in-app-purchase)
- [Apple Small Business Program](https://developer.apple.com/app-store/small-business-program/)

---

*This document is for planning purposes only. No code changes have been made.*
