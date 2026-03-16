/**
 * LuCI Argon Theme - Tirtayana Custom Edition
 * Password Change Reminder System
 * Copyright (C) 2024 Tirtayana
 */

(function() {
    'use strict';

    const PasswordReminder = {
        // Configuration
        config: {
            storageKey: 'tirtayana_password_reminder',
            dismissedKey: 'tirtayana_reminder_dismissed',
            checkInterval: 5000, // Check every 5 seconds
            modalId: 'tirtayana-password-modal',
            passwordChangeUrl: '/cgi-bin/luci/admin/system/admin'
        },

        // Initialize the reminder system
        init: function() {
            // Check if we should show the reminder
            if (this.shouldShowReminder()) {
                this.createModal();
                this.showModal();
                this.attachEventListeners();
            }

            // Also check periodically (in case password gets changed)
            this.startPeriodicCheck();
        },

        // Check if reminder should be shown
        shouldShowReminder: function() {
            // Check if reminder flag is set (from login page)
            const showReminder = sessionStorage.getItem(this.config.storageKey);

            // Check if user has dismissed it (but allow showing again on new session)
            const dismissed = sessionStorage.getItem(this.config.dismissedKey);

            // Show if flagged and not dismissed in this session
            return showReminder === 'true' && dismissed !== 'true';
        },

        // Create the modal HTML
        createModal: function() {
            // Check if modal already exists
            if (document.getElementById(this.config.modalId)) {
                return;
            }

            const modal = document.createElement('div');
            modal.id = this.config.modalId;
            modal.className = 'password-reminder-modal';
            modal.innerHTML = `
                <div class="password-reminder-overlay"></div>
                <div class="password-reminder-content">
                    <div class="reminder-header">
                        <div class="reminder-icon">🔐</div>
                        <h2>Security Warning</h2>
                        <button class="reminder-close" aria-label="Close">&times;</button>
                    </div>

                    <div class="reminder-body">
                        <div class="warning-badge">
                            <span class="badge-icon">⚠️</span>
                            <span class="badge-text">Default Password Detected</span>
                        </div>

                        <p class="reminder-message">
                            <strong>Your router is using the default password!</strong>
                        </p>

                        <p class="reminder-description">
                            For security reasons, it is <strong>strongly recommended</strong> to set a new
                            password immediately. Using the default password leaves your router vulnerable
                            to unauthorized access.
                        </p>

                        <div class="security-tips">
                            <h4>Password Security Tips:</h4>
                            <ul>
                                <li>✓ Use at least 12 characters</li>
                                <li>✓ Mix uppercase and lowercase letters</li>
                                <li>✓ Include numbers and symbols</li>
                                <li>✓ Avoid common words or phrases</li>
                                <li>✓ Don't reuse passwords from other accounts</li>
                            </ul>
                        </div>
                    </div>

                    <div class="reminder-footer">
                        <button class="btn btn-primary btn-change-password">
                            <span class="btn-icon">🔒</span>
                            <span class="btn-text">Change Password Now</span>
                        </button>
                        <button class="btn btn-secondary btn-remind-later">
                            Remind Me Later
                        </button>
                    </div>
                </div>
            `;

            document.body.appendChild(modal);
        },

        // Show the modal
        showModal: function() {
            const modal = document.getElementById(this.config.modalId);
            if (modal) {
                setTimeout(() => {
                    modal.classList.add('show');
                    document.body.style.overflow = 'hidden';

                    // Focus on change password button for accessibility
                    const changeBtn = modal.querySelector('.btn-change-password');
                    if (changeBtn) {
                        changeBtn.focus();
                    }
                }, 500); // Small delay for better UX
            }
        },

        // Hide the modal
        hideModal: function() {
            const modal = document.getElementById(this.config.modalId);
            if (modal) {
                modal.classList.remove('show');
                document.body.style.overflow = '';

                // Mark as dismissed for this session
                sessionStorage.setItem(this.config.dismissedKey, 'true');
            }
        },

        // Navigate to password change page
        navigateToPasswordChange: function() {
            // Clear the reminder flags
            sessionStorage.removeItem(this.config.storageKey);
            sessionStorage.setItem(this.config.dismissedKey, 'true');

            // Navigate to password change page
            window.location.href = this.config.passwordChangeUrl;
        },

        // Attach event listeners
        attachEventListeners: function() {
            const modal = document.getElementById(this.config.modalId);
            if (!modal) return;

            // Change password button
            const changePwdBtn = modal.querySelector('.btn-change-password');
            if (changePwdBtn) {
                changePwdBtn.addEventListener('click', () => {
                    this.navigateToPasswordChange();
                });
            }

            // Remind later button
            const remindLaterBtn = modal.querySelector('.btn-remind-later');
            if (remindLaterBtn) {
                remindLaterBtn.addEventListener('click', () => {
                    this.hideModal();
                });
            }

            // Close button
            const closeBtn = modal.querySelector('.reminder-close');
            if (closeBtn) {
                closeBtn.addEventListener('click', () => {
                    this.hideModal();
                });
            }

            // Overlay click to close
            const overlay = modal.querySelector('.password-reminder-overlay');
            if (overlay) {
                overlay.addEventListener('click', () => {
                    this.hideModal();
                });
            }

            // Escape key to close
            document.addEventListener('keydown', (e) => {
                if (e.key === 'Escape' && modal.classList.contains('show')) {
                    this.hideModal();
                }
            });
        },

        // Start periodic check for password change
        startPeriodicCheck: function() {
            // This would check if password has been changed
            // For now, just a placeholder for future implementation
            setInterval(() => {
                // Could call an API endpoint to check if password is still default
                // For now, we rely on session storage
            }, this.config.checkInterval);
        },

        // Check if we're on the password change page
        isOnPasswordPage: function() {
            return window.location.pathname.includes('/admin/system/admin');
        },

        // Show success message after password change
        showSuccessMessage: function() {
            const successDiv = document.createElement('div');
            successDiv.className = 'password-change-success';
            successDiv.innerHTML = `
                <div class="success-content">
                    <div class="success-icon">✅</div>
                    <h3>Password Changed Successfully!</h3>
                    <p>Your router is now more secure.</p>
                </div>
            `;

            document.body.appendChild(successDiv);

            setTimeout(() => {
                successDiv.classList.add('show');
            }, 100);

            setTimeout(() => {
                successDiv.classList.remove('show');
                setTimeout(() => {
                    successDiv.remove();
                }, 300);
            }, 5000);
        }
    };

    // Add CSS styles dynamically
    const styleSheet = document.createElement('style');
    styleSheet.textContent = `
        /* Password Reminder Modal Styles */
        .password-reminder-modal {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.3s ease, visibility 0.3s ease;
        }

        .password-reminder-modal.show {
            opacity: 1;
            visibility: visible;
        }

        .password-reminder-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.7);
            backdrop-filter: blur(5px);
        }

        .password-reminder-content {
            position: relative;
            background: white;
            border-radius: 16px;
            max-width: 550px;
            width: 90%;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.4);
            transform: scale(0.9);
            transition: transform 0.3s ease;
        }

        .password-reminder-modal.show .password-reminder-content {
            transform: scale(1);
        }

        .reminder-header {
            background: linear-gradient(135deg, #cc1111 0%, #d43f3a 100%);
            color: white;
            padding: 25px 30px;
            border-radius: 16px 16px 0 0;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .reminder-icon {
            font-size: 2.5em;
        }

        .reminder-header h2 {
            flex: 1;
            margin: 0;
            font-size: 1.5em;
            font-weight: 700;
        }

        .reminder-close {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            font-size: 2em;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            cursor: pointer;
            transition: background 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            line-height: 1;
        }

        .reminder-close:hover {
            background: rgba(255, 255, 255, 0.3);
        }

        .reminder-body {
            padding: 30px;
        }

        .warning-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #fff3cd;
            border: 2px solid #cc8800;
            color: #856404;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: 600;
            margin-bottom: 20px;
        }

        .badge-icon {
            font-size: 1.3em;
        }

        .reminder-message {
            font-size: 1.2em;
            color: #0b0b0b;
            margin-bottom: 15px;
        }

        .reminder-description {
            color: #5d5d5d;
            line-height: 1.6;
            margin-bottom: 25px;
        }

        .security-tips {
            background: #f8f9fa;
            border-left: 4px solid #8a6800;
            padding: 20px;
            border-radius: 8px;
        }

        .security-tips h4 {
            color: #0b0b0b;
            margin-bottom: 15px;
            font-size: 1.1em;
        }

        .security-tips ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .security-tips li {
            padding: 8px 0;
            color: #5d5d5d;
            font-size: 0.95em;
        }

        .reminder-footer {
            padding: 25px 30px;
            background: #f8f9fa;
            border-radius: 0 0 16px 16px;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .reminder-footer .btn {
            flex: 1;
            min-width: 200px;
            padding: 14px 20px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            border: none;
            font-size: 1em;
        }

        .btn-primary {
            background: linear-gradient(135deg, #cc1111 0%, #d43f3a 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(204, 17, 17, 0.3);
        }

        .btn-primary:hover {
            background: linear-gradient(135deg, #d43f3a 0%, #e74c3c 100%);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(204, 17, 17, 0.4);
        }

        .btn-secondary {
            background: white;
            color: #5d5d5d;
            border: 2px solid #ddd;
        }

        .btn-secondary:hover {
            background: #f8f9fa;
            border-color: #8a6800;
            color: #8a6800;
        }

        .btn-icon {
            font-size: 1.2em;
        }

        /* Success Message */
        .password-change-success {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 10000;
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            padding: 20px 30px;
            min-width: 300px;
            opacity: 0;
            transform: translateY(-20px);
            transition: all 0.3s ease;
        }

        .password-change-success.show {
            opacity: 1;
            transform: translateY(0);
        }

        .success-content {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .success-icon {
            font-size: 2.5em;
        }

        .success-content h3 {
            margin: 0 0 5px 0;
            color: #5cb85c;
            font-size: 1.2em;
        }

        .success-content p {
            margin: 0;
            color: #5d5d5d;
            font-size: 0.9em;
        }

        /* Mobile Responsive */
        @media only screen and (max-width: 768px) {
            .password-reminder-content {
                width: 95%;
                max-height: 95vh;
            }

            .reminder-header {
                padding: 20px;
            }

            .reminder-header h2 {
                font-size: 1.2em;
            }

            .reminder-icon {
                font-size: 2em;
            }

            .reminder-body {
                padding: 20px;
            }

            .reminder-footer {
                padding: 20px;
                flex-direction: column;
            }

            .reminder-footer .btn {
                min-width: 100%;
                width: 100%;
            }

            .password-change-success {
                right: 10px;
                left: 10px;
                min-width: auto;
            }
        }

        @media only screen and (max-width: 480px) {
            .reminder-header {
                padding: 15px;
            }

            .reminder-icon {
                font-size: 1.8em;
            }

            .reminder-close {
                width: 35px;
                height: 35px;
                font-size: 1.8em;
            }

            .reminder-body {
                padding: 15px;
            }

            .security-tips {
                padding: 15px;
            }

            .security-tips li {
                font-size: 0.9em;
            }
        }
    `;
    document.head.appendChild(styleSheet);

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            PasswordReminder.init();
        });
    } else {
        PasswordReminder.init();
    }

    // Export for potential external use
    window.TirtayanaPasswordReminder = PasswordReminder;

})();
