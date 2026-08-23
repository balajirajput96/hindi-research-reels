import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const catalogDir = resolve(root, 'catalog');
mkdirSync(catalogDir, { recursive: true });

const tracks = [
  { id: 'habits_behavior', title: 'आदतें और व्यवहार परिवर्तन', evidence: 'behavioral_science_pending_research', domains: ['संकेत', 'दोहराव', 'पर्यावरण', 'पहचान', 'छोटे कदम'], focuses: ['शुरुआत', 'स्थिरता', 'रुकावट', 'पुनःशुरू', 'ट्रैकिंग'] },
  { id: 'attention_focus', title: 'ध्यान और फोकस', evidence: 'cognitive_science_pending_research', domains: ['ध्यान-विचलन', 'गहरा काम', 'डिजिटल संकेत', 'कार्य-स्विचिंग', 'मानसिक थकान'], focuses: ['तंत्र', 'सीमा', 'अभ्यास', 'मापन', 'रोज़मर्रा उदाहरण'] },
  { id: 'memory_learning', title: 'स्मृति और सीखना', evidence: 'learning_science_pending_research', domains: ['रिकॉल', 'स्पेसिंग', 'इंटरलीविंग', 'गलतियाँ', 'नींद के बाद सीखना'], focuses: ['रणनीति', 'सीमा', 'मिथक', 'उदाहरण', 'स्व-परीक्षण'] },
  { id: 'emotion_regulation', title: 'भावनाएँ और नियमन', evidence: 'psychology_pending_research', domains: ['भावना पहचान', 'नाम देना', 'रीऐप्रेज़ल', 'शारीरिक संकेत', 'भावनात्मक दूरी'], focuses: ['कौशल', 'सीमा', 'उदाहरण', 'विचार', 'सावधानी'] },
  { id: 'sleep_recovery', title: 'नींद और रिकवरी', evidence: 'sleep_science_pending_research', domains: ['नींद दबाव', 'सर्केडियन संकेत', 'स्क्रीन समय', 'आराम', 'सीखने के बाद नींद'], focuses: ['तंत्र', 'रूटीन', 'मिथक', 'सीमा', 'उदाहरण'] },
  { id: 'stress_coping', title: 'तनाव और सामना', evidence: 'stress_research_pending', domains: ['तनाव प्रतिक्रिया', 'साँस', 'नियंत्रण का दायरा', 'सामाजिक सहारा', 'रिकवरी विराम'], focuses: ['समझ', 'कौशल', 'सावधानी', 'मिथक', 'छोटा कदम'] },
  { id: 'decision_bias', title: 'निर्णय और संज्ञानात्मक पक्षपात', evidence: 'decision_science_pending_research', domains: ['एंकरिंग', 'फ्रेमिंग', 'हानि से बचाव', 'पुष्टि पक्षपात', 'विकल्प थकान'], focuses: ['पहचान', 'उदाहरण', 'सीमा', 'प्रश्न', 'धीमा निर्णय'] },
  { id: 'social_psychology', title: 'सामाजिक मनोविज्ञान', evidence: 'social_psychology_pending_research', domains: ['मानदंड', 'समूह पहचान', 'सहानुभूति', 'सामाजिक तुलना', 'संचार संकेत'], focuses: ['तंत्र', 'उदाहरण', 'सीमा', 'प्रश्न', 'व्यवहार'] },
  { id: 'brain_plasticity', title: 'मस्तिष्क और न्यूरोप्लास्टिसिटी', evidence: 'neuroscience_pending_research', domains: ['कौशल सीखना', 'मोटर अभ्यास', 'मेमोरी नेटवर्क', 'फीडबैक', 'आराम के बाद समेकन'], focuses: ['तंत्र', 'मापन सीमा', 'अध्ययन', 'उदाहरण', 'सावधानी'] },
  { id: 'mindfulness_meditation', title: 'माइंडफुलनेस और मेडिटेशन', evidence: 'mindfulness_research_pending', domains: ['साँस पर ध्यान', 'बॉडी स्कैन', 'ओपन मॉनिटरिंग', 'करुणा अभ्यास', 'वर्तमान क्षण'], focuses: ['परंपरा', 'वैज्ञानिक अध्ययन', 'सीमा', 'अनुभव', 'अभ्यास'] },
  { id: 'philosophy_meaning', title: 'दर्शन और अर्थ', evidence: 'philosophical_concept_pending_context', domains: ['स्टोइक नियंत्रण', 'अर्थ', 'सद्गुण', 'स्वतंत्र इच्छा', 'अनिश्चितता'], focuses: ['विचार', 'तर्क', 'दैनिक प्रश्न', 'विरोध', 'संदर्भ'] },
  { id: 'spiritual_beliefs', title: 'आध्यात्मिक विश्वास और अभ्यास', evidence: 'belief_or_tradition_pending_clear_label', domains: ['ध्यान परंपराएँ', 'करुणा', 'मौन', 'अनुष्ठान', 'आत्म-परीक्षण'], focuses: ['परंपरा', 'विश्वास', 'अनुभव', 'दर्शन', 'वैज्ञानिक सीमा'] }
];

