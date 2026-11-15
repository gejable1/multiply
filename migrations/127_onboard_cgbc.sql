-- migrations/127_onboard_cgbc.sql
-- Onboard a new tenant church: Canlubang Grace Baptist Church (slug 'cgbc')
-- + its L5 pastor Symphony Don Alambat (member_pin_hash NULL -> first-login set_pin),
-- + preload the November 2026 devotional guide (Ephesians, 25 days: Nov 2-30, no Sundays)
--   as church-OWNED copies (Model A, per-church; Inv #208 / mig 025 / 052).
--   Parsed with devotional_admin.html's own parser from RCC_Devotional_Guide_2026-11_Ephesians.docx.
--   author = 'Rosehill Christian Church' (credit Rosehill, no personal name - Pastor, Oct 29).
-- Mirrors 124: church_id supplied explicitly so trg_set_church_id won't clobber.
-- No new tables (no GRANTs needed). FLAT (#209), idempotent, ledger (#212), self-verify.

-- (1) church
insert into churches (name, slug, timezone) values
  ('Canlubang Grace Baptist Church', 'cgbc', 'Asia/Manila')
on conflict (slug) do nothing;

-- (2) L5 pastor - fresh row, NULL pin (first-login set_pin), inserted only if absent
insert into members (name, pipeline_level, church_id, is_external_user, is_test_member, is_platform_admin, share_with_lc)
select 'Symphony Don Alambat', 5, c.id, false, false, false, true
from churches c
where c.slug = 'cgbc'
  and not exists (
    select 1 from members m where m.name = 'Symphony Don Alambat' and m.church_id = c.id
  );

-- (3) November 2026 devotional guide - church-owned copy; never overwrites an existing day
insert into public.devotionals
  (church_id, entry_date, title, scripture_ref, source_note, scripture_text,
   story, explanation, response, prayer, weekly_summary, author)
select c.id, v.entry_date, v.title, v.scripture_ref, v.source_note, v.scripture_text,
       v.story, v.explanation, v.response, v.prayer, v.weekly_summary, 'Rosehill Christian Church'
from churches c
cross join (values
  (DATE '2026-11-02',
   $d$Picked Before You Were Even Born$d$,
   $d$Ephesians 1:1–6 (BSB)$d$,
   NULL,
   $d$1Paul, an apostle of Christ Jesus by the will of God, To the saints in Ephesus, the faithful in Christ Jesus: 2Grace and peace to you from God our Father and the Lord Jesus Christ. 3Blessed be the God and Father of our Lord Jesus Christ, who has blessed us in Christ with every spiritual blessing in the heavenly realms. 4For He chose us in Him before the foundation of the world to be holy and blameless in His presence. In love 5He predestined us for adoption as His sons through Jesus Christ, according to the good pleasure of His will, 6to the praise of His glorious grace, which He has freely given us in the Beloved One.$d$,
   $d$Rhea was fifteen when she found the folder. She was looking for her birth certificate for a school requirement, digging through the plastic envelope her mother kept under the clothes in the aparador. Instead, she found papers with words she didn't understand at first: "Decree of Adoption." Her name was there. So were the names of two strangers.

She sat on the floor for a long time.

When her mother, Gloria, came home from the carinderia where she cooked every day, Rhea was waiting at the table with the folder in front of her. Her father, Nestor, followed a few minutes later, still smelling of rubber and grease from the vulcanizing shop.

"Why didn't you tell me?" Rhea's voice cracked. "So I'm not really yours."

Gloria sat down slowly. Nestor put a hand on her shoulder. For a moment, no one spoke. Then Gloria stood up, went to the old cabinet, and came back with a small box.

Inside were a tiny pair of knitted booties, a baby bottle still in its packaging, and a notebook. On the first page, in her mother's careful handwriting, was a date three years before Rhea was born.

"We waited for a child for eight years," Gloria said. "When we decided to adopt, I started buying things. Booties. A blanket. I wrote your name before I ever saw your face. Every day, I wrote a letter to the daughter I hadn't met yet."

Rhea flipped through the pages. Hundreds of letters. "Anak, today Papa painted your room." "Anak, I wonder what your laugh will sound like."

"We didn't get stuck with you," Nestor said softly. "We chose you. And we would choose you again every single day."

Rhea closed the notebook and leaned into her mother's arms. She had come to the table feeling like an outsider. She left it knowing she had been wanted long before she ever knew it.$d$,
   $d$Paul opens his letter to the Ephesians with a burst of praise. In the original Greek, verses 3 to 14 form one long, breathless sentence, as if Paul is so excited he can't stop to take a breath. Today we look at the first part of it.

He begins by reminding us that God "has blessed us in Christ with every spiritual blessing in the heavenly realms" (v. 3). Notice the words "has blessed." These blessings are not something we are still waiting to earn. If you belong to Jesus, they are already yours.

What is the first blessing on Paul's list? "He chose us in Him before the foundation of the world" (v. 4). Before God made the sun, the mountains, or the first human being, He had you in mind. Your salvation was not an afterthought or a lucky accident. And God chose us for a purpose: "to be holy and blameless in His presence." He is not only saving us from something; He is shaping us into something.

Then Paul says God "predestined us for adoption as His sons through Jesus Christ" (v. 5). In Roman times, an adopted son received full rights as an heir. He was not a servant in the house; he was family. That is what God has done for us.

Why would God do this? Paul says it was "according to the good pleasure of His will" (v. 5). God wasn't forced. He wanted to. And the result is "the praise of His glorious grace" (v. 6).

If you have ever felt unwanted, overlooked, or second-best, this passage speaks directly to you. In Christ, you are chosen, adopted, and deeply loved.$d$,
   $d$This passage teaches me that I am not an accident or an afterthought. Before the world was made, God chose me in Christ. He didn't pick me because I was impressive or because He saw something useful in me. He chose me in love, simply because it pleased Him.

That truth humbles me. So many times I have tried to earn a place in my family, among my friends, even in church. I have measured my worth by what others say about me. But God has already settled the question. I am adopted. I am His child. I belong.

Knowing that I was chosen to be holy and blameless, I should stop treating holiness as a burden and start seeing it as part of my new family identity. Children often grow to resemble their parents, and I want to grow to resemble my heavenly Father.

Because of His grace, I will strive to live like someone who is secure. I will not beg for approval that I already have. This week, I will thank God every morning that I am His, and I will look for one person who feels unwanted and show them the same welcome God has shown me.$d$,
   $d$Heavenly Father, thank You for choosing me before the foundation of the world. I don't fully understand a love like that, but I receive it with a grateful heart. Thank You for adopting me through Jesus and giving me a place in Your family. When I feel unwanted or not enough, remind me that I am Yours. Shape me to be holy and blameless in Your presence. Let my life bring praise to Your glorious grace, which You have freely given me in the Beloved One. In Jesus' name, amen.$d$,
   NULL),
  (DATE '2026-11-03',
   $d$Paid in Full, and Then Some$d$,
   $d$Ephesians 1:7–10 (BSB)$d$,
   NULL,
   $d$7In Him we have redemption through His blood, the forgiveness of our trespasses, according to the riches of His grace 8that He lavished on us with all wisdom and understanding. 9And He has made known to us the mystery of His will according to His good pleasure, which He purposed in Christ 10as a plan for the fullness of time, to bring all things in heaven and on earth together in Christ.$d$,
   $d$Teresita had sold fish at the corner of the market for twenty-two years. Every morning at four, she was at the fish port haggling for galunggong and tilapia, then hauling her batya to her spot before the first customers arrived.

But the past year has been hard. A typhoon flooded her house. Her husband's medicine became more expensive. Little by little, she started borrowing from Lorna's sari-sari store across the street: rice, canned goods, a little cash for the tricycle fare to the hospital.

Lorna kept everything in a thick, dog-eared notebook. Teresita's page became two pages, then three. Every time she passed the store, she felt the weight of those pages.

"Don't worry about it," Lorna would say. But Teresita did worry. She knew the total was more than she could earn in months.

One Saturday afternoon, a young man in a crisp white polo stepped off a jeepney with a backpack. It was Paolo, Teresita's son, home from his first contract as a seaman. He hugged his mother, then walked straight across the street to the store.

"Ate Lorna, how much does my mother owe?"

Lorna hesitated, then opened the notebook. Paolo looked at the pages for a long time. Then he took out an envelope and counted every peso onto the counter.

Then he kept going. "And this is for her groceries next month. And this is for Tatay's medicine."

Lorna carefully tore out the three pages and handed them to Teresita. Her hands shook as she held them.

"Anak, that was your savings."

Paolo smiled. "Nay, you carried me for years. Let me carry you for a while."

That night, Teresita held the pages over the stove and watched them curl into ash. For the first time in a year, she fell asleep without counting.$d$,
   $d$Paul continues his list of blessings with one of the most precious words in the Bible: "In Him we have redemption through His blood, the forgiveness of our trespasses" (v. 7).

"Redemption" means buying something back by paying a price. In Paul's day, the word was used for setting a slave free or paying off a debt. Our sin left us with a debt we could never repay. But Jesus paid it, not with money, but with His own blood on the cross.

Notice that Paul says this is "according to the riches of His grace." God doesn't forgive us out of a small, stingy supply. He forgives from riches. Verse 8 adds that He "lavished" this grace on us. To lavish is to pour out generously, more than enough. God did not just cover our debt; He gave far beyond what we needed.

Then Paul lifts our eyes higher. God "has made known to us the mystery of His will" (v. 9). A "mystery" in the Bible is not a puzzle but a secret that God has now revealed. And the secret is this: God's plan for history is "to bring all things in heaven and on earth together in Christ" (v. 10). Everything broken, scattered, and divided will one day be gathered under Jesus.

So our forgiveness is not a small, private matter. It is part of God's grand plan to restore all creation. When you are forgiven, you are brought into the story God has been writing since the beginning, a story that ends with Jesus at the center of everything.$d$,
   $d$This passage teaches me that my debt has been paid in full. I don't have to carry the pages of my past around anymore, wondering when the bill will come due. Jesus paid for my trespasses with His own blood, and God has forgiven me according to the riches of His grace.

I confess that I sometimes live as if I still owe. I try to make up for my sins by being extra good, or I keep replaying old failures in my mind. That is not humility; it is forgetting what Jesus has done. God did not give me grace in small portions. He lavished it on me.

Because of this, I will strive to walk in the freedom of a forgiven person. When guilt over sin I have already confessed comes knocking, I will remind myself that the debt is gone.

Knowing that God's plan is to bring all things together in Christ, I should also become a person who brings people together rather than pulling them apart. This week, I will release one person from a "debt" I have been holding against them, and I will let Christ be the center of how I think about my past and my future.$d$,
   $d$Lord Jesus, thank You for paying a debt I could never pay. Thank You for Your blood that redeems me and for the forgiveness You have lavished on me. Forgive me for living as if I still owe You, and for holding on to guilt You have already removed. Help me to rest in Your grace. Thank You for making known to me the mystery of Your will, that You will one day bring all things together in Yourself. Make me part of that work today, as a peacemaker who points people to You. Amen.$d$,
   NULL),
  (DATE '2026-11-04',
   $d$Sealed, Signed, and Guaranteed$d$,
   $d$Ephesians 1:11–14 (BSB)$d$,
   NULL,
   $d$11In Him we were also chosen as God’s own, having been predestined according to the plan of Him who works out everything by the counsel of His will, 12in order that we, who were the first to hope in Christ, would be for the praise of His glory. 13And in Him, having heard and believed the word of truth—the gospel of your salvation—you were sealed with the promised Holy Spirit, 14who is the pledge of our inheritance until the redemption of those who are God’s possession, to the praise of His glory.$d$,
   $d$Every December for six years, Carlo and his little sister Ella waited for the box.

Their mother, Rowena, worked as a household helper in Hong Kong. She sent money every month, but the balikbayan box was different. It meant she had been thinking of them for months, buying a shirt on sale here, a bag of chocolates there, slowly filling it in the corner of her tiny room.

This year, the box arrived early, in the middle of November. It was wrapped in layers and layers of packing tape. Their mother's handwriting covered every side in thick black marker: their full names, their address, and in big letters, "HANDLE WITH CARE. FOR MY CHILDREN."

Carlo, now fourteen, noticed something. "Look, Ella. It went through the cargo company, the port, customs, and the delivery truck. Nobody opened it. Because it has her name and her seal all over it."

They cut the tape carefully. Inside were the usual treasures: canned corned beef, lotion, a jacket for Carlo, a stuffed bear for Ella. Lola Amparo found a new pair of reading glasses with a note: "Ma, so you can read my letters."

At the very bottom was an envelope. Ella opened it and read aloud, slowly.

"My dear children, this box is just the beginning. My contract ends next month. I have already bought my plane ticket. Everything in this box is my promise: I am coming home. Keep the bear on your bed until I can hug you myself. Love, Mama."

Ella burst into tears. Carlo pretended he had dust in his eyes.

For the next five weeks, the box sat in the corner of the sala, empty but untouched. Nobody threw it away. It wasn't just a box anymore. It was proof that the rest of their mother's promise was on its way.$d$,
   $d$Paul now turns to what God has secured for our future. He says, "In Him we were also chosen as God's own" (v. 11). Other translations say we "have obtained an inheritance." Both ideas are true: we belong to God, and God has prepared an inheritance for us.

And this is not wishful thinking. Paul says it all happens according to "the plan of Him who works out everything by the counsel of His will" (v. 11). God is not making it up as He goes along. His purposes cannot fail.

Then Paul explains how a person comes into all this: "Having heard and believed the word of truth—the gospel of your salvation—you were sealed with the promised Holy Spirit" (v. 13). Notice the order. We hear the gospel, we believe it, and God seals us.

In the ancient world, a seal showed ownership and protection. A letter or package stamped with a king's seal was not to be tampered with. When God gives us His Spirit, He marks us as His own. No power on earth or in hell can break that seal.

Paul then calls the Spirit "the pledge of our inheritance" (v. 14). A pledge is like a down payment, a first installment that guarantees the rest will come. The joy, peace, and new life the Spirit gives us today are a small taste of the glory that awaits us.

So if you belong to Christ, your future is secure. You are sealed, you are owned, and the rest of God's promise is on its way.$d$,
   $d$This passage teaches me that my place in God's family is not fragile. I was chosen as God's own according to a plan that cannot fail. When I heard the gospel and believed, God sealed me with His Holy Spirit. I am marked as His.

That gives me a deep sense of security. There are days when I feel weak, when my faith feels small, and when I wonder whether I will really make it. But my security doesn't rest on how strong I feel. It rests on the seal God has placed on me.

Knowing that the Holy Spirit is the pledge of my inheritance, I should stop living as if this world is all there is. The best is yet to come. The peace and joy I experience now are only a down payment on what God has prepared.

Because of this, I will strive to live with hope and patience, especially in hard seasons. I will also listen more closely to the Spirit who lives in me instead of brushing aside His gentle promptings. This week, whenever I feel anxious about the future, I will stop and say, "I am sealed. I belong to God. The rest of His promise is on its way."$d$,
   $d$Father, thank You for choosing me as Your own and for working out everything according to Your perfect plan. Thank You for the gospel of my salvation and for sealing me with Your Holy Spirit. When I feel unsure or afraid, remind me that I am marked as Yours and that no one can break Your seal. Holy Spirit, thank You for being the pledge of my inheritance. Help me to listen to You and to live with hope until the day I see Jesus face to face. May my life be to the praise of Your glory. Amen.$d$,
   NULL),
  (DATE '2026-11-05',
   $d$You're Richer Than You Can See$d$,
   $d$Ephesians 1:15–23 (BSB)$d$,
   NULL,
   $d$15For this reason, ever since I heard about your faith in the Lord Jesus and your love for all the saints, 16I have not stopped giving thanks for you, remembering you in my prayers, 17that the God of our Lord Jesus Christ, the glorious Father, may give you a spirit of wisdom and revelation in your knowledge of Him. 18I ask that the eyes of your heart may be enlightened, so that you may know the hope of His calling, the riches of His glorious inheritance in the saints, 19and the surpassing greatness of His power to us who believe. These are in accordance with the working of His mighty strength, 20which He exerted in Christ when He raised Him from the dead and seated Him at His right hand in the heavenly realms, 21far above all rule and authority, power and dominion, and every name that is named, not only in the present age but also in the one to come. 22And God put everything under His feet and made Him head over everything for the church, 23which is His body, the fullness of Him who fills all in all.$d$,
   $d$For most of Grade 3, Miguel sat in the back row and copied from his seatmate. His teacher, Ma'am Joanna, thought he was lazy. His classmates thought he was slow. Miguel himself had decided he was just not smart.

He never told anyone that the words on the board looked like smudges. He thought everyone saw them that way.

Then the school held a free eye screening. A volunteer optometrist pointed to a chart on the wall. "Read the smallest line you can."

Miguel squinted. "What line?"

The next week, his Lola Pacita took him to a small optical shop near the terminal. She paid for the cheapest frames with money from selling kakanin. The optometrist slid the glasses onto Miguel's face and said, "Now look outside."

Miguel stepped out the door and froze.

The mango tree across the street wasn't a green blob anymore. It had leaves. Hundreds of them, each with its own shape, moving in the wind. He could see the wires on the electric posts, the letters on the jeepney signboards, and the wrinkles around Lola's eyes when she smiled.

"Lola," he whispered, "is the world always like this?"

She laughed and cried at the same time. "It always was, apo. You just couldn't see it."

Back in class, Miguel moved to the front row. He read the board out loud just because he could. His scores went up, not because he had suddenly become smart, but because he could finally see what had been in front of him all along.

At the end of the quarter, Ma'am Joanna wrote on his report card: "Miguel is a bright, curious learner." He kept that card under his pillow for weeks.$d$,
   $d$After praising God for all the blessings we have in Christ, Paul now prays for his readers. He has heard about their faith in Jesus and their love for all the saints (v. 15), and he can't stop thanking God for them (v. 16).

But Paul doesn't pray that they would get more blessings. He prays that they would see the blessings they already have. He asks God to give them "a spirit of wisdom and revelation in your knowledge of Him" (v. 17), and that "the eyes of your heart may be enlightened" (v. 18).

Many Christians live spiritually nearsighted. We have been given everything in Christ, but we see only a blur. So Paul prays that we would know three things.

First, "the hope of His calling." God has called us to a future that is certain and glorious.

Second, "the riches of His glorious inheritance in the saints." Amazingly, God sees His people as His treasure.

Third, "the surpassing greatness of His power to us who believe" (v. 19). How great is that power? It is the same power God used when He raised Jesus from the dead and seated Him at His right hand (v. 20), far above every ruler, authority, and name (v. 21).

That resurrection power is at work in those who believe. The same Jesus who rules over everything has been made "head over everything for the church" (v. 22), which is His body (v. 23).

You may feel weak, but you are connected to the greatest power in the universe. Ask God to open your eyes to it.$d$,
   $d$This passage teaches me that my problem is often not a lack of blessings but a lack of sight. God has already given me hope, a place among His treasured people, and access to His mighty power. Yet I go through my days squinting, focused on what I lack instead of what I have in Christ.

I am also challenged by Paul's example of prayer. He thanked God for other believers and prayed for their spiritual growth, not just their health and finances. I should ask the Lord to make my prayers for others deeper and more like Paul's.

Knowing that the same power that raised Jesus from the dead is at work in those who believe, I should stop saying "I can't" so quickly when God calls me to obey. Forgiving someone, breaking a bad habit, or standing for what is right may feel impossible, but nothing is impossible for the God who conquered death.

I will strive to begin each day by asking God to open the eyes of my heart. This week, I will also choose two people in my church and pray Paul's prayer for them by name, asking that they would know God better and see His power at work in their lives.$d$,
   $d$Glorious Father, give me a spirit of wisdom and revelation so that I may know You better. Open the eyes of my heart. Help me to see the hope of Your calling, the riches of Your inheritance in Your people, and the surpassing greatness of Your power. Thank You that the same power that raised Jesus from the dead is at work in me. When I feel weak, remind me that Christ is seated far above every power and name. Teach me to pray for others the way Paul prayed. In Jesus' name, amen.$d$,
   NULL),
  (DATE '2026-11-06',
   $d$Dead Man Walking, Until Grace Walked In$d$,
   $d$Ephesians 2:1–7 (BSB)$d$,
   NULL,
   $d$1And you were dead in your trespasses and sins, 2in which you used to walk when you conformed to the ways of this world and of the ruler of the power of the air, the spirit who is now at work in the sons of disobedience. 3All of us also lived among them at one time, fulfilling the cravings of our flesh and indulging its desires and thoughts. Like the rest, we were by nature children of wrath. 4But because of His great love for us, God, who is rich in mercy, 5made us alive with Christ even when we were dead in our trespasses. It is by grace you have been saved! 6And God raised us up with Christ and seated us with Him in the heavenly realms in Christ Jesus, 7in order that in the coming ages He might display the surpassing riches of His grace, demonstrated by His kindness to us in Christ Jesus.$d$,
   $d$Everybody in the neighborhood knew Ramon. He was a skilled welder, the kind who could fix any gate or window grill in an afternoon. But by evening, his wages were usually gone, poured into bottles of gin on the corner bench or lost at the card table under the mango tree.

His wife, Celia, had stopped arguing. She just counted what was left and figured out how to feed their three kids with it. Ramon told himself he was fine. He worked hard; he deserved to relax. But some nights he came home, saw his children pretending to be asleep, and felt something hollow inside.

Then came the night he lost his entire week's pay in one game. He walked home, sat on the curb outside his own gate, and couldn't make himself go in.

That's where Edwin found him. Edwin was a neighbor, a jeepney driver who used to drink with him until he suddenly stopped two years earlier. Edwin sat down beside him without saying anything.

"Pare," Ramon finally said, "I think I'm already dead. I just haven't been buried yet."

Edwin nodded slowly. "I know that feeling. I used to be exactly where you are." Then he told Ramon how he had come to faith in Jesus, how God had forgiven him and given him a new heart and a new start. "Come with me on Thursday night. A few of us meet at my house to read the Bible."

Ramon went, mostly so Edwin would stop asking. But he kept going. Months later, he knelt in Edwin's small living room and gave his life to Jesus.

It wasn't easy. Some of his old friends laughed at him. But today, Ramon's wages come home. His kids run to meet him at the gate. And on Thursday nights, he is the one sitting on the curb beside men who feel the way he once did.$d$,
   $d$Before we can appreciate how good the good news is, we have to face the bad news. Paul doesn't soften it: "You were dead in your trespasses and sins" (v. 1).

He doesn't say sick or struggling. He says dead. A dead person can't help himself. He can't decide to get better or try harder. That is our spiritual condition apart from Christ.

Paul describes this old life in verses 2 and 3. We followed "the ways of this world," going along with whatever everyone else was doing. We were under the influence of "the ruler of the power of the air," which is Satan. And we lived for "the cravings of our flesh," doing whatever our desires demanded. Paul includes himself: "All of us also lived among them." No one is better than anyone else. By nature, we were all "children of wrath," deserving God's judgment.

Then comes one of the most beautiful turns in the Bible: "But because of His great love for us, God, who is rich in mercy" (v. 4), did what we could never do. He "made us alive with Christ even when we were dead" (v. 5). He "raised us up with Christ and seated us with Him in the heavenly realms" (v. 6).

Why? So that "in the coming ages He might display the surpassing riches of His grace" (v. 7). Every saved sinner is a living display of God's kindness.

Paul can't help but exclaim it in the middle of the passage: "It is by grace you have been saved!" (v. 5). If God can raise the dead, no one is too far gone.$d$,
   $d$This passage teaches me to be honest about where I came from. Before Christ, I was not a good person who just needed a little help. I was spiritually dead, following the world, the devil, and my own desires. I need to remember this, not to wallow in shame, but so that I never lose my amazement at grace.

I am moved by the words "But... God." My story could have ended in death and judgment. But God, rich in mercy and full of love, made me alive with Christ. I did nothing to deserve it. I couldn't have done anything even if I had tried.

Knowing that God raised me up and seated me with Christ, I should stop living like a corpse still taking orders from my old master. The cravings that once controlled me no longer have the final word.

Because of this, I will strive to look at people who are still far from God with hope instead of judgment. If God could make me alive, He can do the same for anyone. This week, I will pray by name for one person who seems "too far gone," and I will look for a chance to share what God has done for me.$d$,
   $d$Merciful God, I was dead in my sins, following the ways of this world and my own desires. But You, because of Your great love, made me alive with Christ. Thank You for raising me up and seating me with Him. I could never have saved myself. It is by grace I have been saved! Help me never to forget where You found me. Give me eyes of hope for those who are still far from You, and use my life to display the riches of Your kindness. In Jesus' name, amen.$d$,
   NULL),
  (DATE '2026-11-07',
   $d$You Can't Buy It, but You Were Made for It$d$,
   $d$Ephesians 2:8–10 (BSB)$d$,
   NULL,
   $d$8For it is by grace you have been saved through faith, and this not from yourselves; it is the gift of God, 9not by works, so that no one can boast. 10For we are God’s workmanship, created in Christ Jesus to do good works, which God prepared in advance as our way of life.$d$,
   $d$Lolo Ernesto had been a carpenter all his life. Now, at seventy-eight, his hands shook a little, but he still spent his mornings in the small shed behind the house, sanding and shaping bits of leftover wood.

His granddaughter, Bianca, was seven and fascinated by everything he made. One afternoon, she found him finishing a small wooden stool, painted bright yellow, with her name carved into the seat.

"Lolo! How much is that?" She dug into her pocket and pulled out three coins, everything she had saved from her baon. "I'll buy it."

Lolo laughed so hard he had to sit down. "Bianca, you can't buy this."

Her face fell. "Is it too expensive?"

"No, apo. It's a gift. I made it for you before you even asked. Keep your coins."

She hugged the stool to her chest. Then she frowned. "But what is it for?"

Lolo took her hand and led her to the kitchen. Her Lola Fe was at the sink, washing a mountain of plates after lunch. Lolo set the stool down beside the sink.

"There. Now you can reach. Lola's back hurts these days. I made this so you could help her."

Bianca climbed up. For the first time, she could see over the edge of the sink. She picked up a sponge and started scrubbing a plate, splashing water everywhere. Lola Fe laughed and showed her how to rinse.

That evening, Bianca dragged the yellow stool all over the house. She used it to help her mother fold clothes on the high table, to water the plants hanging by the window, and to reach the light switch for Lolo when he came in from the shed.

She never paid a single coin for it. But she used it every day for exactly what it was made to do.$d$,
   $d$These three verses are among the best known in the whole Bible, and for good reason. In just a few lines, Paul explains how a person is saved and why.

First, the how: "It is by grace you have been saved through faith" (v. 8). Grace is God's undeserved kindness. Faith is the empty hand that receives it. We are not saved because we trust well enough, but because we trust in Someone who saves completely.

Then Paul makes it crystal clear: "This not from yourselves; it is the gift of God, not by works, so that no one can boast" (vv. 8–9). Salvation is a gift. You can't earn a gift, and you can't pay for it. If we could save ourselves by being good, going to church, or helping others, we would have something to brag about. But in heaven, no one will be boasting about themselves. Every voice will be praising God's grace.

But Paul doesn't stop there. Verse 10 says, "For we are God's workmanship, created in Christ Jesus to do good works." The word "workmanship" describes something carefully crafted, like a masterpiece. You are God's handiwork.

And God made you for a purpose: good works "which God prepared in advance as our way of life." We are not saved by good works, but we are saved for good works. They are not the root of our salvation; they are its fruit.

So grace doesn't make us lazy. It gives us a reason to live. God has already prepared the good works He wants you to walk in. Your part is to step into them.$d$,
   $d$This passage teaches me that I can't buy my way into God's favor. My salvation is a gift from start to finish. My good deeds, my church attendance, and my efforts to be a better person could never pay for it. I can only receive it by faith.

That truth takes away my pride. I have nothing to boast about except Jesus. It also takes away my fear. If my salvation depended on my performance, I would never be sure I had done enough. But because it is by grace, I can rest.

At the same time, I am reminded that I am God's workmanship. He made me in Christ for a purpose. The gifts, abilities, and opportunities in my life are not accidents. God has prepared good works for me to walk in, at home, at work, in my neighborhood, and in my church.

Because of His grace, I will strive to live a life of good works, not to earn God's love, but because I already have it. This week, I will ask God to show me one good work He has prepared for me, and I will do it gladly, whether it is serving my family, helping a neighbor, or encouraging someone at church.$d$,
   $d$Gracious God, thank You for saving me by grace through faith. I didn't earn it, and I can't repay it. It is Your gift. Forgive me for the times I have tried to impress You or compared myself with others. I have nothing to boast about except Jesus. Thank You for making me Your workmanship, created in Christ for good works. Open my eyes to the good works You have prepared for me, and give me a willing heart to walk in them every day. In Jesus' name, amen.$d$,
   $d$This week, we began Paul's letter to the Ephesians, and what a beginning it was! On Monday, we learned that God chose us in Christ before the foundation of the world and adopted us as His children. On Tuesday, we celebrated our redemption through Jesus' blood, the forgiveness He has lavished on us, and His plan to bring all things together in Christ. On Wednesday, we discovered that we are sealed with the Holy Spirit, the pledge that guarantees our inheritance. On Thursday, we prayed with Paul that the eyes of our hearts would be opened to the hope, riches, and resurrection power we have in Christ. On Friday, we faced the hard truth that we were dead in sin, and we rejoiced that God, rich in mercy, made us alive with Christ. And today, we saw that we are saved by grace through faith, not by works, and created in Christ for the good works God has prepared for us.

Next week, Paul will show us that God's grace doesn't only bring us to Himself; it also brings us to one another. We will see how Christ tears down the walls that divide people, makes us members of God's household, reveals a mystery hidden for ages, and invites us to grasp a love so wide and deep that it surpasses knowledge. 🏁$d$),
  (DATE '2026-11-09',
   $d$From Outside the Gate to a Seat at the Table$d$,
   $d$Ephesians 2:11–13 (BSB)$d$,
   NULL,
   $d$11Therefore remember that formerly you who are Gentiles in the flesh and called uncircumcised by the so-called circumcision (that done in the body by human hands)— 12remember that at that time you were separate from Christ, alienated from the commonwealth of Israel, and strangers to the covenants of the promise, without hope and without God in the world. 13But now in Christ Jesus you who once were far away have been brought near through the blood of Christ.$d$,
   $d$Dexter was nineteen and rode on the back of the garbage truck six days a week. At five in the morning, while most of the street was still asleep, he was already jumping down, hauling sacks, and swinging them up into the truck before it rolled to the next house.

There was one house he always noticed. It had a small garden in front and a long wooden table under a mango tree. Every morning, the family who lived there ate breakfast outside: sinangag, itlog, tuyo, and a big pot of coffee. The father, a jeepney mechanic named Rodrigo, laughed loudly. The kids argued over the last piece of fried egg.

Dexter would grab their trash bag from outside the gate and keep his eyes down. He smelled like the truck. His shirt was stained. He knew he didn't belong anywhere near a table like that.

One rainy morning, the truck broke down right in front of that house. The driver went to look for a part. Dexter stood under the edge of the gate, soaked and shivering.

The gate creaked open. Rodrigo stood there holding two mugs of coffee.

"Hoy, iho. Come in. You're getting wet."

Dexter shook his head. "Sir, I'm dirty. I'll just wait here."

Rodrigo laughed. "I fix engines all day. You think I'm scared of dirt? Come. Sit."

Dexter stepped through the gate for the first time. Rodrigo's wife, Merly, put a plate of hot rice and egg in front of him. The kids asked him a hundred questions about the truck. For half an hour, he wasn't the garbage boy outside the gate. He was a guest at the table.

After that, whenever the truck passed, there was a small paper bag waiting on the gate with his name on it: "Para kay Dexter." And sometimes, a chair.$d$,
   $d$After celebrating salvation by grace, Paul asks his readers to look back. "Remember that formerly you who are Gentiles..." (v. 11). Most of the Ephesian believers were Gentiles, people who were not Jewish by birth.

Paul lists five things that were true of them before Christ (v. 12). They were "separate from Christ." They were "alienated from the commonwealth of Israel," outsiders to the people God had chosen. They were "strangers to the covenants of the promise." They were "without hope." And they were "without God in the world."

That is a sad picture: standing outside the gate, looking in at a table where they had no place. And spiritually speaking, that was our condition too. Most of us were not born into God's covenant people. We were far away.

Then come two powerful words again: "But now" (v. 13). "But now in Christ Jesus you who once were far away have been brought near through the blood of Christ."

Notice how we were brought near. Not by cleaning ourselves up first. Not by earning a seat. We were brought near "through the blood of Christ." Jesus opened the gate by giving His life on the cross.

Why does Paul want us to "remember"? Because people who forget how far they once were tend to become proud, or they start looking down on others who are still outside. Remembering keeps us grateful. It also keeps us welcoming. The same grace that brought us near is still reaching out to those who feel they don't belong.$d$,
   $d$This passage teaches me to remember where I came from. There was a time when I was far away from God, without hope and without God in the world. I had no right to a place at His table. Yet through the blood of Christ, I have been brought near.

I confess that I sometimes forget this. I can start acting as if I belong in God's family because I am a good person, or because I have been in church a long time. But I am here only because Jesus opened the gate.

Knowing that I was once an outsider, I should become someone who notices the outsiders around me. There are people in my neighborhood, my workplace, my school, and even my church who stand at the edge, convinced they don't belong.

Because of the grace that brought me near, I will strive to open the gate for others. I will not judge people by how they look, smell, or dress. This week, I will invite one person who seems left out to share a meal, a conversation, or a seat beside me, and I will treat them the way Christ has treated me.$d$,
   $d$Lord Jesus, I was once far away, without hope and without God in the world. But You brought me near through Your blood. Thank You for opening the gate when I had no right to enter. Keep me from forgetting where You found me. Guard my heart against pride, and give me eyes to see the people who still stand outside, feeling unwanted. Make me a person who opens doors and sets out chairs, so that others may taste the welcome I have received from You. Amen.$d$,
   NULL),
  (DATE '2026-11-10',
   $d$The Wall That Had to Come Down$d$,
   $d$Ephesians 2:14–18 (BSB)$d$,
   NULL,
   $d$14For He Himself is our peace, who has made the two one and has torn down the dividing wall of hostility 15by abolishing in His flesh the law of commandments and decrees. He did this to create in Himself one new man out of the two, thus making peace 16and reconciling both of them to God in one body through the cross, by which He extinguished their hostility. 17He came and preached peace to you who were far away and peace to those who were near. 18For through Him we both have access to the Father by one Spirit.$d$,
   $d$For eleven years, Benjamin and Arturo did not speak to each other.

It started with a dispute over half a meter of land between their houses. Words were said. Their wives took sides. Their children were told not to play together. Finally, Arturo built a hollow-block wall right along the line he believed was his, two meters high, topped with broken glass.

The wall became a monument to their anger. Neighbors joked that it was the only thing in the barangay that had never needed repairs.

Then came the typhoon. The rain fell all night, and by morning the creek behind their houses had overflowed. Water rose quickly on Arturo's side. The wall he had built blocked the way the water used to drain, trapping it in his yard. It reached his windows. His wife was screaming. His grandchildren were crying on the kitchen table.

Through the roar of the rain, Arturo heard pounding. Then a crack. A hole appeared in the wall. Then another. Benjamin was on the other side, swinging a sledgehammer with water up to his waist.

The water rushed through the opening and spread out. The level in Arturo's house began to drop. Benjamin kept swinging until the hole was big enough for a man to pass through. Then he reached in.

"Pass the kids to me! My second floor is dry!"

One by one, Arturo handed his grandchildren through the broken wall into Benjamin's arms.

That night, both families slept on Benjamin's second floor, crowded together on mats. Nobody mentioned the half meter of land.

A month later, the whole street watched as the two old men knocked down what was left of the wall together. Where it once stood, they planted a row of camote and kalamansi, and both families harvested it.$d$,
   $d$In Paul's day, there was a real wall in the temple in Jerusalem. It separated the Court of the Gentiles from the inner courts where only Jews could go. Signs on it warned that any Gentile who went beyond it would be put to death. It was a physical picture of the deep hostility between Jews and Gentiles.

Paul declares, "For He Himself is our peace, who has made the two one and has torn down the dividing wall of hostility" (v. 14). Notice that Jesus doesn't just give peace; He Himself is our peace.

How did He do it? "By abolishing in His flesh the law of commandments and decrees" (v. 15). The Old Testament laws that set Israel apart, like circumcision and food laws, were fulfilled in Christ. They no longer separate God's people.

And Jesus didn't simply make Gentiles into Jews or Jews into Gentiles. He created "one new man out of the two" (v. 15). In Christ, there is a brand-new people, the church.

But there is an even deeper peace. Jesus came to reconcile "both of them to God in one body through the cross" (v. 16). Our hostility with each other comes from our hostility with God. When we are made right with Him, we can be made right with one another.

Now, "through Him we both have access to the Father by one Spirit" (v. 18). Every believer, whatever their background, comes to God through the same door.

Whatever walls divide people today, whether family feuds, class, or old grudges, the cross is stronger than all of them.$d$,
   $d$This passage teaches me that Jesus Himself is my peace. He didn't just patch things up between me and God. He tore down the wall of hostility by giving His life on the cross. And if He has done that, He can also tear down the walls between me and other people.

I have to be honest. There are walls in my life that I have built and maintained for a long time. Some are with family members. Some are with former friends or church members. I have told myself I am the one who was wronged. But walls built with pride only end up trapping me.

Knowing that Christ created one new people out of enemies, I should stop treating my grudges as if they were permanent. Since we all have access to the same Father by the same Spirit, I have no right to keep my brother or sister on the other side of a wall.

I will strive to be the first to pick up the sledgehammer of humility. This week, I will pray about one broken relationship, and I will take one concrete step toward peace: a message, a visit, an apology, or a simple greeting.$d$,
   $d$Lord Jesus, You are my peace. Thank You for tearing down the dividing wall of hostility through Your cross. Thank You that I now have access to the Father by one Spirit. Forgive me for the walls I have built and protected out of pride and hurt. Show me where I need to make peace, and give me the courage to take the first step. Make Your church one new people, not divided by background, status, or old grudges, but united in You. Amen.$d$,
   NULL),
  (DATE '2026-11-11',
   $d$You're Not a Visitor Here$d$,
   $d$Ephesians 2:19–22 (BSB)$d$,
   NULL,
   $d$19Therefore you are no longer strangers and foreigners, but fellow citizens with the saints and members of God’s household, 20built on the foundation of the apostles and prophets, with Christ Jesus Himself as the cornerstone. 21In Him the whole building is fitted together and grows into a holy temple in the Lord. 22And in Him you too are being built together into a dwelling place for God in His Spirit.$d$,
   $d$Nora was eighteen when she left her island in the Visayas to work as a kasambahay for the Villanueva family in the city. She had never seen so many cars. She had never worked in a house with a washing machine.

For the first months, she kept to herself. She ate alone in the small kitchen after the family finished. She slept in a tiny room by the laundry area. She was polite and hardworking, but every night she cried quietly for her mother and her younger brothers.

The Villanuevas weren't rich. Mr. Villanueva drove a delivery van, and his wife, Josie, ran a small ukay-ukay stall. But they treated Nora kindly. Still, Nora knew her place. She was the helper.

One evening in her second year, Josie called her to the dining table. "Nora, sit with us."

"Ma'am, I'll eat later."

"No. Sit."

Nora sat at the edge of a chair. The two kids, Paulo and Andrea, were grinning. Then Andrea brought out a small cake with nineteen candles. It was Nora's birthday. She hadn't told anyone.

"We saw it on your ID," Josie said, smiling.

After dinner, Mr. Villanueva set his phone on a stack of books to take a family picture. Nora stepped back to hold the phone for them.

"What are you doing?" he said. "You're in the picture. Halika na."

Nora stood beside Andrea. The camera clicked.

A week later, that picture was printed and framed on the living room wall, next to the kids' graduation photos. Every time Nora dusted the frames, she paused at that one.

She still cooked, cleaned, and did the laundry. But something had changed. She was no longer a visitor in that house. She was part of the household.$d$,
   $d$Paul continues: "Therefore you are no longer strangers and foreigners, but fellow citizens with the saints and members of God's household" (v. 19).

A "stranger" was someone just passing through. A "foreigner" was a resident alien who lived in a place but didn't have full rights. Paul says neither describes us anymore. In Christ, we are full citizens of God's kingdom. And more than that, we are "members of God's household." We are family.

Then Paul switches to a picture of a building. God's people are "built on the foundation of the apostles and prophets, with Christ Jesus Himself as the cornerstone" (v. 20). The foundation is the teaching God gave through the apostles and prophets, which we now have in the Bible. The cornerstone was the first and most important stone in a building. Every other stone was lined up by it. Jesus is the one who holds everything together and sets the direction for everything else.

"In Him the whole building is fitted together and grows into a holy temple in the Lord" (v. 21). In the Old Testament, God's presence dwelt in a temple made of stone. Now God is building a temple made of people.

And this includes you: "In Him you too are being built together into a dwelling place for God in His Spirit" (v. 22). Notice the word "together." You are not a single stone sitting by itself. You are fitted together with other believers.

This means church is not a place we visit. It is a family we belong to and a building God is still constructing, with us in it.$d$,
   $d$This passage teaches me that I am not a visitor in God's house. I am not a guest who has to wait in the kitchen or stand outside the family picture. I am a fellow citizen with the saints and a member of God's household. That is an incredible privilege.

I confess that I sometimes treat church like a place I visit rather than a family I belong to. I come, I sit, I leave, and I don't get involved. But a stone that sits alone is not part of a building. God is fitting me together with other believers to become His dwelling place.

Knowing that Jesus is the cornerstone, I should line up my life with Him. My priorities, my decisions, and my relationships need to be measured against Him, not against what the world says.

Because of this, I will strive to take my place in God's household seriously. I will show up not just to receive but to serve. This week, I will reach out to someone in my church I don't know well, and I will look for one way to help build up the family of God.$d$,
   $d$Father, thank You that I am no longer a stranger or foreigner, but a member of Your household. Thank You for building Your church on the foundation of Your Word, with Jesus as the cornerstone. Forgive me for the times I have treated Your family like a place to visit instead of a home to belong to. Fit me together with my brothers and sisters. Line up my life with Christ. Make our church a holy temple, a dwelling place where Your Spirit is pleased to live. In Jesus' name, amen.$d$,
   NULL),
  (DATE '2026-11-12',
   $d$The Secret Recipe Was Meant to Be Shared$d$,
   $d$Ephesians 3:1–6 (BSB)$d$,
   NULL,
   $d$1For this reason I, Paul, the prisoner of Christ Jesus for the sake of you Gentiles... 2Surely you have heard about the stewardship of God’s grace that was given to me for you, 3that is, the mystery made known to me by revelation, as I have already written briefly. 4In reading this, then, you will be able to understand my insight into the mystery of Christ, 5which was not made known to men in other generations as it has now been revealed by the Spirit to God’s holy apostles and prophets. 6This mystery is that through the gospel the Gentiles are fellow heirs, fellow members of the body, and fellow partakers of the promise in Christ Jesus.$d$,
   $d$In the Dizon family, there was one secret that no one outside the bloodline was allowed to know: the recipe for Corazon's tocino.

For forty years, Corazon had cured pork in her kitchen in Pampanga using a blend of spices that won her customers from three towns. Her daughters knew the recipe. Her sons knew it. But when they married, she made it clear that the in-laws would only ever taste it, never learn it.

"Family lang," she always said, tapping the side of her nose.

Then her youngest son, Victor, married Analyn, a quiet girl from Ilocos. Analyn worked hard in the family's small food stall, waking at three in the morning to help pack orders. She never once asked about the recipe. She just watched the family disappear into the back kitchen while she stayed at the counter.

One year, Corazon fell ill with a bad flu just before the Christmas rush. Orders piled up. Her daughters were all abroad or busy with their own families. Victor was driving deliveries day and night.

Late one evening, Corazon called Analyn into her bedroom. She handed her an old, grease-stained notebook.

"Open it."

Analyn opened it. Page after page of handwritten measurements, notes, and little drawings.

"Nay, I can't. This is for the family."

Corazon reached out and took her hand. "Anak, what do you think you are? You have been my daughter since the day you married my son. I was just slow to show it."

That Christmas, Analyn made every batch of tocino. The customers never tasted the difference.

Today, Analyn's name is written on the inside cover of that notebook, right below Corazon's. "Fellow heir," Corazon calls her, laughing. And the recipe that was once kept from outsiders now feeds a whole new generation.$d$,
   $d$Paul begins a prayer, "For this reason I, Paul, the prisoner of Christ Jesus for the sake of you Gentiles..." (v. 1), but he interrupts himself to explain something important. He will return to the prayer in verse 14.

Paul was writing from prison. He was there because he preached that Gentiles could be saved without becoming Jews first. That message made many people angry. But Paul calls himself not a prisoner of Rome but "the prisoner of Christ Jesus." He believed his chains were part of God's plan.

He speaks of "the stewardship of God's grace that was given to me for you" (v. 2). A steward managed something that belonged to someone else. God had entrusted Paul with a message to manage and share.

What message? "The mystery made known to me by revelation" (v. 3). Again, a biblical mystery is a truth that God kept hidden in the past but has now revealed. It "was not made known to men in other generations as it has now been revealed by the Spirit" (v. 5).

Here is the mystery: "that through the gospel the Gentiles are fellow heirs, fellow members of the body, and fellow partakers of the promise in Christ Jesus" (v. 6).

Notice the word "fellow" three times. Gentiles are not second-class members of God's family. They inherit the same promises, belong to the same body, and share in the same blessings as Jewish believers.

The Old Testament hinted that God would bless all nations through Abraham. But no one fully understood that God would make one equal family out of all peoples. That is the beautiful secret of the gospel, and it was always meant to be shared.$d$,
   $d$This passage teaches me that I am a fellow heir in God's family. I am not a second-class believer who only gets to taste the blessings from a distance. Through the gospel, I share fully in the promises of God in Christ Jesus. That truth fills me with gratitude.

I am also challenged by Paul's attitude. He was in prison, yet he called himself the prisoner of Christ Jesus. He didn't see his hardship as a sign that God had abandoned him. He saw it as part of his calling. I should ask the Lord to help me see my own difficulties the same way.

Knowing that God entrusted the gospel to Paul as a steward, I should remember that the same gospel has now been entrusted to me. The good news that outsiders can become family was never meant to be locked away in a notebook. It was meant to be shared.

Because of this, I will strive to treat every believer as a fellow heir, regardless of their background, language, or status. This week, I will look for one opportunity to share the gospel with someone who may think God's family is only for "other people."$d$,
   $d$Gracious God, thank You for revealing the mystery of Christ. Thank You that through the gospel, I am a fellow heir, a fellow member of the body, and a fellow partaker of Your promise. I don't deserve such a place, yet You have given it freely. Help me, like Paul, to see my hardships as part of Your purpose. Make me a faithful steward of the gospel You have entrusted to me. Give me boldness to share it with those who still think they are outsiders. In Jesus' name, amen.$d$,
   NULL),
  (DATE '2026-11-13',
   $d$Least Likely to Succeed? Think Again$d$,
   $d$Ephesians 3:7–13 (BSB)$d$,
   NULL,
   $d$7I became a servant of this gospel by the gift of God’s grace, given me through the working of His power. 8Though I am less than the least of all the saints, this grace was given me: to preach to the Gentiles the unsearchable riches of Christ, 9and to illuminate for everyone the stewardship of this mystery, which for ages past was kept hidden in God, who created all things. 10His purpose was that now, through the church, the manifold wisdom of God should be made known to the rulers and authorities in the heavenly realms, 11according to the eternal purpose that He accomplished in Christ Jesus our Lord. 12In Him and through faith in Him we may enter God’s presence with boldness and confidence. 13So I ask you not to be discouraged because of my sufferings for you, which are your glory.$d$,
   $d$Danilo had been the utility man at the elementary school for fifteen years. He swept the hallways, fixed leaking faucets, and carried tables for every program. Teachers liked him. Kids greeted him with high fives.

But Danilo carried a secret. He had stopped school in Grade 4 to help his father on the farm, and he could barely read. When he received memos, he would nod and pretend, then ask a teacher later what they said. When he signed his attendance, he copied the letters of his name slowly, like a drawing.

One afternoon, the principal, Mrs. Santos, found him outside the library staring at a poster about the school's new adult literacy class.

"Interested, Danilo?"

He laughed nervously. "Ma'am, I'm too old. And I'm just the utility man."

She smiled. "The class is for anyone. And the door to my office is always open if you need help."

He almost didn't go. But on the first night, he sat in a tiny chair meant for a Grade 1 student, holding a pencil that felt too small in his rough hands. Week after week, he came back. He sounded out words. He read signs on the jeepneys. He read the label on his medicine. One night, he read a whole page of a storybook without stopping, and the other adult learners clapped.

A year later, the kindergarten teacher asked for volunteers for a "Reading Buddies" program. Danilo raised his hand.

Now, every Friday afternoon, a group of five-year-olds sits on the floor around the utility man. He opens a picture book and reads to them, doing all the funny voices.

"Kuya Danilo," one little girl asked once, "how did you learn to read so well?"

He smiled. "Someone gave me a chance I didn't deserve."$d$,
   $d$Paul continues describing his role in God's plan. He says, "I became a servant of this gospel by the gift of God's grace, given me through the working of His power" (v. 7). Paul didn't choose this role because he was qualified. God gave it to him as a gift.

Then he makes a surprising statement: "Though I am less than the least of all the saints, this grace was given me" (v. 8). Paul had once persecuted the church. He had approved of the killing of believers. He never forgot that. He didn't just say he was the least; he invented a word meaning "leaster than the least." Yet God chose him to "preach to the Gentiles the unsearchable riches of Christ."

"Unsearchable" means you can never reach the end of it. No matter how long we study Christ, there is always more to discover.

Paul's task was also "to illuminate for everyone the stewardship of this mystery" (v. 9). And God had an even bigger purpose: "that now, through the church, the manifold wisdom of God should be made known to the rulers and authorities in the heavenly realms" (v. 10). The church, a family of forgiven sinners from every background, is God's display of wisdom to the whole spiritual world.

Because of Christ, "we may enter God's presence with boldness and confidence" (v. 12). We don't have to sneak in or wait outside. The door is open.

So Paul tells them not to be discouraged by his sufferings (v. 13). His imprisonment was helping spread this good news. If God can use "the least," He can use you.$d$,
   $d$This passage teaches me that God's grace is not reserved for the impressive. Paul called himself less than the least of all the saints, yet God gave him the privilege of preaching the unsearchable riches of Christ. If God could use a former persecutor, He can use me.

I confess that I often disqualify myself. I think I'm not educated enough, not gifted enough, or too damaged by my past to serve God in a meaningful way. But my calling doesn't depend on my qualifications. It depends on the gift of God's grace and the working of His power.

Knowing that I can enter God's presence with boldness and confidence through faith in Christ, I should stop approaching Him as if I were unwelcome. The door is always open.

Because of this, I will strive to say yes when God gives me an opportunity to serve, even when I feel unqualified. I will also remember that the church is meant to display God's wisdom, so I want my life to reflect His grace. This week, I will volunteer for one task in my church or community that I have been avoiding because I felt "not good enough."$d$,
   $d$Lord, I am less than the least, yet You have given me Your grace. Thank You for the unsearchable riches of Christ, which I can never exhaust. Thank You that I can come into Your presence with boldness and confidence through faith in Jesus. Forgive me for the times I have disqualified myself from serving You. Work Your power in me. Use my life, my words, and even my weaknesses to display Your wisdom. Let Your church shine as a testimony of Your grace. In Jesus' name, amen.$d$,
   NULL),
  (DATE '2026-11-14',
   $d$A Love Too Deep for Any Rope$d$,
   $d$Ephesians 3:14–21 (BSB)$d$,
   NULL,
   $d$14... for this reason I bow my knees before the Father, 15from whom every family in heaven and on earth derives its name. 16I ask that out of the riches of His glory He may strengthen you with power through His Spirit in your inner being, 17so that Christ may dwell in your hearts through faith. Then you, being rooted and grounded in love, 18will have power, together with all the saints, to comprehend the length and width and height and depth 19of the love of Christ, and to know this love that surpasses knowledge, that you may be filled with all the fullness of God. 20Now to Him who is able to do immeasurably more than all we ask or imagine, according to His power that is at work within us, 21to Him be the glory in the church and in Christ Jesus throughout all generations, forever and ever. Amen.$d$,
   $d$Maricel was nine when her mother left for Manila and never came back. For months afterward, she clung to her father, Efren, every time he walked out the door.

"Papa, are you coming back?"

"Of course, anak."

But the question kept coming, every morning, every evening. Efren was a fisherman, and some nights he had to go out to sea. On those nights, Maricel couldn't sleep.

One calm evening, Efren decided to bring her along. He packed a jacket, a flashlight, and a long coil of rope with a stone tied to one end. They pushed the small bangka into the water and paddled out until the lights of their village looked like tiny stars.

"Anak," he said, "do you want to know how deep the sea is here?"

She nodded. He let the stone drop over the side and began feeding out the rope. Meter after meter disappeared into the black water. Maricel's eyes grew wide. Finally, he reached the end of the rope. It hung straight down, still not touching the bottom.

"My rope isn't long enough," Efren laughed. "Nobody's rope is long enough. That's how deep my love for you is. You can't measure it. And it doesn't run out just because Mama left."

Maricel said nothing. She just leaned against his shoulder and watched the stars until she fell asleep.

Years later, at her college graduation, Maricel learned that her father had been saving a few coins from every catch since the night they went out to sea. He had never told her. He had hoped for more than she could have imagined.

When she walked up the stage, she spotted him in the crowd, sunburned and crying. She raised her diploma toward him like a rope pulled up from the deep.$d$,
   $d$Paul finally returns to the prayer he began in verse 1: "For this reason I bow my knees before the Father" (v. 14). In Paul's day, people usually prayed standing. Kneeling showed deep humility and urgency.

What does Paul pray for? First, that God, "out of the riches of His glory," would "strengthen you with power through His Spirit in your inner being" (v. 16). We often pray for outward strength: health, money, or success. Paul prays for inner strength.

Why? "So that Christ may dwell in your hearts through faith" (v. 17). The word "dwell" means to settle down and be at home. Paul prays that Jesus would not be a visitor in our hearts, but the owner of the house.

Then Paul prays that we, "being rooted and grounded in love," would have power "to comprehend the length and width and height and depth of the love of Christ" (vv. 17–18). Christ's love is wide enough to include everyone, long enough to last forever, high enough to lift us to heaven, and deep enough to reach us at our lowest.

And Paul prays that we would "know this love that surpasses knowledge" (v. 19). It sounds like a contradiction, but it isn't. We can truly experience Christ's love, even though we will never reach the end of it.

Paul closes with one of the greatest praises in the Bible: "Now to Him who is able to do immeasurably more than all we ask or imagine, according to His power that is at work within us" (v. 20). God's love has no bottom, and His power has no limit.$d$,
   $d$This passage teaches me that I will never reach the bottom of Christ's love for me. Its length, width, height, and depth are beyond measuring. Whatever has happened in my life, whoever has walked away from me, His love does not run out.

I realize that I often pray small prayers. I ask God for things on the outside, but I rarely ask Him to strengthen my inner being. Paul's prayer reminds me that what I need most is for Christ to be fully at home in my heart.

Knowing that God is able to do immeasurably more than all I ask or imagine, I should stop limiting Him with my small expectations. My dreams, my worries, and my plans are not too big for Him. In fact, they are usually too small.

Because of this, I will strive to root my life in His love rather than in the approval of people. I will also learn to pray bigger, more faith-filled prayers, both for myself and for others. This week, I will pray Paul's prayer from verses 16 to 19 every day, and I will write down one thing I am trusting God to do that is beyond what I can imagine.$d$,
   $d$Father, I bow before You, from whom every family in heaven and on earth derives its name. Out of the riches of Your glory, strengthen me with power through Your Spirit in my inner being. Let Christ be fully at home in my heart. Root and ground me in love. Help me to grasp the length, width, height, and depth of the love of Christ, a love that surpasses knowledge. You are able to do immeasurably more than all I ask or imagine. To You be the glory in the church and in Christ Jesus forever. Amen.$d$,
   $d$This week, Paul showed us that grace doesn't only bring us to God; it brings us to one another. On Monday, we remembered that we were once far away, without hope and without God, but have been brought near through the blood of Christ. On Tuesday, we saw that Jesus Himself is our peace, tearing down the dividing wall of hostility and creating one new people. On Wednesday, we learned that we are no longer strangers but members of God's household, being built together into a dwelling place for God. On Thursday, Paul revealed the mystery that Gentiles are fellow heirs in Christ. On Friday, we saw how God gave His grace to Paul, "less than the least," and how we can now approach Him with boldness and confidence. And today, we joined Paul in praying to know the love of Christ that surpasses knowledge, and we praised the God who can do immeasurably more than we ask or imagine.

Next week, Paul turns from what God has done to how we should live. We will be challenged to walk worthy of our calling, keep the unity of the Spirit, use our gifts to build up the body, speak the truth in love, put off the old self, deal with anger and bitterness, and become imitators of God. 🏁$d$),
  (DATE '2026-11-16',
   $d$Twenty Men, One House, Zero Arguments$d$,
   $d$Ephesians 4:1–6 (BSB)$d$,
   $d$Eventually$d$,
   $d$1As a prisoner in the Lord, then, I urge you to walk in a manner worthy of the calling you have received: 2with all humility and gentleness, with patience, bearing with one another in love, 3and with diligence to preserve the unity of the Spirit through the bond of peace. 4There is one body and one Spirit, just as you were called to one hope when you were called; 5one Lord, one faith, one baptism; 6one God and Father of all, who is over all and through all and in all.$d$,
   $d$The Ramirez family was moving their bahay kubo. The landslide warnings had come, and the old spot near the riverbank was no longer safe. The new lot was two hundred meters up the slope.

Hazel, the youngest barangay kagawad, had organized the bayanihan. Twenty men showed up on Saturday morning with bamboo poles, which they slid under the house and lifted onto their shoulders.

Within five minutes, the house was tilting badly.

The young men in front were strong and impatient. They wanted to get it done fast, so they marched ahead. The older men at the back couldn't keep up. One side was arguing about which path to take. Someone stepped on someone's foot. The whole house swayed like a boat in a storm, and everyone had to drop it.

"Kayo kasi ang bagal!" one of the young men shouted.

"Kayo naman, ang yabang!" an older man shot back.

Hazel climbed on a rock and whistled. "Everybody stop!" She waited until it was quiet. "The house doesn't care who is strongest. It only cares if we move together. If one side runs, the whole house falls."

She assigned one man to call out the steps. "Isa, dalawa... isa, dalawa..." The young men had to shorten their strides. The older men had to push a little harder. When someone got tired, the person beside him shifted to carry more of the weight without being asked.

Slowly, the house began to move up the hill, steady and level.

When they finally set it down on its new posts, the whole crowd cheered. The young man who had shouted earlier walked over to the older man and handed him a cold bottle of water.

"Pasensya na po, Tay."

The older man smiled and slapped him on the back. "Ayos lang. We got there together."$d$,
   $d$After three chapters about what God has done for us, Paul turns a corner. "As a prisoner in the Lord, then, I urge you to walk in a manner worthy of the calling you have received" (v. 1). The word "then" connects what we believe with how we live. Because God has chosen us, saved us, and made us one family, we should live like it.

What does a worthy walk look like? Paul doesn't start with dramatic achievements. He starts with attitudes: "with all humility and gentleness, with patience, bearing with one another in love" (v. 2).

Humility means not thinking we are better than others. Gentleness is strength under control. Patience is a long fuse. And bearing with one another means putting up with each other's weaknesses, quirks, and slow steps, out of love.

Why do we need these qualities? Because Paul wants us to work "with diligence to preserve the unity of the Spirit through the bond of peace" (v. 3). Notice that we don't create this unity. The Spirit has already made us one. Our job is to protect it, and that takes effort.

Then Paul lists seven "ones" that hold us together (vv. 4–6): one body, one Spirit, one hope, one Lord, one faith, one baptism, and one God and Father of all. We may differ in age, background, personality, and opinions. But what unites us is far greater than what divides us.

A church that walks together, slowly and humbly, shows the world the beauty of the gospel. A church that fights shows the world nothing worth carrying.$d$,
   $d$This passage teaches me that my calling is not only about what I believe but also about how I walk with others. God has called me into one body with one Lord, one faith, and one hope. I cannot claim to honor that calling while being proud, harsh, or impatient with my brothers and sisters.

I confess that I often want others to keep up with my pace. I get frustrated with people who are slower, weaker, or different from me. I forget how patient God has been with me.

Knowing that the Spirit has already made us one, I should take seriously my responsibility to preserve that unity. Unity doesn't happen automatically. It takes humility to admit I might be wrong, gentleness when I feel like shouting, and patience when someone tests me.

Because of this, I will strive to be a peacekeeper in my church, family, and workplace. Instead of complaining about others, I will look for ways to carry more of the weight when they are tired. This week, I will identify one person I find hard to bear with, and I will deliberately show that person kindness and patience.$d$,
   $d$Lord, thank You for calling me into Your family. Help me to walk in a manner worthy of that calling. Clothe me with humility, gentleness, and patience. Teach me to bear with others in love, the way You have borne with me. Make me diligent to preserve the unity of the Spirit through the bond of peace. When I am tempted to rush ahead or to criticize, remind me that we have one Lord, one faith, and one hope. Let our church walk together for Your glory. Amen.$d$,
   NULL),
  (DATE '2026-11-17',
   $d$The Boss Who Learned to Let Go$d$,
   $d$Ephesians 4:7–13 (BSB)$d$,
   NULL,
   $d$7Now to each one of us grace has been given according to the measure of the gift of Christ. 8This is why it says: “When He ascended on high, He led captives away, and gave gifts to men.” 9What does “He ascended” mean, except that He also descended to the lower parts of the earth? 10He who descended is the very One who ascended above all the heavens, in order to fill all things. 11And it was He who gave some to be apostles, some to be prophets, some to be evangelists, and some to be pastors and teachers, 12to equip the saints for works of ministry and to build up the body of Christ, 13until we all reach unity in the faith and in the knowledge of the Son of God, as we mature to the full measure of the stature of Christ.$d$,
   $d$Lourdes ran the busiest carinderia near the bus terminal. Her adobo was famous, her sinigang was legendary, and she did almost everything herself. She went to the market at four in the morning, cooked every dish, managed the cash, and even washed the biggest pots because nobody else did it "right."

She had three helpers, but she treated them like extra hands, not partners. "Just stir this," she would say. "Just serve that." She never taught them anything.

Then one Monday, Lourdes woke up with a back so stiff she couldn't stand. The doctor ordered two weeks of complete rest.

She lay in bed, panicking. The carinderia would close. Customers would go elsewhere.

On the third day, her nephew Jayson visited. "Tita, the carinderia is open."

"What? Who's cooking?"

"Wilma."

Lourdes blinked. Wilma was the quiet dishwasher who had been with her for four years. She barely spoke.

"And Rodel is doing the market. Aiza is handling the cash. They split the work."

The next week, Lourdes insisted on being wheeled to the carinderia to see. Wilma was at the big stove, sleeves rolled up, tasting the sinigang. It was good. Maybe even better than hers.

"How did you learn?" Lourdes asked.

Wilma smiled shyly. "I watched you for four years, Ma'am. I just never had the chance."

That night, Lourdes couldn't sleep. She realized she had been sitting in a kitchen full of gifts and never used them.

When her back healed, she changed everything. She taught Wilma her recipes. She trained Rodel to choose the best meat. She showed Aiza how to keep the books.

Today, the carinderia has two branches. And Lourdes finally takes Sundays off.$d$,
   $d$After stressing unity, Paul turns to diversity. "Now to each one of us grace has been given according to the measure of the gift of Christ" (v. 7). Every believer has received grace, not just to be saved, but to serve. Each of us has been given something.

Paul quotes Psalm 68 to show that the risen Jesus, like a victorious king, "ascended on high" and "gave gifts to men" (v. 8). The One who came down to earth, all the way to the cross and the grave, has now ascended "above all the heavens, in order to fill all things" (vv. 9–10). From His throne, He distributes gifts to His church.

Then Paul names some of these gifts: "apostles... prophets... evangelists... and pastors and teachers" (v. 11). Notice that these gifts are people. Jesus gives leaders to His church.

But what is their job? Not to do all the ministry themselves. Their job is "to equip the saints for works of ministry and to build up the body of Christ" (v. 12). The word "equip" was used for mending fishing nets or setting a broken bone. Leaders prepare and train believers so that every member can serve.

The goal is maturity: "until we all reach unity in the faith and in the knowledge of the Son of God, as we mature to the full measure of the stature of Christ" (v. 13).

So ministry isn't only for pastors. Every believer is a minister. A church grows strong when leaders train, and members serve.$d$,
   $d$This passage teaches me that I have been given grace to serve. I am not a spectator in the church. Jesus, the victorious King, has given gifts to His people, and I am one of the people He has gifted. My part may seem small, but the body is not complete without it.

I confess that I sometimes leave ministry to the pastor and a few "active" members. I sit back and assume someone else will do it. Other times, if I am in a leadership role, I do everything myself instead of training others to serve.

Knowing that leaders are given to equip the saints for works of ministry, I should be willing to be trained, and I should be willing to train others. My goal is not to be needed but to help others grow toward the full stature of Christ.

Because of this, I will strive to discover and use the gifts God has given me. If I lead, I will look for someone I can teach. If I am not in a position of leadership, I will make myself available to be equipped. This week, I will ask my pastor or a mature believer how I can serve in my church.$d$,
   $d$Lord Jesus, You ascended on high and gave gifts to Your church. Thank You for the grace You have given me. Forgive me for sitting back when I should be serving, and for holding on to work I should be sharing. Thank You for the pastors and teachers who equip us. Help me to be teachable and to teach others. Use my gifts to build up Your body until we all reach unity in the faith and maturity in You. Let my life grow to reflect Your stature. Amen.$d$,
   NULL),
  (DATE '2026-11-18',
   $d$The Sister Who Burst My Bubble$d$,
   $d$Ephesians 4:14–16 (BSB)$d$,
   NULL,
   $d$14Then we will no longer be infants, tossed about by the waves and carried around by every wind of teaching and by the clever cunning of men in their deceitful scheming. 15Instead, speaking the truth in love, we will in all things grow up into Christ Himself, who is the head. 16From Him the whole body, fitted and held together by every supporting ligament, grows and builds itself up in love through the work of each individual part.$d$,
   $d$Rommel drove a tricycle and earned just enough to feed his family. So when a friend on Facebook messaged him about an "investment opportunity," he paid attention.

"Pare, put in five thousand, and in two weeks you'll get ten thousand back. Guaranteed. Look at all these people getting paid!"

The posts were full of screenshots: smiling people holding stacks of cash, new motorcycles, new appliances. Everyone in the comments was saying, "Legit! Thank you, boss!"

Rommel started dreaming. Ten thousand could become twenty, then forty. Maybe he could finally buy his own tricycle instead of renting.

He went to his older sister, Melody, to borrow money. Melody worked as a bookkeeper at a hardware store.

"Five thousand for what?" she asked.

He showed her the posts, his eyes bright with excitement. Melody read them carefully. Then she quietly set down the phone.

"Rommel, I love you. That's why I have to tell you the truth. This is a scam."

He frowned. "Ate, you don't understand. Look at all the people getting paid."

"They're getting paid with the money of new people who join. When new people stop joining, it all collapses. I've seen this three times already. Remember Uncle Antonio lost his whole savings that way?"

Rommel was quiet. He wanted to be angry. But Melody wasn't mocking him. She looked sad, as if she was afraid for him.

"I'll lend you five thousand," she said. "But not for that. For your tricycle fund. Pay me back slowly."

Three weeks later, the Facebook page disappeared. Hundreds of people in their town lost money.

Rommel visited Melody that night with a bag of puto. "Thank you, Ate. I'm glad you told me the truth, even though I didn't want to hear it."$d$,
   $d$Paul now describes the goal of a mature church by first showing what immaturity looks like. "Then we will no longer be infants, tossed about by the waves and carried around by every wind of teaching" (v. 14).

Infants believe whatever they are told. They are easily impressed and easily fooled. Spiritually immature believers are like small boats in a storm, pushed one way by a new teaching, another way by a popular speaker, and another by a trend on social media. Paul warns that some people use "clever cunning" and "deceitful scheming" to lead others astray. False teaching is often attractive and persuasive.

What is the answer? "Instead, speaking the truth in love, we will in all things grow up into Christ Himself, who is the head" (v. 15).

Notice that Paul joins truth and love. Truth without love can be harsh and cold. Love without truth can be soft and dishonest. Mature believers speak the truth, even when it is uncomfortable, but they do it with a genuine desire for the other person's good.

And growth happens together. "From Him the whole body, fitted and held together by every supporting ligament, grows and builds itself up in love through the work of each individual part" (v. 16). Jesus, the head, supplies everything. But every part, including you, plays a role.

Sometimes your role is to encourage. Sometimes it is to warn. Either way, when we speak the truth in love, the whole body grows stronger and harder to deceive.$d$,
   $d$This passage teaches me that spiritual maturity protects me from being tossed about by every wind of teaching. I need to be grounded in God's Word so that I can recognize what is false, no matter how attractive or popular it seems.

I confess that I am sometimes easily impressed by persuasive speakers, viral videos, or ideas that promise quick blessings. I need to test everything by Scripture.

I am also challenged about the way I speak to others. Sometimes I avoid telling the truth because I want to be liked. Other times, I tell the truth harshly and without love. Both are failures.

Knowing that the whole body grows through the work of each part, I should take my responsibility seriously. When I see a brother or sister heading toward danger, I should speak up, gently and humbly. And when someone speaks the truth to me in love, I should receive it instead of getting defensive.

I will strive to grow up into Christ, not stay an infant. This week, I will spend extra time in God's Word, and I will ask God for the courage to speak the truth in love to someone who needs to hear it.$d$,
   $d$Lord Jesus, You are the head of the body. Keep me from being tossed about by every wind of teaching. Ground me in Your Word, and give me discernment to recognize deception. Teach me to speak the truth in love, never harshly and never dishonestly. Give me a humble heart that receives correction from others. Help each part of Your body do its work, so that we may grow and build one another up in love. Help me to grow up into You in all things. Amen.$d$,
   NULL),
  (DATE '2026-11-19',
   $d$Throw Out the Old Clothes$d$,
   $d$Ephesians 4:17–24 (BSB)$d$,
   NULL,
   $d$17So I tell you this, and insist on it in the Lord, that you must no longer walk as the Gentiles do, in the futility of their thinking. 18They are darkened in their understanding and alienated from the life of God because of the ignorance that is in them due to the hardness of their hearts. 19Having lost all sense of shame, they have given themselves over to sensuality for the practice of every kind of impurity, with a craving for more. 20But this is not the way you came to know Christ. 21Surely you heard of Him and were taught in Him—in keeping with the truth that is in Jesus— 22to put off your former way of life, your old self, which is being corrupted by its deceitful desires; 23to be renewed in the spirit of your minds; 24and to put on the new self, created to be like God in true righteousness and holiness.$d$,
   $d$Elmer was twelve when he arrived at the children's shelter. He had lived on the streets for three years, sleeping under an overpass, begging at stoplights, and sniffing rugby to forget his hunger. His clothes were torn, stiff with dirt, and smelled of solvent.

On his first night, the house parents, Kuya Allan and Ate Precy, gave him a bath, a haircut, and a clean set of clothes: a white T-shirt, blue shorts, and a pair of slippers that actually fit.

"Throw your old clothes in this bag," Ate Precy said. "We'll get rid of them."

Elmer nodded. But when no one was looking, he rolled up his old shirt and hid it under his mattress.

For weeks, he kept it there. Some nights, when the other kids were asleep, he would take it out and smell it. It reminded him of the streets, of his old friends, of a freedom that had felt exciting even though it was killing him. Twice he almost ran away.

One night, Kuya Allan found him sitting on the bed, holding the old shirt.

He didn't scold him. He just sat down. "You know, Elmer, I used to live under a bridge too."

Elmer looked up, surprised.

"I kept my old life close for a long time. I thought I needed it. But I couldn't fully live in my new life while I was still holding on to the old one." He told Elmer how Jesus had changed him and given him a new heart.

The next morning, Elmer walked to the trash bin behind the shelter. He held the old shirt for a moment. Then he dropped it in.

Years later, Elmer stands in front of the shelter's gate as a house parent himself, holding a stack of clean, folded clothes for a new boy who has just arrived.$d$,
   $d$Paul now insists that believers "must no longer walk as the Gentiles do, in the futility of their thinking" (v. 17). Here, "Gentiles" means people who don't know God.

Paul describes their condition with a downward spiral. Their thinking becomes futile. Their understanding is "darkened." They are "alienated from the life of God" (v. 18). Why? "Because of the ignorance that is in them due to the hardness of their hearts." Sin isn't just a lack of information. It begins with a hard heart that refuses God.

And a hard heart leads to a numb conscience. "Having lost all sense of shame, they have given themselves over to sensuality for the practice of every kind of impurity, with a craving for more" (v. 19). Sin promises satisfaction, but it only creates more craving.

"But this is not the way you came to know Christ" (v. 20). Knowing Jesus means a completely different direction.

Paul uses the picture of changing clothes. We are "to put off your former way of life, your old self, which is being corrupted by its deceitful desires" (v. 22). Old habits lie to us. They promise life but lead to decay.

Then we are "to be renewed in the spirit of your minds" (v. 23). Change starts on the inside, with new thinking shaped by God's truth.

Finally, we are "to put on the new self, created to be like God in true righteousness and holiness" (v. 24). The new self isn't something we make up. God has already created it in Christ. Our job is to put it on every day and stop sneaking back to the old clothes.$d$,
   $d$This passage teaches me that following Jesus is not just adding something good to my old life. It is putting off the old self and putting on the new. I can't fully walk in my new life while I keep my old ways hidden under the mattress.

I confess there are old habits I still hold on to. Some of them I tell myself are harmless. Others I keep "just in case." But they are corrupted by deceitful desires. They promise freedom and deliver chains.

Knowing that a hardened heart leads to a darkened mind, I should be quick to repent when I notice myself becoming numb to sin. I don't want to lose my sense of shame over things that grieve God.

Because I have a new self created to be like God in true righteousness and holiness, I will strive to put it on each morning. I will also renew my mind by filling it with God's Word instead of the world's noise. This week, I will name one old habit I have been secretly keeping, confess it to God, and take one practical step to get rid of it for good.$d$,
   $d$Holy God, thank You for giving me a new self, created to be like You in true righteousness and holiness. Forgive me for clinging to my old ways and hiding them where I think no one can see. Soften my heart so that I never become numb to sin. Renew the spirit of my mind with Your truth. Give me the courage to throw away what belongs to my old life and to put on Christ every day. I want to walk in the new life You have given me. In Jesus' name, amen.$d$,
   NULL),
  (DATE '2026-11-20',
   $d$Never Go to Sleep Angry$d$,
   $d$Ephesians 4:25–32 (BSB)$d$,
   NULL,
   $d$25Therefore each of you must put off falsehood and speak truthfully to his neighbor, for we are all members of one another. 26“Be angry, yet do not sin.” Do not let the sun set upon your anger, 27and do not give the devil a foothold. 28He who has been stealing must steal no longer, but must work, doing good with his own hands, that he may have something to share with the one in need. 29Let no unwholesome talk come out of your mouths, but only what is helpful for building up the one in need and bringing grace to those who listen. 30And do not grieve the Holy Spirit of God, in whom you were sealed for the day of redemption. 31Get rid of all bitterness, rage and anger, outcry and slander, along with every form of malice. 32Be kind and tenderhearted to one another, forgiving each other just as in Christ God forgave you.$d$,
   $d$Noel and Mylene had been married for twelve years. They ran a small bakery that opened at five every morning, so Noel always left the house at three to knead the dough.

On their wedding day, Mylene's grandmother had pulled them aside and given them one piece of advice: "Walang matutulog nang galit." Never go to sleep angry.

Most of the time, they kept that rule. But one night, they broke it.

It started with money. Mylene found out that Noel had lent their savings to his younger brother without telling her. Again. She was furious. Noel felt she didn't care about his family. Voices rose. Doors slammed. Mylene said something about his brother that she instantly regretted. Noel said something about her mother that made her cry.

They went to bed with their backs to each other.

At three in the morning, Noel got up, dressed in silence, and left for the bakery without a word.

Mylene lay in the dark, unable to sleep. Her grandmother's voice kept echoing in her mind. She thought about how hard Noel worked. She thought about his brother's sick child. She thought about the cruel thing she had said.

At four, she got up, made two cups of coffee, and walked the dark street to the bakery.

Noel was punching dough harder than necessary. He looked up when she came in.

She set the coffee down. "I'm sorry for what I said about your brother."

His shoulders dropped. "I'm sorry too. I should have told you. And what I said about your mother was wrong."

They stood together in the warm light of the ovens, kneading the dough side by side. By the time the first customers arrived, the pandesal was ready, and so were their hearts.$d$,
   $d$Paul now gets very practical. The new self shows up in our daily words and actions.

First, honesty. "Each of you must put off falsehood and speak truthfully to his neighbor, for we are all members of one another" (v. 25). Lying to a fellow believer is like one hand lying to the other. It harms the whole body.

Second, anger. "Be angry, yet do not sin. Do not let the sun set upon your anger, and do not give the devil a foothold" (vv. 26–27). Not all anger is sinful. But anger that is held overnight becomes resentment, and resentment gives the devil a place to stand in our hearts. Deal with it quickly.

Third, work. "He who has been stealing must steal no longer, but must work, doing good with his own hands, that he may have something to share with the one in need" (v. 28). The goal of work is not just to stop taking, but to start giving.

Fourth, words. "Let no unwholesome talk come out of your mouths, but only what is helpful for building up the one in need and bringing grace to those who listen" (v. 29). "Unwholesome" means rotten. Our words should build up, not tear down.

Then Paul gives a tender warning: "Do not grieve the Holy Spirit of God" (v. 30). The Spirit is a person who can be saddened by our sin.

Finally, Paul tells us to "get rid of all bitterness, rage and anger" (v. 31), and instead, "be kind and tenderhearted to one another, forgiving each other just as in Christ God forgave you" (v. 32). We forgive because we have been forgiven.$d$,
   $d$This passage teaches me that my new life in Christ must show up in the small, everyday places: my words, my temper, my work, and my willingness to forgive. It is not enough to say I have put on the new self. My family and neighbors should be able to see it.

I confess that I sometimes let the sun go down on my anger. I go to bed nursing a grudge, replaying the argument, and rehearsing what I should have said. I didn't realize I was giving the devil a foothold in my home.

I am also convicted about my words. Some of the things I say, even jokingly, are rotten. They tear people down instead of bringing grace.

Knowing that the Holy Spirit can be grieved, I should be more sensitive to how my attitudes affect Him. Because God has forgiven me so completely in Christ, I have no right to hold on to bitterness.

I will strive to settle conflicts quickly, speak words that build up, and forgive freely. This week, if there is anyone I am angry with, I will not let another night pass without taking a step toward peace.$d$,
   $d$Father, You have forgiven me completely in Christ. Help me to forgive others the same way. Forgive me for the times I let the sun set on my anger and gave the devil a foothold. Guard my mouth from rotten words, and help me to speak only what builds up and brings grace. I don't want to grieve Your Holy Spirit. Remove all bitterness, rage, and malice from my heart. Make me kind and tenderhearted, especially toward those closest to me. In Jesus' name, amen.$d$,
   NULL),
  (DATE '2026-11-21',
   $d$Little Copycats Are Watching$d$,
   $d$Ephesians 5:1–7 (BSB)$d$,
   NULL,
   $d$1Be imitators of God, therefore, as beloved children, 2and walk in love, just as Christ loved us and gave Himself up for us as a fragrant sacrificial offering to God. 3But among you, as is proper among the saints, there must not be even a hint of sexual immorality, or of any kind of impurity, or of greed. 4Nor should there be obscenity, foolish talk, or crude joking, which are out of character, but rather thanksgiving. 5For of this you can be sure: No immoral, impure, or greedy person (that is, an idolater), has any inheritance in the kingdom of Christ and of God. 6Let no one deceive you with empty words, for because of such things the wrath of God is coming on the sons of disobedience. 7Therefore do not be partakers with them.$d$,
   $d$Joel was a construction worker with a loud laugh and a louder mouth. At the site, he was famous for his jokes, the kind that made the other workers roar and made the women walking past cover their ears. At home, he wasn't much different. When he hit his thumb or the TV signal went out, a stream of curse words followed.

His wife, Rosalie, had asked him many times to watch his language around the kids. He always laughed it off. "They're too young to understand."

Then came his mother's seventy-fifth birthday. The whole clan gathered in the small backyard. Joel's four-year-old son, Gabriel, was the star of the party, dancing and singing for his titas.

Then Gabriel climbed on a chair and announced, "I'll tell a joke like Papa!"

Everyone clapped. Joel grinned proudly.

Gabriel repeated, word for word, one of Joel's crudest jokes from the construction site.

The yard went silent. Joel's mother put her hand over her mouth. One of the titas quickly ushered the other kids away. Rosalie stared at Joel, her face burning.

Gabriel looked around, confused. "Why is nobody laughing? Papa's friends always laugh."

Joel felt like the ground had opened beneath him. He scooped up his son and carried him inside.

That night, after Gabriel fell asleep, Joel sat on the edge of the bed for a long time. "He was just copying me," he said quietly to Rosalie. "He'll become whatever I am."

The next day at the site, when someone started a dirty joke, Joel walked away. The men teased him for weeks. He didn't care.

Months later, Gabriel climbed on another chair at another family party. "I'll tell a joke like Papa!" This time, it was about a chicken crossing the road. And everyone laughed.$d$,
   $d$Paul gives us one of the most remarkable commands in the Bible: "Be imitators of God, therefore, as beloved children" (v. 1). Just as little children copy their parents, we are to copy our heavenly Father.

How do we imitate God? "Walk in love, just as Christ loved us and gave Himself up for us as a fragrant sacrificial offering to God" (v. 2). The love we imitate is not just a feeling. It is a self-giving love, the kind Jesus showed on the cross.

Then Paul contrasts this love with its counterfeits. "Among you, as is proper among the saints, there must not be even a hint of sexual immorality, or of any kind of impurity, or of greed" (v. 3). The world often confuses lust with love. But lust takes; love gives. Greed is similar. It always wants more for self.

Paul also addresses our speech: "Nor should there be obscenity, foolish talk, or crude joking, which are out of character, but rather thanksgiving" (v. 4). Dirty jokes and vulgar talk don't fit God's children. Instead, our mouths should overflow with gratitude.

Then comes a serious warning. "No immoral, impure, or greedy person (that is, an idolater), has any inheritance in the kingdom of Christ and of God" (v. 5). Paul calls greed idolatry because it puts things in God's place. People who live this way, with no repentance, show they don't belong to God's kingdom.

"Let no one deceive you with empty words" (v. 6). The world says these things are harmless. But God's judgment is real. "Therefore do not be partakers with them" (v. 7).

Beloved children want to look like their Father.$d$,
   $d$This passage teaches me that I am called to be an imitator of God, like a beloved child who copies his father. That is both a privilege and a responsibility. The more I spend time with Him, the more I should resemble Him.

I am challenged by the standard Paul sets: not even a hint of impurity or greed. I confess that I sometimes excuse small compromises. I laugh at jokes I shouldn't laugh at. I entertain thoughts I shouldn't entertain. I want more when I should be grateful for what I have.

Knowing that others, especially those younger than me, are watching and copying my example, I should take my words and actions more seriously. My children, my students, my younger siblings, or new believers may become what they see in me.

Because Christ gave Himself up for me, I will strive to walk in love that gives rather than takes. I will replace crude talk with thanksgiving. This week, I will pay attention to my words and the content I allow into my mind. I will eliminate one thing that does not fit a child of God, and I will begin each day by thanking Him for at least three blessings.$d$,
   $d$Father, I want to be an imitator of You, as Your beloved child. Teach me to walk in love, just as Christ loved me and gave Himself up for me. Forgive me for the times I have allowed impurity, greed, or crude talk into my life. Cleanse my heart and my mouth. Fill me with thanksgiving instead. Help me to remember that others are watching me, and let them see something of You in my life. Keep me from being deceived by empty words. In Jesus' name, amen.$d$,
   $d$This week, Paul moved from what we believe to how we live. On Monday, we were urged to walk worthy of our calling, with humility, gentleness, and patience, preserving the unity of the Spirit. On Tuesday, we learned that Christ has given gifts to His church, and that leaders are meant to equip every believer for ministry. On Wednesday, we saw that mature believers are not tossed about by every wind of teaching, but grow together by speaking the truth in love. On Thursday, we were called to put off the old self and put on the new self, created to be like God. On Friday, Paul got practical: speak truthfully, deal with anger before sunset, work to give, build others up with our words, and forgive as God forgave us. And today, we were challenged to be imitators of God as beloved children, walking in love and leaving behind impurity, greed, and crude talk.

Next week, Paul will call us to live as children of light, walking wisely and being filled with the Spirit. Then he will bring the gospel into our homes and workplaces, speaking to husbands and wives, parents and children, and workers and employers. Finally, he will hand us the armor of God for the spiritual battle we all face. 🏁$d$),
  (DATE '2026-11-23',
   $d$The Cashier Who Wouldn't Turn Off the Light$d$,
   $d$Ephesians 5:8–14 (BSB)$d$,
   NULL,
   $d$8For you were once darkness, but now you are light in the Lord. Walk as children of light, 9for the fruit of the light consists in all goodness, righteousness, and truth. 10Test and prove what pleases the Lord. 11Have no fellowship with the fruitless deeds of darkness, but rather expose them. 12For it is shameful even to mention what the disobedient do in secret. 13But everything exposed by the light becomes visible, for everything that is illuminated becomes a light itself. 14So it is said: “Wake up, O sleeper, rise up from the dead, and Christ will shine on you.”$d$,
   $d$Jenalyn was twenty-two and had just been hired as a cashier at a busy hardware store near the highway. The owner, Mr. Tan, was strict but fair, and the pay was enough to help her parents and send her younger brother to school.

In her second month, two of the older cashiers, Lani and Marivic, invited her to have a merienda with them.

"You're nice, Jenalyn," Lani said. "So we'll teach you how things work here. When a customer pays cash and doesn't ask for a receipt, you don't punch it in. You just keep it in the drawer and we split it at the end of the day. Small amounts only. Mr. Tan never notices."

Jenalyn's stomach dropped. "I can't do that."

Marivic laughed. "Everyone does it. Don't be so innocent."

For weeks, they ignored her. They stopped inviting her to merienda. They whispered when she passed. Jenalyn punched in every sale, every peso, every time.

Then one Friday, Mr. Tan called all the cashiers into his office. Inventory didn't match the sales. Someone had been stealing. He looked at each of them.

"I'll ask once. Does anyone know anything?"

Lani and Marivic stared at the floor. Jenalyn's heart pounded. She thought about her job. She thought about her brother's tuition. Then she spoke quietly and told him the truth.

Lani and Marivic were let go. For a while, Jenalyn felt terrible.

Six months later, Marivic walked into the store. Jenalyn froze. But Marivic came to the counter with tears in her eyes.

"I got a new job. I don't do that anymore. Getting caught was the best thing that happened to me. Thank you for not playing along."

Jenalyn reached across the counter and squeezed her hand.$d$,
   $d$Paul says something striking: "For you were once darkness, but now you are light in the Lord" (v. 8). He doesn't just say we were in darkness. We were darkness. And now we don't just have light; we are light, because we belong to the Lord.

So he says, "Walk as children of light." Light has a recognizable fruit: "all goodness, righteousness, and truth" (v. 9). Goodness is how we treat others. Righteousness is doing what is right before God. Truth is honesty in word and life.

Children of light also "test and prove what pleases the Lord" (v. 10). In every decision, the question is not "What can I get away with?" but "What would please Him?"

Then Paul says, "Have no fellowship with the fruitless deeds of darkness, but rather expose them" (v. 11). Sin produces nothing good in the end. So we should refuse to participate, and we should let our lives shine in a way that shows sin for what it is. Some things done in secret are so shameful that Paul doesn't even want to describe them (v. 12).

But here is the hope: "Everything exposed by the light becomes visible, for everything that is illuminated becomes a light itself" (v. 13). When sin is brought into the light, people can repent, be forgiven, and become children of light too.

Paul ends with what may have been an early Christian song: "Wake up, O sleeper, rise up from the dead, and Christ will shine on you" (v. 14). It is a call to every believer who has grown spiritually sleepy. Wake up. Shine.$d$,
   $d$This passage teaches me that I am not just someone who visits the light now and then. In the Lord, I am light. That means my life should produce the fruit of goodness, righteousness, and truth, even when no one else around me does.

I confess that it is often easier to stay quiet and go along with the crowd. I don't want to be the odd one out or lose friends. But children of light can't have fellowship with deeds of darkness.

Knowing that exposure can lead to healing, I should not be afraid of the light, both in my own life and in the lives of others. When my sin is exposed, I want to repent rather than hide. And when I see wrong, I want to respond with courage and compassion.

I should ask the Lord to wake me up in any area where I have become spiritually sleepy. I don't want to drift through life with my light dimmed.

I will strive to test every decision by asking, "Does this please the Lord?" This week, I will refuse to take part in one thing I know is wrong, even if it costs me something, and I will pray for someone who needs to come into the light.$d$,
   $d$Lord, I was once darkness, but now I am light in You. Thank You for shining on me. Help me to walk as a child of light, bearing the fruit of goodness, righteousness, and truth. Give me courage to refuse the deeds of darkness, even when it is unpopular. Wake me up wherever I have become spiritually sleepy. Let my life expose what is wrong, not with pride, but with love, so that others may also come into Your light. In Jesus' name, amen.$d$,
   NULL),
  (DATE '2026-11-24',
   $d$What Are You Doing While You Wait?$d$,
   $d$Ephesians 5:15–21 (BSB)$d$,
   NULL,
   $d$15Pay careful attention, then, to how you walk, not as unwise but as wise, 16redeeming the time, because the days are evil. 17Therefore do not be foolish, but understand what the Lord’s will is. 18Do not get drunk on wine, which leads to reckless indiscretion. Instead, be filled with the Spirit. 19Speak to one another with psalms, hymns, and spiritual songs. Sing and make music in your hearts to the Lord, 20always giving thanks to God the Father for everything in the name of our Lord Jesus Christ. 21Submit to one another out of reverence for Christ.$d$,
   $d$Jasper was a twenty-year-old delivery rider. Most of his day wasn't spent riding. It was spent waiting: waiting for orders, waiting outside restaurants, waiting in parking lots for the next notification.

He filled every minute with his phone. Videos, games, endless scrolling. By the end of each day, he couldn't remember a single thing he'd watched.

One afternoon, he noticed another rider in the waiting area outside a fast-food place. Mario was older, maybe forty, with gray in his hair. He sat on his motorcycle with a worn notebook and a thick reviewer, mouthing words to himself.

"What's that, Kuya?"

Mario looked up, a little embarrassed. "ALS reviewer. I never finished high school. My exam is in March."

"You study while waiting for orders?"

"I figured out I wait about four hours a day. That's twenty-eight hours a week. I can't waste that." He smiled. "My daughter will graduate from high school next year. I want to graduate before her."

Jasper laughed, but the words stayed with him. That night, he checked his phone's screen time. Six hours and forty minutes. He felt a little sick.

The next day, during his waiting time, he left the games closed. He downloaded free lessons on basic accounting, something he had always been curious about. It was hard at first. His fingers kept drifting to the old apps.

Months later, Jasper and Mario sat together in the same waiting area. Mario was holding a certificate: he had passed. Jasper was halfway through an online bookkeeping course.

"We still wait the same number of hours," Mario said, grinning.

Jasper nodded. "But now the waiting is taking us somewhere."

When their phones buzzed with new orders, they bumped fists and rode off.$d$,
   $d$Paul continues: "Pay careful attention, then, to how you walk, not as unwise but as wise" (v. 15). A wise person lives with intention, not by accident.

One mark of wisdom is "redeeming the time, because the days are evil" (v. 16). To "redeem" time means to buy it back, to make the most of every opportunity. Time is one of God's most precious gifts, and we can't get it back once it is gone. In a world full of distraction and evil, wise believers use their time for what matters.

"Therefore do not be foolish, but understand what the Lord's will is" (v. 17). God's will is not hidden. Much of it is already clearly written in His Word.

Then Paul gives a contrast: "Do not get drunk on wine, which leads to reckless indiscretion. Instead, be filled with the Spirit" (v. 18). A drunk person is controlled by alcohol. A Spirit-filled person is controlled by God. Being filled with the Spirit is not a one-time event; the verb means "keep on being filled."

What does a Spirit-filled life look like? Paul gives four signs. We encourage one another with "psalms, hymns, and spiritual songs" (v. 19). We worship from the heart: "Sing and make music in your hearts to the Lord." We are thankful: "always giving thanks to God the Father for everything" (v. 20). And we are humble: "Submit to one another out of reverence for Christ" (v. 21).

The Spirit-filled life isn't mainly about dramatic experiences. It is seen in grateful hearts, singing lips, and humble relationships.$d$,
   $d$This passage teaches me that time is a gift I will one day give account for. The days are evil, and distractions are everywhere. If I am not careful, I can spend hours each day on things that leave me empty and forgetful.

I confess that I often walk carelessly. I let my time slip away through endless scrolling, idle talk, and entertainment. I am busy but not always wise.

Knowing that God wants me to be filled with the Spirit, I should ask the Lord to fill me again each day. I don't want to be controlled by alcohol, my phone, my moods, or anything else. I want to be controlled by Him.

Because of this, I will strive to redeem the time God has given me. I will look for "waiting time" in my day and turn it into time for prayer, Scripture, learning, or encouraging someone. I will also fill my heart with songs of worship and my mouth with thanksgiving.

This week, I will check how I am spending my time, cut back on one time-wasting habit, and use that time to grow spiritually or to serve someone else.$d$,
   $d$Lord, teach me to walk wisely and to redeem the time You have given me. Forgive me for the hours I have wasted on things that don't matter. Help me to understand Your will. Fill me with Your Spirit, not just once, but every day. Let my heart overflow with songs of worship and my mouth with thanksgiving for everything. Give me a humble spirit that submits to others out of reverence for Christ. Let my life, minute by minute, honor You. In Jesus' name, amen.$d$,
   NULL),
  (DATE '2026-11-25',
   $d$Forty Years Under One Umbrella$d$,
   $d$Ephesians 5:22–33 (BSB)$d$,
   NULL,
   $d$22Wives, submit to your husbands as to the Lord. 23For the husband is the head of the wife as Christ is the head of the church, His body, of which He is the Savior. 24Now as the church submits to Christ, so also wives should submit to their husbands in everything. 25Husbands, love your wives, just as Christ loved the church and gave Himself up for her 26to sanctify her, cleansing her by the washing with water through the word, 27and to present her to Himself as a glorious church, without stain or wrinkle or any such blemish, but holy and blameless. 28In the same way, husbands ought to love their wives as their own bodies. He who loves his wife loves himself. 29Indeed, no one ever hated his own body, but he nourishes and cherishes it, just as Christ does the church. 30For we are members of His body. 31“For this reason a man will leave his father and mother and be united to his wife, and the two will become one flesh.” 32This mystery is profound, but I am speaking about Christ and the church. 33Nevertheless, each one of you also must love his wife as he loves himself, and the wife must respect her husband.$d$,
   $d$At their fortieth wedding anniversary, the family gathered in the small yard of Roberto and Lydia's house. There was pancit, lumpia, and a cake their grandchildren had decorated with too much frosting.

When it was time for messages, their granddaughter Trisha, who was getting married the following year, stood up with a question.

"Lolo, Lola, what's your secret?"

Lydia laughed. "Ask your Lolo about the umbrella."

Everyone turned to Roberto. He shrugged. "There's no secret. When it rains, I hold the umbrella over her."

The grandchildren looked confused. But the older relatives were nodding.

Lydia explained. For forty years, whenever it rained, Roberto had held the umbrella. Not over both of them equally, but tilted toward her. By the time they arrived, her clothes were dry and his shoulder was soaked.

"At first, I thought he was just being silly," she said. "But then I realized he does that in everything. When money was tight, he skipped meals so the kids and I could eat. When I was sick, he cooked, washed, and still went to work. He always tilts the umbrella toward me."

She looked at her husband. "So I decided long ago that I would never make him feel small. When he makes decisions for the family, I tell him what I think, but in the end I trust him and support him. I honor him in front of the kids. I never put him down in front of other people."

Roberto cleared his throat. "That's why it's easy to hold the umbrella. She makes me feel like the strongest man in the world."

Trisha wiped her eyes. Her fiancé, sitting beside her, quietly reached for her hand.

Later that evening, as the family left, a light rain began to fall. Roberto opened the umbrella and tilted it toward Lydia.$d$,
   $d$This is one of the most discussed passages in the Bible, and sometimes one of the most misunderstood. It helps to remember that it starts in verse 21: "Submit to one another out of reverence for Christ." Every relationship in a Christian home is built on mutual humility.

Paul first speaks to wives: "Wives, submit to your husbands as to the Lord" (v. 22). Submission doesn't mean wives are inferior or that their opinions don't matter. In Christ, husbands and wives are equal heirs of grace. Submission means a wife willingly supports and follows her husband's leadership, "as to the Lord." It is not blind obedience, and it never means submitting to abuse or to sin.

Then Paul speaks to husbands, and he spends far more words on them. "Husbands, love your wives, just as Christ loved the church and gave Himself up for her" (v. 25). Husbands are called to lead, but their model is Jesus, who led by laying down His life. A Christlike husband doesn't demand his way. He sacrifices for his wife's good.

Christ's love has a goal: to make the church "holy and blameless" (v. 27). In the same way, a husband should help his wife grow spiritually. He should "nourish and cherish" her as he cares for his own body (vv. 28–29).

Then Paul reveals something profound. Marriage is a living picture of "Christ and the church" (v. 32). When a husband loves sacrificially and a wife respects joyfully, the world gets a glimpse of the gospel.

Paul sums it up: each husband "must love his wife as he loves himself, and the wife must respect her husband" (v. 33).$d$,
   $d$This passage teaches me that marriage is far more than a human arrangement. It is meant to be a picture of Christ and His church. Whether I am married, single, or hoping to be married one day, I am reminded that God takes this relationship seriously.

If I am a husband, I am challenged to love my wife the way Christ loves the church. That means sacrificing my comfort, my pride, and my preferences for her good. I should ask the Lord to make me a leader who serves, not one who demands.

If I am a wife, I am challenged to respect and support my husband, not because he is perfect, but out of reverence for Christ. I should guard my words so that I build him up instead of tearing him down.

Whatever my situation, I will strive to practice mutual submission in all my relationships. I will look for ways to tilt the umbrella toward others.

This week, if I am married, I will do one specific act of sacrificial love or respect for my spouse. If I am not, I will pray for the marriages in my family and church, asking God to make them a beautiful picture of the gospel.$d$,
   $d$Lord Jesus, thank You for loving the church and giving Yourself up for her. Thank You that I am part of the bride You are making holy and blameless. Bless the marriages in my family and in my church. Teach husbands to love sacrificially and wives to respect joyfully. Heal marriages that are hurting. Keep us all humble, submitting to one another out of reverence for You. Let every Christian home be a living picture of Your love for Your people. Amen.$d$,
   NULL),
  (DATE '2026-11-26',
   $d$The Night Papa Stopped Shouting$d$,
   $d$Ephesians 6:1–4 (BSB)$d$,
   NULL,
   $d$1Children, obey your parents in the Lord, for this is right. 2“Honor your father and mother” (which is the first commandment with a promise), 3“that it may go well with you and that you may have a long life on the earth.” 4Fathers, do not provoke your children to wrath; instead, bring them up in the discipline and instruction of the Lord.$d$,
   $d$Ariel sold balut every night from eight until past midnight, walking the streets with his basket and calling out, "Baluuuut!" During the day, he slept a few hours and then worked as a helper at a welding shop. He was always tired.

His fifteen-year-old daughter, Kaye, was always angry.

She came home late from school without texting. She spent hours on her phone. She rolled her eyes when he spoke. And every time she did, Ariel exploded.

"Wala kang respeto! I work day and night for you!"

Kaye would slam her door. The next day, it would happen again.

One evening, Ariel's neighbor, an older man named Lucio, walked with him for a while on his balut route.

"You shout at your daughter a lot," Lucio said gently.

"She doesn't listen."

"Maybe she doesn't feel heard either." Lucio paused. "I shouted at my son for years. Now he lives in Cebu and calls me twice a year. I wish I had spent more time listening."

That night, Ariel came home early. Kaye was in her room. He knocked softly.

"Anak, can I come in?"

She looked surprised. He sat on the edge of her bed with a warm balut wrapped in paper.

"I'm sorry for shouting," he said. "Tell me about your day. I want to hear."

At first, she said nothing. Then, slowly, it came out: a friend had betrayed her, a teacher had embarrassed her in class, and she felt alone.

Ariel just listened.

A few weeks later, Ariel came home past midnight, exhausted. On the table was a plate of rice and fried egg, covered with a plate, and a note in Kaye's handwriting: "Pa, kain ka muna. Thank you for working so hard. I love you."

He kept that note in his wallet.$d$,
   $d$Paul now turns to children and parents. "Children, obey your parents in the Lord, for this is right" (v. 1). Notice that Paul speaks directly to children, which means children were present when this letter was read in church. They are full members of God's family, and God has instructions for them too.

Obedience is "right" because it reflects God's order for the family. The phrase "in the Lord" means children obey as part of their obedience to Jesus. It also means they are not required to obey anything that would clearly go against God's commands.

Paul then quotes the fifth commandment: "Honor your father and mother" (v. 2). Obedience is about actions; honor is about attitude. Even as adults, when we no longer have to obey our parents in everything, we are still called to honor them, respect them, care for them, and speak well of them.

Paul notes that this is "the first commandment with a promise": "that it may go well with you and that you may have a long life on the earth" (v. 3). In general, families where children honor their parents tend to be healthier and more stable.

Then Paul speaks to fathers: "Fathers, do not provoke your children to wrath" (v. 4). In Paul's culture, fathers had almost total authority. Paul tells them not to abuse it. Harshness, constant criticism, unfairness, and neglect can crush a child's spirit.

Instead, fathers are to "bring them up in the discipline and instruction of the Lord." Discipline means training and correction. Instruction means teaching. Both should be done with patience and love, pointing children to Jesus.$d$,
   $d$This passage teaches me that God cares deeply about relationships between parents and children. Whether I am a child, a parent, or both, I have a role to play in building a home that honors Him.

As a son or daughter, I should ask myself whether I truly honor my parents. Do I speak respectfully to them and about them? Do I show gratitude for their sacrifices? Even if they have made mistakes, God calls me to honor them.

If I am a parent, I am challenged by the warning not to provoke my children. I confess that I sometimes discipline in anger instead of love. I lecture more than I listen. I forget that my children need my time and attention, not just my provision.

Knowing that children are to be brought up in the discipline and instruction of the Lord, I should take my role seriously. Teaching my children about Jesus is not just the church's job. It begins at home.

I will strive to be patient, to listen more, and to point my family to Christ. This week, I will spend unhurried time with my parents or my children, and I will express my love and gratitude in words.$d$,
   $d$Heavenly Father, thank You for the gift of family. Help me to honor my parents, not only with my actions but with my attitude. If I am a parent, give me patience and wisdom. Forgive me for the times I have provoked my children through harshness or neglect. Teach me to listen, to correct with love, and to point my children to You. Heal broken relationships in my family. Let our homes be places where Your Word is taught and lived. In Jesus' name, amen.$d$,
   NULL),
  (DATE '2026-11-27',
   $d$Working When the Boss Isn't Looking$d$,
   $d$Ephesians 6:5–9 (BSB)$d$,
   NULL,
   $d$5Slaves, obey your earthly masters with respect and fear and sincerity of heart, just as you would obey Christ. 6And do this not only to please them while they are watching, but as servants of Christ, doing the will of God from your heart. 7Serve with good will, as to the Lord and not to men, 8because you know that the Lord will reward each one for whatever good he does, whether he is slave or free. 9And masters, do the same for your slaves. Give up your use of threats, because you know that He who is both their Master and yours is in heaven, and there is no favoritism with Him.$d$,
   $d$Bernard worked the night shift as a security guard at a rice warehouse on the edge of town. His job was simple: walk around the building every hour, check the doors, sign the logbook, and stay awake.

His fellow guard, Ronnie, had a different approach. As soon as the owner, Mr. Lim, left for the night, Ronnie would set an alarm, stretch out on a sack of rice, and sleep until morning. Before he left, he would fill in the logbook as if he had done every round.

"Pare, nobody checks," he told Bernard. "Relax."

But Bernard kept walking every hour, flashlight in hand, even on rainy nights when the mud came up to his ankles. When people asked him why, he just said, "That's what I'm paid for."

What neither of them knew was that Mr. Lim had installed new CCTV cameras. For two months, he quietly reviewed the footage. Night after night, he saw Ronnie sleeping and Bernard walking.

Mr. Lim was not an easy boss. He was known for shouting and threatening to fire people over small mistakes. But watching Bernard's faithfulness shook him.

He called Bernard into his office. "You did your rounds every night, even when nobody was watching. Why?"

Bernard shrugged. "Sir, I don't work just for you. I work for God. He's always watching."

Mr. Lim was quiet for a long time.

Bernard was promoted to head of security, with a raise. But something else happened too. Mr. Lim started treating his workers differently. He stopped shouting. He gave everyone a day off on their birthdays. He even gave Ronnie a second chance, with a warning.

Months later, a worker asked Mr. Lim why he had changed.

He pointed out the window to where Bernard was walking his rounds. "That guard taught me who the real Boss is."$d$,
   $d$In Paul's time, slavery was a normal part of society. Some estimates say that a large part of the population of the Roman Empire was enslaved. Many early Christians were slaves, and some were masters.

The Bible does not endorse slavery as an ideal. In fact, the gospel planted seeds that would eventually undermine it, because masters and slaves were brothers in Christ. But Paul starts where people are and teaches them how to live as believers in their situation.

Today, the closest application is to employees and employers.

To workers, Paul says: "Obey your earthly masters with respect and fear and sincerity of heart, just as you would obey Christ" (v. 5). Our work is ultimately service to Jesus.

He continues: "Do this not only to please them while they are watching, but as servants of Christ, doing the will of God from your heart" (v. 6). Some people only work hard when the boss is watching. Christians should work faithfully even when no one sees, because God always sees.

"Serve with good will, as to the Lord and not to men" (v. 7). And there is a reward: "the Lord will reward each one for whatever good he does" (v. 8). Even if no earthly boss notices, God will.

To masters, Paul says: "Do the same for your slaves" (v. 9). Treat those under you with the same sincerity and good will. "Give up your use of threats." Why? Because "He who is both their Master and yours is in heaven, and there is no favoritism with Him."

Bosses and workers stand on level ground before God. Both serve the same Master.$d$,
   $d$This passage teaches me that my work is a place of worship. Whether I am a student, a vendor, an employee, a helper, or a boss, I am ultimately serving the Lord Jesus. That changes how I see my job.

I confess that I sometimes work hard only when I am being watched. I cut corners when no one is checking. I complain about my boss behind his back. But God sees everything, and He is the one I truly serve.

Knowing that the Lord will reward every good thing I do, I should stop worrying so much about whether people notice my efforts. My faithfulness is never wasted, even if it goes unseen.

If I have people under me, I am also challenged to treat them fairly, kindly, and without threats. My authority is borrowed. I have a Master in heaven too, and He shows no favoritism.

I will strive to work with sincerity of heart, as if Jesus Himself were my supervisor, because He is. This week, I will do one task with excellence even though no one will see it, and I will thank or encourage someone I work with.$d$,
   $d$Lord Jesus, You are my true Master. Help me to see my work as service to You. Forgive me for the times I worked only to please people, or only when someone was watching. Give me a sincere heart and good will in everything I do. If I lead others, help me to lead without threats, with fairness and kindness. Remind me that You see every faithful act and that You will reward it. Let my work be a testimony of Your grace. Amen.$d$,
   NULL),
  (DATE '2026-11-28',
   $d$Suit Up Before You Step Out$d$,
   $d$Ephesians 6:10–17 (BSB)$d$,
   NULL,
   $d$10Finally, be strong in the Lord and in His mighty power. 11Put on the full armor of God, so that you can make your stand against the devil’s schemes. 12For our struggle is not against flesh and blood, but against the rulers, against the authorities, against the powers of this world’s darkness, and against the spiritual forces of evil in the heavenly realms. 13Therefore take up the full armor of God, so that when the day of evil comes, you will be able to stand your ground, and having done everything, to stand. 14Stand firm then, with the belt of truth buckled around your waist, with the breastplate of righteousness arrayed, 15and with your feet fitted with the readiness of the gospel of peace. 16In addition to all this, take up the shield of faith, with which you can extinguish all the flaming arrows of the evil one. 17And take the helmet of salvation and the sword of the Spirit, which is the word of God.$d$,
   $d$Alvin was a lineman for the electric cooperative. Every morning before climbing a post, he went through the same routine. Hard hat. Safety glasses. Rubber gloves. Sleeves. Harness. Boots. He checked every piece, every strap, every buckle.

The younger linemen teased him. "Kuya Alvin, it's just a small repair! You take ten minutes just to get dressed!"

He always answered the same way. "The wire doesn't care how small the repair is."

They laughed. Some of them didn't bother with the gloves for quick jobs. It was hot, and the gear was heavy.

One afternoon, after a typhoon, the crew was called to restore power in a flooded barangay. The lines were tangled, and the power company had confirmed that the section was switched off. One of the younger linemen, Mark, climbed up without his gloves.

Alvin climbed the next post, fully geared up as always.

Suddenly there was a loud pop and a flash. Somewhere down the line, someone had reconnected a generator illegally, sending current back into the wire. Mark had just pulled his hand away, shaken but unhurt. But a wire whipped loose and struck Alvin's arm.

Everyone screamed. Alvin hung in his harness for a moment, stunned. Then he gave a thumbs up.

His rubber gloves and sleeves had taken the charge. His harness had held him. His hard hat had protected his head when he hit the post.

That evening, back at the station, the younger linemen were quiet. The next morning, Alvin found them all in the equipment room before him, carefully putting on every piece of gear.

Mark grinned at him, buckling his harness. "Kuya, we're not just getting dressed. We're getting ready."

Alvin laughed and handed him a pair of gloves.$d$,
   $d$Paul begins his conclusion with a call to battle: "Finally, be strong in the Lord and in His mighty power" (v. 10). Our strength isn't our own. It comes from the same power that raised Jesus from the dead.

Why do we need strength? Because we face an enemy. "Put on the full armor of God, so that you can make your stand against the devil's schemes" (v. 11). The devil is real, and he is crafty. He uses temptation, discouragement, lies, and division.

Paul makes it clear: "Our struggle is not against flesh and blood" (v. 12). Our real enemies are not our neighbors, spouses, or coworkers. Behind much of the conflict and evil in the world are "spiritual forces of evil in the heavenly realms."

So Paul says to "take up the full armor of God," so that we "will be able to stand" (v. 13). Notice how often he uses the word "stand." Our goal is not to attack wildly but to hold our ground.

Then he describes the armor, piece by piece (vv. 14–17):

The belt of truth: living honestly and holding to God's truth.

The breastplate of righteousness: the right standing Christ gives us, and a life of obedience that guards our hearts.

Feet fitted with the gospel of peace: being ready to stand firm and to share the good news.

The shield of faith: trusting God's promises to extinguish the devil's flaming arrows of doubt and accusation.

The helmet of salvation: the assurance that we belong to God.

The sword of the Spirit, which is the word of God: our only offensive weapon, used to resist lies.

The armor is not optional. We must put it on every day.$d$,
   $d$This passage teaches me that I am in a spiritual battle whether I recognize it or not. The devil has schemes, and he is targeting my mind, my home, my church, and my faith. I can't afford to step out each day unprotected.

I confess that I often fight the wrong enemy. I get angry at people when the real battle is spiritual. I forget that my struggle is not against flesh and blood.

I also confess that I sometimes go into my day without preparing. I skip prayer. I neglect God's Word. I treat spiritual armor like something optional for "big" problems, forgetting that temptation doesn't care how small the moment is.

Knowing that God has given me everything I need to stand, I should put on His armor daily. I want to be anchored in truth, guarded by righteousness, ready with the gospel, protected by faith and salvation, and armed with God's Word.

I will strive to begin each morning by consciously putting on the armor of God through prayer and Scripture. This week, I will memorize one verse to use as my "sword" against a specific temptation or lie I often face.$d$,
   $d$Lord, I want to be strong in You and in Your mighty power. Thank You for giving me Your full armor. Today I put on the belt of truth, the breastplate of righteousness, and the readiness of the gospel of peace. I take up the shield of faith, the helmet of salvation, and the sword of the Spirit, which is Your Word. Help me to recognize the devil's schemes and to stand firm. Remind me that my struggle is not against people. Give me victory through Jesus. Amen.$d$,
   $d$This week, Paul showed us how the gospel shapes every part of our lives. On Monday, we were reminded that we are light in the Lord, called to walk as children of light and to expose the deeds of darkness. On Tuesday, we learned to walk wisely, redeeming the time and being filled with the Spirit, with hearts full of song and thanksgiving. On Wednesday, we saw that Christian marriage is a picture of Christ and the church, where husbands love sacrificially and wives respect joyfully. On Thursday, Paul spoke to children and parents, calling children to honor and parents to raise their children in the Lord without provoking them. On Friday, we learned that our work is service to Christ, whether anyone is watching or not, and that bosses and workers serve the same Master. And today, we were called to be strong in the Lord and to put on the full armor of God so that we can stand.

On Monday, we will finish the book of Ephesians. Paul will call us to pray at all times for all the saints, ask for prayer for his own bold witness, and close his letter with words of peace, love, and grace. 🏁$d$),
  (DATE '2026-11-30',
   $d$The Prayer List on the Refrigerator$d$,
   $d$Ephesians 6:18–24 (BSB)$d$,
   NULL,
   $d$18Pray in the Spirit at all times, with every kind of prayer and petition. To this end, stay alert with all perseverance in your prayers for all the saints. 19Pray also for me, that whenever I open my mouth, words may be given me so that I will boldly make known the mystery of the gospel, 20for which I am an ambassador in chains. Pray that I may proclaim it fearlessly, as I should. 21Tychicus, the beloved brother and faithful servant in the Lord, will tell you everything, so that you also may know about me and what I am doing. 22I have sent him to you for this very purpose, that you may know about us, and that he may encourage your hearts. 23Peace to the brothers and love with faith from God the Father and the Lord Jesus Christ. 24Grace to all who love our Lord Jesus Christ with an undying love.$d$,
   $d$Tita Luz had not left her house in three years. Her knees had grown too weak for the stairs, and she spent most of her days in a chair by the window, watching the street.

But she was not idle.

On her refrigerator was a long sheet of paper, taped at the corners and filled with names in shaky handwriting. Next to each name was a short note. "Rachel, looking for work." "The Cruz family, new baby." "Nathan, sad lately."

Every morning, after her breakfast of pandesal and coffee, Tita Luz shuffled to the refrigerator and prayed through every name. Every evening, she did it again.

Nathan was the nineteen-year-old who lived across the street. He had dropped out of college after his father died. He had stopped coming to the youth group. He spent most nights alone on the rooftop, staring at nothing.

He didn't know that Tita Luz watched his light go on and off every night. He didn't know that she prayed for him by name twice a day.

One afternoon, Tita Luz's daughter asked Nathan to help carry a new electric fan up to her mother's room. As he set it down, he noticed the list on the refrigerator. His own name was there, with a date written beside it from eight months ago. Beside that, in a different color ink: "Still praying."

He stood there for a long time.

"Tita... you've been praying for me?"

She smiled. "Every day, anak. Since your father passed."

Nathan sat on the floor beside her chair and cried for the first time in months.

A year later, he was back in school and back in church. Every Saturday, he visits Tita Luz with fresh pandesal. He brings her news of the people on her list. And together, they add new names.$d$,
   $d$After describing the armor of God, Paul adds the most important element in spiritual battle: prayer. "Pray in the Spirit at all times, with every kind of prayer and petition" (v. 18).

Prayer is not one more piece of armor; it is what keeps the soldier connected to the Commander. "In the Spirit" means praying with the Holy Spirit's help, in line with God's will. "At all times" means prayer is not limited to emergencies or Sundays. "Every kind of prayer" includes praise, confession, thanksgiving, and requests.

Paul adds, "Stay alert with all perseverance in your prayers for all the saints." We don't fight alone. We pray for one another, and we keep praying even when answers seem slow.

Then Paul asks for prayer himself: "Pray also for me, that whenever I open my mouth, words may be given me so that I will boldly make known the mystery of the gospel" (v. 19). Notice what he doesn't ask for. He doesn't ask to be released from prison. He asks for boldness to keep preaching. He calls himself "an ambassador in chains" (v. 20). Even in prison, he represents the King.

Paul then mentions Tychicus, "the beloved brother and faithful servant in the Lord" (v. 21), who would carry the letter and share news. His job was to "encourage your hearts" (v. 22). Every church needs people like Tychicus.

The letter ends as it began, with grace and peace (vv. 23–24). Paul's final words are a blessing on "all who love our Lord Jesus Christ with an undying love." That is the heart of everything we have read this month: a God of grace, calling us to love Him forever.$d$,
   $d$This passage teaches me that prayer is not an extra activity for super-spiritual people. It is the lifeline of every believer. Paul calls me to pray in the Spirit at all times, with every kind of prayer, persevering for all the saints.

I confess that my prayers are often rushed, irregular, and focused mostly on myself. I don't always remember to pray for my brothers and sisters, and when I say "I'll pray for you," I sometimes forget.

I am moved by Paul's request. He was in chains, yet he asked not for comfort but for boldness. I should ask the Lord to give me that same desire: to make the gospel known clearly and fearlessly, wherever I am.

Knowing that Tychicus was sent to encourage hearts, I should also look for ways to be an encourager. A simple visit, a message, or a prayer can lift someone who is quietly struggling.

As I finish Ephesians, I will strive to keep loving the Lord Jesus with an undying love. This week, I will start my own prayer list with the names of people God has placed in my life, and I will pray for them faithfully.$d$,
   $d$Father, thank You for walking with me through the letter to the Ephesians. Thank You for every spiritual blessing in Christ, for grace that saved me, for making me part of Your family, and for the armor that helps me stand. Teach me to pray in the Spirit at all times, and to persevere in prayer for all the saints. Give me boldness to make the gospel known. Make me an encourager like Tychicus. Grant me peace, love, and faith, and help me to love Jesus with an undying love. Amen.$d$,
   NULL)
) as v(entry_date, title, scripture_ref, source_note, scripture_text, story, explanation, response, prayer, weekly_summary)
where c.slug = 'cgbc'
on conflict (church_id, entry_date) do nothing;

-- ledger (#212)
insert into public.schema_migrations (version, filename, note) values
  ('127','127_onboard_cgbc.sql','onboard Canlubang Grace Baptist Church (slug cgbc) + L5 pastor Symphony Don Alambat (NULL pin) + Nov 2026 Ephesians devotional guide (25 days)')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- SELF-VERIFY - rerun until all read PASS
select 'church present' as checkpoint,
       case when (select count(*) from churches where slug='cgbc') = 1 then 'PASS' else 'FAIL' end as status
union all
select 'pastor L5 (exactly one)',
       case when (select count(*) from members m join churches c on c.id=m.church_id
                   where c.slug='cgbc' and m.pipeline_level=5 and m.name='Symphony Don Alambat') = 1
            then 'PASS' else 'FAIL' end
union all
select 'November guide loaded (25 days)',
       case when (select count(*) from devotionals d join churches c on c.id=d.church_id
                   where c.slug='cgbc' and d.entry_date between date '2026-11-01' and date '2026-11-30') = 25
            then 'PASS' else 'FAIL' end
union all
select 'Rosehill guide untouched (still has Nov days)',
       case when (select count(*) from devotionals d join churches c on c.id=d.church_id
                   where c.slug='rosehill' and d.entry_date between date '2026-11-01' and date '2026-11-30') > 0
            then 'PASS' else 'CHECK' end
union all
select 'ledger 127',
       case when exists (select 1 from public.schema_migrations where version='127') then 'PASS' else 'FAIL' end;
