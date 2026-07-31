# IMAGE UPLOADS ARCHITECTURE & SECURITY SPECIFICATION

---

## 1. Overview

Property listings support visual documentation through uploaded photographs.

- **Maximum Limit:** Up to **5 images** per property.
- **Storage Location:** Disk filesystem at `backend/uploads/properties/{property_id}/`.
- **Database Reference:** Relative file path stored in `property_images` table (`image_url` field).
- **Primary Image:** Image with `sort_order = 1` acts as the cover thumbnail card image.

---

## 2. Server-Side Validation Rules

Every image payload passed to `backend/api/uploads/property_image.php` or property creation must be validated against:

1. **Count Boundary:** Total images attached to a single property ID must **NOT exceed 5**.
2. **File Size Limit:** Maximum **5 MB** per image file.
3. **MIME Type Whitelist:**
   - `image/jpeg`
   - `image/png`
   - `image/webp`
4. **Extension Whitelist:** `.jpg`, `.jpeg`, `.png`, `.webp`.
5. **Real Image Verification:** Verified using `getimagesize()` or PHP `finfo_file()` to prevent malicious scripts renamed as `.jpg`.

---

## 3. Filename Sanitization & Storage Structure

Original filenames sent by clients are **NEVER** trusted or preserved directly.

### Filename Generation Pattern:
`img_{property_id}_{timestamp}_{random8}.{ext}`
Example: `img_15_1700000000_a8f9c2e1.jpg`

### Directory Structure:
```
backend/
└── uploads/
    └── properties/
        ├── .htaccess                # Disable script execution
        ├── 15/
        │   ├── img_15_1700000000_a8f9c2e1.jpg
        │   ├── img_15_1700000005_b9e0d3f2.jpg
        │   └── img_15_1700000010_c1a2b3c4.jpg
        └── 16/
            └── img_16_1700000020_d4e5f6a7.jpg
```

---

## 4. Deletion & Cleanup Protocol

When a Super Admin deletes a property image or deletes an entire property:

1. **Single Image Removal:**
   - PHP queries physical file path from `property_images` table.
   - Deletes file from filesystem using PHP `unlink()`.
   - Deletes database row from `property_images`.
   - Re-indexes remaining images `sort_order` (1..N).

2. **Property Removal:**
   - PHP fetches all associated image rows.
   - Iterates and `unlink()`s all physical files.
   - Removes the property directory `backend/uploads/properties/{property_id}/` using `rmdir()`.
   - Cascading foreign key deletes DB rows.