const angles = ['मिथक और प्रमाण', 'कैसे समझें', 'एक छोटा अभ्यास', 'सामान्य भूल', 'सीमाएँ और सावधानी', 'रोज़मर्रा उदाहरण', 'विज़ुअल मॉडल', 'अध्ययन को पढ़ना', 'जर्नल प्रश्न', 'अगला शोध-सवाल'];
const batchFor = (number) => `Batch_${String(Math.ceil(number / 30)).padStart(3, '0')}`;
const idFor = (number) => String(number).padStart(4, '0');

const reels = [
  {
    reel_id: '0001', batch: 'Batch_001', track: 'habits_behavior', working_title_hi: 'आदत 21 दिन में नहीं, संकेत और दोहराव से बनती है',
    status: 'qc_passed_drive_verified', evidence_status: 'verified',
    drive_folder_id: '1VdOHjx3yba1f6J-x1ZKEJwxLu_nKIFzC',
    drive_file_id: '1CTNcuAZgjpBeMiZD33rRsl6_StfzkzqP',
    source_metadata_file_id: '1RqJY2DrnCtHB0YSAVFbadXpiVJrTtzUd',
    metadata_file_id: '1fLPCiUfN21dGgN_JxA1gc3vROzGsuXWR',
    qc_file_id: '1JetS0w_BlEz2YJGVuSVAIHBNWbMl69Yh',
    caption_file_id: '1blMUq1uVtyaH5odrvVrx_XvhGW8TY7G1',
    script_file_id: '1zplpmLuTg4IEOZqV8IGna46lyTXZSvx-',
    duration_seconds: 56.96,
    visual_route: 'AI editorial visuals assembled as deterministic motion graphics'
  }
];

let number = 2;
outer: for (const track of tracks) {
  for (const domain of track.domains) {
    for (const focus of track.focuses) {
      for (const angle of angles) {
        if (number > 3000) break outer;
        const reelId = idFor(number);
        reels.push({
          reel_id: reelId,
          batch: batchFor(number),
          track: track.id,
          working_title_hi: `${track.title}: ${domain} — ${focus} (${angle})`,
          status: 'planned_research_pending',
          evidence_status: track.evidence,
          required_before_production: ['authoritative_sources_verified', 'claim_classified', 'Hindi_script_fact_checked', 'visual_plan_qc']
        });
        number += 1;
      }
    }
  }
}

if (reels.length !== 3000) throw new Error(`Expected 3000 reels; received ${reels.length}`);
const state = {
  schema_version: '2.0', project: '3000_HINDI_RESEARCH_REELS', language: 'hi-IN',
  storage: { primary: 'Google Drive', root_folder_id: '1Fi466y5laOcSOof7nUta6i9u5Ft3Zwlt', root_folder_name: '3000_HINDI_RESEARCH_REELS', batch_folder_pattern: 'Batch_001 through Batch_100', verified_upload_required: true },
  production_contract: { total_reels: 3000, batches: 100, reels_per_batch: 30, aspect_ratio: '9:16', target_duration_seconds: 60, voice_required: true, captions_required: true, evidence_classification_required: true, raw_terminal_history_policy: 'metadata_only_never_content' },
  tracks: tracks.map(({ id, title, evidence }) => ({ id, title_hi: title, evidence_default: evidence })),
  state: { completed_reels: 1, active_reel: '0002', next_reel: '0002', retry_queue: [], failed_reels: [], last_verified_reel: '0001' },
  reels
};

writeFileSync(resolve(catalogDir, 'reel_registry.json'), JSON.stringify(reels, null, 2) + '\n');
writeFileSync(resolve(catalogDir, 'canonical_production_state.json'), JSON.stringify(state, null, 2) + '\n');
console.log(`Generated canonical registry with ${reels.length} unique reel slots; next reel ${state.state.next_reel}.`);
