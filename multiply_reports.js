// ═══════════════════════════════════════════════════════════════
// MULTIPLY · Reports Module
// ─────────────────────────────────────────────────────────────────
// Single source of truth for member-facing reports. Both the desktop
// dashboard (multiply_dashboard.html) and the mobile leader tool
// (lc_leader_tool.html) load this file and call MultiplyReports.<x>()
// with the same arguments to get the same HTML output. That HTML
// renders well on screen AND prints cleanly to PDF via the browser's
// built-in Print → Save as PDF flow, thanks to embedded @media print
// rules.
//
// PHILOSOPHY
//   - Reports take data IN, return HTML OUT. They never touch the DOM
//     directly except to insert their result into a caller-provided
//     container.
//   - Reports are responsible for: loading their own data from
//     Supabase, applying sensitivity tiers, handling missing data,
//     and providing print-friendly markup.
//   - Reports DO NOT: handle navigation, manage modals, decide what
//     surface they're rendered into. The CALLER decides where it goes.
//
// PUBLIC API
//   MultiplyReports.giftsProfile(memberId, options) → Promise<string>
//
//   options = {
//     tier:       'pastoral' | 'sensitive' | 'public',  // default 'pastoral'
//     context:    'inline' | 'page',                    // default 'inline'
//     showActions: true | false,                        // default true
//     supabase:   <Supabase client>,                    // default: window.db or shared
//   }
//
// USAGE
//   const html = await MultiplyReports.giftsProfile(member.id, {
//     tier: LeaderScope.canSee('pastoral', member) ? 'pastoral' : 'public',
//     context: 'inline',
//     showActions: true
//   });
//   container.innerHTML = html;
//
// PRINTING
//   The caller doesn't need to do anything special. When the user
//   clicks Print in their browser, the @media print CSS kicks in,
//   hides interactive controls (.mr-no-print), and produces a clean
//   document. Print-only elements (.mr-print-only) appear only on
//   paper.
//
// DEPENDENCIES
//   - Optional: window.MultiplyShared (for the Supabase client). If
//     absent, the caller can pass a `supabase` option explicitly.
//
// IMPORTANT: Reports respect sensitivity tiers but do NOT enforce
// authorization on their own. The caller must already have decided
// the viewer is allowed to see the report; reports just adjust the
// visible content based on the declared tier.
// ═══════════════════════════════════════════════════════════════

