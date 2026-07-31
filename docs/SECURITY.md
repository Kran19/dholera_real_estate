# SECURITY SPECIFICATION — DHOLERA REAL ESTATE

---

## 1. Security Architecture Summary

The security design follows OWASP principles tailored for mobile-first Core PHP REST APIs:

1. **Zero SQL Injection:** 100% PDO prepared statements with parameter binding.
2. **Password Integrity:** Hashed using `password_hash($password, PASSWORD_DEFAULT)`.
3. **Session Hardening:** Random 64-char hexadecimal bearer tokens stored in DB with expiration.
4. **Independent Authorization:** Backend PHP middleware enforces role checks regardless of UI state.
5. **Secure Uploads:** MIME-type validation, size restrictions, safe random renaming, and execution prohibition.
6. **Data Leakage Prevention:** Production PHP suppresses verbose errors and stack traces.

---

## 2. SQL Injection Prevention Strategy

### ❌ Dangerous (FORBIDDEN):
```php
$db->query("SELECT * FROM properties WHERE village_name = '" . $_GET['village'] . "'");
```

### ✅ Secure (MANDATORY):
```php
$stmt = $db->prepare("SELECT * FROM properties WHERE village_name = :village");
$stmt->execute([':village' => $village]);
$properties = $stmt->fetchAll(PDO::FETCH_ASSOC);
```

---

## 3. Directory Security & Upload Execution Protection

To prevent remote code execution (RCE) via malicious uploaded files:

1. **Upload Directory `.htaccess` Configuration:**
```apache
# backend/uploads/.htaccess
<FilesMatch "\.(php|php5|php7|php8|phtml|exe|pl|cgi)$">
    Order Deny,Allow
    Deny from all
</FilesMatch>
php_flag engine off
```

2. **File MIME Verification:**
PHP uses `finfo_file(finfo_open(FILEINFO_MIME_TYPE), $tmp_file)` to verify the actual file signature on disk, ignoring user-supplied extension header.

---

## 4. API Error Handling & Privacy

- **Development Mode:** Logs errors to `backend/logs/error.log`.
- **API Response:** Returns generic error JSON (`"message": "Internal server error occurred"`). Never exposes SQL statements, file paths, database usernames, or PHP call stacks to client responses.
