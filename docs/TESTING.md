# TESTING STRATEGY & TEST MATRIX — DHOLERA REAL ESTATE

---

## 1. Quality Assurance Strategy

Testing is conducted systematically across backend API endpoints, security controls, database integrity, and Flutter mobile UI flows.

---

## 2. Test Matrix

### A. Authentication Verification
| Test Case | Steps | Expected Result | Pass/Fail |
| :--- | :--- | :--- | :--- |
| **Auth-01** | Login with correct username & passcode | Returns HTTP 200, valid token & user object | Pending |
| **Auth-02** | Login with incorrect passcode | Returns HTTP 401, "Invalid username or password" | Pending |
| **Auth-03** | Login with inactive user account | Returns HTTP 403, "Account deactivated" | Pending |
| **Auth-04** | Access protected API without Bearer token | Returns HTTP 401, "Unauthorized access" | Pending |
| **Auth-05** | Logout API call | Invalidates token in DB, subsequent calls return 401 | Pending |

### B. User Management (Super Admin)
| Test Case | Steps | Expected Result | Pass/Fail |
| :--- | :--- | :--- | :--- |
| **User-01** | Admin creates valid user | User created in DB, password hashed | Pending |
| **User-02** | Admin creates user with duplicate username | Returns HTTP 400 validation error | Pending |
| **User-03** | Admin deactivates user | Status changes to inactive, user logged out | Pending |
| **User-04** | Normal user calls `/api/users/create.php` | Returns HTTP 403 Forbidden | Pending |

### C. Property Management & Images
| Test Case | Steps | Expected Result | Pass/Fail |
| :--- | :--- | :--- | :--- |
| **Prop-01** | Admin creates property with 3 valid images | Property & 3 image rows saved, files stored in `uploads/properties/{id}/` | Pending |
| **Prop-02** | Admin attempts uploading 6 images | Request rejected, "Maximum 5 images allowed" | Pending |
| **Prop-03** | Admin uploads non-image file (.php/.exe) | Request rejected, MIME type error | Pending |
| **Prop-04** | Admin deletes property | Property, image rows & physical image folder deleted | Pending |
| **Prop-05** | User browses properties with pagination | Returns 20 items per page with valid pagination metadata | Pending |

### D. Search & Filter
| Test Case | Steps | Expected Result | Pass/Fail |
| :--- | :--- | :--- | :--- |
| **Srch-01** | Search by Village Name | Returns matching village properties | Pending |
| **Srch-02** | Search by Survey Number | Returns matching survey no properties | Pending |
| **Srch-03** | Filter by Area Unit (`Bigha`) | Returns only `Bigha` properties | Pending |
