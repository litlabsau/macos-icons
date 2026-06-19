// Generate small WebP thumbnails for every PNG in png/.
//
// Originals in png/ are left untouched — the gallery uses these thumbnails for
// fast previews, while Copy URL / Download still point at the full-res PNG.
//
// Usage:
//   npm install
//   npm run thumbnails        (or: node scripts/generate-thumbnails.js)

const fs = require("fs");
const path = require("path");
const sharp = require("sharp");

const SRC_DIR = "png"; // source PNGs (unchanged)
const OUT_DIR = path.join("assets", "thumbs"); // generated WebP thumbnails
const MAX_SIZE = 160; // longest edge in px (2x of the 80px display slot)
const QUALITY = 82; // WebP quality (0-100)

async function main() {
  fs.mkdirSync(OUT_DIR, { recursive: true });

  const pngs = fs
    .readdirSync(SRC_DIR)
    .filter((f) => f.toLowerCase().endsWith(".png"));

  if (pngs.length === 0) {
    console.log(`No PNGs found in ${SRC_DIR}/`);
    return;
  }

  let written = 0;
  for (const file of pngs) {
    const name = path.basename(file, path.extname(file));
    const dest = path.join(OUT_DIR, `${name}.webp`);
    await sharp(path.join(SRC_DIR, file))
      .resize(MAX_SIZE, MAX_SIZE, { fit: "inside", withoutEnlargement: true })
      .webp({ quality: QUALITY })
      .toFile(dest);
    written++;
  }

  // Remove orphaned thumbnails whose source PNG was deleted
  const stems = new Set(pngs.map((f) => path.basename(f, path.extname(f))));
  for (const thumb of fs.readdirSync(OUT_DIR).filter((f) => f.endsWith(".webp"))) {
    if (!stems.has(path.basename(thumb, ".webp"))) {
      fs.unlinkSync(path.join(OUT_DIR, thumb));
      console.log(`removed orphan: ${thumb}`);
    }
  }

  console.log(`Done. ${written} thumbnail(s) written to ${OUT_DIR}/`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
