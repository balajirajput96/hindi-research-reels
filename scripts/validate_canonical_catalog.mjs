import { readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const state = JSON.parse(readFileSync(resolve(root, 'catalog/canonical_production_state.json'), 'utf8'));
const reels = JSON.parse(readFileSync(resolve(root, 'catalog/reel_registry.json'), 'utf8'));
const fail = (message) => { throw new Error(message); };

if (state.production_contract.total_reels !== 3000 || reels.length !== 3000) fail('Catalog must contain exactly 3000 reels.');
const ids = new Set(reels.map((reel) => reel.reel_id));
const titles = new Set(reels.map((reel) => reel.working_title_hi));
if (ids.size !== 3000) fail('Reel identifiers are not unique.');
if (titles.size !== 3000) fail('Reel working titles are not unique.');
if (reels[0].reel_id !== '0001' || reels.at(-1).reel_id !== '3000') fail('Reel identifiers must span 0001–3000.');
const batchCounts = new Map();
for (const reel of reels) batchCounts.set(reel.batch, (batchCounts.get(reel.batch) ?? 0) + 1);
if (batchCounts.size !== 100 || [...batchCounts.values()].some((count) => count !== 30)) fail('Every batch must contain exactly 30 reels.');
const reel1 = reels.find((reel) => reel.reel_id === '0001');
const reel2 = reels.find((reel) => reel.reel_id === '0002');
const reel3 = reels.find((reel) => reel.reel_id === '0003');
if (reel1.status !== 'qc_passed_drive_verified' || reel1.duration_seconds < 55 || reel1.duration_seconds > 65) fail('Reel 0001 completion contract is invalid.');
if (reel2.status !== 'qc_passed_drive_verified' || reel2.duration_seconds < 55 || reel2.duration_seconds > 65 || !reel2.drive_file_id || !reel2.source_metadata_file_id || !reel2.qc_file_id) fail('Reel 0002 completion contract is invalid.');
if (reel3.status !== 'qc_passed_drive_verified' || reel3.duration_seconds < 55 || reel3.duration_seconds > 65 || !reel3.drive_file_id || !reel3.source_metadata_file_id || !reel3.qc_file_id) fail('Reel 0003 completion contract is invalid.');
if (state.state.completed_reels !== 3 || state.state.next_reel !== '0004' || state.state.retry_queue.length !== 0) fail('Canonical production checkpoint is invalid.');
if (!Array.isArray(state.state.completed_concept_keys) || state.state.completed_concept_keys.length !== 3 || !state.state.completed_concept_keys.includes(reel3.concept_key)) fail('Reel 0003 concept completion contract is invalid.');
console.log('Canonical catalog validation passed: 3000 unique reels, 100 complete batches, Reels 0001–0003 verified, Reel 0004 next.');
