# Family System Enhancement: Implementation Plan

This document outlines the tasks required to enhance the family management system in the EatSoon app. The goal is to address architectural loopholes, improve user experience, and create a scalable foundation for future family-related features.

---

## Phase 1: Core State Management & Data Model Enhancement

This phase focuses on strengthening the backend and core application state to properly handle multiple families and a user's active context.

-   [x] **Enhance `UserModel` (`lib/features/auth/data/models/user_model.dart`)**
    -   [x] Add `List<String> familyIds` to store all families a user belongs to.
    -   [x] Rename `familyId` to `currentFamilyId` for clarity. This will represent the currently active family context for the UI.
    -   [x] Update the `fromFirestore` and `toFirestore` methods to handle these new fields.

-   [ ] **Update `AuthProvider` (`lib/features/auth/providers/auth_provider.dart`)**
    -   [ ] Modify the provider to fetch and store the full `UserModel` which includes `familyIds` and `currentFamilyId`.
    -   [ ] Implement a new public method: `Future<void> switchFamily(String newFamilyId)`.
        -   This method should update the `currentFamilyId` field in the user's document in Firestore.
        -   After a successful update, it must call `reloadUser()` to propagate the state change throughout the app.
        -   Add appropriate error handling and loading states.

-   [x] **Update `FamilyService` (`lib/features/family/data/services/family_service.dart`)**
    -   [x] Modify `createFamily` to add the new family's ID to the creator's `familyIds` list and set it as their `currentFamilyId`.
    -   [x] Modify `acceptInvitation` to add the family's ID to the user's `familyIds` list and set it as their `currentFamilyId`.

---

## Phase 2: UI/UX for Family Context Switching

This phase is about giving users the tools to manage and switch between their families if they belong to more than one.

-   [x] **Create a Reusable "Family Switcher" Widget**
    -   [x] Design a dropdown or modal widget that displays a list of family names.
    -   [x] The list should be populated from `authProvider.user.familyIds`.
    -   [x] On selection, it should call `authProvider.switchFamily(selectedFamilyId)`.
    -   [x] The widget should only be interactive if `familyIds.length > 1`.

-   [x] **Integrate Family Switcher into Home Screen (`lib/features/home/presentation/screens/home_screen.dart`)**
    -   [x] Add the switcher to the header of the `_buildFamilyMembers` card.
    -   [x] It should display the name of the currently active family.
    -   [x] The family members list and family activity feed should react to changes from the switcher.

-   [x] **Integrate Family Switcher into Profile Screen (`lib/features/profile/presentation/screens/profile_screen.dart`)**
    -   [x] Add the switcher to the `_buildProfileHeader` section, near the user's name.
    *   This provides a secondary, logical place for users to manage their active context.

---

## Phase 3: Differentiating Personal vs. Family Data

This phase ensures that data displayed on various screens is clearly scoped and unambiguous to the user.

-   [ ] **Refactor Home Screen Data Display (`lib/features/home/presentation/screens/home_screen.dart`)**
    -   [ ] **Confirm Personal Stats:** Ensure the top statistics cards (`Expiring Soon`, `Total Items`) are always sourced from the user's personal inventory data (`InventoryService`).
    -   [ ] **Personal Activity Feed:** Keep the "Recent Activity" section as-is, sourcing from the user's personal activity stream.
    -   [ ] **Create Family Activity Feed:** Implement a new widget section, likely within the `_buildFamilyMembers` card, titled "Recent Family Activity".
        -   This feed must source its data from `ActivityService.getFamilyActivitiesStream(authProvider.user.currentFamilyId)`.
        -   The UI for each activity item should clearly show which family member performed the action (using `activity.userName` and `activity.userProfileImage`).

-   [ ] **Confirm Profile Screen Data Scope (`lib/features/profile/presentation/screens/profile_screen.dart`)**
    -   [ ] Verify that all statistics on this screen (`Items Added`, `Recipes Viewed`, etc.) are sourced from the user's personal activity stream. This screen should remain a personal dashboard.

-   [ ] **Verify Family Dashboard (`lib/features/family/presentation/screens/family_members_screen.dart`)**
    -   [ ] Confirm that this screen correctly uses the `currentFamilyId` from the `AuthProvider` to display data.
    -   [ ] All stats, member lists, and activity feeds on this screen must be scoped to the currently active family.

---
## Progress Tracker

### Phase 1: Core State Management & Data Model Enhancement
- [x] **`UserModel` Enhancement**
- [x] **`AuthProvider` Update**
- [x] **`FamilyService` Update**

### Phase 2: UI/UX for Family Context Switching
- [x] **"Family Switcher" Widget Creation**
- [ ] **Home Screen Integration**
- [ ] **Profile Screen Integration**

### Phase 3: Differentiating Personal vs. Family Data
- [ ] **Home Screen Data Refactor**
- [ ] **Profile Screen Data Scope Confirmation**
- [ ] **Family Dashboard Verification**