(function (global) {
  'use strict';

  // ───────────────────────────────────────────────────────────
  // GIFT DEFINITIONS
  // ───────────────────────────────────────────────────────────
  // Embedded reference data for all 16 spiritual gifts. Source of
  // truth lives here; spiritual_gifts_diagnostic.html derives from
  // the same dataset. Keep the two in sync if you ever revise.
  //
  // Each entry has:
  //   id        — lowercase canonical key (matches gifts_diagnostic.primary_gift)
  //   name      — display name (English)
  //   nameTl    — display name (Tagalog) — for future bilingual rendering
  //   emoji     — one-char visual marker
  //   greek     — Greek root + meaning
  //   cluster   — 'word' / 'service' / 'sign' (Romans 12 vs 1 Cor 12)
  //   desc      — full description (English)
  //   descTl    — full description (Tagalog)
  //   scripture — scripture references
  //   examples  — biblical examples
  //   ministries — ministry placement suggestions for this church
  //   items     — question indices in the diagnostic (informational only)

  const GIFTS = [
    {
      id:'leadership', name:'Leadership', nameTl:'Pamumuno', emoji:'⚡',
      greek:'proistemi — to lead, to care for, to stand before',
      cluster:'word',
      desc:'God has given you the ability to motivate and guide others toward a unified goal. You can see where a group needs to go and inspire people to get there together. You are people-oriented in your approach — you build team unity and push others toward completing God\'s work. Leadership differs from Administration in that you focus on the people, not just the task.',
      descTl:'Ipinagkaloob sa iyo ng Diyos ang kakayahang udyukan at gabayan ang iba tungo sa iisang layunin. Nakikita mo kung saan dapat patungo ang grupo at napapakilos mo silang sabay-sabay. Nakatuon ka sa mga tao — nagtatayo ka ng pagkakaisa ng team at nagtutulak sa iba na tapusin ang gawain ng Diyos. Naiiba ang Pamumuno sa Pamamahala dahil ang focus mo ay sa mga tao, hindi lamang sa gawain.',
      scripture:'Romans 12:8 · 1 Timothy 5:17 · Hebrews 13:17',
      examples:'Moses, Joshua',
      ministries:['Life Connect Group Leader','Ministry Team Leader','EOLO Campaign Captain','Sunday School Coordinator','Youth Leadership'],
      items:[6,16,27,43,65]
    },
    {
      id:'administration', name:'Administration', nameTl:'Pamamahala', emoji:'📋',
      greek:'kubernesis — to steer, to pilot, to organize',
      cluster:'word',
      desc:'You have the ability to organize people, resources, and systems to accomplish long-term ministry goals. Like a ship\'s pilot, you keep the team on course and moving forward. You have a strong sense of team purpose and are always looking ahead at what will be most beneficial to the church. Administration partners naturally with Leadership but is more task-oriented.',
      descTl:'May kakayahan kang ayusin ang mga tao, resources, at sistema para makamit ang mga pangmatagalang layunin ng ministry. Tulad ng piloto ng barko, pinapanatili mong nasa tamang ruta at sumusulong ang team. May malakas kang sense ng team purpose at lagi kang tumitingin sa hinaharap kung ano ang pinakamakakabuti sa simbahan. Natural na nakikipag-partner ang Pamamahala sa Pamumuno ngunit mas nakatuon sa gawain.',
      scripture:'1 Corinthians 12:28 · Titus 1:5',
      examples:'Joseph, Nehemiah',
      ministries:['Events Coordination','Church Administration','Ministry Planning Team','Finance Committee','Database & Records'],
      items:[1,17,31,47,59]
    },
    {
      id:'teaching', name:'Teaching', nameTl:'Pagtuturo', emoji:'📖',
      greek:'didasko — to teach, to instruct, to explain doctrine',
      cluster:'word',
      desc:'You have a special ability to communicate biblical truths in ways that strengthen, deepen, and grow the church. Teachers carry a heavy responsibility (James 3:1) to accurately explain what the Bible says, what it means, and how to apply it. You love long hours of Bible study and feel deep satisfaction when you see others grasp and live out God\'s Word.',
      descTl:'May natatanging kakayahan ka na ihatid ang mga katotohanan ng Bibliya sa paraang nagpapatibay, nagpapalalim, at nagpapalago sa simbahan. Mabigat ang responsibilidad ng tagapagturo (Santiago 3:1) na tumpak na ipaliwanag ang sinasabi ng Bibliya, ang kahulugan nito, at kung paano ito ipinapamuhay. Mahilig kang mag-aral ng mahabang oras at malalim ang iyong kasiyahan kapag nakikita mong naiintindihan at isinasabuhay ng iba ang Salita ng Diyos.',
      scripture:'1 Corinthians 12:28 · Romans 12:7 · Ephesians 4:11',
      examples:'Apollos, Paul',
      ministries:['Sunday School Teacher','BTLI Lecturer','Life Connect Facilitator','Children\'s Ministry Teacher','Bible Study Leader'],
      items:[2,18,33,61,73]
    },
    {
      id:'knowledge', name:'Knowledge', nameTl:'Kaalaman', emoji:'🔍',
      greek:'gnosis — knowledge, understanding',
      cluster:'know',
      desc:'God has given you a special ability to discover, understand, and clearly explain great truths from Scripture. Your purpose is to inform and help the church understand God\'s will from His Word. You tend to be well-versed in the Bible and often partner naturally with those who have the gift of Teaching.',
      descTl:'Ipinagkaloob sa iyo ng Diyos ang natatanging kakayahang tumuklas, umunawa, at malinaw na ipaliwanag ang mga dakilang katotohanan mula sa Kasulatan. Ang iyong layunin ay magbigay-kaalaman at tulungan ang simbahan na maunawaan ang kalooban ng Diyos mula sa Kanyang Salita. Karaniwang malalim ka sa Bibliya at natural na nakikipag-partner sa mga may kaloob ng Pagtuturo.',
      scripture:'1 Corinthians 12:28 · Romans 15:14',
      examples:'Ezra, Paul',
      ministries:['Bible Research Team','Theology Study Group','Sermon Preparation Support','Resource Development','Library Ministry'],
      items:[9,24,39,68,79]
    },
    {
      id:'wisdom', name:'Wisdom', nameTl:'Karunungan', emoji:'💡',
      greek:'sophia — deep understanding, practical insight',
      cluster:'know',
      desc:'Wisdom is not just knowing truth — it is knowing how to apply truth to specific people and situations in ways that lead to holiness and worship. Those with this gift can see where a decision or action is heading, making their warnings and counsel extremely valuable. When situations are unclear, it is wise to listen to someone with this gift.',
      descTl:'Ang Karunungan ay hindi lamang pag-alam ng katotohanan — ito ay ang pagkakaroon ng kakayahang ilapat ang katotohanan sa mga tiyak na tao at sitwasyon sa paraang humahantong sa kabanalan at pagsamba. Ang mga may ganitong kaloob ay nakikita kung saan papunta ang isang desisyon o aksyon, kaya napakahalaga ng kanilang babala at payo. Sa hindi malinaw na sitwasyon, matalino na makinig sa may ganitong kaloob.',
      scripture:'1 Corinthians 12:8 · Colossians 1:9–10 · James 3:13–18',
      examples:'Solomon, Daniel',
      ministries:['Pastoral Care Team','Elder / Advisory Role','Pre-marital Counseling Support','Conflict Mediation','Strategic Planning'],
      items:[3,19,48,62,74]
    },
    {
      id:'prophecy', name:'Prophecy', nameTl:'Pagpopropesiya', emoji:'🔥',
      greek:'propheteia — to proclaim, to declare God\'s message',
      cluster:'word',
      desc:'You have the ability to receive a message from God and declare it clearly to others — through preaching, teaching, or direct communication. This is not the same as Old Testament prophecy (writing Scripture), but a fervent declaration of God\'s Word through encouragement, correction, and revealing hidden sin. Everything shared must be tested against Scripture.',
      descTl:'May kakayahan kang tumanggap ng mensahe mula sa Diyos at malinaw na ipahayag ito sa iba — sa pamamagitan ng pangangaral, pagtuturo, o tuwirang pakikipag-usap. Hindi ito katulad ng propesiya sa Lumang Tipan (pagsulat ng Kasulatan), kundi masigasig na pagpapahayag ng Salita ng Diyos sa pamamagitan ng pagpapalakas-loob, pagtutuwid, at paghahayag ng mga lihim na kasalanan. Ang lahat ng ibinabahagi ay dapat suriin sa Kasulatan.',
      scripture:'1 Corinthians 14:29–33 · 1 Thessalonians 5:20–21',
      examples:'Agabus, Philip\'s daughters',
      ministries:['Devotional Preacher','Evangelism Team','Prayer Intercessor','Worship Sharing','Small Group Lead Devotion'],
      items:[10,25,40,54,69]
    },
    {
      id:'discernment', name:'Discernment', nameTl:'Pagkilala / Diskresyon', emoji:'🛡',
      greek:'diakrisis — to evaluate, to distinguish, to judge',
      cluster:'know',
      desc:'You have the ability to judge whether something is from God, from human flesh, or from the enemy. You can recognize inconsistency, false teaching, and spiritual deception that others might miss. This gift protects the church from dangerous influences and is especially important in an era of misinformation and false teaching.',
      descTl:'May kakayahan kang humatol kung ang isang bagay ay galing sa Diyos, sa tao, o sa kaaway. Nakikilala mo ang inconsistency, maling turo, at espirituwal na panlilinlang na maaaring hindi mapansin ng iba. Ang kaloob na ito ay nagpoprotekta sa simbahan mula sa mga mapanganib na impluwensya at lalo nang mahalaga sa panahon ng misinformation at maling turo.',
      scripture:'1 Corinthians 12:10 · Acts 5:3–6 · 1 John 4:1',
      examples:'Peter (with Ananias), Berean believers',
      ministries:['Theology Review Team','Counseling Support','Worship Screening','Guest Speaker Evaluation','Prayer Ministry'],
      items:[11,26,41,55,70]
    },
    {
      id:'exhortation', name:'Encouragement', nameTl:'Pagpapalakas-loob', emoji:'🤝',
      greek:'parakaleo — to call alongside, to strengthen',
      cluster:'care',
      desc:'You are the person who naturally stands beside those who are discouraged and lifts them up. You are gifted at motivating, affirming, and challenging other believers to take action and keep growing. Your goal is to see the church continually strengthen and deepen — and you do it through specific, personal encouragement that moves people forward.',
      descTl:'Ikaw ang taong natural na tumatabi sa mga nasisiraan ng loob at nagpapaangat sa kanila. May kaloob ka sa pag-uudyok, pagpapatibay, at paghamon sa kapwa mananampalataya na kumilos at patuloy na lumago. Ang iyong layunin ay makitang patuloy na nagiging matatag at malalim ang simbahan — at ginagawa mo ito sa pamamagitan ng tiyak at personal na pagpapalakas-loob na nagpapakilos sa mga tao.',
      scripture:'Romans 12:8 · Acts 11:23–24 · Acts 14:21–22',
      examples:'Barnabas, Paul',
      ministries:['Pastoral Care Ministry','Visitation Team','New Member Follow-up','Crisis Support','Mentoring Program'],
      items:[20,34,49,63,75]
    },
    {
      id:'shepherding', name:'Shepherding', nameTl:'Pagpapastol', emoji:'🐑',
      greek:'poimen — shepherd, pastor, caretaker',
      cluster:'care',
      desc:'You carry a deep sense of responsibility for the spiritual welfare of others. Like a shepherd, you protect people from false teaching and harmful influences, feed them through faithful proclamation of Scripture, care for the spiritually sick, and guide those who are wandering. The shepherd\'s role is anchored in humility and sacrificial service.',
      descTl:'May malalim kang pakiramdam ng responsibilidad para sa espirituwal na kapakanan ng iba. Tulad ng pastol, pinoprotektahan mo ang mga tao mula sa mga maling turo at nakakapinsalang impluwensya, pinapakain mo sila sa pamamagitan ng tapat na pangangaral ng Kasulatan, inaalagaan mo ang mga may sakit sa espiritu, at ginagabayan mo ang mga naliligaw. Ang papel ng pastol ay nakaugat sa kababaang-loob at sakripisyong paglilingkod.',
      scripture:'Ephesians 4:11 · Jeremiah 3:15 · John 10:11–18',
      examples:'David, Timothy',
      ministries:['Life Connect Group Leadership','Pastoral Care Team','Follow-up Ministry','Hospital / Prison Visitation','Mentoring / Discipleship'],
      items:[4,21,35,50,76]
    },
    {
      id:'faith', name:'Faith', nameTl:'Pananampalataya', emoji:'⛰',
      greek:'pistis — confidence, trust, assurance',
      cluster:'deed',
      desc:'This is not saving faith — every believer has that. This is a special God-given ability to trust God beyond what seems possible, to believe that God will act even when circumstances say otherwise. The Holy Spirit uses people with this gift to build the church\'s confidence in God. They expect God to show up and are never surprised when He does something extraordinary.',
      descTl:'Hindi ito ang nagliligtas na pananampalataya — taglay ito ng bawat mananampalataya. Ito ay natatanging kakayahang ibinigay ng Diyos para magtiwala sa Kanya nang higit sa tila posible, na maniwalang kikilos ang Diyos kahit ang sitwasyon ay nagsasabi ng iba. Ginagamit ng Banal na Espiritu ang mga may kaloob na ito para palakasin ang tiwala ng simbahan sa Diyos. Inaasahan nilang gagawa ang Diyos at hindi sila nagugulat kapag may ginagawa Siyang pambihira.',
      scripture:'1 Corinthians 12:9 · Hebrews 11:1–40',
      examples:'Abraham, George Müller',
      ministries:['Prayer Ministry','Mission Team','Church Planting Support','Vision Casting Team','Intercession Ministry'],
      items:[12,28,42,56,80]
    },
    {
      id:'evangelism', name:'Evangelism', nameTl:'Pag-eebanghelyo', emoji:'🌏',
      greek:'euaggelistes — bringer of Good News',
      cluster:'deed',
      desc:'While all believers are called to share the gospel, some have a special measure of faith and effectiveness in this area. You have a unique ability to communicate the gospel clearly, you feel a deep burden for those who don\'t know Jesus, you are not easily discouraged by rejection, and you naturally connect with people from all walks of life.',
      descTl:'Bagama\'t ang lahat ng mananampalataya ay tinawag para ibahagi ang ebanghelyo, may iilan na may natatanging sukat ng pananampalataya at pagiging epektibo sa bahaging ito. May kakayahan kang malinaw na ibahagi ang ebanghelyo, may malalim kang pasanin para sa mga hindi pa kilala si Hesus, hindi ka madaling masisiraan ng loob sa pagtanggi, at natural kang nakakakonekta sa mga taong galing iba\'t ibang antas ng buhay.',
      scripture:'Ephesians 4:11 · Acts 8:5–12 · Matthew 28:18–20',
      examples:'Philip, Billy Graham',
      ministries:['EOLO Campaign Leadership','EGR Evangelism Retreat Team','Outreach Ministry','Campus Ministry','Street Evangelism'],
      items:[5,36,51,64,77]
    },
    {
      id:'apostleship', name:'Apostleship', nameTl:'Pagiging Apostol', emoji:'🚀',
      greek:'apostolos — one sent out, a pioneer',
      cluster:'deed',
      desc:'The office of Apostle ended with the original twelve, but the gift continues in a different way. Those with this gift are called to pioneer new ministries, reach unreached places, develop church leaders, and take the gospel where it has not yet gone. They are leaders of leaders — entrepreneurial, risk-taking, and able to hold many responsibilities at once.',
      descTl:'Natapos na ang opisyo ng Apostol sa orihinal na labindalawa, ngunit nagpapatuloy ang kaloob sa ibang paraan. Ang mga may ganitong kaloob ay tinawag para magpasimula ng mga bagong ministry, abutin ang mga lugar na hindi pa naaabot, magpaunlad ng mga lider ng simbahan, at dalhin ang ebanghelyo kung saan hindi pa ito nakakarating. Sila ay mga lider ng mga lider — entrepreneurial, mapangahas, at may kakayahang humawak ng maraming responsibilidad nang sabay-sabay.',
      scripture:'Ephesians 4:11 · 1 Corinthians 12:28 · Acts 1:21–22',
      examples:'Paul, Barnabas',
      ministries:['Church Planting Team','Missions Ministry','New Ministry Launch','Cross-Cultural Outreach','Leadership Development'],
      items:[13,29,44,57,71]
    },
    {
      id:'service', name:'Service / Helps', nameTl:'Paglilingkod / Pagtulong', emoji:'🛠',
      greek:'diakonia / antilepsis — to serve, to assist, to help',
      cluster:'deed',
      desc:'This gift has the broadest application of all. You energize the church by making sure everything gets done so that others can use their gifts fully. You serve out of genuine love — not for recognition. You are the backbone of ministry. Without people with this gift, every ministry would struggle. Service is the heart and foundation of all spiritual gifts.',
      descTl:'Ang kaloob na ito ay may pinakamalawak na aplikasyon sa lahat. Nakakapagpalakas ka sa simbahan dahil sa pagtitiyak na natatapos ang lahat ng bagay para magamit ng iba ang kanilang mga kaloob nang lubusan. Naglilingkod ka mula sa tunay na pag-ibig — hindi para sa pagkilala. Ikaw ang gulugod ng ministry. Kung wala ang mga taong may ganitong kaloob, ang bawat ministry ay magkakaproblema. Ang Paglilingkod ang puso at pundasyon ng lahat ng mga kaloob na espirituwal.',
      scripture:'Romans 12:7 · Acts 6:1–7 · Mark 10:42–45',
      examples:'Martha, Timothy, the seven deacons',
      ministries:['Events Crew','Media & Tech Support','Facility Team','Worship Support','Children\'s Ministry Volunteer'],
      items:[14,30,46,58,72]
    },
    {
      id:'mercy', name:'Mercy', nameTl:'Awa / Habag', emoji:'💙',
      greek:'eleos — compassion, pity, kindness',
      cluster:'care',
      desc:'Everyone should be merciful, but you have an extraordinary patience and compassion for those who are suffering. You can support people through long-term trials without burning out. You become the hands and feet of Jesus for those who are burdened. You are highly sensitive to others\' needs — you know when someone is not okay even before they say it.',
      descTl:'Lahat ay dapat maawain, ngunit may pambihira kang pasensya at habag para sa mga nagdurusa. Kaya mong samahan ang mga tao sa pangmatagalang pagsubok nang hindi natatabunan. Nagiging kamay at paa ka ni Hesus para sa mga pinapasanan. Sensitibo ka sa pangangailangan ng iba — alam mo kapag hindi okay ang isang tao kahit hindi pa nila sinasabi.',
      scripture:'Romans 12:8 · Matthew 5:7 · Luke 10:30–37',
      examples:'John the Beloved, the Good Samaritan',
      ministries:['Pastoral Care Ministry','Hospital / Prison Visitation','Crisis Counseling Support','Special Needs Ministry','Grief Care Team'],
      items:[7,22,37,52,66]
    },
    {
      id:'giving', name:'Giving', nameTl:'Pagbibigay', emoji:'🎁',
      greek:'metadidomi / haplotes — to share generously, with pure motives',
      cluster:'deed',
      desc:'Your giving is not just financial — it is wholehearted, openhanded, and pure in motivation. God uses you to meet the needs of churches, ministries, missionaries, and individuals who cannot fully provide for themselves. You are an excellent steward. You find deep joy when someone shares a need with you because you get to be a channel of God\'s blessing.',
      descTl:'Ang iyong pagbibigay ay hindi lamang pinansyal — buong-puso, bukas-palad, at dalisay ang motibasyon. Ginagamit ka ng Diyos para tugunan ang mga pangangailangan ng mga simbahan, ministry, missionary, at mga taong hindi lubusang makapagbibigay para sa kanilang sarili. Mahusay kang katiwala. Malalim ang iyong kagalakan kapag may nagbabahagi sa iyo ng pangangailangan dahil nagiging daluyan ka ng pagpapala ng Diyos.',
      scripture:'Romans 12:8,13 · 2 Corinthians 8:1–5 · Acts 4:32–37',
      examples:'Matthew, Barnabas, Lydia',
      ministries:['Stewardship Ministry','Missions Giving Team','Benevolence Fund','Resource Coordination','Financial Counseling Support'],
      items:[8,23,38,53,67]
    },
    {
      id:'hospitality', name:'Hospitality', nameTl:'Mapagpatuloy', emoji:'🏠',
      greek:'philoxenos — love of strangers, welcoming the guest',
      cluster:'care',
      desc:'You have a special ability to make anyone feel welcome, comfortable, and at home. You open your house, your table, and your heart without hesitation. You ensure that every visitor to the church feels like they belong. When there is tension in a room, you often become the peacemaker. You are not afraid to care for strangers.',
      descTl:'May natatanging kakayahan kang ipadama sa kahit sino na sila ay tinatanggap, komportable, at nasa kanilang tahanan. Bukas mong binubuksan ang iyong bahay, iyong mesa, at iyong puso nang walang pag-aalinlangan. Sinisigurado mong ang bawat bisita sa simbahan ay nakakaramdam na sila ay kabilang. Kapag may tensyon sa isang silid, ikaw madalas ang nagiging tagapamayapa. Hindi ka natatakot sa pag-aalaga ng mga estranghero.',
      scripture:'Romans 12:9–13 · Romans 16:23 · 1 Peter 4:9 · Hebrews 13:1–2',
      examples:'Lydia, Martha, Phoebe',
      ministries:['Welcome / Greeter Team','Church Events Hosting','Small Group Hosting','New Member Reception','Merienda / Meal Ministry'],
      items:[15,32,45,60,78]
    }
  ];


  // Lookup map for O(1) access by ID
  const GIFTS_BY_ID = {};
  GIFTS.forEach(g => { GIFTS_BY_ID[g.id] = g; });

  // ───────────────────────────────────────────────────────────
  // PRINT-AWARE CSS
  // ───────────────────────────────────────────────────────────
  // Injected once on first report render. Keeps inline reports
  // looking right on screen AND producing clean printed output.
  let _stylesInjected = false;
  function ensureStyles() {
    if (_stylesInjected) return;
    _stylesInjected = true;
    const style = document.createElement('style');
    style.id = 'multiply-reports-styles';
    style.textContent = `
      /* ─── Multiply Reports — shared styles ─── */
      .mr-report { font-family: 'DM Sans', system-ui, sans-serif; color: #1a1612; }
      .mr-report * { box-sizing: border-box; }
      .mr-section { margin-bottom: 1.25rem; }
      .mr-section-label {
        font-size: 10px; letter-spacing: .12em; text-transform: uppercase;
        color: #6b5f4f; font-weight: 700; margin-bottom: .55rem;
      }
      .mr-card {
        background: #f5efe3; border: 1px solid #e2d8cc; border-radius: 8px;
        padding: 1rem; margin-bottom: 1rem;
      }
      .mr-card-tinted {
        background: #e8f1ec; border: 1px solid rgba(42,92,64,.2);
        border-radius: 8px; padding: .9rem 1.1rem; margin-bottom: 1rem;
      }
      .mr-top3 {
        display: grid; grid-template-columns: 1fr 1fr 1fr;
        gap: 8px; margin-bottom: 1rem;
      }
      @media (max-width: 480px) {
        .mr-top3 { grid-template-columns: 1fr; }
      }
      .mr-top3-card {
        background: #f5ebd6; border: 1px solid rgba(184,136,42,.25);
        border-radius: 8px; padding: .9rem .65rem; text-align: center;
      }
      .mr-top3-card.mr-secondary { background: #e8f1ec; border-color: rgba(42,92,64,.2); }
      .mr-top3-card.mr-supporting { background: #eaf0f5; border-color: rgba(60,90,140,.2); }
      .mr-top3-rank {
        font-size: 9px; letter-spacing: .1em; text-transform: uppercase;
        font-weight: 700; margin-bottom: 4px; color: #b8882a;
      }
      .mr-secondary .mr-top3-rank { color: #2a5c40; }
      .mr-supporting .mr-top3-rank { color: #3c5a8c; }
      .mr-top3-emoji { font-size: 26px; line-height: 1.1; margin: 2px 0; }
      .mr-top3-name { font-size: 13px; font-weight: 700; color: #1a1612; }
      .mr-top3-greek {
        font-size: 10.5px; color: #6b5f4f; margin-top: 3px;
        font-style: italic; line-height: 1.4;
      }
      .mr-bar-row {
        display: flex; align-items: center; gap: 9px; margin-bottom: 5px;
        page-break-inside: avoid;
      }
      .mr-bar-label {
        font-size: 12px; color: #1a1612; min-width: 145px; line-height: 1.3;
      }
      .mr-bar-label.mr-strong { font-weight: 700; }
      .mr-bar-track {
        flex: 1; height: 14px; background: #f5efe3; border: 1px solid #e2d8cc;
        border-radius: 3px; overflow: hidden; min-width: 60px;
      }
      .mr-bar-fill { height: 100%; border-radius: 3px; transition: width .4s; }
      .mr-bar-fill.mr-high { background: #2a5c40; }
      .mr-bar-fill.mr-mid  { background: #b8882a; }
      .mr-bar-fill.mr-low  { background: #9b8e7e; }
      .mr-bar-num {
        font-size: 11px; font-weight: 700; color: #6b5f4f;
        min-width: 36px; text-align: right;
      }
      .mr-gift-detail {
        background: #fff; border: 1px solid #e2d8cc; border-radius: 8px;
        padding: 1rem; margin-bottom: .75rem; page-break-inside: avoid;
      }
      .mr-gift-detail-head {
        display: flex; align-items: center; gap: 10px; margin-bottom: .5rem;
      }
      .mr-gift-detail-emoji { font-size: 24px; }
      .mr-gift-detail-name {
        font-size: 15px; font-weight: 700; color: #1a1612;
      }
      .mr-gift-detail-greek {
        font-size: 11px; color: #6b5f4f; font-style: italic;
        margin-top: 2px;
      }
      .mr-gift-detail-desc {
        font-size: 12.5px; color: #2a2620; line-height: 1.6; margin-bottom: .65rem;
      }
      .mr-meta-grid {
        display: grid; grid-template-columns: 1fr 1fr; gap: 8px;
        font-size: 11.5px; line-height: 1.5;
      }
      @media (max-width: 480px) {
        .mr-meta-grid { grid-template-columns: 1fr; }
      }
      .mr-meta-label {
        font-size: 9px; letter-spacing: .08em; text-transform: uppercase;
        font-weight: 700; color: #6b5f4f; margin-bottom: 2px;
      }
      .mr-ministry-list { list-style: none; padding: 0; margin: 0; }
      .mr-ministry-list li {
        padding: 7px 0; border-bottom: 1px solid #f0e8db;
        font-size: 12.5px; color: #1a1612;
        display: flex; align-items: center; gap: 8px;
      }
      .mr-ministry-list li:last-child { border-bottom: none; }
      .mr-ministry-rank {
        font-size: 9px; font-weight: 700; padding: 2px 8px; border-radius: 10px;
        background: #f5ebd6; color: #b8882a;
      }
      .mr-ministry-rank.mr-good { background: #e8f1ec; color: #2a5c40; }
      .mr-empty {
        text-align: center; padding: 2rem 1rem; color: #6b5f4f;
      }
      .mr-empty-emoji { font-size: 36px; margin-bottom: .5rem; opacity: .5; }
      .mr-empty-title {
        font-size: 14px; font-weight: 600; color: #1a1612; margin-bottom: .35rem;
      }
      .mr-empty-msg {
        font-size: 12.5px; line-height: 1.55; max-width: 360px; margin: 0 auto;
      }
      .mr-redacted {
        background: #f5efe3; border: 1.5px dashed #d8c8a6; border-radius: 8px;
        padding: 1.25rem 1rem; text-align: center;
      }
      .mr-redacted-emoji { font-size: 28px; margin-bottom: .4rem; }
      .mr-redacted-title {
        font-size: 13px; font-weight: 700; color: #1a1612; margin-bottom: .3rem;
      }
      .mr-redacted-msg {
        font-size: 11.5px; color: #6b5f4f; line-height: 1.55;
        max-width: 340px; margin: 0 auto;
      }
      .mr-actions {
        display: flex; gap: 8px; flex-wrap: wrap;
        margin-top: 1rem; padding-top: 1rem; border-top: 1px solid #e2d8cc;
      }
      .mr-btn {
        font-family: inherit; font-size: 12px; font-weight: 600;
        padding: 7px 14px; border-radius: 6px; cursor: pointer;
        border: 1.5px solid #e2d8cc; background: #f5efe3; color: #1a1612;
      }
      .mr-btn-primary {
        background: #2a5c40; color: #fff; border-color: #2a5c40;
      }
      .mr-footer-meta {
        font-size: 10.5px; color: #9b8e7e; text-align: center;
        margin-top: 1.25rem; padding-top: .75rem; border-top: 1px solid #e2d8cc;
        line-height: 1.5;
      }
      .mr-print-only { display: none; }

      /* ─── Print mode ─── */
      @media print {
        .mr-report {
          color: #000 !important;
          font-size: 11pt;
          line-height: 1.45;
        }
        .mr-no-print { display: none !important; }
        .mr-print-only { display: block !important; }
        .mr-card, .mr-card-tinted, .mr-gift-detail {
          break-inside: avoid; page-break-inside: avoid;
          background: #fff !important;
          border: 1px solid #888 !important;
        }
        .mr-section { break-inside: avoid-page; }
        .mr-bar-fill.mr-high { background: #444 !important; }
        .mr-bar-fill.mr-mid  { background: #777 !important; }
        .mr-bar-fill.mr-low  { background: #aaa !important; }
        .mr-top3-card {
          background: #f5f5f5 !important; border: 1px solid #888 !important;
        }
        .mr-actions { display: none !important; }
        .mr-section-label, .mr-meta-label { color: #444 !important; }
      }
    `;
    document.head.appendChild(style);
  }

  // ───────────────────────────────────────────────────────────
  // HELPERS
  // ───────────────────────────────────────────────────────────
  function escapeHTML(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, c => (
      {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]
    ));
  }
  function getDB(opts) {
    if (opts && opts.supabase) return opts.supabase;
    if (global.MultiplyShared && global.MultiplyShared.getDB) {
      return global.MultiplyShared.getDB();
    }
    if (global.db) return global.db;
    return null;
  }
  function fmtDate(s) {
    if (!s) return '—';
    try {
      return new Date(s).toLocaleDateString('en-PH', {
        year: 'numeric', month: 'short', day: 'numeric'
      });
    } catch (e) { return s; }
  }

  // ───────────────────────────────────────────────────────────
  // REPORT: giftsProfile
  // ───────────────────────────────────────────────────────────
  // Loads the most recent gifts_diagnostic row for the member,
  // renders Top 3 cards, full 16-gift ranking, per-gift detail
  // for the top 3 (with description, scripture, examples), and
  // ministry placement suggestions.
  //
  // Returns a Promise<string> of complete report HTML, ready to
  // insert into any container.
  async function giftsProfile(memberId, opts) {
    ensureStyles();
    opts = Object.assign({
      tier: 'pastoral',
      context: 'inline',
      showActions: true,
    }, opts || {});

    if (!memberId) return _emptyState('No member selected.');

    // Sensitivity gate — if the caller is below the pastoral tier,
    // we redact entirely. Above 'pastoral', full content.
    if (opts.tier === 'public') {
      return _redactedState(
        'Spiritual gift results are visible to leaders within the member\'s discipleship tree.'
      );
    }

    // Fetch
    const db = getDB(opts);
    if (!db) {
      return _errorState('Database client not available. Caller must provide MultiplyShared, window.db, or opts.supabase.');
    }

    let memberRow = null;
    let giftsRow = null;
    try {
      const memberRes = await db.from('members')
        .select('id,name,pipeline_level,lc_group,ministry,ministry2,ministry3')
        .eq('id', memberId).maybeSingle();
      memberRow = memberRes.data || null;

      const giftsRes = await db.from('gifts_diagnostic').select('*')
        .eq('member_id', memberId)
        .order('date_taken', { ascending: false })
        .limit(1).maybeSingle();
      giftsRow = giftsRes.data || null;
    } catch (e) {
      return _errorState('Could not load gift data: ' + (e.message || e));
    }

    if (!memberRow) {
      return _emptyState('Member not found.');
    }

    if (!giftsRow) {
      return _noDataState(memberRow, opts);
    }

    return _renderFullReport(memberRow, giftsRow, opts);
  }

  function _renderFullReport(member, gifts, opts) {
    const scores = gifts.all_scores || {};
    // Sort by score desc; fall back to canonical order if scores missing
    const ranked = Object.entries(scores)
      .map(([id, score]) => ({ id, score: Number(score) || 0 }))
      .sort((a, b) => b.score - a.score);

    const maxScore = 25; // diagnostic rubric: 5 questions × max 5 each = 25 per gift
    const top3 = ranked.slice(0, 3);

    const generatedAt = new Date().toLocaleString('en-PH', {
      year: 'numeric', month: 'short', day: 'numeric',
      hour: 'numeric', minute: '2-digit'
    });

    const ministries = [gifts.ministry_match_1, gifts.ministry_match_2, gifts.ministry_match_3]
      .filter(Boolean);

    let html = '<div class="mr-report">';

    // Print-only header
    html += '<div class="mr-print-only" style="text-align:center;margin-bottom:1rem;padding-bottom:.75rem;border-bottom:2px solid #444">';
    html += '<div style="font-size:14pt;font-weight:700">Spiritual Gifts Profile</div>';
    html += '<div style="font-size:10pt;color:#444">' + escapeHTML(member.name) + ' · Rosehill Christian Church</div>';
    html += '</div>';

    // Member context card
    html += '<div class="mr-card-tinted mr-section">';
    html += '<div class="mr-section-label">Spiritual Gifts Profile</div>';
    html += '<div style="font-size:15px;font-weight:700;color:#1a1612">' + escapeHTML(member.name) + '</div>';
    const memberMeta = [];
    if (member.lc_group) memberMeta.push(escapeHTML(member.lc_group));
    if (member.ministry) memberMeta.push(escapeHTML(member.ministry));
    memberMeta.push('Taken ' + fmtDate(gifts.date_taken));
    html += '<div style="font-size:11.5px;color:#6b5f4f;margin-top:3px">' + memberMeta.join(' · ') + '</div>';
    html += '</div>';

    // Top 3 cards
    if (top3.length) {
      html += '<div class="mr-section">';
      html += '<div class="mr-section-label">Top 3 Gifts</div>';
      html += '<div class="mr-top3">';
      const rankClasses = ['', 'mr-secondary', 'mr-supporting'];
      const rankLabels = ['Primary Gift', 'Secondary Gift', 'Supporting Gift'];
      top3.forEach((entry, i) => {
        const def = GIFTS_BY_ID[entry.id];
        if (!def) return;
        html += '<div class="mr-top3-card ' + rankClasses[i] + '">';
        html += '<div class="mr-top3-rank">' + rankLabels[i] + '</div>';
        html += '<div class="mr-top3-emoji">' + def.emoji + '</div>';
        html += '<div class="mr-top3-name">' + escapeHTML(def.name) + '</div>';
        html += '<div class="mr-top3-greek">' + escapeHTML(def.greek.split(' — ')[0] || def.greek) + '</div>';
        html += '<div style="font-size:10.5px;color:#6b5f4f;margin-top:5px;font-weight:600">' + entry.score + ' / ' + maxScore + '</div>';
        html += '</div>';
      });
      html += '</div>';
      html += '</div>';
    }

    // Top 3 detailed cards (description, scripture, examples)
    if (top3.length) {
      html += '<div class="mr-section">';
      html += '<div class="mr-section-label">What These Gifts Mean</div>';
      top3.forEach((entry, i) => {
        const def = GIFTS_BY_ID[entry.id];
        if (!def) return;
        html += '<div class="mr-gift-detail">';
        html += '<div class="mr-gift-detail-head">';
        html += '<div class="mr-gift-detail-emoji">' + def.emoji + '</div>';
        html += '<div>';
        html += '<div class="mr-gift-detail-name">' + escapeHTML(def.name) + '</div>';
        html += '<div class="mr-gift-detail-greek">' + escapeHTML(def.greek) + '</div>';
        html += '</div></div>';
        html += '<div class="mr-gift-detail-desc">' + escapeHTML(def.desc) + '</div>';
        html += '<div class="mr-meta-grid">';
        html += '<div><div class="mr-meta-label">Key Scripture</div>' + escapeHTML(def.scripture) + '</div>';
        html += '<div><div class="mr-meta-label">Biblical Example</div>' + escapeHTML(def.examples) + '</div>';
        html += '</div>';
        html += '</div>';
      });
      html += '</div>';
    }

    // All 16 ranked
    if (ranked.length) {
      html += '<div class="mr-section">';
      html += '<div class="mr-section-label">All 16 Gifts — Ranked</div>';
      ranked.forEach(entry => {
        const def = GIFTS_BY_ID[entry.id];
        if (!def) return;
        const pct = Math.min(100, Math.round((entry.score / maxScore) * 100));
        const tone = entry.score >= 18 ? 'mr-high' : (entry.score >= 12 ? 'mr-mid' : 'mr-low');
        const labelStrong = entry.score >= 18 ? 'mr-strong' : '';
        html += '<div class="mr-bar-row">';
        html += '<div class="mr-bar-label ' + labelStrong + '">' + def.emoji + ' ' + escapeHTML(def.name) + '</div>';
        html += '<div class="mr-bar-track"><div class="mr-bar-fill ' + tone + '" style="width:' + pct + '%"></div></div>';
        html += '<div class="mr-bar-num">' + entry.score + '/' + maxScore + '</div>';
        html += '</div>';
      });
      html += '</div>';
    }

    // Ministry placement suggestions
    if (ministries.length) {
      html += '<div class="mr-section">';
      html += '<div class="mr-section-label">Recommended Ministry Placements</div>';
      html += '<ul class="mr-ministry-list">';
      ministries.forEach((m, i) => {
        const rankCls = i === 0 ? '' : 'mr-good';
        const rankLabel = i === 0 ? 'Primary' : 'Good fit';
        html += '<li>';
        html += '<span class="mr-ministry-rank ' + rankCls + '">' + rankLabel + '</span>';
        html += '<span>' + escapeHTML(m) + '</span>';
        html += '</li>';
      });
      html += '</ul>';
      html += '</div>';
    }

    // Footer (timestamp)
    html += '<div class="mr-footer-meta">';
    html += 'Generated ' + escapeHTML(generatedAt);
    html += ' · Rosehill Christian Church · MULTIPLY';
    html += '</div>';

    // Actions (hidden in print)
    if (opts.showActions) {
      html += '<div class="mr-actions mr-no-print">';
      html += '<button class="mr-btn mr-btn-primary" onclick="window.print()">📄 Print / Save as PDF</button>';
      html += '<button class="mr-btn" onclick="MultiplyReports.copyGiftsLink(\'' + escapeHTML(member.id) + '\')">🔗 Copy Retake Link</button>';
      html += '</div>';
    }

    html += '</div>'; // /.mr-report
    return html;
  }

  function _noDataState(member, opts) {
    let html = '<div class="mr-report">';
    html += '<div class="mr-empty">';
    html += '<div class="mr-empty-emoji">🎁</div>';
    html += '<div class="mr-empty-title">No Gifts Diagnostic taken yet</div>';
    html += '<div class="mr-empty-msg">' + escapeHTML(member.name) + ' hasn\'t completed the spiritual gifts assessment. Send them the link to get started — it takes about 15 minutes.</div>';
    if (opts.showActions !== false) {
      html += '<div class="mr-actions mr-no-print" style="justify-content:center;border:none;padding-top:1rem">';
      html += '<button class="mr-btn mr-btn-primary" onclick="MultiplyReports.copyGiftsLink(\'' + escapeHTML(member.id) + '\')">📋 Copy Diagnostic Link</button>';
      html += '</div>';
    }
    html += '</div></div>';
    return html;
  }

  function _emptyState(msg) {
    return '<div class="mr-report"><div class="mr-empty">' +
      '<div class="mr-empty-emoji">🎁</div>' +
      '<div class="mr-empty-msg">' + escapeHTML(msg) + '</div>' +
      '</div></div>';
  }

  function _redactedState(msg) {
    ensureStyles();
    return '<div class="mr-report"><div class="mr-redacted">' +
      '<div class="mr-redacted-emoji">🔒</div>' +
      '<div class="mr-redacted-title">Gift Profile Hidden</div>' +
      '<div class="mr-redacted-msg">' + escapeHTML(msg) + '</div>' +
      '</div></div>';
  }

  function _errorState(msg) {
    ensureStyles();
    return '<div class="mr-report"><div class="mr-empty">' +
      '<div class="mr-empty-emoji">⚠️</div>' +
      '<div class="mr-empty-title">Could not load report</div>' +
      '<div class="mr-empty-msg">' + escapeHTML(msg) + '</div>' +
      '</div></div>';
  }

  // ───────────────────────────────────────────────────────────
  // Convenience: copy a fresh diagnostic link for a member
  // ───────────────────────────────────────────────────────────
  function copyGiftsLink(memberId) {
    const url = 'https://gejable1.github.io/multiply/spiritual_gifts_diagnostic.html?id=' + memberId;
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(url).then(
        () => _toast('🔗 Diagnostic link copied'),
        () => _toast('⚠ Copy failed — link: ' + url)
      );
    } else {
      // Fallback for older browsers
      const ta = document.createElement('textarea');
      ta.value = url; ta.style.position='fixed'; ta.style.opacity='0';
      document.body.appendChild(ta); ta.select();
      try { document.execCommand('copy'); _toast('🔗 Diagnostic link copied'); }
      catch(e){ _toast('⚠ Copy failed'); }
      document.body.removeChild(ta);
    }
  }

  function _toast(msg) {
    const t = document.createElement('div');
    t.textContent = msg;
    t.style.cssText = 'position:fixed;left:50%;top:24px;transform:translateX(-50%);' +
      'background:#1f4530;color:#fff;padding:10px 18px;border-radius:8px;' +
      'font-family:DM Sans,sans-serif;font-size:13px;font-weight:600;' +
      'box-shadow:0 8px 24px rgba(0,0,0,.18);z-index:99999;';
    document.body.appendChild(t);
    setTimeout(() => t.remove(), 2200);
  }

  // ───────────────────────────────────────────────────────────
  // Public API
  // ───────────────────────────────────────────────────────────
  global.MultiplyReports = {
    giftsProfile,
    copyGiftsLink,
    // Exposed for advanced callers / inspection — treat as read-only.
    _GIFTS: GIFTS,
    _GIFTS_BY_ID: GIFTS_BY_ID,
  };

})(typeof window !== 'undefined' ? window : globalThis);
