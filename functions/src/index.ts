import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import { getFirestore } from "firebase-admin/firestore";

admin.initializeApp();

// use this everywhere instead of admin.firestore()
const db = getFirestore(admin.app(), "eatsoon001");

/**
 * Sends an email to a user when a new family invitation is created for them.
 * This function is triggered when a new document is added to the
 * 'familyInvitations' collection. It then creates a new document in the 'mail'
 * collection, which is processed by the "Trigger Email" Firebase Extension.
 */
export const sendFamilyInvitationEmail = onDocumentCreated(
    {
        document: "familyInvitations/{invitationId}",
        database: "eatsoon001",
    },
    async (event) => {
        logger.info("New family invitation from eatsoon001, preparing email.", {
            invitationId: event.params.invitationId,
        });

        const snapshot = event.data;
        if (!snapshot) {
            logger.error("No data associated with the event");
            return;
        }

        const data = snapshot.data();
        const { inviteeEmail, inviterName, familyName } = data;
        const invitationId = event.params.invitationId; // The doc ID is the code

        if (!inviteeEmail || !inviterName || !familyName) {
            logger.error("Invitation document is missing required fields.", {
                invitationId,
                data,
            });
            return;
        }

        try {
            await db.collection("mail").add({
                to: [inviteeEmail],
                message: {
                    subject: `You're invited to join the ${familyName} family on EatSoon!`,
                    html: `
                        <div style="font-family: sans-serif; padding: 20px;">
                            <h1 style="color: #333;">You've been invited!</h1>
                            <p>Hi there,</p>
                            <p>
                                <b>${inviterName}</b> has invited you to join their family,
                                <b>${familyName}</b>, on the EatSoon app.
                            </p>
                            <p>
                                To accept, open the app and enter the following code on the
                                'Family' page when prompted:
                            </p>
                            <p style="
                                font-size: 24px;
                                font-weight: bold;
                                letter-spacing: 2px;
                                background-color: #f0f0f0;
                                padding: 16px;
                                border-radius: 8px;
                                text-align: center;
                            ">
                                ${invitationId}
                            </p>
                            <p>This invitation is valid for 7 days.</p>
                            <p>Thanks,</p>
                            <p><b>The EatSoon Team</b></p>
                        </div>
                    `,
                },
            });
            logger.info(`Successfully queued invitation email for ${inviteeEmail}`);
        } catch (error) {
            logger.error(
                "Failed to create email document in 'mail' collection.",
                { error, invitationId },
            );
        }
    },
);

/**
 * Handles a user's request to accept a family invitation.
 * This is a callable function that executes all validation and database
 * writes within a secure, atomic transaction on the server.
 */
export const acceptFamilyInvitation = onCall(
    {
        // Enforce App Check, which is a good practice for callable functions.
        enforceAppCheck: true,
    },
    async (request) => {
        // 1. Authentication & Input Validation
        if (!request.auth) {
            throw new HttpsError(
                "unauthenticated",
                "You must be logged in to accept an invitation.",
            );
        }
        const userId = request.auth.uid;
        const userEmail = request.auth.token.email;
        const userName = request.auth.token.name || "User";
        const userPhoto = request.auth.token.picture || null;

        const { invitationId } = request.data;

        if (!invitationId || typeof invitationId !== "string") {
            throw new HttpsError(
                "invalid-argument",
                "The function must be called with a valid 'invitationId'.",
            );
        }
        if (!userEmail) {
            throw new HttpsError(
                "failed-precondition",
                "Your account must have a verified email address.",
            );
        }

        logger.info(`User ${userId} attempting to accept invitation ${invitationId}`);

        // 2. Run acceptance logic in a transaction for atomicity
        try {
            await db.runTransaction(async (transaction) => {
                const invitationRef = db
                    .collection("familyInvitations")
                    .doc(invitationId);
                const invitationDoc = await transaction.get(invitationRef);

                // 3. Invitation Validation
                if (!invitationDoc.exists) {
                    throw new HttpsError("not-found", "This invitation does not exist.");
                }

                const invitation = invitationDoc.data();

                if (!invitation) {
                    throw new HttpsError("internal", "Invitation data is missing.");
                }

                if (invitation.inviteeEmail.toLowerCase() !== userEmail.toLowerCase()) {
                    throw new HttpsError(
                        "permission-denied",
                        "This invitation is not for you.",
                    );
                }
                if (invitation.status !== "pending") {
                    throw new HttpsError(
                        "failed-precondition",
                        "This invitation has already been responded to.",
                    );
                }
                if (invitation.expiresAt.toDate() < new Date()) {
                    throw new HttpsError(
                        "failed-precondition",
                        "This invitation has expired.",
                    );
                }

                const { familyId } = invitation;
                const familyRef = db.collection("families").doc(familyId);
                const familyMembersRef = db.collection("familyMembers").doc(familyId);
                const userRef = db.collection("users").doc(userId);

                // 4. Perform all database writes
                const now = new Date();
                const newMemberData = {
                    displayName: userName,
                    email: userEmail,
                    profileImage: userPhoto,
                    role: "member", // New users always join as 'member'
                    status: "active",
                    joinedAt: now,
                    lastActiveAt: now,
                };

                // Add member to familyMembers document
                transaction.set(
                    familyMembersRef,
                    { members: { [userId]: newMemberData } },
                    { merge: true },
                );

                // Add familyId to the user's document
                transaction.update(userRef, {
                    familyIds: admin.firestore.FieldValue.arrayUnion(familyId),
                    currentFamilyId: familyId,
                });

                // Update family member count
                transaction.update(familyRef, {
                    "statistics.memberCount": admin.firestore.FieldValue.increment(1),
                });

                // Mark invitation as accepted
                transaction.update(invitationRef, {
                    status: "accepted",
                    respondedAt: now,
                });
            });

            logger.info(`Successfully accepted invitation ${invitationId} for user ${userId}.`);
            return { success: true, message: "Invitation accepted successfully!" };
        } catch (error) {
            logger.error(`Error accepting invitation ${invitationId}:`, error);
            if (error instanceof HttpsError) {
                throw error; // Re-throw HttpsError to be sent to the client
            }
            // For other errors, throw a generic internal error.
            throw new HttpsError("internal", "An unexpected error occurred. Please try again.");
        }
    },
);
