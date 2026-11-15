// The Last Signature: an emotional, cinematic Roblox story game for make.fun's roblox-game-01.
// The game is this directory's Rojo project, built into game.rbxl with
// `rojo build default.project.json --output game.rbxl`. This program hands it
// in: it copies game.rbxl, src/, screenshots/ and PLAY.json from beside this
// file to /output and writes /output/dossier.json, the summary the judge
// reads, with the vendored make.fun library.
//
// The game: you are Alex, 17, back in your late grandmother Elena's old house
// after a mysterious envelope and an old key. Explore six rooms, find five
// memories, make three choices, solve two puzzles, and reach one of four
// endings as you uncover the secret behind a forged signature. The server
// owns every rule; the client draws the title screen, the HUD, the memory
// scenes, the choice dialogue and the ending cards.
//
// Outside the grader's container, MAKEFUN_OUTPUT_DIR stands in for /output:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, cpSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const here = fileURLToPath(new URL('.', import.meta.url));
const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

// The grader's /output exists; a local run's stand-in may not, so make it.
mkdirSync(out, { recursive: true });

copyFileSync(join(here, 'game.rbxl'), join(out, 'game.rbxl'));
copyFileSync(join(here, 'PLAY.json'), join(out, 'PLAY.json'));
cpSync(join(here, 'src'), join(out, 'src'), { recursive: true });
mkdirSync(join(out, 'screenshots'), { recursive: true });
if (existsSync(join(here, 'screenshots'))) cpSync(join(here, 'screenshots'), join(out, 'screenshots'), { recursive: true });

// The scorer's own caps (reference/gate.json): only text_max_bytes shapes the bytes; the others refuse an entry the
// scorer would refuse (more than 4 screenshots or one over 256 KiB; a place of more than 500000 instances, whose
// scripts' sources come to over 8 MiB or whose scripts' paths come to over 1048576 characters, in all).
const dossierPath = join(out, 'dossier.json');
writeFileSync(
  dossierPath,
  buildDossier(out, { text_max_bytes: 65536, screenshots: { max: 4, max_bytes: 262144 }, max_instances: 500000, scripts_max_source_bytes: 8388608, scripts_max_path_chars: 1048576 }),
);
console.log(`The Last Signature: wrote ${dossierPath}`);
