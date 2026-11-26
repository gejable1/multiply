-- migrations/130_devo_2026_12_daniel_bilingual.sql
-- S115 - December 2026 devotional guide (Daniel, 27 days: Dec 1-31, no Sundays)
-- for Rosehill, in English + a Tagalog DRAFT (tl_status = 'draft').
--   * English: parsed with devotional_admin.html's own parser from
--     RCC_Devotional_Guide_2026-12_Daniel.docx. Inserted ONLY if the day is not
--     already there (never overwrites an English day you already loaded).
--   * Tagalog: Claude's translation of title, story, explanation, response,
--     prayer and weekly summary. Scripture stays English (scripture_text_tl NULL,
--     so the apps show the BSB text). Written only where tl_status is NULL or
--     'draft' -- a day you have marked 'reviewed' is never overwritten.
--   * Members see Tagalog only after the Pastor marks a day 'reviewed'.
-- NEEDS migration 129 first (the *_tl columns). Stops with a clear message if not.
-- author = 'Rosehill Christian Church' (credit Rosehill, no personal name).
-- RUN FLAT (no BEGIN/COMMIT). Idempotent. No new tables (no GRANTs needed).

-- (0) Guard: 129 must be run first
DO $g$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                  WHERE table_schema='public' AND table_name='devotionals' AND column_name='tl_status') THEN
    RAISE EXCEPTION 'Run migrations/129_devotional_tagalog.sql first, then run this script again.';
  END IF;
END
$g$;

-- (1) English days (insert only if missing)
INSERT INTO public.devotionals
  (church_id, entry_date, title, scripture_ref, source_note, scripture_text,
   story, explanation, response, prayer, weekly_summary, author)
SELECT c.id, v.entry_date, v.title, v.scripture_ref, v.source_note, v.scripture_text,
       v.story, v.explanation, v.response, v.prayer, v.weekly_summary, 'Rosehill Christian Church'
  FROM public.churches c,
  (VALUES
  (DATE '2026-12-01', $q$Uprooted, But Not Unseen$q$, $q$Daniel 1:1–7 (BSB)$q$, NULL, $q$¹In the third year of the reign of Jehoiakim king of Judah, Nebuchadnezzar king of Babylon came to Jerusalem and besieged it. ²And the Lord delivered into his hand Jehoiakim king of Judah, along with some of the articles from the house of God. He carried these off to the land of Shinar, to the house of his god, where he put them in the treasury of his god. ³Then the king ordered Ashpenaz, the chief of his court officials, to bring in some Israelites from the royal family and the nobility— ⁴young men without blemish, handsome, gifted in all wisdom, knowledgeable, quick to understand, and qualified to serve in the king’s palace—and to teach them the language and literature of the Chaldeans. ⁵The king assigned them daily provisions of the royal food and wine. They were to be trained for three years, after which they were to enter the king’s service. ⁶Among these young men were some from Judah: Daniel, Hananiah, Mishael, and Azariah. ⁷The chief official gave them new names: To Daniel he gave the name Belteshazzar; to Hananiah, Shadrach; to Mishael, Meshach; and to Azariah, Abednego.$q$, $q$For forty-two years, Lolo Ernesto woke before sunrise to walk his rice field. He knew every dike, every water gate, and which corner flooded first when the rains came. Then the land was sold. A subdivision was going up, and his children agreed it was time for him to move in with his eldest son in the city.

The condo was on the fourteenth floor. It had cold air, a tiled floor, and no soil anywhere. Lolo Ernesto stood at the window for hours, looking down at roads where his field should have been.

The building guard called him "Tatay." The neighbors called him "Lolo of 14-C." His grandchildren were too busy with gadgets to ask what life was like on the farm. Some nights he felt like a man without a name.

One morning his granddaughter Bianca found him on the tiny balcony. He was tearing open an old rice sack he had secretly brought from the province. Inside was a handful of soil from the farm and a small bag of seeds.

"Lolo, what are you doing?"

"Remembering who I am," he said.

Within a month, the balcony was green with pechay, tomatoes, and kangkong in old paint cans. The guard asked for a few seedlings. A young nurse next door wanted to learn how to grow herbs. Soon Lolo Ernesto was teaching a little class every Saturday at the building's roof deck, with Bianca as his assistant.

"They moved me," he told her one afternoon, his hands brown with soil, "but they didn't uproot me. Some things you carry inside."

Bianca looked at him, really looked, for the first time in a long time. "Lolo," she said, "can you teach me how to plant rice someday?"

He laughed until his eyes were wet.$q$, $q$The book of Daniel opens with a disaster. Babylon's army surrounds Jerusalem, and the city falls. The king of Judah is taken. Sacred articles from God's temple are carried off and placed in the treasury of a pagan god. To anyone watching, it looks like Babylon's gods have won.

But look closely at verse 2: "The Lord delivered into his hand Jehoiakim king of Judah." Nebuchadnezzar thought he was in control. He wasn't. God was. This tragedy happened because God allowed it, as discipline for His people's long unfaithfulness. He had warned them through prophet after prophet. Even in judgment, God was still on His throne.

Then the story narrows to a few teenagers. Nebuchadnezzar wanted the best young men of Judah. He would teach them Babylon's language and literature, feed them from his table, and turn them into loyal servants. Their very names were changed. Daniel means "God is my judge." Hananiah means "the Lord is gracious." Mishael asks "who is like God?" Azariah means "the Lord helps." Their new names honored Babylon's gods instead.

Babylon's goal was simple: reshape their minds, their habits, and their identity until they forgot who they belonged to.

The world still tries to do this. It wants to rename us, telling us we are only what we earn, what we own, or what people think of us. But a new label cannot erase the God who made you His own. You may be uprooted, but you are never unseen. The Lord who ruled over Babylon still rules over your circumstances today.$q$, $q$This passage teaches me that even when my life is turned upside down, God has not lost control. Daniel's world collapsed while he was still young. He lost his home, his freedom, and even his name. Yet the very first thing Scripture says about that disaster is that the Lord was the one at work.

I confess that when things fall apart, I often assume God has stepped away. I look at my losses and conclude that I've been forgotten. Daniel 1 reminds me that the Lord is sovereign even over the hard chapters, and that He can use a painful season for a purpose I can't yet see.

I also see how quietly the world tries to reshape me. It doesn't always shout. Sometimes it simply trains me, day by day, to think, want, and live like everyone around me. Knowing this, I should guard what I feed my mind and remember whose name I carry.

I will strive to begin each day by remembering who I am in Christ: chosen, loved, and belonging to Him. Whatever label people give me, I will answer first to the name God has given me.$q$, $q$Sovereign Lord, thank You that nothing in my life is outside Your hand. When I feel uprooted and lost, remind me that You still see me and still rule over every season. Forgive me for doubting You when things fall apart. Guard my heart and mind from the quiet pressure to become like the world around me. Help me remember that I belong to You, and let my life carry Your name with honor wherever You place me. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-02', $q$Decide Before the Pressure Comes$q$, $q$Daniel 1:8–16 (BSB)$q$, NULL, $q$⁸But Daniel made up his mind that he would not defile himself with the king’s food or wine. So he asked the chief official for permission not to defile himself. ⁹Now God had granted Daniel favor and compassion from the chief official, ¹⁰but he said to Daniel, “I fear my lord the king, who has assigned your food and drink. For why should he see your faces looking thinner than those of the other young men your age? You would endanger my head before the king!” ¹¹Then Daniel said to the steward whom the chief official had appointed over Daniel, Hananiah, Mishael, and Azariah, ¹²“Please test your servants for ten days. Let us be given only vegetables to eat and water to drink. ¹³Then compare our appearances with those of the young men who are eating the royal food, and deal with your servants according to what you see.” ¹⁴So he consented to this and tested them for ten days. ¹⁵And at the end of ten days, they looked healthier and better nourished than all the young men who were eating the king’s food. ¹⁶So the steward continued to withhold their choice food and the wine they were to drink, and he gave them vegetables instead.$q$, $q$Ephraim was nineteen when he got his first real job as a welder's helper at a construction site in the city. The pay was small, but it was steady, and his mother back in the province cried when he told her.

On his first payday, the crew gathered behind the bunkhouse with a case of gin and a plastic basin of pulutan. "Bagong salta!" someone shouted. "Tagay ka!"

Ephraim had made up his mind on the bus ride to the city. He had watched his own father drink away half the family's money for years. He would not start down that road. So he smiled and raised his bottle of softdrink.

"Pass muna ako, Kuya. Pero thank you."

The men laughed. Some teased him. One called him "Sister Ephraim" for weeks. Ephraim didn't argue and didn't preach. He just kept showing up early, cleaning the tools, and asking the senior welders questions.

He also started something small. Every Monday, he walked to the bakery before sunrise and came back with a bag of hot pandesal and a big thermos of coffee for the whole crew. "Para sa Monday blues," he'd say.

By the third month, nobody called him "Sister" anymore. Some of the younger helpers started skipping the payday sessions to join Ephraim at the carinderia instead, saving the rest of their pay.

Then one day the foreman, Ronaldo, called him over. "There's a rush job on the third floor. The steel frames have to be perfect. I need someone with a clear head and steady hands at seven in the morning." He paused. "I want you."

Ephraim's hands didn't shake once that morning. He had decided long before who he wanted to be.$q$, $q$Verse 8 is the turning point of the chapter: "But Daniel made up his mind that he would not defile himself with the king's food or wine." Daniel didn't wait until the plate was in front of him. He settled the matter in his heart first.

Why the food? We aren't told every reason. The king's food likely included meat not prepared according to God's law and portions offered to idols. Eating from the king's table also meant depending on the king and being shaped by him. Daniel had accepted a new language and a new name, but here he drew a line. His deepest loyalty would stay with God.

Notice how Daniel handled it. He didn't rebel, insult anyone, or stage a protest. He respectfully asked permission. When the official was afraid, Daniel offered a reasonable test: ten days of vegetables and water. He made it easy for others to say yes.

And notice who was working behind the scenes: "God had granted Daniel favor and compassion from the chief official" (v. 9). Daniel did his part with courage and courtesy, and God opened the door.

At the end of the ten days, Daniel and his friends looked healthier than everyone else. God honored their faithfulness.

Most of our compromises don't happen in big, dramatic moments. They happen in small ones, when we haven't decided ahead of time. Daniel teaches us to settle our convictions before the pressure comes, and then to stand firm with grace instead of pride.$q$, $q$This passage teaches me that faithfulness is usually decided long before the moment of testing. Daniel made up his mind first, and that settled heart carried him through. I realize that many of my failures happened because I never really decided beforehand. I simply drifted along with the crowd.

I should ask the Lord to show me the areas where I need to draw a clear line: the shows I watch, the jokes I laugh at, the shortcuts I take at work, and the habits that slowly pull my heart away from Him. Once He shows me, I will strive to decide now, in the quiet, instead of waiting for the pressure.

I am also challenged by the way Daniel stood firm. He was respectful, creative, and gracious. He didn't treat the official as an enemy. Because of his example, I will try to hold my convictions without looking down on others, and to look for wise ways to honor God that also show kindness to people around me.

Knowing that God gave Daniel favor, I can trust Him to go before me too. My part is to be faithful. His part is to open doors.$q$, $q$Lord, give me a heart that is settled on You before the pressure comes. Show me where I have been drifting and where I need to draw a clear line. Help me stand firm with courage, but also with kindness and respect, so that people see Your grace in me and not pride. When I feel alone in doing what is right, remind me that You are working behind the scenes, granting favor and opening doors. I want to honor You in the small choices of every day. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-03', $q$Still Standing When the Kings Are Gone$q$, $q$Daniel 1:17–21 (BSB)$q$, NULL, $q$¹⁷To these four young men God gave knowledge and understanding in every kind of literature and wisdom. And Daniel had insight into all kinds of visions and dreams. ¹⁸Now at the end of the time specified by the king, the chief official presented them to Nebuchadnezzar. ¹⁹And the king spoke with them, and among all the young men he found no one equal to Daniel, Hananiah, Mishael, and Azariah. So they entered the king’s service. ²⁰In every matter of wisdom and understanding about which the king consulted them, he found them ten times better than all the magicians and enchanters in his entire kingdom. ²¹And Daniel remained there until the first year of King Cyrus.$q$, $q$On his last day of work, Teodoro arrived at the school at five in the morning, as he had for thirty-five years. He unlocked the gate, swept the quadrangle, and checked the faucets in the comfort rooms. Then he sat on the bench by the flagpole and waited for the bell.

Teodoro had been the school's utility man since he was twenty-four. In that time he had served under seven principals. Some were strict, some were kind, and one barely spoke to him at all. Buildings were added and torn down. Uniforms changed colors twice. Through it all, Teodoro kept doing his work the same way: carefully, cheerfully, and on time.

He also kept doing small things nobody asked him to do. He fixed broken chairs before anyone complained. He kept a box of safety pins and spare buttons for students with torn uniforms. He knew which children came to school hungry, and he quietly shared his baon with them.

That afternoon the teachers surprised him with a program in the covered court. Teodoro thought it would be short. Instead, one by one, former students stood up. One was now a teacher in the same school. Another was an engineer. Another was a police officer. Each had a story about Teodoro: a fixed bicycle, a word of encouragement, a pandesal on a hungry morning.

The current principal, Mrs. Villareal, took the microphone last. "Principals come and go," she said, smiling. "Seven of us have sat in that office. But this school has only one Teodoro."

Teodoro looked down at his rough hands and shook his head. "I just did what was in front of me," he said. "Every day."$q$, $q$After the ten-day test, the story fast-forwards three years. Daniel and his friends complete their training, and the king himself interviews them. He finds them "ten times better" than all the magicians and enchanters in his kingdom (v. 20).

But don't miss where their excellence came from: "To these four young men God gave knowledge and understanding" (v. 17). Yes, they studied hard. Babylon's education was demanding. But their wisdom was ultimately a gift from God. Faithfulness in small things, like refusing the king's food, was followed by God's blessing in big things.

This doesn't mean every faithful believer will be promoted or praised. But it does mean that God sees, and He is able to equip His people for whatever assignment He gives them. A Christian can be both holy and excellent. In fact, we should be. Our work is one of the ways we honor God in a world that doesn't know Him.

Then comes a quiet but powerful line: "And Daniel remained there until the first year of King Cyrus" (v. 21). That's around seventy years. Nebuchadnezzar would die. Babylon itself would fall to the Medes and Persians. Kings would rise and disappear. But Daniel was still there, still faithful, still serving.

That is the real victory of chapter 1. Babylon tried to absorb Daniel. Instead, Daniel outlasted Babylon. Kingdoms that look unbeatable today will pass away. But a life anchored in God endures.$q$, $q$This passage teaches me that God is the true source of my abilities. Every skill, every bit of understanding, and every opportunity I have is a gift from His hand. That humbles me, because I'm tempted to take credit for what I've accomplished. It also encourages me, because what God gives, He can also increase.

I am challenged to be excellent in my work, not to impress people, but to honor the Lord. Whether I sweep floors, cook meals, teach children, drive a vehicle, or care for a family, I can do it with my whole heart as worship. Because of Daniel's example, I will stop treating my ordinary tasks as small or unimportant.

I am also moved by the words "Daniel remained." Faithfulness is not proven in a week or a month. It is proven over years, through changes I didn't choose and leaders I didn't pick. Knowing that kingdoms and seasons pass, I should stop placing my security in the people and systems around me.

I will strive to be the kind of believer who is still standing, still serving, and still trusting God long after the noise of today has faded.$q$, $q$Faithful God, thank You for every gift and ability You have given me. Forgive me for the times I have taken credit for what came from Your hand. Help me to do my work with excellence and joy, as an act of worship to You. When seasons change and people come and go, keep me steady and faithful. Let my life outlast the passing things of this world because it is rooted in You. Give me the endurance to keep serving You, day after day, year after year. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-04', $q$When Nobody on Earth Can$q$, $q$Daniel 2:1–13 (BSB)$q$, NULL, $q$¹In the second year of his reign, Nebuchadnezzar had dreams that troubled his spirit, and sleep escaped him. ²So the king gave orders to summon the magicians, enchanters, sorcerers, and astrologers to explain his dreams. When they came and stood before the king, ³he said to them, “I have had a dream, and my spirit is anxious to understand it.” ⁴Then the astrologers answered the king in Aramaic, “O king, may you live forever! Tell your servants the dream, and we will give the interpretation.” ⁵The king replied to the astrologers, “My word is final: If you do not tell me the dream and its interpretation, you will be cut into pieces and your houses will be reduced to rubble. ⁶But if you tell me the dream and its interpretation, you will receive from me gifts and rewards and great honor. So tell me the dream and its interpretation.” ⁷They answered a second time, “Let the king tell the dream to his servants, and we will give the interpretation.” ⁸The king replied, “I know for sure that you are stalling for time, because you see that my word is final. ⁹If you do not tell me the dream, there is only one decree for you. You have conspired to speak before me false and fraudulent words, hoping the situation will change. Therefore tell me the dream, and I will know that you can give me its interpretation.” ¹⁰The astrologers answered the king, “No one on earth can do what the king requests! No king, however great and powerful, has ever asked anything like this of any magician, enchanter, or astrologer. ¹¹What the king requests is so difficult that no one can tell it to him except the gods, whose dwelling is not with mortals.” ¹²This response made the king so furious with anger that he gave orders to destroy all the wise men of Babylon. ¹³So the decree went out that the wise men were to be executed, and men went to look for Daniel and his friends to execute them.$q$, $q$Rodel drove a pedicab outside the public market from six in the morning until late at night. On a good day he cleared four hundred pesos after paying the boundary. On a bad day, he went home with almost nothing.

He had never been a man who asked anyone for help. He had his pride, his cigarettes, and on weekends, his bottle. "Bahala na," was his answer to every problem.

Then his six-year-old daughter, Kristine, collapsed while playing. The doctor at the provincial hospital said she had a hole in her heart. She needed surgery in Manila. The estimate was more than he would earn in ten years.

Rodel tried everything. He borrowed from his cousins until they stopped answering. He went to a five-six lender and came back with barely enough for the bus fare. He lined up at offices for assistance and was told to come back next month. At night he sat on the step outside their rented room, smoking, staring at nothing.

"Pare, wala na talagang magagawa," a fellow driver told him. "Nobody can help you with that kind of amount."

It was his neighbor, Rosario, a widow who sold kakanin, who knocked on his door one evening. "Rodel, may I pray for Kristine?" He almost said no. Instead, he nodded.

Rosario's small church began praying and visiting. One of the members, a nurse, helped him apply to a children's heart foundation he had never heard of. Another drove him to Manila for free.

Kristine had her surgery in March. Months later, Rodel sat in the back row of Rosario's church, holding his daughter's hand. He had come to the end of everything he could do. That was where he finally found the One who could.$q$, $q$Chapter 2 opens with the most powerful man on earth unable to sleep. Nebuchadnezzar had a dream that troubled him deeply. So he called in his experts: magicians, enchanters, sorcerers, and astrologers. These were Babylon's best minds, the people everyone turned to for answers.

But the king made a shocking demand. They had to tell him not only the meaning of the dream, but the dream itself. If they couldn't, they would be killed and their houses destroyed.

Why such a demand? The king seems to suspect his advisers were frauds. Anyone can invent an interpretation. But only someone with real access to divine knowledge could tell him what he had actually dreamed.

The experts panicked. Their answer in verses 10–11 is one of the most honest confessions in the book: "No one on earth can do what the king requests... no one can tell it to him except the gods, whose dwelling is not with mortals."

Without realizing it, they had stated the very point of the chapter. Human wisdom has limits. There are some problems no expert, no money, and no power on earth can solve. What they didn't know is that the true God does not stay far away. He is a God who reveals and who comes near to His people.

The king's fury spread, and the death sentence reached even Daniel and his friends, who hadn't been called. Sometimes we get caught in a crisis we didn't create.

When you reach the end of human answers, you are not at the end of hope. You are at the place where God begins to show His glory.$q$, $q$This passage teaches me that there are problems in life that no one on earth can solve. The wisest people in Babylon admitted it, and I need to admit it too. Some of my burdens are simply too big for my strength, my savings, or my connections.

I confess that I often run to everyone and everything before I run to God. I call friends, search online, and make plans in panic. Prayer becomes my last resort instead of my first response. Knowing that God is not far away like the gods of Babylon, I should bring my impossible situations to Him first.

I am also reminded that sometimes I get caught in crises I didn't create, just as Daniel was swept up in the king's decree. When that happens, I don't have to be bitter or afraid. The same God who was with Daniel is with me.

Because of this, I will strive to name my "impossible" situations before the Lord today. I will hand them over to Him honestly. I will also watch for someone around me who has run out of answers, and I will be willing to knock on their door and offer to pray.$q$, $q$Lord, You know the problems in my life that no one on earth can solve. I bring them to You now. Forgive me for running everywhere else first and coming to You last. Thank You that You are not a distant God but One who comes near and reveals Yourself to those who seek You. When I feel trapped by circumstances I didn't choose, help me trust that You are still in control. Use me to bring hope to someone who has run out of answers. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-05', $q$Before You Panic, Call Your Friends$q$, $q$Daniel 2:14–23 (BSB)$q$, NULL, $q$¹⁴When Arioch, the commander of the king’s guard, had gone out to execute the wise men of Babylon, Daniel replied with discretion and tact. ¹⁵“Why is the decree from the king so harsh?” he asked. At this time Arioch explained the situation to Daniel. ¹⁶So Daniel went in and asked the king to give him some time, so that he could give him the interpretation. ¹⁷Then Daniel returned to his house and explained the matter to his friends Hananiah, Mishael, and Azariah, ¹⁸urging them to plead for mercy from the God of heaven concerning this mystery, so that Daniel and his friends would not be killed with the rest of the wise men of Babylon. ¹⁹During the night, the mystery was revealed to Daniel in a vision, and he blessed the God of heaven ²⁰and declared: “Blessed be the name of God forever and ever, for wisdom and power belong to Him. ²¹He changes the times and seasons; He removes kings and establishes them. He gives wisdom to the wise and knowledge to the discerning. ²²He reveals the deep and hidden things; He knows what lies in darkness, and light dwells with Him. ²³To You, O God of my fathers, I give thanks and praise, because You have given me wisdom and power. And now You have made known to me what we have requested, for You have made known to us the dream of the king.”$q$, $q$The notice came on a Wednesday afternoon. Leonardo's small furniture shop had three days to fix its electrical wiring and fire exits or be closed down by the city.

Leonardo had built the shop over twenty years. He made tables, cabinets, and beds for families all over town. Three days was impossible. His first impulse was to shout at the inspector, a young man named Arvin who looked almost apologetic.

Instead, Leonardo took a breath. "Sir, I'm not arguing. But can you help me understand exactly what needs fixing? And if we do it right, can you give me until Saturday?"

Arvin blinked. Most shop owners yelled at him. He sat down and walked Leonardo through the list, item by item. "Saturday," he said finally. "I'll come back myself."

That night, Leonardo called three men: Joel, Alfredo, and Benjie. They had all started as his apprentices years ago. Now they had shops of their own.

"I need help," he said simply. "And I can't pay you much."

They came anyway. Joel brought an electrician friend. Alfredo brought tools. Benjie brought his wife's pancit and a big pot of rice. For three nights they worked side by side, laughing, sweating, and talking about the old days.

On Saturday morning, Arvin walked through the shop with his clipboard. He checked every outlet and every exit. Then he signed the paper and shook Leonardo's hand.

When he left, Leonardo didn't celebrate right away. He gathered the three men, looked at each of them, and said, "Before anything else, thank you. I couldn't have done this alone."

That evening he wrote three thank-you notes and slipped one into each man's hand.$q$, $q$When the executioners came for Daniel, he didn't panic. Verse 14 says he "replied with discretion and tact." He asked Arioch, the commander, a calm question: "Why is the decree from the king so harsh?" Then he went to the king and asked for time. The same king who had just accused his advisers of stalling for time now granted Daniel's request. God was already at work.

Next, Daniel went home and called his friends. Hananiah, Mishael, and Azariah weren't asked to fix the problem. They were asked to pray, to "plead for mercy from the God of heaven" (v. 18). Daniel knew this was a matter only God could handle, and he knew he shouldn't face it alone.

God answered that night. And look at Daniel's first response: before running to the king, before saving his life, he worshiped. His prayer in verses 20–23 is one of the most beautiful in Scripture. Wisdom and power belong to God. He "changes the times and seasons; He removes kings and establishes them." He "reveals the deep and hidden things."

Babylon's wise men had said only the gods could reveal the dream. Daniel shows us that the God of heaven does exactly that.

This passage gives us a simple pattern for crisis. Stay calm and respectful. Ask for what you need. Gather believing friends to pray. And when God answers, stop and give Him thanks before you move on. Prayer and praise belong together.$q$, $q$This passage teaches me that how I respond in a crisis reveals where my trust really lies. Daniel was facing death, yet he spoke with calm and wisdom. I confess that when trouble comes, my first reaction is often fear, anger, or harsh words. I should ask the Lord to give me Daniel's steady spirit, so that I respond with discretion and tact instead of panic.

I am also challenged by Daniel's friendships. He had people he could call in the middle of the night to pray with him. Do I have friends like that? Am I that kind of friend to others? I will strive to build deeper, praying friendships in my church and small group, not only for my own sake but so I can stand with others in their hard times.

Knowing that Daniel praised God before he did anything else, I want to be quicker to give thanks. Too often I receive God's answers and rush on, forgetting to worship.

This week, I will name one prayer God has recently answered, and I will thank Him for it out loud. I will also reach out to a friend and ask, "How can I pray for you?"$q$, $q$God of heaven, wisdom and power belong to You. You change the times and seasons, and You know what lies in darkness. When trouble comes, give me a calm and wise heart instead of panic. Thank You for the friends You have given me to pray with. Make me a faithful prayer partner to others. And when You answer, help me never forget to stop and praise You first. To You, O God, I give thanks and praise, for You hear and You answer. In Jesus' name, amen.$q$, $q$This week we began the book of Daniel and met four young men far from home. On Tuesday, we saw Jerusalem fall and Daniel and his friends given new names, yet the Lord was still in control. On Wednesday, Daniel made up his mind not to defile himself, and he stood firm with courage and courtesy. On Thursday, we learned that God gave these young men wisdom and that Daniel remained faithful long after kings had come and gone. On Friday, Babylon's experts admitted that no one on earth could meet the king's impossible demand. And today, Daniel answered the crisis with calm words, praying friends, and heartfelt praise to the God who reveals mysteries.

Next week, Daniel will stand before the king and reveal the great dream of a statue and a stone that becomes a kingdom. Then we'll meet a golden image, three young men who refuse to bow, and a fiery furnace with a fourth Man walking in the flames. 🏁$q$),
  (DATE '2026-12-07', $q$It Wasn't Me$q$, $q$Daniel 2:24–35 (BSB)$q$, NULL, $q$²⁴Therefore Daniel went to Arioch, whom the king had appointed to destroy the wise men of Babylon, and said to him, “Do not execute the wise men of Babylon! Bring me before the king, and I will give him the interpretation.” ²⁵Arioch hastily brought Daniel before the king and said to him, “I have found a man among the exiles from Judah who will tell the king the interpretation.” ²⁶The king responded to Daniel, whose name was Belteshazzar, “Are you able to tell me what I saw in the dream, as well as its interpretation?” ²⁷Daniel answered the king, “No wise man, enchanter, medium, or magician can explain to the king the mystery of which he inquires. ²⁸But there is a God in heaven who reveals mysteries, and He has made known to King Nebuchadnezzar what will happen in the latter days. Your dream and the visions that came into your mind as you lay on your bed were these: ²⁹As you lay on your bed, O king, your thoughts turned to the future, and the Revealer of Mysteries made known to you what will happen. ³⁰And to me this mystery has been revealed, not because I have more wisdom than any man alive, but in order that the interpretation might be made known to the king, and that you may understand the thoughts of your mind. ³¹As you, O king, were watching, a great statue appeared. A great and dazzling statue stood before you, and its form was awesome. ³²The head of the statue was pure gold, its chest and arms were silver, its belly and thighs were bronze, ³³its legs were iron, and its feet were part iron and part clay. ³⁴As you watched, a stone was cut out, but not by human hands. It struck the statue on its feet of iron and clay, and crushed them. ³⁵Then the iron, clay, bronze, silver, and gold were shattered and became like chaff on the threshing floor in summer. The wind carried them away, and not a trace of them could be found. But the stone that had struck the statue became a great mountain and filled the whole earth.$q$, $q$Mylene had worked at the small drugstore near the district hospital for only eight months when it happened.

A tired-looking young father handed her two prescriptions from two different doctors. One was for his son's ear infection. The other was for a seizure condition the boy had been treated for years ago. Mylene read them twice. Something about the combination bothered her.

She remembered a lesson from her first week. Mrs. Domingo, the pharmacist who owned the store, had made her copy a long list of dangerous drug combinations into a small notebook. "You will not remember everything," she had said. "So write it down, and check it every time."

Mylene took out the notebook. There it was. The two medicines together could cause a serious reaction in a child.

She called Mrs. Domingo over, who confirmed it right away and phoned the doctor. Within an hour the prescription was changed. The young father kept shaking Mylene's hand. "You may have saved my son's life," he said.

A week later, a local radio program called to interview "the alert pharmacy assistant." Mylene was nervous but agreed.

"How did you catch the mistake?" the announcer asked. "You must be very smart."

Mylene laughed. "No, sir. It wasn't me. My boss trained me to write everything down and check every time. I only opened the notebook. She is the one who made sure the answer was already there."

Mrs. Domingo was listening on the small radio behind the counter. She pretended to be busy counting tablets, but Mylene saw her wipe her eyes with the back of her hand.

From that day on, Mrs. Domingo let Mylene train every new assistant who came through the door.$q$, $q$Daniel now walks into the throne room carrying the answer God gave him. Notice his first concern: "Do not execute the wise men of Babylon!" (v. 24). These were pagan magicians, men who had failed the king. Yet Daniel pleaded for their lives. God's people should be a blessing even to those who don't share their faith.

Arioch rushed Daniel in and took a little credit for himself: "I have found a man" (v. 25). But Daniel did the opposite. When the king asked if he could reveal the dream, Daniel said plainly that no human expert could do it. "But there is a God in heaven who reveals mysteries" (v. 28). Then he added, "This mystery has been revealed, not because I have more wisdom than any man alive" (v. 30).

What an opportunity for pride! Daniel could have built his reputation in one moment. Instead, he pointed every eye to God.

Then he described the dream: a huge, dazzling statue of gold, silver, bronze, iron, and clay. Impressive as it was, it stood on weak feet. A stone "cut out, but not by human hands" struck those feet, and the whole statue collapsed into dust that the wind blew away. The stone grew into a mountain that filled the earth.

Tomorrow we'll see what it means. For today, hold on to this: the most important thing about the stone is that no human hand cut it. God does His greatest work in ways no one can take credit for. Our job, like Daniel's, is to make sure He gets the glory.$q$, $q$This passage teaches me that every good thing I have to offer comes from God. Daniel stood before the most powerful man in the world with the answer everyone wanted, and the first words out of his mouth were about God, not himself. I confess that I often enjoy the praise of people a little too much. I like being known as the one who knew, who fixed it, or who saved the day.

Because of Daniel's example, I will strive to give credit where it truly belongs. When I am praised, I will point back to God, and also to the people He used to shape me: parents, teachers, mentors, and friends.

I am also challenged by Daniel's concern for the wise men who failed. They were not his friends or fellow believers, yet he pleaded for their lives. I should ask the Lord to give me that same kindness toward people who are different from me or who have let me down.

Knowing that God does His greatest work "not by human hands," I will stop trying to be the hero of my own story. This week, I will look for a chance to honor God openly when someone thanks me.$q$, $q$God in heaven, You are the Revealer of Mysteries, and every bit of wisdom I have comes from You. Forgive me for the times I have quietly taken the glory that belongs to You. Teach me to point people to You whenever they praise me. Give me a heart that cares even for those who don't know You, and make me a blessing to them. Let my life be like Daniel's, showing the world that there is a God in heaven who still speaks and still saves. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-08', $q$Sandcastles and the Rock$q$, $q$Daniel 2:36–49 (BSB)$q$, NULL, $q$³⁶This was the dream; now we will tell the king its interpretation. ³⁷You, O king, are the king of kings, to whom the God of heaven has given sovereignty, power, strength, and glory. ³⁸Wherever the sons of men or beasts of the field or birds of the air dwell, He has given them into your hand and has made you ruler over them all. You are that head of gold. ³⁹But after you, there will arise another kingdom, inferior to yours. Next, a third kingdom, one of bronze, will rule the whole earth. ⁴⁰Finally, there will be a fourth kingdom as strong as iron; for iron shatters and crushes all things, and like iron that crushes all things, it will shatter and crush all the others. ⁴¹And just as you saw that the feet and toes were made partly of fired clay and partly of iron, so this will be a divided kingdom, yet some of the strength of iron will be in it—just as you saw the iron mixed with clay. ⁴²And as the toes of the feet were partly iron and partly clay, so this kingdom will be partly strong and partly brittle. ⁴³As you saw the iron mixed with clay, so the peoples will mix with one another, but will not hold together any more than iron mixes with clay. ⁴⁴In the days of those kings, the God of heaven will set up a kingdom that will never be destroyed, nor will it be left to another people. It will shatter all these kingdoms and bring them to an end, but will itself stand forever. ⁴⁵And just as you saw a stone being cut out of the mountain without human hands, and it shattered the iron, bronze, clay, silver, and gold, so the great God has told the king what will happen in the future. The dream is true, and its interpretation is trustworthy.” ⁴⁶At this, King Nebuchadnezzar fell on his face, paid homage to Daniel, and ordered that an offering of incense be presented to him. ⁴⁷The king said to Daniel, “Your God is truly the God of gods and Lord of kings, the Revealer of Mysteries, since you were able to reveal this mystery.” ⁴⁸Then the king promoted Daniel and gave him many generous gifts. He made him ruler over the entire province of Babylon and chief administrator over all the wise men of Babylon. ⁴⁹And at Daniel’s request, the king appointed Shadrach, Meshach, and Abednego to manage the province of Babylon, while Daniel remained in the king’s court.$q$, $q$Nathaniel spent the whole afternoon building the biggest sandcastle he had ever made. It had four towers, a wall, a moat, and a bridge made from a flat piece of driftwood. He decorated it with shells and a tiny flag made from a candy wrapper.

"Lolo Fidel! Look!" he shouted.

His grandfather had just pulled the small fishing boat up onto the sand. He wiped his hands and walked over slowly. "Ang ganda," he said. "That's a palace fit for a king."

Nathaniel beamed. "It's going to be here forever."

Lolo Fidel smiled but said nothing.

An hour later, the tide came in. The first wave filled the moat. The second took the bridge. By the time the sun was setting, Nathaniel was standing in ankle-deep water, staring at a smooth, flat beach. He was almost crying.

His grandfather put a hand on his shoulder and pointed down the shore, to the old stone seawall at the edge of the village. "Do you know who built that?"

Nathaniel shook his head.

"Nobody remembers anymore. It was there when my own lolo was a boy. Typhoons have hit it. Big waves have hit it. Every year, people build houses, stores, even a resort near it. Many of those are gone now." He squeezed Nathaniel's shoulder. "But the wall is still there."

They walked over together. Nathaniel ran his hand along the rough, sea-worn stones.

"Lolo, why doesn't it break?"

"Because it doesn't sit on the sand," his grandfather said. "It sits on the rock underneath."

The next day, Nathaniel built another sandcastle. But this time he built it right beside the old seawall, and he laughed when the waves came.$q$, $q$Daniel now explains the dream. The golden head is Nebuchadnezzar himself, the king "to whom the God of heaven has given sovereignty" (v. 37). Even the greatest king on earth only rules because God allows it.

After Babylon would come other kingdoms: silver, bronze, and iron. Many Bible teachers understand these as Medo-Persia, Greece, and Rome. Each would be powerful in its time. The iron kingdom would crush everything, yet its feet would be a weak mix of iron and clay, strong and brittle at the same time.

Then comes the heart of the dream: "In the days of those kings, the God of heaven will set up a kingdom that will never be destroyed... it will itself stand forever" (v. 44). This is the stone cut without human hands. It is God's own kingdom, and it is not built by armies or politics. It begins small, like a stone, but it grows until it fills the whole earth.

As Christians, we see this fulfilled in Jesus. He came during the days of Rome, the iron kingdom. He announced, "The kingdom of God is near." His kingdom started with a handful of disciples, and today it has spread to every nation. One day, when He returns, it will fill the earth completely.

The king fell on his face and confessed that Daniel's God is "the God of gods and Lord of kings." Daniel was promoted, and he didn't forget his friends.

Every human kingdom, government, company, and fortune is a sandcastle. Only God's kingdom stands forever. Build your life there.$q$, $q$This passage teaches me that every earthly power, no matter how dazzling, is temporary. Gold, silver, bronze, and iron all end up as dust blown away by the wind. I confess that I am often impressed by what the world values. I admire wealth, status, and influence, and I worry too much about the leaders and systems around me, as if they had the final word.

Knowing that the God of heaven has set up a kingdom that will never be destroyed, I should place my hope there. Jesus is the stone not cut by human hands. His kingdom is growing, and nothing can stop it.

I will strive to examine where I am building my life. Am I pouring my time, money, and energy into sandcastles that the next tide will wash away? Or am I investing in what lasts forever: knowing God, loving people, and sharing the gospel?

I am also encouraged by Daniel's loyalty. When he was promoted, he remembered his friends. Because of this, I will look for ways to lift up others when God gives me favor, instead of keeping it all to myself.

Today, I will choose one thing that has eternal value and give it my best attention.$q$, $q$King of kings, thank You that Your kingdom will never be destroyed. Every other power rises and falls, but You reign forever. Forgive me for being so easily impressed by things that will not last. Help me to build my life on the solid rock of Jesus and His kingdom. Give me eyes to see what is eternal and the courage to invest my life in it. And when You bless me, help me to remember and lift up others along the way. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-09', $q$When Everyone Bows$q$, $q$Daniel 3:1–12 (BSB)$q$, NULL, $q$¹King Nebuchadnezzar made a golden statue sixty cubits high and six cubits wide, and he set it up on the plain of Dura in the province of Babylon. ²Then King Nebuchadnezzar sent word to assemble the satraps, prefects, governors, advisers, treasurers, judges, magistrates, and all the other officials of the provinces to attend the dedication of the statue he had set up. ³So the satraps, prefects, governors, advisers, treasurers, judges, magistrates, and all the rulers of the provinces assembled for the dedication of the statue that King Nebuchadnezzar had set up, and they stood before it. ⁴Then the herald loudly proclaimed, “O people of every nation and language, this is what you are commanded: ⁵As soon as you hear the sound of the horn, flute, zither, lyre, harp, pipes, and all kinds of music, you must fall down and worship the golden statue that King Nebuchadnezzar has set up. ⁶And whoever does not fall down and worship will immediately be thrown into the blazing fiery furnace.” ⁷Therefore, as soon as all the people heard the sound of the horn, flute, zither, lyre, harp, and all kinds of music, the people of every nation and language would fall down and worship the golden statue that King Nebuchadnezzar had set up. ⁸At this time some astrologers came forward and maliciously accused the Jews, ⁹saying to King Nebuchadnezzar, “O king, may you live forever! ¹⁰You, O king, have issued a decree that everyone who hears the sound of the horn, flute, zither, lyre, harp, pipes, and all kinds of music must fall down and worship the golden statue, ¹¹and that whoever does not fall down and worship will be thrown into the blazing fiery furnace. ¹²But there are some Jews you have appointed to manage the province of Babylon—Shadrach, Meshach, and Abednego—who have ignored you, O king, and have refused to serve your gods or worship the golden statue you have set up.”$q$, $q$Joshua had been a cook on a cargo ship for two years when the new arrangement started.

At one foreign port, some of the crew began buying cartons of cigarettes cheaply and hiding them in the ship's storerooms. At the next port, they sold them to a contact on the docks without paying any duties. The profit was big. "Everyone does it on this route," the chief steward, Herminio, explained. "Small thing lang. The company will never know."

Joshua's storeroom was the best hiding place on the ship. Herminio asked him to move some rice sacks to make room.

Joshua thought of his wife and two children back home. He thought of the extra money. He also thought of what kind of man he wanted his children to see when he came home.

"Sorry, Chief," he said quietly. "Hindi ko kaya. I'll cook for everyone, I'll clean, I'll take extra shifts. But I can't help with this."

At first, nobody said anything. Then the jokes started. His food was suddenly "too salty." Someone hid his slippers. At meals, men stopped sitting at his table.

Two weeks later, the captain called Joshua into his office. "Some crew members say you're not a team player," he said, looking at a paper. "They say you've been difficult."

Joshua's heart pounded. He knew exactly who had complained and why. He took a deep breath.

"Captain, I've done every task given to me. You can check the logbook. I've only refused one thing." He paused. "If you want to know what it is, check the storeroom near the galley."

The captain looked at him for a long time. Then he picked up the phone. He didn't know what the captain would find, or if the crew would make the rest of the voyage miserable. He washed his hands, tied on his apron, and thought of his wife and children waiting at home. Whatever happened next, he hadn't bowed.$q$, $q$Nebuchadnezzar had seen a dream of a statue with a head of gold. Now he builds a statue that is gold from head to toe, about ninety feet tall. It's as if he were saying, "My kingdom will not pass away." He calls every official in the empire to the plain of Dura to bow before it.

Notice the long lists in this chapter: officials, musical instruments, nations, and languages. They are repeated again and again. The writer is painting a picture of overwhelming pressure. Everyone important is there. The music plays. The whole crowd falls down together. And for anyone who refuses, there is a blazing furnace.

This was more than politics. Bowing to the statue meant honoring the king's gods and giving him ultimate loyalty. For God's people, it was idolatry, a direct violation of the first two commandments.

Then some astrologers "maliciously accused the Jews" (v. 8). These were likely jealous men who resented the success of Shadrach, Meshach, and Abednego. They used the king's decree as a weapon. Faithfulness to God will sometimes make people angry, not because we have done wrong, but because our refusal to bow exposes what everyone else is doing.

Idolatry today rarely involves golden statues. But the pressure is the same. When the "music plays" at work, in school, or online, everyone is expected to bow to money, popularity, convenience, or "what everyone does." Standing up when everyone else is bowing is never easy. But it is how God's people show the world who their true King is.$q$, $q$This passage teaches me that there will be moments when everyone around me bows, and I will have to decide whether I will stand. Shadrach, Meshach, and Abednego were surrounded by officials, music, and the threat of the furnace. Yet they would not give their worship to anyone but God.

I confess that I sometimes bow just to avoid being noticed. I go along with gossip, small dishonesty, or habits I know displease God, simply because everyone else is doing it. I should ask the Lord to show me the "golden statues" in my life: anything I am honoring above Him or bowing to out of fear.

I am also reminded that faithfulness may bring accusation. People may misunderstand me or even speak against me. Knowing that the three young men faced malicious accusers, I will not be surprised when doing right costs me something.

Because of their example, I will strive to stand firm with humility and respect. I don't need to be proud or noisy. I only need to remain standing when the music plays.

This week, I will name one area where I've been bowing to pressure, and I will ask God for the courage to stand.$q$, $q$Lord, You alone are worthy of my worship. Forgive me for the times I have bowed to pressure, fear, or the crowd instead of honoring You. Show me the idols in my heart that I have not noticed. Give me the courage to stand when everyone else is bowing, and the humility to do it without pride. When I am misunderstood or accused for doing what is right, help me trust You to defend me. May my life show the world who my true King is. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-10', $q$Even If Not$q$, $q$Daniel 3:13–18 (BSB)$q$, NULL, $q$¹³Then Nebuchadnezzar, furious with rage, summoned Shadrach, Meshach, and Abednego. So these men were brought before the king, ¹⁴and Nebuchadnezzar said to them, “Shadrach, Meshach, and Abednego, is it true that you do not serve my gods or worship the golden statue I have set up? ¹⁵Now, if you are ready, as soon as you hear the sound of the horn, flute, zither, lyre, harp, pipes, and all kinds of music, you must fall down and worship the statue I have made. But if you refuse to worship, you will be thrown at once into the blazing fiery furnace. Then what god will be able to deliver you from my hands?” ¹⁶Shadrach, Meshach, and Abednego replied to the king, “O Nebuchadnezzar, we have no need to answer you in this matter. ¹⁷If the God whom we serve exists, then He is able to deliver us from the blazing fiery furnace and from your hand, O king. ¹⁸But even if He does not, let it be known to you, O king, that we will not serve your gods or worship the golden statue you have set up.”$q$, $q$Melchor had driven trucks for the same trading company for eleven years. He hauled sacks of feed and fertilizer from the port to warehouses in the provinces. He was careful, never late, and had never had an accident.

One morning, the operations manager, Mr. Salcedo, called him into the office. "We have a big shipment today. Load ten tons more than usual."

Melchor frowned. "Sir, that's way over the limit. The brakes won't handle the mountain road."

Mr. Salcedo slid a paper across the desk. It was a weighbridge ticket, already filled out with a much lower weight. "Don't worry. I have a contact at the weighing station. Just drive."

Melchor looked at the fake ticket for a long time. He thought of his three children in school and the motorcycle he was still paying for. He also thought of the jeepneys and tricycles he passed every day on that mountain road, full of families.

"Sir," he said, "I can't do it."

Mr. Salcedo's face hardened. "You know there are ten drivers waiting for your job."

"I know, sir." Melchor's voice shook, but he kept going. "Maybe you'll fire me. Maybe God will give me another job, maybe not. But I won't drive an overloaded truck down that mountain. Even if I lose this job, I won't."

He was let go two weeks later.

That night, he sat with his wife, Veronica, at their small kitchen table. He expected her to be angry. Instead, she took his hand.

"I married a man who wouldn't risk other people's lives for money," she said. "I'm still married to him."

Melchor spent four months doing odd jobs. It wasn't easy. But he slept well every night, and he never once regretted that morning.$q$, $q$Nebuchadnezzar, "furious with rage," gave the three young men one more chance. The music would play again. If they bowed, all would be forgiven. If not, the furnace. Then he added a challenge: "What god will be able to deliver you from my hands?" (v. 15).

Their answer is one of the bravest statements in the Bible. "We have no need to answer you in this matter" (v. 16). They weren't being rude. They simply didn't need time to think it over. The question had been settled long ago.

In verse 17, the BSB reads, "If the God whom we serve exists." This isn't doubt. It's a way of answering the king's mocking question. In effect, they were saying, "You ask what god can save us? If it comes to the furnace, our God is real, and He is able."

Then come the words that have strengthened believers for centuries: "But even if He does not... we will not serve your gods" (v. 18).

This is mature faith. They were certain of God's power, but they didn't presume to know God's plan. They trusted that He could rescue them, and they would obey Him even if He chose not to.

Some people think faith means always expecting the outcome we want. But true faith rests in who God is, not in what He will do for us. Our obedience is not a deal with God. We obey because He is worthy, whether the fire comes or not.

Can you say "even if not" to God today?$q$, $q$This passage teaches me the difference between faith in God and faith in the outcome I want. Shadrach, Meshach, and Abednego believed God could save them, but they were ready to obey Him even if He didn't. I confess that my faith is often conditional. I trust God as long as things go my way, and I struggle when they don't.

I should ask the Lord to give me "even if not" faith. Even if the healing doesn't come right away, I will trust Him. Even if I lose the job, the opportunity, or the approval of people, I will stay faithful. Even if my prayers aren't answered the way I hoped, I will not turn away.

I am also challenged by how settled they were. They didn't need to debate with the king. Knowing that hesitation often leads to compromise, I will strive to settle my convictions in advance, so that when the pressure comes, my answer is already clear.

Because God is worthy of my obedience no matter what, I will choose to honor Him today in one decision where obeying Him might cost me something.$q$, $q$Mighty God, I believe You are able to do far more than I ask or imagine. But even if You don't do what I want, I choose to trust and obey You. Forgive me for the times my faith has been a bargain instead of surrender. Give me a settled heart that doesn't waver when pressure comes. Help me to honor You whether I'm delivered from the fire or must walk through it. You are worthy of my worship in every season. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-11', $q$There Was Someone Else in the Fire$q$, $q$Daniel 3:19–30 (BSB)$q$, NULL, $q$¹⁹At this, Nebuchadnezzar was filled with rage, and the expression on his face changed toward Shadrach, Meshach, and Abednego. He gave orders to heat the furnace seven times hotter than usual, ²⁰and he commanded some mighty men of valor in his army to tie up Shadrach, Meshach, and Abednego and throw them into the blazing fiery furnace. ²¹So they were tied up, wearing robes, trousers, turbans, and other clothes, and they were thrown into the blazing fiery furnace. ²²The king’s command was so urgent and the furnace so hot that the fiery flames killed the men who carried up Shadrach, Meshach, and Abednego. ²³And these three men, Shadrach, Meshach, and Abednego, firmly bound, fell into the blazing fiery furnace. ²⁴Suddenly King Nebuchadnezzar jumped up in amazement and asked his advisers, “Did we not throw three men, firmly bound, into the fire?” “Certainly, O king,” they replied. ²⁵“Look!” he exclaimed. “I see four men, unbound and unharmed, walking around in the fire—and the fourth looks like a son of the gods!” ²⁶Then Nebuchadnezzar approached the door of the blazing fiery furnace and called out, “Shadrach, Meshach, and Abednego, servants of the Most High God, come out!” So Shadrach, Meshach, and Abednego came out of the fire, ²⁷and when the satraps, prefects, governors, and royal advisers had gathered around, they saw that the fire had no effect on the bodies of these men. Not a hair of their heads was singed, their robes were unaffected, and there was no smell of fire on them. ²⁸Nebuchadnezzar declared, “Blessed be the God of Shadrach, Meshach, and Abednego, who has sent His angel and delivered His servants who trusted in Him. They violated the king’s command and risked their lives rather than serve or worship any god except their own God. ²⁹Therefore I decree that the people of any nation or language who say anything offensive against the God of Shadrach, Meshach, and Abednego will be cut into pieces and their houses reduced to rubble. For there is no other god who can deliver in this way.” ³⁰Then the king promoted Shadrach, Meshach, and Abednego in the province of Babylon.$q$, $q$After her husband Eduardo died, Lourdes stopped answering her phone.

For thirty years she had sewn school uniforms and gowns in the front room of their small house while Eduardo fixed watches at a table beside her. Now his table sat empty, his tools still neatly arranged in a tin box. Lourdes would sit at her sewing machine for hours without turning it on.

Her children lived far away and could only call. Friends sent messages: "Let me know if you need anything." Lourdes never let anyone know.

Except Carmela didn't ask. Carmela just came.

Carmela lived three houses down. She was a widow too, a retired laundry woman with bad knees and a loud laugh. On the first morning, she knocked, walked in without waiting, and set down two cups of hot salabat. She didn't say much. She just sat.

The next day she came again. And the next. Some days she swept the floor. Some days she brought rice and fried fish. Some nights, when Lourdes couldn't stop crying, Carmela simply held her hand until she fell asleep on the sofa, then let herself out quietly.

Months passed. One afternoon, Lourdes turned on her sewing machine again. Carmela heard the familiar hum from down the street and came hobbling over with a grin.

Lourdes was making a dress. It was blue, Carmela's favorite color.

"Why are you doing this?" Carmela asked, touching the fabric.

Lourdes stopped and looked at her friend. "Because the worst year of my life should have burned me up," she said softly. "But I wasn't alone in it. You were there the whole time."

Carmela laughed loudly and wiped her eyes. "Of course I was. Where else would I go?"$q$, $q$The king's rage boiled over. He ordered the furnace heated seven times hotter, so hot that the soldiers who threw the three young men in were killed by the flames. Shadrach, Meshach, and Abednego, tied up and fully clothed, fell into the fire.

Then the king jumped up in shock. "Did we not throw three men, firmly bound, into the fire?... Look! I see four men, unbound and unharmed, walking around in the fire—and the fourth looks like a son of the gods!" (vv. 24–25).

Notice three things. First, God didn't keep them out of the fire. He met them in it. Second, the only things the fire destroyed were the ropes that bound them. Third, they were not alone. There was a fourth figure walking with them. Nebuchadnezzar later called him an angel. Many Christians have seen in him a picture of the Son of God, who promises to be with His people in every trial.

When they came out, "not a hair of their heads was singed... and there was no smell of fire on them" (v. 27). God's deliverance was complete.

The king, who had asked, "What god will be able to deliver you?" now answered his own question: "There is no other god who can deliver in this way" (v. 29). Their faithfulness became a testimony to the whole empire.

God has not promised to keep us from every fire. But He has promised, "When you walk through the fire, you will not be scorched" (Isaiah 43:2). In your hardest trial, you are never alone. Someone else is in the fire with you.$q$, $q$This passage teaches me that God's presence is greater than any fire I will face. He didn't stop the three young men from being thrown into the furnace, but He walked with them inside it. I confess that I often pray only for escape from my trials. I want God to keep the fire away. But Daniel 3 shows me that sometimes His greater gift is His presence in the fire.

I am comforted that the only thing the flames destroyed were the ropes. Knowing that God can use my hardest seasons to set me free from things that bind me, such as fear, pride, or worldly attachments, I should stop seeing every trial as a loss.

I will strive to remember, when I am in the middle of a painful season, that I am not alone. Jesus is with me, and He will bring me through.

I am also challenged to be like the fourth man in someone else's fire. There are people around me walking through grief, sickness, or loss. Because God has been with me, I will choose to show up for one hurting person this week, not with advice, but with my presence.$q$, $q$Lord Jesus, thank You for walking with me through the fire. When I face trials I cannot escape, remind me that You are right there beside me. Use the heat of hard seasons to burn away whatever binds me and keeps me from following You freely. Bring me through, Lord, so that my life becomes a testimony that there is no other God who can deliver like You. Make me a faithful presence for others who are walking through their own fires. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-12', $q$The Proud Man's Testimony$q$, $q$Daniel 4:1–9 (BSB)$q$, NULL, $q$¹King Nebuchadnezzar, To the people of every nation and language who dwell in all the earth: May your prosperity be multiplied. ²I am pleased to declare the signs and wonders that the Most High God has performed for me. ³How great are His signs, how mighty His wonders! His kingdom is an eternal kingdom; His dominion endures from generation to generation. ⁴I, Nebuchadnezzar, was at ease in my house and flourishing in my palace. ⁵I had a dream, and it frightened me; while in my bed, the images and visions in my mind alarmed me. ⁶So I issued a decree that all the wise men of Babylon be brought before me to interpret the dream for me. ⁷When the magicians, enchanters, astrologers, and diviners came in, I told them the dream, and they could not interpret it for me. ⁸But at last, into my presence came Daniel (whose name is Belteshazzar after the name of my god, and in whom is the spirit of the holy gods). And I told him the dream: ⁹“O Belteshazzar, chief of the magicians, I know that the spirit of the holy gods is in you and that no mystery baffles you. So explain to me the visions I saw in my dream, and their interpretation.$q$, $q$Everyone in town knew Gregorio. He owned the biggest fishpond operation in the area, three delivery trucks, and the only two-story concrete house on his street. He was proud of all of it, and he made sure people knew.

He paid his workers late and laughed when they complained. "If you don't like it, there are others who want your job." He never went to anyone's wake, birthday, or wedding unless there was something in it for him. "I made all this with my own hands," he liked to say. "I don't owe anybody anything."

Then one night, while counting money at his desk, Gregorio's left hand stopped working. His face felt numb. He tried to call out and couldn't form the words.

It was Tomas, his oldest caretaker, who found him and rushed him to the hospital in the back of a fish truck.

The doctors called it a mild stroke. He recovered most of his strength over the next months. But something had shaken loose inside him. Lying in the hospital bed, he couldn't count money or give orders. He could only lie there and be afraid.

Tomas visited him every week. Tomas's family prayed for him. Tomas's pastor came once and simply sat with him and talked about Jesus, the One who came not for the proud but for those who know they need Him.

A year later, Gregorio called all his workers together at the fishponds. He had prepared a big lunch. When everyone had eaten, he stood up, a little unsteady.

"I need to tell you what happened to me," he said. His voice cracked. "I thought I built everything myself. I was wrong. God humbled me, and then God saved me."

Then he raised everyone's pay.$q$, $q$Chapter 4 is unusual. It is written as a letter from Nebuchadnezzar himself, sent "to the people of every nation and language" (v. 1). The proud king who once demanded worship for his golden statue is now telling the whole world about the greatness of Daniel's God.

He begins with praise: "How great are His signs, how mighty His wonders! His kingdom is an eternal kingdom" (v. 3). This is the same king who once thought his own kingdom would last forever. Something has clearly changed.

Then he tells the story. "I, Nebuchadnezzar, was at ease in my house and flourishing in my palace" (v. 4). Life was comfortable. His enemies were defeated, and his treasury was full. That kind of ease is dangerous. When everything goes well, it's easy to forget God.

Then came another troubling dream. Once again, his wise men failed. Once again, "at last" Daniel came in. It's interesting that Daniel was the last one called, even though he had helped before. The king still turned to his old experts first.

Notice that the king still calls Daniel by his Babylonian name, Belteshazzar, "after the name of my god." He also says "the spirit of the holy gods" is in him. Nebuchadnezzar had learned something, but his understanding of God was still incomplete. God was not finished with him.

Next week we'll see the dream and how God humbled this proud king. But we already know how it ends: with a testimony. God's goal in humbling us is never to destroy us. It is to bring us to Himself.$q$, $q$This passage teaches me that God can change even the proudest heart. Nebuchadnezzar went from demanding worship to declaring the greatness of God to the whole world. That gives me hope for the people I've given up on, and it gives me hope for myself.

I am also warned by the words "at ease" and "flourishing." I confess that I tend to drift from God most when life is comfortable. When the bills are paid and everyone is healthy, my prayers become shorter and my dependence on God grows weaker. I should ask the Lord to keep me humble and close to Him, especially in good seasons.

I notice too that the king still called on his old experts first, before Daniel. Knowing that I often run to my old sources of comfort before turning to God, I will strive to make Him my first call, not my last resort.

Because God turns humbled people into testimonies, I will not hide the lessons He has taught me through hard times. This week, I will share with someone one way God has humbled me and brought me closer to Him.$q$, $q$Most High God, Your kingdom is eternal and Your power endures forever. Thank You that You can change even the proudest heart, including mine. Keep me humble when life is easy, and don't let comfort pull me away from You. Help me to come to You first, not last. Give me courage to tell others the story of what You have done in my life. And please work in the hearts of proud people I love, bringing them to know You. In Jesus' name, amen.$q$, $q$This week we watched the God of heaven reveal His power in Babylon. On Monday, Daniel stood before the king with the answer, but gave all the credit to "a God in heaven who reveals mysteries." On Tuesday, we learned that every earthly kingdom is like a statue destined for dust, but God's kingdom, the stone not cut by human hands, will stand forever. On Wednesday, the whole empire bowed before a golden statue, except three young men. On Thursday, they told the king, "Even if He does not deliver us, we will not bow." On Friday, God met them in the fire, and a fourth Man walked with them. Today, we began reading the proud king's own testimony of how God changed him.

Next week, we'll hear the rest of Nebuchadnezzar's story: a great tree cut down, a king humbled, and a heart restored. Then we'll meet his successor, Belshazzar, at a wild party where a mysterious hand writes on the wall. 🏁$q$),
  (DATE '2026-12-14', $q$The Stump Still Has Roots$q$, $q$Daniel 4:10–18 (BSB)$q$, NULL, $q$¹⁰In these visions of my mind as I was lying in bed, I saw this come to pass: There was a tree in the midst of the land, and its height was great. ¹¹The tree grew large and strong; its top reached the sky, and it was visible to the ends of the earth. ¹²Its leaves were beautiful, its fruit was abundant, and upon it was food for all. Under it the beasts of the field found shelter, in its branches the birds of the air nested, and from it every creature was fed. ¹³As I lay on my bed, I also saw in the visions of my mind a watcher, a holy one, coming down from heaven. ¹⁴He called out in a loud voice: ‘Cut down the tree and chop off its branches; strip off its leaves and scatter its fruit. Let the beasts flee from under it, and the birds from its branches. ¹⁵But leave the stump with its roots in the ground, and a band of iron and bronze around it, in the tender grass of the field. Let him be drenched with the dew of heaven and graze with the beasts on the grass of the earth. ¹⁶Let his mind be changed from that of a man, and let him be given the mind of a beast till seven times pass him by. ¹⁷This decision is the decree of the watchers, the verdict declared by the holy ones, so that the living will know that the Most High rules over the kingdom of mankind and gives it to whom He wishes, setting over it the lowliest of men.’ ¹⁸This is the dream that I, King Nebuchadnezzar, saw. Now, Belteshazzar, tell me the interpretation, because none of the wise men of my kingdom can interpret it for me. But you are able, because the spirit of the holy gods is in you.”$q$, $q$The old mango tree in Lola Remedios's yard was older than anyone on the street. Its branches stretched over three houses. Every summer it gave so much fruit that Lola Remedios filled basins and sent them to every neighbor. Children played under its shade. Tricycle drivers parked beneath it to rest at noon. Birds nested in it all year.

"That tree feeds half the street," people liked to say.

Then a strong typhoon came. In the middle of the night, a branch the size of a jeepney cracked and crashed onto the neighbor's roof. In the morning, men from the municipal office came with chainsaws. The tree was rotten inside, they said. It had to come down.

Lola Remedios's grandson, Kenneth, watched from the window as branch after branch fell. By afternoon, only a wide, ugly stump was left. The street looked bare. The birds were gone.

"Lola, why didn't they pull out the stump too?" Kenneth asked.

"I asked them not to," she said. "The roots are still good. Only the inside of the trunk was rotten."

Kenneth didn't understand. For months, the stump just sat there. People used it as a bench.

Then, one morning after the rains, Kenneth ran into the house shouting. "Lola! Lola! Come see!"

From the side of the old stump, three bright green shoots had pushed through the bark. They were small, but they were alive.

Lola Remedios knelt down slowly and touched one with her finger. "You see?" she said, smiling. "They cut down what was rotten. But as long as the roots are still in the ground, there's hope."

Kenneth tied a red ribbon around the stump so no one would sit on the new shoots.$q$, $q$Nebuchadnezzar now describes his second great dream. He saw a huge tree in the middle of the earth. It reached the sky and could be seen everywhere. It was beautiful and fruitful. Animals rested in its shade, birds nested in its branches, and "from it every creature was fed" (v. 12).

The tree is a picture of the king's power. And notice that it wasn't all bad. His kingdom provided food, order, and protection to many people. God gives leaders power so they can bless those under them.

But then a "watcher, a holy one" came down from heaven with a command: "Cut down the tree." Its branches, leaves, and fruit would be stripped away. Even more frightening, the man represented by the tree would lose his mind and live like an animal "till seven times pass him by."

Why? Verse 17 gives the purpose: "so that the living will know that the Most High rules over the kingdom of mankind and gives it to whom He wishes, setting over it the lowliest of men." This is the main theme of Daniel. Kings think they rule, but God rules over them.

Yet there's a ray of hope in this dark dream. "Leave the stump with its roots in the ground" (v. 15). The judgment was real, but it wasn't final. God planned to cut the king down, not to destroy him, but to bring him to his senses.

That's how God deals with His people too. His discipline may cut deep, but He leaves the roots. His goal is never destruction, but restoration.$q$, $q$This passage teaches me that whatever influence God gives me is meant to bless others. Like the great tree, my home, my work, and my position should be places where people find shelter and nourishment. I should ask the Lord whether the people under my care are being fed and protected, or only used for my benefit.

I am also reminded that the Most High rules. No matter how strong or successful I become, I am not the one in charge. Knowing that God can bring down even the mightiest tree, I will strive to hold my achievements with open hands.

But what comforts me most is the stump left in the ground. I confess that there have been seasons when God cut away things in my life, and it hurt. I didn't understand it then. Now I see that He was removing what was rotten so that something new could grow.

Because God's discipline always leaves the roots, I will not lose hope when He prunes me. If I am in a season of loss right now, I will trust that new life can still come. And I will look for one person this week whom I can shelter and encourage.$q$, $q$Most High God, You rule over every kingdom, every leader, and every life. Thank You for the gifts and influence You have given me. Help me to use them to bless others and not just myself. When You cut away things in my life that are rotten, give me grace to trust You. Thank You that Your discipline always leaves the roots and that You never give up on Your children. Bring new life out of the stumps of my life, for Your glory. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-15', $q$A Haircut and a Hard Truth$q$, $q$Daniel 4:19–27 (BSB)$q$, NULL, $q$¹⁹For a time, Daniel, who was also known as Belteshazzar, was perplexed, and his thoughts alarmed him. So the king said, “Belteshazzar, do not let the dream or its interpretation alarm you.” “My lord,” replied Belteshazzar, “may the dream apply to those who hate you, and its interpretation to your enemies! ²⁰The tree you saw that grew large and strong, whose top reached the sky and was visible to all the earth, ²¹whose foliage was beautiful and whose fruit was abundant, providing food for all, under which the beasts of the field lived, and in whose branches the birds of the air nested— ²²you, O king, are that tree! For you have become great and strong; your greatness has grown to reach the sky, and your dominion extends to the ends of the earth. ²³And you, O king, saw a watcher, a holy one, coming down from heaven and saying: ‘Cut down the tree and destroy it, but leave the stump with its roots in the ground, and a band of iron and bronze around it, in the tender grass of the field. Let him be drenched with the dew of heaven, and graze with the beasts of the field till seven times pass him by.’ ²⁴This is the interpretation, O king, and this is the decree that the Most High has issued against my lord the king: ²⁵You will be driven away from mankind, and your dwelling will be with the beasts of the field. You will feed on grass like an ox and be drenched with the dew of heaven, and seven times shall pass you by, until you acknowledge that the Most High rules over the kingdom of mankind and gives it to whom He wishes. ²⁶As for the command to leave the stump of the tree with its roots, your kingdom will be restored to you as soon as you acknowledge that Heaven rules. ²⁷Therefore, may my advice be pleasing to you, O king. Break away from your sins by doing what is right, and from your iniquities by showing mercy to the oppressed. Perhaps there will be an extension of your prosperity.”$q$, $q$Wilfredo had been cutting Mr. Arcilla's hair every two weeks for nearly ten years. Mr. Arcilla owned the biggest hardware store in town, and he always came in at exactly four o'clock, sat in the same chair, and talked the whole time.

Wilfredo knew a lot about him. He knew Mr. Arcilla shouted at his workers and docked their pay for small mistakes. He knew one of his old delivery boys had been fired for being late the day his mother was rushed to the hospital. People in town spoke about Mr. Arcilla with fear, never with warmth.

One afternoon, Mr. Arcilla was quieter than usual. "My son doesn't want to take over the store," he finally said. "He says he doesn't want to become like me. Can you believe that?"

Wilfredo kept cutting. His hands were steady, but his heart was pounding. He could just nod and agree, as he always did. Or he could tell the truth.

"Sir," he said carefully, "can I say something? You can get another barber afterwards if you're angry."

Mr. Arcilla looked at him in the mirror. "Go ahead."

"You've been good to me. You always pay on time and tip well. But your workers are afraid of you, sir. And I think your son sees that." He set down the scissors. "I'm saying this because I hope it's not too late. If you start being kind to them, maybe he'll see a different father."

The shop was silent. Wilfredo was sure he had just lost his best customer.

Mr. Arcilla stood, paid, and walked out without a word.

Two weeks later, at exactly four o'clock, he was back. He sat down and said quietly, "I gave the delivery boys a raise. My son noticed."$q$, $q$When Daniel heard the dream, he was "perplexed, and his thoughts alarmed him" (v. 19). He understood exactly what it meant, and he didn't want to say it. Even the king noticed and told him not to be afraid.

Daniel's first words are surprising: "My lord, may the dream apply to those who hate you." Daniel genuinely cared about this king. This was the man who had destroyed Jerusalem and carried Daniel into exile. Yet Daniel didn't enjoy announcing his judgment. He wished it were someone else's.

Still, he told the truth plainly: "You, O king, are that tree!" (v. 22). The king would be driven away from people and live like an animal "until you acknowledge that the Most High rules" (v. 25). But the stump meant hope. His kingdom would return "as soon as you acknowledge that Heaven rules" (v. 26).

Then Daniel did something even braver. He gave the king personal advice: "Break away from your sins by doing what is right, and from your iniquities by showing mercy to the oppressed" (v. 27). He didn't speak in general terms. He named the king's specific sins: pride and cruelty to the weak. And he offered a way out: repentance might bring "an extension of your prosperity."

This is what speaking truth in love looks like. Daniel was respectful, compassionate, and honest. He didn't flatter the king, and he didn't attack him either. He told him the truth because he wanted him to be saved.

God still calls His people to speak hard truths with love, not to win arguments, but to win people back to Him.$q$, $q$This passage teaches me that real love sometimes requires hard words. Daniel could have softened the message or kept quiet to protect himself. Instead, he told the king the truth because he cared about him. I confess that I often stay silent when someone I know is heading in the wrong direction. I tell myself it's not my business, but often I'm just afraid of their reaction.

I am also challenged by Daniel's heart. He didn't enjoy delivering judgment. He was troubled by it and wished it would fall on someone else. I should ask the Lord to give me that same compassion, so that when I must correct someone, I do it with tears and not with pride.

Because of Daniel's example, I will strive to be honest and specific, but always respectful and kind. I will also point people to the hope of repentance, not just to the problem.

Knowing that God may want to use me to warn someone I love, I will pray this week about one person who needs to hear a loving truth. If God opens the door, I will speak gently and trust Him with the result.$q$, $q$Lord, give me Daniel's courage and compassion. Forgive me for the times I stayed silent because I feared what people would think. When someone I love is heading toward harm, help me speak the truth with gentleness and respect. Keep me from pride when I correct others, and remind me of my own need for Your mercy. Use my words to point people back to You, where there is always hope for those who turn from their sins. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-16', $q$Who Built This?$q$, $q$Daniel 4:28–37 (BSB)$q$, NULL, $q$²⁸All this happened to King Nebuchadnezzar. ²⁹Twelve months later, as he was walking on the roof of the royal palace of Babylon, ³⁰the king exclaimed, “Is this not Babylon the Great, which I myself have built by the might of my power as a royal residence and for the glory of my majesty?” ³¹While the words were still in the king’s mouth, a voice came from heaven: “It is decreed to you, King Nebuchadnezzar, that the kingdom has departed from you. ³²You will be driven away from mankind to live with the beasts of the field, and you will feed on grass like an ox. And seven times will pass you by, until you acknowledge that the Most High rules over the kingdom of mankind and gives it to whom He wishes.” ³³At that moment the sentence against Nebuchadnezzar was fulfilled. He was driven away from mankind. He ate grass like an ox, and his body was drenched with the dew of heaven, until his hair grew like the feathers of an eagle and his nails like the claws of a bird. ³⁴But at the end of those days I, Nebuchadnezzar, looked up to heaven, and my sanity was restored to me. Then I praised the Most High, and I honored and glorified Him who lives forever: “For His dominion is an everlasting dominion, and His kingdom endures from generation to generation. ³⁵All the peoples of the earth are counted as nothing, and He does as He pleases with the army of heaven and the peoples of the earth. There is no one who can restrain His hand or say to Him, ‘What have You done?’” ³⁶At the same time my sanity was restored, my honor and splendor returned to me for the glory of my kingdom. My advisers and nobles sought me out, and I was restored to my throne, and surpassing greatness was added to me. ³⁷Now I, Nebuchadnezzar, praise and exalt and glorify the King of heaven, for all His works are true and all His ways are just. And He is able to humble those who walk in pride.$q$, $q$At twenty-six, Jayson was the most talked-about online seller in his town. He sold gadgets and accessories through live streams, and on a good night he made more money than his father earned in a month as a tricycle driver.

He bought a new car, a big TV for his parents, and designer shoes for himself. In his live streams he liked to say, "Self-made 'to, mga kaibigan! No one helped me. Hard work lang!"

What he didn't say was that he often sold fake items as originals. He delayed paying his suppliers for months. When his younger cousin, who packed orders for him, asked for a raise, Jayson laughed and said, "Be grateful you have a job."

Then it all fell apart in a single month. A customer posted a video exposing his fake products. It went viral. His online store was banned. Suppliers came to collect, and the car was taken back. Within half a year, Jayson was stacking boxes as a warehouse helper for minimum wage.

He was angry for a long time. Then one night, sitting alone on the warehouse loading dock after a double shift, he looked up at the stars and broke down. "I didn't build anything," he whispered. "I just took."

The next Sunday, he went with his cousin to a small church that met in a rented space above a bakery. He sat in the back. The pastor spoke about a God who humbles the proud but gives grace to the humble.

Two years later, Jayson started selling again, this time slowly, honestly, and with receipts. On his first live stream, he looked into the camera and said, "Before anything else, I want to tell you what God did in my life."$q$, $q$God gave Nebuchadnezzar a full year to change. Daniel had warned him and given him a way out. But nothing changed.

Then, one evening, the king was walking on the roof of his palace, looking over the great city. Babylon was one of the wonders of the ancient world, with massive walls, beautiful gardens, and grand buildings. Filled with pride, he said, "Is this not Babylon the Great, which I myself have built by the might of my power... and for the glory of my majesty?" (v. 30).

Look at all the "I" and "my" in that sentence. There's no room for God in it.

"While the words were still in the king's mouth," God acted. The most powerful man in the world lost his mind and lived like a wild animal. He ate grass. His hair grew long and his nails like claws. Pride had made him think he was a god, and God showed him that without His mercy, he was less than a man.

But the stump remained. "At the end of those days I, Nebuchadnezzar, looked up to heaven, and my sanity was restored" (v. 34). The moment he looked up, his mind came back. His first act was not to grab his throne, but to praise God.

His final words are some of the most remarkable in the Bible: "Now I, Nebuchadnezzar, praise and exalt and glorify the King of heaven... And He is able to humble those who walk in pride" (v. 37).

Pride makes us look down on others. Humility begins when we look up to heaven. That's where sanity, restoration, and true greatness are found.$q$, $q$This passage teaches me how dangerous pride is, especially when it is quiet and comfortable. Nebuchadnezzar wasn't shouting in anger. He was simply admiring his own success. I confess that I sometimes look at what I've accomplished and silently take all the credit. I forget the God who gave me breath, health, opportunities, and the people who helped me along the way.

I am also struck by God's patience. He gave the king a whole year to repent. Knowing that God's patience is not permission to keep sinning, I should not delay in turning from the pride He has already shown me.

But I am most encouraged by verse 34. The moment the king looked up, everything changed. I will strive to look up more often: to begin my days with thanksgiving, to see my blessings as gifts, and to remember that God is the true builder of anything good in my life.

Because God is able to humble the proud, I want to humble myself first. Today, I will thank God out loud for three things I usually take credit for, and I will thank one person who helped me get where I am.$q$, $q$King of heaven, all Your works are true and all Your ways are just. Forgive me for the times I have looked at my life and said, "I built this." Everything I have comes from You. Humble my heart before You have to humble my circumstances. Teach me to look up to You every day in gratitude and praise. Thank You for restoring those who turn to You. Make me a living testimony that You lift up the humble and give grace to all who seek You. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-17', $q$The Party Before the Storm$q$, $q$Daniel 5:1–12 (BSB)$q$, NULL, $q$¹Later, King Belshazzar held a great feast for a thousand of his nobles, and he drank wine with them. ²Under the influence of the wine, Belshazzar gave orders to bring in the gold and silver vessels that Nebuchadnezzar his father had taken from the temple in Jerusalem, so that the king could drink from them, along with his nobles, his wives, and his concubines. ³Thus they brought in the gold vessels that had been taken from the temple, the house of God in Jerusalem, and the king drank from them, along with his nobles, his wives, and his concubines. ⁴As they drank the wine, they praised their gods of gold and silver, bronze and iron, wood and stone. ⁵At that moment the fingers of a human hand appeared and wrote on the plaster of the wall, near the lampstand in the royal palace. As the king watched the hand that was writing, ⁶his face grew pale and his thoughts so alarmed him that his hips gave way and his knees knocked together. ⁷The king called out for the enchanters, astrologers, and diviners to be brought in, and he said to these wise men of Babylon, “Whoever reads this inscription and tells me its interpretation will be clothed in purple and have a gold chain placed around his neck, and he will be made the third highest ruler in the kingdom.” ⁸So all the king’s wise men came in, but they could not read the inscription or interpret it for him. ⁹Then King Belshazzar became even more terrified, his face grew even more pale, and his nobles were bewildered. ¹⁰Hearing the outcry of the king and his nobles, the queen entered the banquet hall. “O king, may you live forever!” she said. “Do not let your thoughts terrify you, or your face grow pale. ¹¹There is a man in your kingdom who has the spirit of the holy gods in him. In the days of your father he was found to have insight, intelligence, and wisdom like that of the gods. Your father, King Nebuchadnezzar, appointed him chief of the magicians, enchanters, astrologers, and diviners. Your own father, the king, ¹²did this because Daniel, the one he named Belteshazzar, was found to have an extraordinary spirit, as well as knowledge, understanding, and the ability to interpret dreams, explain riddles, and solve difficult problems. Summon Daniel, therefore, and he will give you the interpretation.”$q$, $q$The typhoon warning had been raised since morning. The barangay sent text blasts. A truck with a loudspeaker drove through the riverside streets: "Mag-evacuate na po tayo! The river is rising!"

Kevin and his friends laughed at it. "Every year they say that," Kevin said. "Nothing happens." They had just been paid at the construction site, and they had planned a drinking session at Kevin's house by the river for weeks. They weren't going to cancel because of a little rain.

So while families carried bags and children to the covered court, the group turned up the videoke and opened the first case of beer. When Arnel, a barangay volunteer, knocked on the door to warn them again, they mocked him.

"Kuya Arnel, join us! Relax ka lang!"

Arnel shook his head. "Please. The water rose a meter in two hours. At least move up to the main road."

They closed the door on him.

By midnight, the power went out. By one in the morning, water was pouring under the door. Within minutes it reached their knees, then their waists. The current outside was strong. Kevin's friends were shouting. Kevin's knees were shaking so hard he could barely stand on the table where he had climbed.

Then they heard it: the sound of a motor and a flashlight sweeping across the water. It was Arnel in a rubber boat with two other volunteers.

"Grab the rope!" Arnel shouted.

Wet, cold, and shaking, Kevin climbed into the boat. He couldn't look at Arnel. The man he had laughed at was the only one who had come.

At the evacuation center, Kevin sat silently for a long time. Then he walked over and quietly helped Arnel stack the relief goods.$q$, $q$Chapter 5 jumps forward more than twenty years. Nebuchadnezzar is gone, and Belshazzar is ruling in Babylon. History tells us that on this very night, the armies of the Medes and Persians were camped outside the city walls. Babylon was in danger. And what did the king do? He threw a party for a thousand nobles.

Then, "under the influence of the wine," he made a terrible decision. He ordered the sacred gold and silver cups taken from God's temple in Jerusalem to be brought in. He and his guests drank from them while praising "gods of gold and silver, bronze and iron, wood and stone" (v. 4). It was a deliberate mockery of the living God.

At that very moment, human fingers appeared and wrote on the wall. The king, so proud a moment before, turned pale. "His hips gave way and his knees knocked together" (v. 6). No one could read the writing.

Then the queen, probably the queen mother, came in. She remembered a man from Nebuchadnezzar's days, someone with "an extraordinary spirit" who could "solve difficult problems." Daniel had been forgotten by the new king, but not by God.

This passage warns us about two dangers. The first is careless living in the face of danger: partying while judgment is at the gates. The second is treating holy things lightly. God's name, His Word, His church, and His people are not things to joke about or misuse.

Belshazzar laughed at God until the moment God wrote on his wall. It's far better to take God seriously now, while there is still time.$q$, $q$This passage teaches me that God will not be mocked forever. Belshazzar used holy things for his own pleasure and praised lifeless idols, and God interrupted his party with a message he could not ignore. I confess that I sometimes treat holy things too casually. I joke about sin, hurry through worship, or use God's name carelessly.

I should ask the Lord to give me a healthy fear of Him. Not a fear that drives me away, but a reverence that takes Him seriously.

I am also warned by the king's carelessness. The enemy was at the gates, and he was throwing a party. Knowing that life is short and that God's warnings are real, I will strive not to live as if there is no tomorrow and no judgment. I will stop ignoring the warnings God sends through His Word, my conscience, and the people who love me.

I am encouraged too by Daniel. A new king had forgotten him, but God had not. When I feel overlooked, I can trust that God knows exactly where I am.

This week, I will treat my time with God with reverence and give Him my full attention.$q$, $q$Holy God, forgive me for the times I have treated You lightly. Give me a reverent heart that takes Your name, Your Word, and Your warnings seriously. Keep me from careless living and from ignoring the signs You send me. Thank You that You are patient and that You send people to warn and rescue those who are in danger. When I feel forgotten, remind me that You always know where I am. Help me live each day with my eyes open to what truly matters. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-18', $q$You Knew All This$q$, $q$Daniel 5:13–24 (BSB)$q$, NULL, $q$¹³So Daniel was brought before the king, who asked him, “Are you Daniel, one of the exiles my father the king brought from Judah? ¹⁴I have heard that the spirit of the gods is in you, and that you have insight, intelligence, and extraordinary wisdom. ¹⁵Now the wise men and enchanters were brought before me to read this inscription and interpret it for me, but they could not give its interpretation. ¹⁶But I have heard about you, that you are able to give interpretations and solve difficult problems. Therefore, if you can read this inscription and give me its interpretation, you will be clothed in purple and have a gold chain placed around your neck, and you will be made the third highest ruler in the kingdom.” ¹⁷In response, Daniel said to the king, “You may keep your gifts for yourself and give your rewards to someone else. Nevertheless, I will read the inscription for the king and interpret it for him. ¹⁸As for you, O king, the Most High God gave your father Nebuchadnezzar sovereignty and greatness, glory and honor. ¹⁹Because of the greatness that He bestowed on him, the people of every nation and language trembled in fear before him. He killed whom he wished and kept alive whom he wished; he exalted whom he wished and humbled whom he wished. ²⁰But when his heart became arrogant and his spirit was hardened with pride, he was deposed from his royal throne, and his glory was taken from him. ²¹He was driven away from mankind, and his mind was like that of a beast. He lived with the wild donkeys and ate grass like an ox, and his body was drenched with the dew of heaven until he acknowledged that the Most High God rules over the kingdom of mankind, setting over it whom He wishes. ²²But you his son, O Belshazzar, have not humbled your heart, even though you knew all this. ²³Instead, you have exalted yourself against the Lord of heaven. The vessels from His house were brought to you, and as you drank wine from them with your nobles, wives, and concubines, you praised your gods of silver and gold, bronze and iron, wood and stone, which cannot see or hear or understand. But you have failed to glorify the God who holds in His hand your very breath and all your ways. ²⁴Therefore He sent the hand that wrote the inscription.$q$, $q$Marvin grew up watching gambling slowly destroy his father. He remembered the nights his mother cried over unpaid bills. He remembered selling their small TV to pay a debt. He remembered his father's empty promises: "Last na 'to, promise."

As a teenager, Marvin swore he would never be like him. He gave his life to the Lord at a youth camp, and for years he kept that promise.

Now he was thirty-two, a forklift operator at a warehouse with a wife and a baby girl. It started innocently: a few online games on his phone during breaks. Then small bets with friends. Then bigger ones. He told himself it was just entertainment. Soon, he was hiding his phone from his wife, Joanna, and skipping church to "catch up on sleep."

One payday, he won big. He was so excited that he drove straight to his older sister Cecilia's house with a gift: a brand-new rice cooker and an envelope of cash for her kids' tuition.

Cecilia looked at the envelope. Then she looked at him.

"Where did this come from, Marvin?"

He tried to laugh it off. She didn't laugh.

"Keep it," she said softly, pushing it back. "I don't want it." Her eyes filled with tears. "Marvin, you saw what it did to Papa. You saw what it did to Mama. You knew all this. How can you do the same thing?"

Marvin wanted to be angry. Instead, he sat down on her plastic chair and covered his face with his hands.

That night, he confessed everything to Joanna. The next Sunday, he was back in church. He deleted the apps, gave his phone password to his wife, and joined a men's accountability group.

The first person he called with good news a year later was Cecilia.$q$, $q$Belshazzar offered Daniel purple robes, a gold chain, and the third-highest position in the kingdom. Daniel's answer was blunt: "You may keep your gifts for yourself and give your rewards to someone else" (v. 17). Daniel was now an old man, probably over eighty. He had nothing to gain from the king's approval, and he wouldn't let rewards affect his message.

Then Daniel gave the king a history lesson. God had given Nebuchadnezzar great power, but when his heart became proud, God humbled him until he "acknowledged that the Most High God rules" (v. 21).

Then came the sharpest words in the chapter: "But you his son, O Belshazzar, have not humbled your heart, even though you knew all this" (v. 22).

That was Belshazzar's real guilt. He wasn't ignorant. He knew the story of his grandfather's fall and restoration. He had every reason to fear God. Instead, he "exalted himself against the Lord of heaven," drank from the temple vessels, and praised idols "which cannot see or hear or understand."

Daniel's final charge goes right to the heart: "You have failed to glorify the God who holds in His hand your very breath and all your ways" (v. 23).

This is a warning for those of us who grew up knowing the truth. Knowledge alone doesn't save us. We can know the right answers and still refuse to humble our hearts. Every breath we take is a gift from God. The question isn't how much we know, but whether we honor Him with what we know.$q$, $q$This passage teaches me that knowing the truth is not the same as obeying it. Belshazzar knew what had happened to Nebuchadnezzar, yet he walked straight into the same pride. I confess that there are lessons I have learned, sometimes painfully, that I am still not living out. I have seen where certain sins lead, yet I keep playing with them.

I should ask the Lord to search my heart for any area where He could say to me, "You knew all this." I don't want to be someone who has heard many sermons but still hasn't changed.

I am also challenged by Daniel's integrity. He refused the king's gifts so his message would be clear. Knowing that money and favors can quietly silence the truth, I will strive to be someone whose words can't be bought.

I am humbled by verse 23. God holds my very breath. Because every breath is His gift, I will make it my aim to glorify Him in all my ways.

This week, I will name one lesson I already know but haven't obeyed, and I will take one concrete step to change, including asking someone to hold me accountable.$q$, $q$God who holds my very breath, forgive me for the times I have known the truth but refused to humble my heart. Search me and show me where I have repeated the mistakes I know so well. Give me the courage to turn away from them completely. Thank You for people who love me enough to tell me the truth. Keep my words honest and my heart free from the influence of gifts and favors. With every breath You give me, let me glorify You. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-19', $q$Weighed and Found Wanting$q$, $q$Daniel 5:25–31 (BSB)$q$, NULL, $q$²⁵Now this is the inscription that was written: MENE, MENE, TEKEL, PARSIN. ²⁶And this is the interpretation of the message: MENE means that God has numbered the days of your reign and brought it to an end. ²⁷TEKEL means that you have been weighed on the scales and found deficient. ²⁸PERES means that your kingdom has been divided and given over to the Medes and Persians.” ²⁹Then Belshazzar gave the command, and they clothed Daniel in purple, placed a gold chain around his neck, and proclaimed him the third highest ruler in the kingdom. ³⁰That very night Belshazzar king of the Chaldeans was slain, ³¹and Darius the Mede received the kingdom at the age of sixty-two.$q$, $q$Bernardo's junk shop sat at the end of a dusty road near the river. Every morning, scavengers pushed their carts up to his weighing scale with sacks of plastic bottles, cardboard, scrap metal, and old copper wire. For many of them, what Bernardo paid was all they would eat that day.

Bernardo prided himself on being fair. "Honest timbang," he would say. "That's why people come back."

When his nephew Rex started helping at the shop, Bernardo was glad. Rex was quick with numbers and good with the customers. Business went up. Bernardo began spending more time at home and leaving the weighing to Rex.

Then one afternoon, an old scavenger named Ignacio came to Bernardo's house. He took off his cap and held it nervously.

"Sir, I'm sorry to bother you. For months, I've been bringing the same full sack of bottles every week. It used to weigh eight kilos. Now it's always just six." He hesitated. "Maybe I'm just getting old."

Bernardo went to the shop that night. He took out a five-kilo sack of rice he had just bought and set it on the scale. It read four kilos. He found the small piece of metal Rex had hidden underneath.

Bernardo sat in the dark shop for a long time.

The next morning, he called Rex in. There was no shouting, just a quiet, serious talk that ended with Rex in tears. Then Bernardo took out an old notebook and started going through every name he could remember.

Over the next month, he found as many of the scavengers as he could and paid back what they had been shorted. It took most of his savings.

When Ignacio received his envelope, he cried. "Sir, you didn't have to."

"Yes, I did," Bernardo said. "A scale is supposed to tell the truth."$q$, $q$Finally, Daniel read the inscription: "MENE, MENE, TEKEL, PARSIN." These were Aramaic words for weights and measures, a bit like saying "counted, counted, weighed, divided." On their own, they didn't make sense. But God gave Daniel the meaning.

MENE: "God has numbered the days of your reign and brought it to an end" (v. 26). Belshazzar thought his reign would go on and on. But God had already counted every day, and the last one had come.

TEKEL: "You have been weighed on the scales and found deficient" (v. 27). This is one of the most sobering lines in the Bible. God had placed the king's life on His perfect scale. All his wealth, power, parties, and pride weighed nothing.

PERES: "Your kingdom has been divided and given over to the Medes and Persians" (v. 28).

Amazingly, Belshazzar still honored Daniel as he had promised. But it was too late. "That very night Belshazzar king of the Chaldeans was slain" (v. 30). The great city of Babylon fell in a single night, just as God had said.

Every one of us will one day be weighed on God's scales. And the honest truth is that all of us, on our own, would be "found deficient." None of us measures up to God's holiness.

That's why the gospel is such good news. Jesus stepped onto the scale for us. He lived the perfect life we couldn't live and took the judgment we deserved. When we trust in Him, God sees us clothed in His righteousness. In Christ, we are no longer found wanting.$q$, $q$This passage teaches me that God measures my life with perfect accuracy. Belshazzar thought he had plenty of time, but his days were already numbered. I confess that I often live as if I will always have tomorrow to get right with God, to forgive someone, or to change what I know is wrong. Knowing that my days are counted by God, I should stop putting off what matters most.

I am humbled by the word TEKEL. If my life were placed on God's scale today, apart from Christ, it would be found deficient. My good works, my church attendance, and my reputation could never balance it.

But because of Jesus, I don't need to fear the scale. He has given me His righteousness. Because of this grace, I will strive to live a life of gratitude, not of fear.

I am also reminded to be honest in my own "weighing." Do I measure others fairly? Am I truthful in my work, my business, and my words?

This week, I will settle one thing I have been putting off, whether it's an apology, a debt, or a step of obedience, because I don't know how many days God has numbered for me.$q$, $q$Righteous God, You number my days and You weigh every heart. I confess that on my own I fall short of Your glory. Thank You for sending Jesus to stand in my place and to clothe me in His righteousness. Because of Him, I am not found wanting. Help me to live with gratitude and urgency, not wasting the days You have given me. Make me honest in all my dealings, and help me to do today what I should not put off until tomorrow. In Jesus' name, amen.$q$, $q$This week we watched God deal with two proud kings. On Monday, Nebuchadnezzar dreamed of a great tree cut down, with only the stump left in the ground. On Tuesday, Daniel lovingly but boldly told the king the truth and urged him to repent. On Wednesday, the king boasted, "I built this," and God humbled him until he looked up to heaven and praised the Most High. On Thursday, his successor Belshazzar mocked God at a drunken feast, and a hand wrote on the wall. On Friday, Daniel told him, "You knew all this," yet you did not humble your heart. And today, we read the verdict: weighed on the scales and found deficient. Babylon fell that very night.

Next week brings us to Christmas. We'll see Daniel, now an old man, keep praying just as before, even when it means the lions' den. Then, on Christmas Day itself, we'll read Daniel's vision of "One like a Son of Man" coming on the clouds to receive an everlasting kingdom. 🏁$q$),
  (DATE '2026-12-21', $q$Nothing to Find$q$, $q$Daniel 6:1–9 (BSB)$q$, NULL, $q$¹Now it pleased Darius to appoint 120 satraps to rule throughout the kingdom, ²and over them three administrators, including Daniel, to whom these satraps were accountable so that the king would not suffer loss. ³Soon, by his extraordinary spirit, Daniel distinguished himself among the administrators and satraps. So the king planned to set him over the whole kingdom. ⁴Thus the administrators and satraps sought a charge against Daniel concerning the kingdom, but they could find no charge or corruption, because he was trustworthy, and no negligence or corruption was found in him. ⁵Finally these men said, “We will never find any charge against this Daniel, unless we find something against him concerning the law of his God.” ⁶So the administrators and satraps went together to the king and said, “O King Darius, may you live forever! ⁷All the royal administrators, prefects, satraps, advisers, and governors have agreed that the king should establish an ordinance and enforce a decree that for thirty days anyone who petitions any god or man except you, O king, will be thrown into the den of lions. ⁸Therefore, O king, establish the decree and sign the document so that it cannot be changed—in accordance with the law of the Medes and Persians, which cannot be repealed.” ⁹Therefore King Darius signed the written decree.$q$, $q$Rosalie had been the treasurer of the farmers' cooperative for six years. She was a rice farmer's wife who had finished only two years of college, but she kept the books like a bank. Every peso that came in was written down. Every peso that went out had a receipt. Every quarter, she posted a simple report on the bulletin board at the coop office for all the members to see.

When the coop's board began talking about making her the general manager, some people weren't happy. Two board members, Celso and Ramir, had their own candidate in mind, a relative of Celso's. They began whispering.

"Why is the treasurer so quiet?" they asked at meetings. "Maybe she's hiding something. We should have an outside audit."

Rosalie didn't argue. "Sige po," she said. "Please, go ahead."

The coop hired an auditor from the city. For two weeks, he went through six years of records: ledgers, bank statements, receipts, and loan papers. Celso and Ramir checked on him every few days. "Anything yet?"

At the general assembly, the auditor stood up to give his report. The hall was full. Celso and Ramir sat in the front row.

"I've audited many cooperatives," the auditor said. "Usually I find something: missing receipts, unexplained withdrawals, careless math. Here, I found nothing." He held up a thick folder. "Every centavo is accounted for. Frankly, I've never seen books this clean."

The hall broke into applause. Rosalie looked down at her hands, embarrassed.

Celso and Ramir left early.

That evening, an old farmer named Mauricio stopped by her house with a bag of fresh eggs. "Ma'am Rosalie," he said, "they went looking for dirt. All they found was the truth."$q$, $q$Babylon has fallen, and a new empire is in charge. King Darius organizes his kingdom under 120 officials and three top administrators. One of them is Daniel, now in his eighties. Even at this age, Daniel "distinguished himself" so much that the king planned to put him over the entire kingdom.

That made the other officials jealous. So they went looking for something, anything, to use against him. They checked his work, his finances, and his decisions. Verse 4 gives the result: "they could find no charge or corruption, because he was trustworthy, and no negligence or corruption was found in him."

What a testimony! No bribes. No shortcuts. No laziness. Daniel had served under several kings and empires, and his record was spotless.

So his enemies changed tactics. "We will never find any charge against this Daniel, unless we find something against him concerning the law of his God" (v. 5). They knew the only way to trap Daniel was through his faithfulness to God.

They flattered the king into signing a law: for thirty days, no one could pray to anyone except the king. Anyone who disobeyed would be thrown to the lions. And because it was a law of the Medes and Persians, it could never be changed.

Here is the goal for every believer: to live in such a way that the only "charge" anyone can bring against us is our devotion to God. Integrity in our work and finances doesn't just protect us. It points to the God we serve.

If someone examined your life today, what would they find?$q$, $q$This passage teaches me that integrity is one of the strongest testimonies I can give. Daniel's enemies searched his work, his money, and his habits and found nothing. The only thing they could use against him was his faithfulness to God. I confess that my life would not always survive that kind of inspection. There are small shortcuts I take, small exaggerations I tell, and small areas of laziness I excuse.

I should ask the Lord to search me and show me anything in my work, my finances, or my words that would bring shame to His name. Knowing that people are watching how Christians live, I will strive to be trustworthy in small things and in big things.

I am also reminded that faithfulness can make people jealous. Daniel did nothing wrong, yet people plotted against him. Because of this, I will not be surprised if my integrity is resented, and I will not respond with bitterness.

This week, I will choose one area where I've been careless, whether it's keeping my word, handling money, or doing my work well, and I will make it right. I want my life to be an open book that points to God.$q$, $q$Faithful God, I want to live a life of integrity before You and before people. Search my heart and show me any area of dishonesty, carelessness, or compromise. Help me to be trustworthy in the smallest things. When others look for faults in me, may they find only a heart devoted to You. Protect me from bitterness when I am misunderstood or opposed. Let my life be a clear and honest witness to the God I serve. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-22', $q$Just as Before$q$, $q$Daniel 6:10–17 (BSB)$q$, NULL, $q$¹⁰Now when Daniel learned that the document had been signed, he went into his house, where the windows of his upper room opened toward Jerusalem, and three times a day he got down on his knees, prayed, and gave thanks to his God, just as he had done before. ¹¹Then these men went as a group and found Daniel petitioning and imploring his God. ¹²So they approached the king and asked about his royal decree: “Did you not sign a decree that for thirty days any man who petitions any god or man except you, O king, will be thrown into the den of lions?” The king replied, “According to the law of the Medes and Persians the order stands, and it cannot be repealed.” ¹³Then they told the king, “Daniel, one of the exiles from Judah, shows no regard for you, O king, or for the decree that you have signed. He still makes his petition three times a day.” ¹⁴As soon as the king heard this, he was deeply distressed and set his mind on delivering Daniel, and he labored until sundown to rescue him. ¹⁵Then the men approached the king together and said to him, “Remember, O king, that by the law of the Medes and Persians no decree or ordinance established by the king can be changed.” ¹⁶So the king gave the order, and they brought Daniel and threw him into the den of lions. The king said to Daniel, “May your God, whom you serve continually, deliver you!” ¹⁷A stone was brought and placed over the mouth of the den, and the king sealed it with his own signet ring and with the rings of his nobles, so that nothing concerning Daniel could be changed.$q$, $q$Every night at exactly eight o'clock, Lolo Simeon read to his grandson Ethan. He would sit on the old rattan chair by the window, put on his thick glasses, and open whatever book Ethan picked. Then, before Ethan went to bed, Lolo Simeon would ask him the same question: "What was the best part of your day?"

It had been that way since Ethan was four.

When Ethan was nine, everything at home fell apart. His parents argued night after night, and then his father moved out. His mother started working double shifts at the factory. The house was tense and quiet. Ethan stopped talking at school. Some nights he didn't eat.

Relatives told Lolo Simeon, "Let the boy be. He's too upset for stories now."

But at eight o'clock that first terrible night, Lolo Simeon sat down on the rattan chair, put on his glasses, and opened a book. Ethan stayed in his room. Lolo Simeon read out loud anyway, loud enough for Ethan to hear through the door.

The next night, he did it again. And the next.

On the fifth night, the door creaked open. Ethan came out, sat on the floor next to the chair, and leaned his head against his grandfather's knee. Lolo Simeon kept reading as if nothing had happened.

At the end of the chapter, he asked softly, "What was the best part of your day?"

Ethan was quiet for a long time. Then he said, "This."

Years later, at his college graduation, Ethan told the story to a crowd of classmates and teachers. "When everything else changed," he said, "my lolo didn't. He just kept doing what he had always done. That's what saved me."$q$, $q$"Now when Daniel learned that the document had been signed..." (v. 10). Daniel knew the law. He knew the punishment. And what did he do? He went home, opened his windows toward Jerusalem, knelt down, "prayed, and gave thanks to his God, just as he had done before."

Notice three things about Daniel's prayer life. First, it was regular: three times a day. Prayer was not an emergency button for Daniel. It was the rhythm of his life. Second, it included thanksgiving, even on the day he learned he might die. Third, he did it "just as he had done before." He didn't hide, and he didn't make a show of defiance. He simply refused to change his faithful habit.

That is why the crisis didn't shake him. The strength he needed in the lions' den was built in thousands of ordinary days of prayer.

His enemies were waiting. They caught him praying and rushed to the king. Darius was "deeply distressed" (v. 14) and tried all day to find a way out, but he was trapped by his own law. Finally, he gave the order. Daniel was thrown into the den, and a stone was sealed over the entrance.

But listen to what the king said: "May your God, whom you serve continually, deliver you!" (v. 16). Even this pagan king had noticed that Daniel's faith was constant.

The habits you build today will carry you through the crisis of tomorrow. Don't wait for a lions' den to learn how to pray.$q$, $q$This passage teaches me that the strength I need for tomorrow's crisis is built in today's ordinary faithfulness. Daniel didn't suddenly become a man of prayer when the law was signed. He had been praying three times a day for years. I confess that my prayer life is often inconsistent. I pray more when I'm in trouble and less when things are fine.

I should ask the Lord to help me build steady habits of prayer, Bible reading, and thanksgiving, not as a religious duty, but as the regular rhythm of my relationship with Him.

I am deeply moved that Daniel gave thanks on the very day he learned he might die. Knowing that gratitude is a powerful weapon against fear, I will strive to thank God even when circumstances look dark.

I am also challenged by the words "just as he had done before." When pressure comes, I am tempted either to hide my faith or to make a show of it. Daniel did neither. He simply stayed faithful.

This week, I will set a regular time and place to meet with God every day, and I will guard it. I want my faith to be so consistent that even the people around me can say I serve God continually.$q$, $q$Lord, teach me to pray like Daniel, faithfully, regularly, and with a thankful heart. Forgive me for treating prayer like an emergency button instead of a daily conversation with You. Help me build habits of devotion that will hold me steady when trials come. When pressure rises, give me the courage not to hide my faith and the humility not to show it off. Let people see that I serve You continually, in good times and in hard times. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-23', $q$Shut Mouths$q$, $q$Daniel 6:18–28 (BSB)$q$, NULL, $q$¹⁸Then the king went to his palace and spent the night fasting. No entertainment was brought before him, and sleep fled from him. ¹⁹At the first light of dawn, the king got up and hurried to the den of lions. ²⁰When he reached the den, he cried out in a voice of anguish, “O Daniel, servant of the living God, has your God, whom you serve continually, been able to deliver you from the lions?” ²¹Then Daniel replied, “O king, may you live forever! ²²My God sent His angel and shut the mouths of the lions. They have not hurt me, for I was found innocent in His sight, and I have done no wrong against you, O king.” ²³The king was overjoyed and gave orders to lift Daniel out of the den, and when Daniel was lifted out of the den, no wounds whatsoever were found on him, because he had trusted in his God. ²⁴At the command of the king, the men who had falsely accused Daniel were brought and thrown into the den of lions—they and their children and wives. And before they had reached the bottom of the den, the lions overpowered them and crushed all their bones. ²⁵Then King Darius wrote to the people of every nation and language throughout the land: “May your prosperity abound. ²⁶I hereby decree that in every part of my kingdom, men are to tremble in fear before the God of Daniel: For He is the living God, and He endures forever; His kingdom will never be destroyed, and His dominion will never end. ²⁷He delivers and rescues; He performs signs and wonders in the heavens and on the earth, for He has rescued Daniel from the power of the lions.” ²⁸So Daniel prospered during the reign of Darius and the reign of Cyrus the Persian.$q$, $q$Ramil had driven a tricycle in his town for fifteen years. Everyone at the terminal knew he was the one who returned lost phones and wallets. "Honest Ramil," the other drivers teased him.

So he couldn't believe it when a woman came to the terminal one morning, shouting and pointing at him.

"That's him! He stole my bag! It had my salary in it!"

She had ridden his tricycle the night before. When she got home, she said, her bag was gone. A crowd gathered. Some people shook their heads. Others started posting on social media: "Beware of this tricycle driver!" One post was shared hundreds of times, with Ramil's photo.

The police asked Ramil to come in for questioning. That night, he couldn't sleep. His wife, Divina, sat beside him on the bench outside their house, holding his hand. His regular passengers called and messaged to say they believed him. His terminal president, an older driver named Fernando, went to the barangay hall first thing in the morning and asked for the CCTV footage from the street where the woman had gotten off.

At noon, Fernando came running to the terminal, waving his phone.

The video was clear. The woman stepped out of Ramil's tricycle with the bag on her shoulder. She stood talking to a friend on the corner for twenty minutes, set the bag down on a bench, and walked away without it. A few minutes later, a stranger picked it up.

The woman came to the terminal the next day with her head down. She apologized to Ramil in front of everyone and deleted her post. The people who had shared it went quiet.

Ramil just nodded. "It's okay, ma'am. I hope you find your bag."

Then he went back to work.$q$, $q$The king had a terrible night. He refused food, refused entertainment, and couldn't sleep. At the first light of dawn, he ran to the den and cried out, "O Daniel, servant of the living God, has your God... been able to deliver you?" (v. 20).

From the darkness came Daniel's calm voice: "My God sent His angel and shut the mouths of the lions. They have not hurt me" (v. 22). The old man had spent the night among hungry lions and walked out without a scratch. Verse 23 tells us why: "because he had trusted in his God."

Interestingly, Daniel was probably more at peace that night than the king was. Faith doesn't always remove the lions, but it gives peace in the den.

Then comes a hard part of the story. The king threw Daniel's accusers into the den, together with their wives and children, and the lions killed them at once. This was the king's cruel decision, following the harsh customs of that time. The Bible records it honestly, but it does not praise it. God's own law said children should not be punished for the sins of their parents. What the passage does show is that the accusers had plotted death for an innocent man, and the trap they set came back on them.

Darius then sent a decree to the whole empire: Daniel's God "is the living God, and He endures forever... He delivers and rescues" (vv. 26–27).

Long after Daniel, another innocent Man was condemned through a plot. He was placed in a tomb, and a stone was sealed over it. But on the third day, the stone was rolled away. Jesus walked out alive, and death itself could not hold Him.$q$, $q$This passage teaches me that God is able to shut the mouths of lions, both real lions and the "lions" of fear, false accusation, and danger in my own life. Daniel spent the night in the den, but he was not alone and he was not harmed. I confess that when I face frightening situations, I often lose my peace long before the danger arrives.

I am struck that Daniel slept among lions while the king couldn't sleep in his palace. Knowing that peace comes from trust, not from comfortable circumstances, I should ask the Lord to give me that same calm confidence in Him.

I am also reminded that God sees when I am falsely accused. I don't need to fight every battle or defend myself in anger. Because God is my defender, I will strive to answer accusations with patience and leave my reputation in His hands.

Finally, I see Jesus in this story: the innocent One, the sealed stone, and the early morning deliverance. His resurrection gives me hope that no den, no grave, and no lie can have the last word.

This week, I will bring my biggest fear to God in prayer, and I will choose to trust Him with it.$q$, $q$Living God, You deliver and rescue, and nothing is too hard for You. Thank You for shutting the mouths of lions in my life, even the ones I didn't know were there. When I am afraid, give me Daniel's peace. When I am falsely accused, help me trust You to defend me. Thank You for Jesus, the innocent One who walked out of the sealed tomb. Because He lives, I can face every den with hope. May my life lead others to tremble before You and trust You too. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-24', $q$When the Sea Is Churning$q$, $q$Daniel 7:1–8 (BSB)$q$, NULL, $q$¹In the first year of the reign of Belshazzar over Babylon, Daniel had a dream, and visions passed through his mind as he lay on his bed. He wrote down the dream, and this is the summary of his account. ²Daniel declared: “In my vision in the night I looked, and suddenly the four winds of heaven were churning up the great sea. ³Then four great beasts came up out of the sea, each one different from the others: ⁴The first beast was like a lion, and it had the wings of an eagle. I watched until its wings were torn off and it was lifted up from the ground and made to stand on two feet like a man, and given the mind of a man. ⁵Suddenly another beast appeared, which looked like a bear. It was raised up on one of its sides, and it had three ribs in its mouth between its teeth. So it was told, ‘Get up and gorge yourself on flesh!’ ⁶Next, as I watched, another beast appeared. It was like a leopard, and on its back it had four wings like those of a bird. The beast also had four heads, and it was given authority to rule. ⁷After this, as I watched in my vision in the night, suddenly a fourth beast appeared, and it was terrifying—dreadful and extremely strong—with large iron teeth. It devoured and crushed; then it trampled underfoot whatever was left. It was different from all the beasts before it, and it had ten horns. ⁸While I was contemplating the horns, suddenly another horn, a little one, came up among them, and three of the first horns were uprooted before it. This horn had eyes like those of a man and a mouth that spoke words of arrogance.$q$, $q$It was Christmas Eve, and the Noche Buena table was set: ham, queso de bola, spaghetti, and a big plate of lumpia. But the chair at the head of the table was empty, and a phone was propped up against the pitcher of juice.

On the screen was their mother, Analyn. She was a caregiver in a city thousands of kilometers away. Behind her, the window was dark. She was smiling, but her children could tell she was tired.

"Merry Christmas, mga anak!" she said.

Her oldest, Patricia, was fifteen. She had been reading the news all week. There was unrest in the country where her mother worked: protests, curfews, and talk of more violence. Every night before sleeping, Patricia checked her phone to make sure her mother had messaged.

"Ma," Patricia finally asked, "are you safe? The news looks scary."

Analyn's smile faded for a moment. "There's a lot of noise here," she admitted. "Sirens at night. People are angry. I won't lie, anak. Sometimes I'm afraid."

The table went quiet. The youngest, Gabriel, stopped eating his spaghetti.

Then Analyn leaned closer to the camera. "But listen. Before I left home, your Lola told me something. She said, 'The world will always be noisy and dangerous. But it has never been out of God's hands.' So every night, when I hear the sirens, I remember that."

She held up a small, worn notebook. "I've been writing down every day something I'm thankful for. Do you want to hear today's?"

Patricia nodded, wiping her eyes.

"Today," Analyn said, smiling again, "I get to see all of you on Christmas Eve."

Patricia reached out and touched the screen. Outside, the neighbors' fireworks began to pop.$q$, $q$Today the book of Daniel changes direction. The first six chapters told stories about Daniel's life. The last six record visions God gave him about the future. This vision came years earlier, during Belshazzar's reign.

Daniel saw "the four winds of heaven churning up the great sea" (v. 2). In the Bible, the stormy sea often pictures the restless, chaotic world of nations. Out of it came four terrifying beasts: a lion with eagle's wings, a bear with ribs in its mouth, a leopard with four wings and four heads, and a fourth beast "dreadful and extremely strong," with iron teeth and ten horns.

Then a little horn appeared, uprooting three others, with human eyes "and a mouth that spoke words of arrogance" (v. 8).

What does it mean? Tomorrow and on Saturday, God's messenger will explain more. For now, notice that this vision parallels Nebuchadnezzar's dream of the statue in chapter 2. Many Bible teachers see the same four kingdoms: Babylon, Medo-Persia, Greece, and Rome. But the picture has changed. In chapter 2, the kingdoms looked like a dazzling statue of precious metals. That's how human empires see themselves. In chapter 7, they look like wild, devouring beasts. That's how God sees them when they rule without Him.

On this Christmas Eve, remember that Jesus was born in the days of that fourth kingdom, Rome. He came into a world full of beasts: violent rulers, heavy taxes, and fear. Yet He came. The noisier the world becomes, the more we need to remember that the sea is churning only because God has allowed it, and He has a King ready to rule.$q$, $q$This passage teaches me that the world will often feel like a churning sea full of frightening beasts. Daniel saw powerful empires rise up, crush others, and speak arrogant words. I confess that the news sometimes fills me with fear. Wars, corruption, violence, and uncertainty make me wonder whether anyone is in control.

But knowing that God showed Daniel these things in advance comforts me. Nothing in history takes God by surprise. The beasts rise only within the limits He allows, and their time is short.

On this Christmas Eve, I am reminded that Jesus was born into a world much like this one, under a cruel and powerful empire. He didn't wait for the world to become peaceful before He came. He came into the chaos to bring peace that the world cannot give.

Because of this, I will strive not to let the noise of the world steal my peace or my joy this season. When I feel anxious about the news, I will turn my worry into prayer.

Tonight, before I sleep, I will name one thing I am thankful for, and I will thank God that the Prince of Peace has come.$q$, $q$Lord, the world is often loud, dangerous, and full of fear. But You have never lost control of it. Thank You that You see the beginning from the end and that no power rises without Your permission. On this Christmas Eve, thank You for sending Jesus into our broken and noisy world. When I am afraid, remind me that the Prince of Peace has come and that He reigns. Fill my heart and my home with Your peace tonight. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-25', $q$The King Who Came Down$q$, $q$Daniel 7:9–14 (BSB)$q$, NULL, $q$⁹As I continued to watch, thrones were set in place, and the Ancient of Days took His seat. His clothing was white as snow, and the hair of His head was like pure wool. His throne was flaming with fire, and its wheels were all ablaze. ¹⁰A river of fire was flowing, coming out from His presence. Thousands upon thousands attended Him, and myriads upon myriads stood before Him. The court was convened, and the books were opened. ¹¹Then I kept watching because of the arrogant words the horn was speaking. As I continued to watch, the beast was slain, and its body was destroyed and thrown into the blazing fire. ¹²As for the rest of the beasts, their dominion was removed, but they were granted an extension of life for a season and a time. ¹³In my vision in the night I continued to watch, and I saw One like the Son of Man coming with the clouds of heaven. He approached the Ancient of Days and was led into His presence. ¹⁴And He was given dominion, glory, and kingship, that the people of every nation and language should serve Him. His dominion is an everlasting dominion that will not pass away, and His kingdom is one that will never be destroyed.$q$, $q$On Christmas Eve, the last bus to the province was packed. Families with balikbayan boxes, students going home for the holidays, and workers carrying bags of gifts squeezed into every seat. The new conductor, a gray-haired man in a faded company shirt, worked his way down the aisle, punching tickets.

He helped an old woman lift her heavy box onto the rack. He gave his own bottle of water to a crying toddler's mother. When a young student realized she was fifty pesos short, he quietly paid for it himself. Somewhere past midnight, when the bus stopped at a roadside eatery, he bought hot coffee for the driver and stood outside in the cold while everyone else ate.

The driver, Elmer, had worked for the bus company for twenty years. He liked the new conductor but thought he was strange. "Bago ka lang, Tay?" he asked. "Where were you assigned before?"

The old man just smiled. "Oh, here and there."

Two days later, the company held its year-end gathering for all its employees. The drivers, conductors, and mechanics sat at long tables. Then the owner of the company was introduced: Mr. Lorenzo Dizon, a man most of them had never seen in person.

The gray-haired conductor stepped up to the microphone.

Elmer nearly dropped his plate.

"I wanted to understand your work," Mr. Dizon said. "So I didn't stay in my office. I came down to ride with you. I lifted the boxes. I stood in the cold. And now I understand what you do every day."

Then he announced new benefits for every driver and conductor in the company.

Elmer shook his head, laughing. "All night," he said to the mechanic beside him, "I was talking to the boss and didn't know it."$q$, $q$Merry Christmas! On this day, Daniel lifts our eyes from the beasts on earth to the throne room of heaven.

"Thrones were set in place, and the Ancient of Days took His seat" (v. 9). This is God Himself, eternal and pure, with clothing white as snow, a throne blazing with fire, and countless angels serving Him. "The court was convened, and the books were opened" (v. 10). The arrogant beasts had made a lot of noise, but now heaven's court sits in judgment, and their power is taken away.

Then Daniel sees the most wonderful sight of all: "One like the Son of Man coming with the clouds of heaven" (v. 13). He looks human, like a son of man, yet He comes on the clouds, which in Scripture is how God Himself comes. He approaches the Ancient of Days and receives "dominion, glory, and kingship" and a kingdom "that will never be destroyed" (v. 14).

The beasts came up from the churning sea. This King comes from heaven. The beasts devoured people. This King will be served by every nation.

Who is He? Jesus answered that question Himself. "Son of Man" was His favorite title for Himself. At His trial, He told the high priest, "You will see the Son of Man sitting at the right hand of Power and coming with the clouds of heaven" (Mark 14:62).

That is the wonder of Christmas. The One who will one day come in glory on the clouds first came down in humility, born in a manger. He became truly human, a Son of Man, so that He could save us and share His everlasting kingdom with us.$q$, $q$This passage teaches me that the baby born in Bethlehem is the King of an everlasting kingdom. On Christmas Day, it's easy to think only of a manger and a sweet child. But Daniel shows me who that child really is: the Son of Man who receives all dominion, glory, and kingship from the Ancient of Days.

I am amazed that this glorious King chose to come down so humbly. He didn't stay far away in heaven. He came into our world, took on our flesh, and walked among ordinary people. Because of this, I know He understands my weakness, my struggles, and my pain.

Knowing that He will return on the clouds of heaven, I should not live as if Christmas were only about gifts and food. I will strive to celebrate today with worship at the center, giving my King the honor He deserves.

I also want to share this good news. Somewhere around me today is someone who is lonely, grieving, or far from God. I will look for one person to bless, through a visit, a call, a gift, or a simple word about the King who came down for us.

Today, I bow before Jesus, the Son of Man and King of kings.$q$, $q$Ancient of Days, You reign in glory and holiness forever. Thank You for sending Your Son, the Son of Man, to be born for us in humility. Lord Jesus, You came down from heaven so that we could be part of Your everlasting kingdom. I worship You today as my Savior and King. Fill my celebration with joy and gratitude, and keep my heart centered on You. Use me today to share Your love with someone who needs it. Come again soon, Lord, on the clouds of heaven. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-26', $q$The Last Word Isn't Theirs$q$, $q$Daniel 7:15–28 (BSB)$q$, NULL, $q$¹⁵I, Daniel, was grieved in my spirit, and the visions in my mind alarmed me. ¹⁶I approached one of those who were standing there, and I asked him the true meaning of all this. So he told me the interpretation of these things: ¹⁷‘These four great beasts are four kings who will arise from the earth. ¹⁸But the saints of the Most High will receive the kingdom and possess it forever—yes, forever and ever.’ ¹⁹Then I wanted to know the true meaning of the fourth beast, which was different from all the others—extremely terrifying—devouring and crushing with iron teeth and bronze claws, then trampling underfoot whatever was left. ²⁰I also wanted to know about the ten horns on its head and the other horn that came up, before which three of them fell—the horn whose appearance was more imposing than the others, with eyes and with a mouth that spoke words of arrogance. ²¹As I watched, this horn was waging war against the saints and prevailing against them, ²²until the Ancient of Days arrived and pronounced judgment in favor of the saints of the Most High, and the time came for them to possess the kingdom. ²³This is what he said: ‘The fourth beast is a fourth kingdom that will appear on the earth, different from all the other kingdoms, and it will devour the whole earth, trample it down, and crush it. ²⁴And the ten horns are ten kings who will rise from this kingdom. After them another king, different from the earlier ones, will rise and subdue three kings. ²⁵He will speak out against the Most High and oppress the saints of the Most High, intending to change the appointed times and laws; and the saints will be given into his hand for a time, and times, and half a time. ²⁶But the court will convene, and his dominion will be taken away and completely destroyed forever. ²⁷Then the sovereignty, dominion, and greatness of the kingdoms under all of heaven will be given to the people, the saints of the Most High. His kingdom will be an everlasting kingdom, and all rulers will serve and obey Him.’ ²⁸Thus ends the matter. As for me, Daniel, my thoughts troubled me greatly, and my face turned pale. But I kept the matter to myself.”$q$, $q$Edna's small bakery sat on a corner near the public school. Every morning before dawn, she baked pandesal, ensaymada, and her famous ube rolls. Students lined up before class. Parents stopped by on their way to work.

Then a big bakery chain opened a branch right across the street.

At first, Edna wasn't worried. There was room for both. But the new branch played dirty. They undercut her prices for months, losing money just to drive her out. Someone posted fake reviews online, saying her bread had made students sick. A health inspector showed up three times in one month after anonymous complaints.

Every inspection, her bakery passed. But the damage was done. Sales dropped by half. Edna had to let one of her two helpers go. Some nights, she sat in her empty shop after closing and cried.

Her husband, Ruben, a jeepney mechanic, would sit with her. "Keep baking, Edna," he would say. "Just keep baking honest bread."

So she did. She didn't respond to the fake reviews with anger. She kept her prices fair, her shop clean, and her bread fresh. Her loyal customers kept coming, even if there were fewer of them.

A year later, it came out that the branch manager across the street had been behind the fake reviews and complaints. The company fired him, apologized publicly, and soon closed the branch altogether.

On the first morning after it closed, the line outside Edna's bakery stretched to the corner. A teacher at the front of the line smiled at her. "We never stopped believing in you, Ma'am Edna."

Edna handed her a warm ube roll. "It was a long year," she said. "But they didn't get the last word."$q$, $q$Daniel's vision troubled him deeply. So he asked one of the heavenly beings standing nearby to explain it. The answer was short: "These four great beasts are four kings who will arise from the earth. But the saints of the Most High will receive the kingdom and possess it forever" (vv. 17–18).

Daniel wanted to know more about the fourth beast and especially the little horn with arrogant words. He learned that this horn would "speak out against the Most High and oppress the saints," trying to change God's appointed times and laws (v. 25). Many Bible teachers see this as a picture of the final enemy of God's people before Christ returns. Others see in it every ruler who sets himself up against God. Either way, the point is clear.

God's people will face real opposition. Verse 21 says the horn waged war against the saints "and prevailed against them." That's honest. Sometimes evil seems to win.

But notice the time limit: "a time, and times, and half a time" (v. 25). Evil's season is measured and limited. It doesn't last forever.

Then: "The court will convene, and his dominion will be taken away and completely destroyed forever" (v. 26). And the kingdom will be given "to the people, the saints of the Most High" (v. 27).

Yesterday we saw that the kingdom belongs to the Son of Man. Today we learn that He shares it with His people. The ones who were oppressed will reign with Him.

Daniel was still troubled when the vision ended. That's okay. We don't have to understand every detail. We only need to remember who has the last word.$q$, $q$This passage teaches me that opposition against God's people is real, but it is temporary. Daniel was told plainly that the arrogant horn would prevail against the saints for a time. I confess that when I see evil succeeding, I sometimes wonder if God has forgotten His people.

But knowing that God has set a limit on evil's season, I can endure with hope. The court of heaven will convene. Every injustice will be judged. And the kingdom will be given to the saints of the Most High.

I am amazed that Jesus, the Son of Man, shares His everlasting kingdom with ordinary believers like me. Because of this, I will strive not to give up when following Christ is costly. I will keep doing what is right, even when it seems no one notices.

I am also comforted that Daniel was troubled and didn't understand everything. I don't have to have all the answers about the future. I only need to trust the One who holds it.

As this year comes to a close, I will name one area where I have felt discouraged by opposition, and I will place it in God's hands, trusting that He will have the last word.$q$, $q$Most High God, thank You that evil will not last forever. When I see injustice and opposition against Your people, help me remember that You have set its limits. Give me endurance to keep doing what is right when it is hard. Thank You for the amazing promise that Your saints will share in the everlasting kingdom of Your Son. When I don't understand everything about the future, help me trust You. You have the final word over my life and over all the earth. In Jesus' name, amen.$q$, $q$What a week it has been! On Monday, Daniel's enemies searched his life and found no fault, so they trapped him through his faith. On Tuesday, Daniel prayed and gave thanks "just as he had done before," even though it meant the lions' den. On Wednesday, God shut the lions' mouths, and the king declared to the whole empire that Daniel's God is the living God. On Christmas Eve, Daniel saw four beasts rise from a churning sea. On Christmas Day, we rejoiced as the Son of Man came before the Ancient of Days and received an everlasting kingdom. And today, we learned that evil will rage for a limited time, but the saints of the Most High will possess the kingdom forever.

Next week we close the year with four days. Daniel will see another vision, of a ram and a goat, and the angel Gabriel will help him understand it. Then, on the last two days of the year, we'll kneel with Daniel as he prays a heartfelt prayer of confession, asking God for mercy not because of our righteousness, but because of His great compassion. 🏁$q$),
  (DATE '2026-12-28', $q$How Long, Lord?$q$, $q$Daniel 8:1–14 (BSB)$q$, NULL, $q$¹In the third year of the reign of King Belshazzar, a vision appeared to me, Daniel, subsequent to the one that had appeared to me earlier. ²And in the vision I saw myself in the citadel of Susa, in the province of Elam. I saw in the vision that I was beside the Ulai Canal. ³Then I lifted up my eyes and saw a ram with two horns standing beside the canal. The horns were long, but one was longer than the other, and the longer one grew up later. ⁴I saw the ram charging toward the west and the north and the south. No animal could stand against him, and there was no deliverance from his power. He did as he pleased and became great. ⁵As I was contemplating all this, suddenly a goat with a prominent horn between his eyes came out of the west, crossing the surface of the entire earth without touching the ground. ⁶He came toward the two-horned ram I had seen standing beside the canal and rushed at him with furious power. ⁷I saw him approach the ram in a rage against him, and he struck the ram and shattered his two horns. The ram was powerless to stand against him, and the goat threw him to the ground and trampled him, and no one could deliver the ram from his power. ⁸Thus the goat became very great, but at the height of his power, his large horn was broken off, and four prominent horns came up in its place, pointing toward the four winds of heaven. ⁹From one of these horns a little horn emerged and grew extensively toward the south and the east and toward the Beautiful Land. ¹⁰It grew as high as the host of heaven, and it cast down some of the host and some of the stars to the earth, and trampled them. ¹¹It magnified itself, even to the Prince of the host; it removed His daily sacrifice and overthrew the place of His sanctuary. ¹²And in the rebellion, the host and the daily sacrifice were given over to the horn, and it flung truth to the ground and prospered in whatever it did. ¹³Then I heard a holy one speaking, and another holy one said to him, “How long until the fulfillment of the vision of the daily sacrifice, the rebellion that causes desolation, and the surrender of the sanctuary and of the host to be trampled?” ¹⁴He said to me, “It will take 2,300 evenings and mornings; then the sanctuary will be properly restored.”$q$, $q$Perla's son, Jerome, left home when he was nineteen. There had been a terrible argument with his father about the friends he was running with and the money missing from the drawer. Jerome slammed the door and didn't come back.

At first, Perla heard rumors. Someone saw him in the city. Someone said he was working at a car wash. Someone said he was in trouble. Then, for a long time, nothing.

Every night, Perla left the porch light on. Her husband, Eliseo, told her it was a waste of electricity. She left it on anyway.

Every Christmas, she cooked Jerome's favorite, pork menudo with extra potatoes, and set a plate aside. Every birthday, she bought a small cake and wrote his name on it. Her friends gently told her to move on. Some nights, washing the dishes alone, she would whisper, "How long? How long until he comes home?"

One year has passed. Then three. Then five.

In the sixth year, a week before Christmas, there was a knock at the door late at night. Eliseo opened it.

A thin young man stood in the porch light, holding a plastic bag. He looked older and tired. His eyes were red.

"Pa," Jerome said. His voice broke. "I've been clean for a year. I have a job now. I just... I saw the light was still on."

Eliseo stood frozen. Then he pulled his son into his arms.

Perla came running from the kitchen, still holding a ladle. She didn't say "Where have you been?" She didn't say "Why didn't you call?"

She just said, "Anak, sit down. The menudo is still warm."$q$, $q$Today's vision came a few years after the one in chapter 7. This time, Daniel saw a powerful ram with two horns charging in every direction. "No animal could stand against him" (v. 4). Then a goat with one great horn came from the west so fast it seemed not to touch the ground. It shattered the ram and became very great. But "at the height of his power, his large horn was broken off," and four horns grew in its place (v. 8).

Tomorrow the angel Gabriel will tell us that the ram is Media and Persia and the goat is Greece. History shows how accurately this came true. Alexander the Great swept east and conquered the Persian Empire in just a few years. Then he died suddenly at about thirty-two, and his kingdom was divided among four of his generals.

From one of those divisions came a "little horn" who attacked God's people, stopped the daily sacrifices, and "flung truth to the ground" (v. 12). Many Bible teachers identify him as Antiochus IV, a Greek ruler who desecrated the temple in Jerusalem about 170 years before Christ. His actions also picture the final enemy of God's people.

Then Daniel heard an angel ask the question believers have asked for centuries: "How long?" (v. 13). How long will evil be allowed to trample what is holy?

The answer was specific: "2,300 evenings and mornings; then the sanctuary will be properly restored" (v. 14). The suffering had a limit set by God. And just as promised, the temple was later cleansed and restored.

God doesn't always tell us how long. But He always knows, and His restoration always comes.$q$, $q$This passage teaches me that God sees the rise and fall of every power and that He sets the limits of every season of suffering. The ram seemed unstoppable until the goat came. The goat seemed unstoppable until its great horn was broken. I confess that I am often too impressed by whatever looks strong today, and too afraid of whatever seems to be winning.

I am also comforted that heaven itself asked, "How long?" That tells me it's not a lack of faith to ask God that question. I have my own "how long" prayers: for loved ones far from God, for healing, for answers, and for change.

Knowing that God gave a specific limit to the suffering in Daniel's vision, I should trust that my waiting has a limit too, even if I can't see it. Restoration is coming.

Because of this, I will strive to keep "the porch light on" in my prayers. I will not give up praying for the people and situations I've been carrying.

As this year ends, I will write down the names of the people I'm waiting on God for, and I will commit to keep praying for them in the new year.$q$, $q$Lord of history, You raise up kings and bring them down, and nothing is outside Your control. Thank You that every season of suffering has a limit set by You. You know how long I have been waiting and praying. Give me the strength not to give up. Keep my faith burning like a light left on for the ones I love. I trust that in Your perfect time, You will restore what has been broken. Thank You for being faithful even when the waiting is long. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-29', $q$Then I Got Up$q$, $q$Daniel 8:15–27 (BSB)$q$, NULL, $q$¹⁵While I, Daniel, was watching the vision and trying to understand it, there stood before me one having the appearance of a man. ¹⁶And I heard the voice of a man calling from between the banks of the Ulai: “Gabriel, explain the vision to this man.” ¹⁷As he came near to where I stood, I was terrified and fell facedown. “Son of man,” he said to me, “understand that the vision concerns the time of the end.” ¹⁸While he was speaking with me, I fell into a deep sleep, with my face to the ground. Then he touched me, helped me to my feet, ¹⁹and said, “Behold, I will make known to you what will happen in the latter time of wrath, because it concerns the appointed time of the end. ²⁰The two-horned ram that you saw represents the kings of Media and Persia. ²¹The shaggy goat represents the king of Greece, and the large horn between his eyes is the first king. ²²The four horns that replaced the broken one represent four kingdoms that will rise from that nation, but will not have the same power. ²³In the latter part of their reign, when the rebellion has reached its full measure, an insolent king, skilled in intrigue, will come to the throne. ²⁴His power will be great, but it will not be his own. He will cause terrible destruction and succeed in whatever he does. He will destroy the mighty men along with the holy people. ²⁵Through his craft and by his hand, he will cause deceit to prosper, and in his own mind he will make himself great. In a time of peace he will destroy many, and he will even stand against the Prince of princes. Yet he will be broken off, but not by human hands. ²⁶The vision of the evenings and the mornings that has been spoken is true. Now you must seal up the vision, for it concerns the distant future.” ²⁷I, Daniel, was exhausted and lay ill for days. Then I got up and went about the king’s business. I was confounded by the vision; it was beyond understanding.$q$, $q$Aurora had been the midwife at the small birthing clinic in the barangay for twenty-two years. She had helped bring more than two thousand babies into the world. She knew most of the children in town by name, because she had been the first to hold them.

But one night in December, she lost one.

The labor had gone wrong suddenly. Aurora did everything she had been trained to do. She called the ambulance, rode with the young mother to the hospital, and held her hand the whole way. The doctors worked hard. But the baby didn't survive.

Aurora came home at dawn and sat at her kitchen table without turning on the light. Her husband, Nicanor, made her coffee, but she didn't drink it. Her mind kept going back over every minute. Had she missed something? Why did it happen? Why to that sweet young mother, who had already picked out a name?

She didn't have answers. She felt sick. For two days, she stayed home.

On the third morning, her phone rang. It was the clinic. A woman from the next street had gone into labor, and the second midwife was out of town.

Aurora sat for a moment, looking at the phone. Then she stood up slowly, washed her face, and put on her uniform.

Three hours later, she was holding a healthy, screaming baby boy. The mother laughed and cried at the same time.

When Aurora got home that evening, she found the young mother she had lost the baby with waiting at her gate. Aurora's heart dropped. But the young woman simply hugged her.

"Thank you for not leaving me that night," she whispered. "And thank you for going back."$q$, $q$As Daniel tried to understand the vision, someone "having the appearance of a man" stood before him, and a voice called out, "Gabriel, explain the vision to this man" (v. 16). Gabriel is the same angel who would one day announce the births of John the Baptist and of Jesus.

Daniel was so terrified that he fell facedown. Gabriel touched him, helped him to his feet, and explained. The ram was "the kings of Media and Persia." The goat was "the king of Greece," and its large horn was the first king. The four horns were four kingdoms that would come after him (vv. 20–22).

Then Gabriel described "an insolent king, skilled in intrigue" (v. 23). He would be powerful and deceitful. He would destroy many and even "stand against the Prince of princes," God Himself. "Yet he will be broken off, but not by human hands" (v. 25). Once again, God would deal with the proud ruler Himself, just as the stone "not cut by human hands" struck the statue in chapter 2.

Notice Daniel's reaction at the end. "I, Daniel, was exhausted and lay ill for days. Then I got up and went about the king's business. I was confounded by the vision; it was beyond understanding" (v. 27).

Even Daniel, the great interpreter of dreams, didn't understand everything. He was overwhelmed and sick. But then he got up and went back to work.

That is a beautiful picture of faith. We don't have to understand everything God is doing in order to keep serving Him. Sometimes faith simply means getting up and doing the next faithful thing.$q$, $q$This passage teaches me that it's okay not to understand everything God is doing. Daniel was one of the wisest men who ever lived, and even he said the vision was "beyond understanding." I confess that I often want explanations before I'm willing to move forward. I want to know why something happened before I trust God with it.

I am comforted that Gabriel touched Daniel and helped him to his feet. Knowing that God meets me in my weakness and gently lifts me up, I should not be ashamed when I feel overwhelmed.

I am also deeply challenged by the words "Then I got up and went about the king's business." There have been times this year when I was knocked down by disappointment, confusion, or grief. Some of those questions still don't have answers. But I can still get up and do the next faithful thing.

Because of this, I will strive to keep serving God even when I don't understand His ways. I will trust His character when I can't trace His plan.

As the year ends, I will identify one area where I've stopped serving because I was hurt or confused, and I will ask God for the strength to get up again.$q$, $q$Lord, there are things in my life that I don't understand. Some of this year's questions still have no answers. Thank You that I don't need to understand everything in order to trust You. When I am overwhelmed, touch me and lift me to my feet as You lifted Daniel. Give me the strength to get up and do the next faithful thing You've called me to do. Help me trust Your heart even when I can't see Your plan. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-30', $q$We Were Wrong$q$, $q$Daniel 9:1–10 (BSB)$q$, NULL, $q$¹In the first year of Darius son of Xerxes, a Mede by descent, who was made ruler over the kingdom of the Chaldeans— ²in the first year of his reign, I, Daniel, understood from the sacred books, according to the word of the LORD to Jeremiah the prophet, that the desolation of Jerusalem would last seventy years. ³So I turned my attention to the Lord God to seek Him by prayer and petition, with fasting, sackcloth, and ashes. ⁴And I prayed to the LORD my God and confessed, “O, Lord, the great and awesome God, who keeps His covenant of loving devotion to those who love Him and keep His commandments, ⁵we have sinned and done wrong. We have acted wickedly and rebelled. We have turned away from Your commandments and ordinances. ⁶We have not listened to Your servants the prophets, who spoke in Your name to our kings, leaders, and fathers, and to all the people of the land. ⁷To You, O Lord, belongs righteousness, but this day we are covered with shame—the men of Judah, the people of Jerusalem, and all Israel near and far, in all the countries to which You have driven us because of our unfaithfulness to You. ⁸O LORD, we are covered with shame—our kings, our leaders, and our fathers—because we have sinned against You. ⁹To the Lord our God belong compassion and forgiveness, even though we have rebelled against Him ¹⁰and have not obeyed the voice of the LORD our God to walk in His laws, which He set before us through His servants the prophets.$q$, $q$For as long as Benedicto could remember, his family and his cousins on the other side of the river did not speak. At reunions, they sat at separate tables. When his Uncle Pablo died, his father refused to go to the burial. All Benedicto was ever told was, "They cheated us out of land."

Now Benedicto was sixty-eight, a retired fisherman, and both of his parents were gone. While cleaning out his father's old wooden trunk, he found a bundle of letters tied with string.

He sat on the floor and read them one by one. As he read, his hands began to shake.

The letters told a different story. Fifty years ago, his grandfather had borrowed money from Uncle Pablo's father to buy a boat. When the boat sank in a storm, Benedicto's family never repaid the debt. Instead, they moved the boundary stones of the shared land a few meters during the night. When Uncle Pablo's family complained, Benedicto's father accused them of lying.

It wasn't the cousins who had cheated. It was his own family.

Benedicto didn't sleep that night. In the morning, he put on his best polo shirt, took the letters, and crossed the river.

His cousin Rodrigo opened the door, surprised and suspicious. Benedicto didn't make a speech. He held out the letters with trembling hands.

"Rodrigo," he said, "we were wrong. My lolo was wrong. My father was wrong. I didn't know, but I should have asked. I'm sorry for what my family did to yours."

Rodrigo read for a long time. Then he looked up with wet eyes and stepped aside from the doorway.

"Pasok ka, Pinsan," he said. "You must be hungry."$q$, $q$Chapter 9 opens with Daniel doing something simple: reading his Bible. He was studying the book of Jeremiah and found God's promise that the desolation of Jerusalem would last seventy years (Jeremiah 25:11–12). By now, nearly seventy years had passed since Daniel was taken to Babylon. The time was almost up!

How did Daniel respond? He didn't just sit back and wait. "I turned my attention to the Lord God to seek Him by prayer and petition, with fasting, sackcloth, and ashes" (v. 3). God's promise didn't make Daniel passive. It moved him to pray.

Notice how his prayer begins. First, he praises God as "great and awesome," the God who keeps His covenant of love (v. 4). Then he confesses: "We have sinned and done wrong. We have acted wickedly and rebelled" (v. 5).

Daniel says "we." He was one of the most faithful men in the Bible. Nowhere does Scripture record a sin in his life. Yet he doesn't point at others. He stands with his people and confesses their sin as his own. He acknowledges that they didn't listen to the prophets God sent.

Then he contrasts God and His people: "To You, O Lord, belongs righteousness, but this day we are covered with shame" (v. 7). But in the middle of all that shame, he holds on to hope: "To the Lord our God belong compassion and forgiveness" (v. 9).

This is what real confession looks like. It's honest about sin, humble enough to say "we," and full of hope in God's mercy. And it often begins with simply opening God's Word.$q$, $q$This passage teaches me that reading God's Word should lead me to prayer. Daniel read a promise and immediately turned to God with his whole heart. I confess that I often read the Bible like any other book. I gather information but don't let it move me to pray, confess, or act.

I am also challenged by the way Daniel said "we." It's easy for me to point at the sins of my family, my church, or my country, as if I had nothing to do with them. Daniel, though faithful, humbly stood with his people and confessed their sins as his own. I should ask the Lord to give me that same humility.

Knowing that righteousness belongs to God and that I need His mercy as much as anyone, I will strive to stop blaming and start confessing. Where my family or my community has wronged others, I can be the one to say, "We were wrong," and seek to make things right.

Because to God belongs compassion and forgiveness, I don't need to fear confession. As this year closes, I will set aside time today to read God's Word slowly and let it lead me into honest prayer about my own life.$q$, $q$Great and awesome God, You keep Your covenant of love with those who love You. I confess that I have sinned and done wrong. I have not always listened to Your Word. Forgive me for the times I have blamed others instead of humbly confessing. Give me Daniel's heart, to stand with my family, my church, and my nation in honest prayer. Thank You that to You belong compassion and forgiveness. Let Your Word move me to pray and to change. In Jesus' name, amen.$q$, NULL),
  (DATE '2026-12-31', $q$Not Because We Deserve It$q$, $q$Daniel 9:11–19 (BSB)$q$, NULL, $q$¹¹All Israel has transgressed Your law and turned away, refusing to obey Your voice; so the oath and the curse written in the Law of Moses the servant of God has been poured out on us, because we have sinned against You. ¹²You have carried out the words spoken against us and against our rulers by bringing upon us a great disaster. For under all of heaven, nothing has ever been done like what has been done to Jerusalem. ¹³Just as it is written in the Law of Moses, all this disaster has come upon us, yet we have not sought the favor of the LORD our God by turning from our iniquities and giving attention to Your truth. ¹⁴Therefore the LORD has kept the calamity in store and brought it upon us. For the LORD our God is righteous in all He does; yet we have not obeyed His voice. ¹⁵Now, O Lord our God, who brought Your people out of the land of Egypt with a mighty hand, and who made for Yourself a name renowned to this day, we have sinned; we have acted wickedly. ¹⁶O Lord, in keeping with all Your righteous acts, I pray that Your anger and wrath may turn away from Your city Jerusalem, Your holy mountain; for because of our sins and the iniquities of our fathers, Jerusalem and Your people are a reproach to all around us. ¹⁷So now, our God, hear the prayers and petitions of Your servant. For Your sake, O Lord, cause Your face to shine upon Your desolate sanctuary. ¹⁸Incline Your ear, O my God, and hear; open Your eyes and see the desolation of the city that bears Your name. For we are not presenting our petitions before You because of our righteous acts, but because of Your great compassion. ¹⁹O Lord, listen! O Lord, forgive! O Lord, hear and act! For Your sake, O my God, do not delay, because Your city and Your people bear Your name.”$q$, $q$It had been a hard year for Dominic and his wife, Leah. Dominic was a carpenter's helper, and when the construction company he worked for went bankrupt in March, the work dried up. Leah sold kakanin from their small rented room, but it wasn't enough. By December, they were seven months behind on rent.

Their landlady, Lola Concepcion, was a quiet widow who lived on the ground floor. She never shouted or threatened. Every month, when Dominic came to say they couldn't pay, she simply wrote something in a small green notebook and said, "I understand."

On the morning of December 31, Dominic went downstairs with a heavy heart. He had done the math many times. Even if he found steady work in January, it would take years to pay her back. He had decided to tell her they would move out.

"Lola," he began, "I'm so sorry. We haven't paid since June. We don't deserve to stay. We'll leave after New Year."

Lola Concepcion looked at him for a long moment. Then she took out the green notebook and opened it to a page full of numbers. Dominic recognized his own name at the top.

Slowly, she tore out the page. Then she tore it in half, and in half again.

"Lola, I don't understand. Why?"

"Not because you deserve it," she said with a small smile. "When my husband was alive, we were once in your place. Someone forgave us. I've never forgotten it."

Dominic couldn't speak. He went upstairs, where Leah was cooking. She looked at his face and dropped her spoon.

That night, as the fireworks lit up the sky, they stood on their small balcony holding hands. For the first time all year, they weren't afraid of tomorrow.$q$, $q$Daniel continues his prayer with deep honesty. Israel's exile was not an accident. "All Israel has transgressed Your law" (v. 11). The disaster that fell on Jerusalem was exactly what God had warned about in the Law of Moses. "The LORD our God is righteous in all He does; yet we have not obeyed His voice" (v. 14).

Daniel makes no excuses. He doesn't say God was unfair. He doesn't blame Babylon. He admits that God's judgment was just.

But then the prayer turns. Daniel remembers who God is: the God "who brought Your people out of the land of Egypt with a mighty hand" (v. 15). The God who rescued before can rescue again.

Then comes the heart of the prayer: "We are not presenting our petitions before You because of our righteous acts, but because of Your great compassion" (v. 18).

That is the only ground on which anyone can approach God. Not our good deeds, our church attendance, or our religious record. Only His mercy.

Notice too what Daniel cares about most. Again and again he says, "for Your sake," "Your city," "Your people," "Your name." Daniel's greatest concern is God's glory.

And then the prayer ends with a passionate cry: "O Lord, listen! O Lord, forgive! O Lord, hear and act!" (v. 19).

On the last day of the year, this is a perfect prayer for us. We look back and see where we failed. But we don't come to God on the basis of our performance this year. We come because of His great compassion, which we see most clearly in Jesus. And we ask Him to listen, forgive, and act in the year ahead.$q$, $q$This passage teaches me that I can never come to God on the basis of my own goodness. As I look back on this year, I see many ways I have failed: words I shouldn't have said, opportunities I wasted, and times I didn't obey God's voice. Like Daniel, I must admit that the Lord is righteous in all He does, and that I am the one who has fallen short.

But I don't have to end the year in shame. Knowing that God hears me "because of His great compassion," I should come to Him with confidence, not because I deserve His help, but because He is merciful. Jesus has opened the way.

I am also challenged by Daniel's concern for God's name. I confess that my prayers are often only about my needs. Because God's glory matters most, I will strive in the new year to pray "for Your sake," asking God to work in ways that bring honor to His name.

Tonight, as this year ends, I will take time to thank God for His mercy throughout the past twelve months. Then I will make Daniel's prayer my own for the new year: O Lord, listen! O Lord, forgive! O Lord, hear and act!$q$, $q$O Lord, You are righteous in all You do, and I have not always obeyed Your voice. As this year ends, I don't come to You because of my good works, but because of Your great compassion. Thank You for Jesus, through whom I can approach You with confidence. Forgive me for my failures this year. Thank You for every mercy You have shown me. In the year ahead, work in my life, my family, my church, and my nation for the sake of Your name. O Lord, listen! O Lord, forgive! O Lord, hear and act! In Jesus' name, amen.$q$, NULL)
  ) AS v(entry_date, title, scripture_ref, source_note, scripture_text, story, explanation, response, prayer, weekly_summary)
 WHERE c.slug = 'rosehill'
ON CONFLICT (church_id, entry_date) DO NOTHING;

-- (2) Tagalog draft (never touches a day already marked 'reviewed')
UPDATE public.devotionals d
   SET title_tl = v.title_tl, story_tl = v.story_tl, explanation_tl = v.explanation_tl,
       response_tl = v.response_tl, prayer_tl = v.prayer_tl, weekly_summary_tl = v.weekly_summary_tl,
       tl_status = 'draft', updated_at = now()
  FROM (VALUES
  (DATE '2026-12-01', $q$Nabunot, Pero Hindi Nakalimutan$q$, $q$Apatnapu't dalawang taon nang gumigising si Lolo Ernesto bago sumikat ang araw para lakarin ang kanyang palayan. Kabisado niya ang bawat pilapil, bawat padaluyan ng tubig, at kung aling sulok ang unang binabaha kapag umuulan. Pagkatapos, naibenta ang lupa. Itatayo roon ang isang subdivision, at nagkasundo ang kanyang mga anak na panahon na para lumipat siya sa panganay niyang anak sa lungsod.

Nasa ikalabing-apat na palapag ang condo. Malamig ang hangin, tiles ang sahig, at walang lupa kahit saan. Ilang oras na nakatayo si Lolo Ernesto sa bintana, nakatingin sa mga kalsadang dapat sana'y palayan niya.

"Tatay" ang tawag sa kanya ng guwardiya ng gusali. "Lolo ng 14-C" naman ang tawag ng mga kapitbahay. Masyadong abala sa gadgets ang mga apo niya para itanong kung ano ang buhay sa bukid. May mga gabing pakiramdam niya ay isa siyang taong walang pangalan.

Isang umaga, nakita siya ng apo niyang si Bianca sa maliit na balkonahe. Pinupunit niya ang isang lumang sako ng bigas na palihim niyang dinala mula sa probinsya. Sa loob nito ay isang dakot ng lupa mula sa bukid at isang maliit na supot ng mga binhi.

"Lolo, ano po ang ginagawa n'yo?"

"Inaalala ko kung sino ako," sabi niya.

Sa loob ng isang buwan, luntian na ang balkonahe sa pechay, kamatis, at kangkong na nakatanim sa mga lumang lata ng pintura. Humingi ng ilang punla ang guwardiya. Gusto namang matutong magtanim ng herbs ng isang batang nurse sa katabing unit. Hindi nagtagal, nagtuturo na si Lolo Ernesto ng isang maliit na klase tuwing Sabado sa roof deck ng gusali, at si Bianca ang kanyang katulong.

"Inilipat nila ako," sabi niya kay Bianca isang hapon, habang kayumanggi ang mga kamay sa lupa, "pero hindi nila ako nabunot. May mga bagay na dala-dala mo sa loob."

Tinitigan siya ni Bianca, talagang tinitigan, sa unang pagkakataon matapos ang mahabang panahon. "Lolo," sabi niya, "puwede n'yo po ba akong turuang magtanim ng palay balang araw?"

Tumawa siya hanggang mangilid ang luha sa kanyang mga mata.$q$, $q$Nagsisimula ang aklat ng Daniel sa isang sakuna. Pinalibutan ng hukbo ng Babilonia ang Jerusalem, at bumagsak ang lungsod. Binihag ang hari ng Juda. Kinuha ang mga banal na kagamitan mula sa templo ng Diyos at inilagay sa kabang-yaman ng isang diyos-diyosan. Sa sinumang nakamasid, mukhang nanalo ang mga diyos ng Babilonia.

Pero tingnan nang mabuti ang talata 2: "Ibinigay ng Panginoon sa kanyang kamay si Jehoiakim na hari ng Juda." Akala ni Nebuchadnezzar, siya ang may hawak ng lahat. Hindi pala. Ang Diyos ang may hawak. Nangyari ang trahedyang ito dahil pinahintulutan ito ng Diyos, bilang pagdidisiplina sa matagal nang kawalang-katapatan ng Kanyang bayan. Binalaan Niya sila sa pamamagitan ng sunud-sunod na propeta. Kahit sa paghatol, nasa Kanyang trono pa rin ang Diyos.

Pagkatapos, kumitid ang kuwento sa ilang kabataan. Gusto ni Nebuchadnezzar ang pinakamahuhusay na binata ng Juda. Tuturuan niya sila ng wika at panitikan ng Babilonia, pakakainin mula sa kanyang hapag, at gagawing tapat na mga lingkod. Pati ang mga pangalan nila ay pinalitan. Ang ibig sabihin ng Daniel ay "Ang Diyos ang aking hukom." Ang Hananias ay "mapagpala ang Panginoon." Ang Misael ay nagtatanong, "sino ang katulad ng Diyos?" Ang Azarias ay "tumutulong ang Panginoon." Ang mga bago nilang pangalan ay pumaparangal naman sa mga diyos ng Babilonia.

Simple lang ang layunin ng Babilonia: baguhin ang kanilang isip, mga gawi, at pagkakakilanlan hanggang makalimutan nila kung kanino sila nabibilang.

Ginagawa pa rin ito ng mundo hanggang ngayon. Gusto nitong palitan ang pangalan natin, sinasabing tayo ay kung magkano lang ang kinikita natin, kung ano ang pag-aari natin, o kung ano ang tingin ng ibang tao sa atin. Pero hindi kayang burahin ng bagong tatak ang Diyos na umangkin sa iyo bilang Kanya. Maaaring nabunot ka sa kinalalagyan mo, pero hindi ka kailanman nakalimutan. Ang Panginoong naghari sa Babilonia ay naghahari pa rin sa kalagayan mo ngayon.$q$, $q$Itinuturo sa akin ng talatang ito na kahit baligtad na ang buhay ko, hindi nawawalan ng kontrol ang Diyos. Gumuho ang mundo ni Daniel habang bata pa siya. Nawala ang kanyang tahanan, ang kanyang kalayaan, at pati ang kanyang pangalan. Pero ang pinakaunang sinasabi ng Kasulatan tungkol sa sakunang iyon ay ang Panginoon ang kumikilos.

Inaamin ko na kapag nagkakagulo ang mga bagay, madalas kong iniisip na lumayo na ang Diyos. Tinitingnan ko ang mga nawala sa akin at sinasabi kong nakalimutan na ako. Pinaaalala sa akin ng Daniel 1 na naghahari ang Panginoon kahit sa mahihirap na kabanata ng buhay, at kaya Niyang gamitin ang masakit na panahon para sa layuning hindi ko pa nakikita.

Nakikita ko rin kung gaano katahimik sinisikap ng mundo na hubugin ako. Hindi ito laging sumisigaw. Minsan, sinasanay lang ako nito, araw-araw, na mag-isip, magnais, at mamuhay tulad ng lahat ng nasa paligid ko. Dahil dito, dapat kong bantayan kung ano ang ipinapasok ko sa isip ko at alalahanin kung kaninong pangalan ang dala ko.

Sisikapin kong simulan ang bawat araw sa pag-alala kung sino ako kay Cristo: pinili, minamahal, at pag-aari Niya. Anumang tatak ang ibigay sa akin ng tao, uunahin kong sagutin ang pangalang ibinigay sa akin ng Diyos.$q$, $q$Makapangyarihang Panginoon, salamat po na walang anuman sa buhay ko ang nasa labas ng Inyong kamay. Kapag pakiramdam ko'y nabunot ako at naliligaw, ipaalala po Ninyo na nakikita N'yo pa rin ako at naghahari pa rin Kayo sa bawat panahon. Patawarin po Ninyo ako sa mga pagkakataong nag-alinlangan ako sa Inyo kapag nagkakagulo ang lahat. Bantayan po Ninyo ang aking puso at isip mula sa tahimik na panggigipit na maging katulad ng mundo sa paligid ko. Tulungan N'yo po akong alalahanin na ako'y sa Inyo, at nawa'y dalhin ng buhay ko ang Inyong pangalan nang may karangalan saanman N'yo ako ilagay. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-02', $q$Magpasya Bago Dumating ang Panggigipit$q$, $q$Labinsiyam na taong gulang si Ephraim nang makuha niya ang una niyang tunay na trabaho bilang helper ng welder sa isang construction site sa lungsod. Maliit ang sahod, pero tuloy-tuloy, at napaiyak ang nanay niya sa probinsya nang ibalita niya ito.

Sa una niyang sahod, nagtipon ang crew sa likod ng bunkhouse dala ang isang kahon ng gin at isang plastik na palanggana ng pulutan. "Bagong salta!" sigaw ng isa. "Tagay ka!"

Nakapagpasya na si Ephraim habang nasa bus papuntang lungsod. Ilang taon niyang pinanood ang sarili niyang tatay na ubusin sa inuman ang kalahati ng pera ng pamilya. Hindi siya magsisimula sa landas na iyon. Kaya ngumiti siya at itinaas ang bote niya ng softdrink.

"Pass muna ako, Kuya. Pero thank you."

Nagtawanan ang mga lalaki. Tinukso siya ng ilan. Ilang linggo siyang tinawag ng isa na "Sister Ephraim." Hindi nakipagtalo si Ephraim at hindi rin nangaral. Patuloy lang siyang pumapasok nang maaga, naglilinis ng mga gamit, at nagtatanong sa mga senior welder.

Nagsimula rin siya ng isang maliit na bagay. Tuwing Lunes, naglalakad siya papunta sa panaderya bago sumikat ang araw at bumabalik na may dalang supot ng mainit na pandesal at isang malaking thermos ng kape para sa buong crew. "Para sa Monday blues," sabi niya.

Pagdating ng ikatlong buwan, wala nang tumatawag sa kanyang "Sister." Ang ilan sa mga batang helper ay hindi na sumasama sa inuman tuwing sahod at sumasabay na lang kay Ephraim sa karinderya, at iniipon ang natitira nilang sahod.

Isang araw, tinawag siya ng foreman na si Ronaldo. "May rush job sa ikatlong palapag. Kailangang perpekto ang mga steel frame. Kailangan ko ng taong malinaw ang isip at matatag ang kamay pagdating ng alas-siyete ng umaga." Huminto siya sandali. "Ikaw ang gusto ko."

Hindi nanginig kahit minsan ang mga kamay ni Ephraim nang umagang iyon. Matagal na niyang napagpasyahan kung sino ang gusto niyang maging.$q$, $q$Ang talata 8 ang pagbabago sa takbo ng kabanata: "Ngunit ipinasya ni Daniel na hindi niya dudungisan ang kanyang sarili sa pagkain o alak ng hari." Hindi na hinintay ni Daniel na nasa harap na niya ang plato. Inayos na niya ang bagay na ito sa kanyang puso noon pa man.

Bakit ang pagkain? Hindi sinasabi sa atin ang lahat ng dahilan. Malamang na kasama sa pagkain ng hari ang karneng hindi inihanda ayon sa kautusan ng Diyos at mga bahaging inialay sa mga diyos-diyosan. Ang pagkain sa hapag ng hari ay nangangahulugan ding pag-asa sa hari at pagpapahubog sa kanya. Tinanggap ni Daniel ang bagong wika at bagong pangalan, pero dito siya gumuhit ng hangganan. Mananatili sa Diyos ang pinakamalalim niyang katapatan.

Pansinin kung paano ito hinarap ni Daniel. Hindi siya naghimagsik, hindi nang-insulto, at hindi nagprotesta. Magalang siyang humingi ng pahintulot. Nang matakot ang opisyal, nag-alok si Daniel ng makatwirang pagsubok: sampung araw ng gulay at tubig. Pinadali niya para sa iba ang pumayag.

At pansinin kung sino ang kumikilos sa likod ng lahat: "Ipinagkaloob ng Diyos kay Daniel ang pabor at habag ng punong opisyal" (t. 9). Ginawa ni Daniel ang bahagi niya nang may tapang at paggalang, at binuksan ng Diyos ang pinto.

Pagkatapos ng sampung araw, mas malusog tingnan si Daniel at ang mga kaibigan niya kaysa sa lahat. Pinarangalan ng Diyos ang kanilang katapatan.

Karamihan sa ating mga pakikipagkompromiso ay hindi nangyayari sa malalaki at madadramang sandali. Nangyayari ito sa maliliit, kapag hindi tayo nakapagpasya nang maaga. Itinuturo sa atin ni Daniel na ayusin na ang ating mga paninindigan bago pa dumating ang panggigipit, at pagkatapos ay manindigan nang may biyaya sa halip na kayabangan.$q$, $q$Itinuturo sa akin ng talatang ito na ang katapatan ay kadalasang napagpapasyahan matagal bago pa dumating ang sandali ng pagsubok. Nagpasya muna si Daniel, at ang matatag na pusong iyon ang nagdala sa kanya. Napagtanto ko na marami sa mga pagkabigo ko ay nangyari dahil hindi talaga ako nakapagpasya nang maaga. Basta na lang akong sumabay sa agos ng karamihan.

Dapat kong hilingin sa Panginoon na ipakita sa akin ang mga bahagi ng buhay ko kung saan kailangan kong gumuhit ng malinaw na hangganan: ang mga palabas na pinapanood ko, ang mga biro na tinatawanan ko, ang mga shortcut na ginagawa ko sa trabaho, at ang mga gawing unti-unting naglalayo sa puso ko sa Kanya. Kapag ipinakita na Niya, sisikapin kong magpasya ngayon, sa katahimikan, sa halip na hintayin pa ang panggigipit.

Hinahamon din ako ng paraan ng paninindigan ni Daniel. Magalang siya, malikhain, at mapagbiyaya. Hindi niya itinuring na kaaway ang opisyal. Dahil sa kanyang halimbawa, sisikapin kong panghawakan ang aking mga paninindigan nang hindi minamaliit ang iba, at maghanap ng matatalinong paraan para parangalan ang Diyos habang nagpapakita rin ng kabaitan sa mga tao sa paligid ko.

Dahil alam kong binigyan ng Diyos ng pabor si Daniel, makapagtitiwala rin ako na mauuna Siya sa akin. Ang bahagi ko ay maging tapat. Ang bahagi Niya ay magbukas ng mga pinto.$q$, $q$Panginoon, bigyan po Ninyo ako ng pusong matatag na nakatuon sa Inyo bago pa dumating ang panggigipit. Ipakita po Ninyo kung saan ako napapaanod at kung saan ko kailangang gumuhit ng malinaw na hangganan. Tulungan po Ninyo akong manindigan nang may tapang, pero may kabaitan at paggalang din, para makita ng mga tao ang Inyong biyaya sa akin at hindi kayabangan. Kapag pakiramdam ko'y nag-iisa ako sa paggawa ng tama, ipaalala po Ninyo na kumikilos Kayo sa likod ng lahat, nagbibigay ng pabor at nagbubukas ng mga pinto. Nais ko po Kayong parangalan sa maliliit na pagpili sa bawat araw. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-03', $q$Nakatayo Pa Rin Kahit Wala Na ang mga Hari$q$, $q$Sa huling araw ng kanyang trabaho, dumating si Teodoro sa paaralan nang alas-singko ng umaga, gaya ng ginagawa niya sa loob ng tatlumpu't limang taon. Binuksan niya ang gate, winalis ang quadrangle, at tiningnan ang mga gripo sa mga CR. Pagkatapos, umupo siya sa bangko sa tabi ng flagpole at hinintay ang bell.

Utility man na ng paaralan si Teodoro mula pa noong dalawampu't apat na taong gulang siya. Sa panahong iyon, pitong principal na ang pinagsilbihan niya. May mga mahigpit, may mababait, at may isa pang halos hindi siya kinakausap. May mga gusaling naidagdag at may mga giniba. Dalawang beses nang nagpalit ng kulay ang uniporme. Sa kabila ng lahat, ganoon pa rin ang paraan ng paggawa ni Teodoro: maingat, masaya, at nasa oras.

Patuloy rin siyang gumagawa ng maliliit na bagay na walang nag-uutos sa kanya. Inaayos niya ang mga sirang upuan bago pa may magreklamo. May kahon siya ng mga perdible at ekstrang butones para sa mga estudyanteng napunit ang uniporme. Alam niya kung sinong mga bata ang pumapasok nang gutom, at tahimik niyang ibinabahagi sa kanila ang kanyang baon.

Nang hapong iyon, sinorpresa siya ng mga guro ng isang programa sa covered court. Akala ni Teodoro ay sandali lang ito. Pero isa-isang tumayo ang mga dating estudyante. Ang isa ay guro na ngayon sa parehong paaralan. Ang isa ay engineer. Ang isa pa ay pulis. Bawat isa ay may kuwento tungkol kay Teodoro: isang naayos na bisikleta, isang salitang nagpalakas ng loob, isang pandesal sa isang gutom na umaga.

Ang kasalukuyang principal, si Mrs. Villareal, ang huling humawak ng mikropono. "Dumarating at umaalis ang mga principal," nakangiti niyang sabi. "Pito na kaming naupo sa opisinang iyon. Pero iisa lang ang Teodoro ng paaralang ito."

Tumingin si Teodoro sa magagaspang niyang mga kamay at umiling. "Ginawa ko lang po ang nasa harap ko," sabi niya. "Araw-araw."$q$, $q$Pagkatapos ng sampung araw na pagsubok, lumaktaw ang kuwento nang tatlong taon. Natapos ni Daniel at ng mga kaibigan niya ang kanilang pagsasanay, at ang hari mismo ang kumapanayam sa kanila. Natuklasan niyang "sampung ulit na mas magaling" sila kaysa sa lahat ng salamangkero at engkantador sa kanyang kaharian (t. 20).

Pero huwag palampasin kung saan nagmula ang kanilang kahusayan: "Sa apat na binatang ito, nagbigay ang Diyos ng kaalaman at pang-unawa" (t. 17). Oo, nag-aral sila nang husto. Mabigat ang edukasyon sa Babilonia. Pero ang kanilang karunungan ay sa huli'y regalo mula sa Diyos. Ang katapatan sa maliliit na bagay, tulad ng pagtanggi sa pagkain ng hari, ay sinundan ng pagpapala ng Diyos sa malalaking bagay.

Hindi ito nangangahulugang bawat tapat na mananampalataya ay maitataas sa posisyon o pupurihin. Pero nangangahulugan ito na nakikita ng Diyos, at kaya Niyang ihanda ang Kanyang bayan para sa anumang gawaing ibibigay Niya sa kanila. Ang isang Cristiano ay maaaring maging banal at mahusay nang sabay. Sa katunayan, dapat ganoon tayo. Ang ating trabaho ay isa sa mga paraan ng pagpaparangal natin sa Diyos sa mundong hindi nakakakilala sa Kanya.

Pagkatapos ay may isang tahimik pero makapangyarihang linya: "At nanatili roon si Daniel hanggang sa unang taon ni Haring Ciro" (t. 21). Mga pitumpung taon iyon. Mamamatay si Nebuchadnezzar. Ang Babilonia mismo ay babagsak sa mga Medo at Persiano. May mga haring babangon at mawawala. Pero naroon pa rin si Daniel, tapat pa rin, naglilingkod pa rin.

Iyan ang tunay na tagumpay ng kabanata 1. Sinikap ng Babilonia na lamunin si Daniel. Sa halip, si Daniel ang nagtagal nang higit sa Babilonia. Ang mga kahariang mukhang hindi matatalo ngayon ay lilipas din. Pero ang buhay na nakaangkla sa Diyos ay mananatili.$q$, $q$Itinuturo sa akin ng talatang ito na ang Diyos ang tunay na pinagmumulan ng aking mga kakayahan. Bawat kasanayan, bawat pang-unawa, at bawat pagkakataong mayroon ako ay regalo mula sa Kanyang kamay. Nagpapakumbaba ito sa akin, dahil natutukso akong angkinin ang papuri sa mga naabot ko. Pinalalakas din nito ang loob ko, dahil ang ibinibigay ng Diyos ay kaya rin Niyang paramihin.

Hinahamon akong maging mahusay sa aking trabaho, hindi para humanga ang mga tao, kundi para parangalan ang Panginoon. Nagwawalis man ako ng sahig, nagluluto, nagtuturo sa mga bata, nagmamaneho, o nag-aalaga ng pamilya, magagawa ko ito nang buong puso bilang pagsamba. Dahil sa halimbawa ni Daniel, titigil na ako sa pagturing sa mga karaniwan kong gawain na maliit o walang halaga.

Naaantig din ako sa mga salitang "nanatili si Daniel." Hindi napapatunayan ang katapatan sa isang linggo o isang buwan. Napapatunayan ito sa loob ng maraming taon, sa gitna ng mga pagbabagong hindi ko pinili at mga lider na hindi ko pinili. Dahil alam kong lumilipas ang mga kaharian at mga panahon, dapat ko nang itigil ang paglalagay ng aking seguridad sa mga tao at sistema sa paligid ko.

Sisikapin kong maging mananampalatayang nakatayo pa rin, naglilingkod pa rin, at nagtitiwala pa rin sa Diyos matagal na matapos maglaho ang ingay ng kasalukuyan.$q$, $q$Tapat na Diyos, salamat po sa bawat regalo at kakayahang ibinigay Ninyo sa akin. Patawarin po Ninyo ako sa mga pagkakataong inangkin ko ang papuri sa mga bagay na nagmula sa Inyong kamay. Tulungan po Ninyo akong gawin ang aking trabaho nang may kahusayan at kagalakan, bilang pagsamba sa Inyo. Kapag nagbabago ang mga panahon at dumarating at umaalis ang mga tao, panatilihin po Ninyo akong matatag at tapat. Nawa'y magtagal ang buhay ko nang higit sa mga lumilipas na bagay ng mundong ito dahil nakaugat ito sa Inyo. Bigyan po Ninyo ako ng pagtitiis para patuloy na maglingkod sa Inyo, araw-araw, taon-taon. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-04', $q$Kapag Walang Sinuman sa Lupa ang Makagagawa$q$, $q$Nagmamaneho si Rodel ng pedicab sa labas ng palengke mula alas-sais ng umaga hanggang hatinggabi. Sa magandang araw, nakakauwi siya ng apat na raang piso pagkatapos magbayad ng boundary. Sa masamang araw, halos wala siyang naiuuwi.

Hindi siya kailanman naging taong humihingi ng tulong kaninuman. May pride siya, may sigarilyo, at tuwing Sabado't Linggo, may bote. "Bahala na" ang sagot niya sa bawat problema.

Pagkatapos, bigla na lang bumagsak habang naglalaro ang anim na taong gulang niyang anak na si Kristine. Sinabi ng doktor sa provincial hospital na may butas sa puso ang bata. Kailangan niyang maoperahan sa Maynila. Ang tantiyang gastos ay higit pa sa kikitain niya sa loob ng sampung taon.

Sinubukan ni Rodel ang lahat. Nangutang siya sa mga pinsan niya hanggang hindi na sila sumasagot. Pumunta siya sa isang nagpapautang ng five-six at umuwing halos pamasahe lang sa bus ang dala. Pumila siya sa mga opisina para humingi ng tulong at pinabalik siya sa susunod na buwan. Gabi-gabi, nakaupo siya sa baitang sa labas ng inuupahan nilang kuwarto, naninigarilyo, nakatulala.

"Pare, wala na talagang magagawa," sabi ng isang kapwa drayber. "Walang makakatulong sa 'yo sa ganyang kalaking halaga."

Ang kapitbahay niyang si Rosario, isang biyudang nagtitinda ng kakanin, ang kumatok sa pinto niya isang gabi. "Rodel, puwede ko bang ipanalangin si Kristine?" Muntik na siyang tumanggi. Sa halip, tumango siya.

Nagsimulang manalangin at dumalaw ang maliit na simbahan ni Rosario. Tinulungan siya ng isa sa mga miyembro, isang nurse, na mag-apply sa isang foundation para sa mga batang may sakit sa puso na hindi pa niya naririnig kailanman. Inihatid naman siya ng isa pa sa Maynila nang libre.

Naoperahan si Kristine noong Marso. Makalipas ang ilang buwan, nakaupo si Rodel sa pinakahuling hanay ng simbahan ni Rosario, hawak ang kamay ng kanyang anak. Narating na niya ang dulo ng lahat ng kaya niyang gawin. Doon niya sa wakas natagpuan ang Isang may kakayahan.$q$, $q$Nagsisimula ang kabanata 2 sa pinakamakapangyarihang tao sa mundo na hindi makatulog. Nanaginip si Nebuchadnezzar ng isang bagay na labis na bumagabag sa kanya. Kaya ipinatawag niya ang kanyang mga eksperto: mga salamangkero, engkantador, manggagaway, at astrologo. Sila ang pinakamatatalinong isip ng Babilonia, ang mga taong nilalapitan ng lahat para sa kasagutan.

Pero nagbigay ang hari ng nakagugulat na utos. Kailangan nilang sabihin sa kanya hindi lang ang kahulugan ng panaginip, kundi ang mismong panaginip. Kung hindi nila kaya, papatayin sila at wawasakin ang kanilang mga bahay.

Bakit ganoon kabigat ang hiling? Mukhang hinala ng hari na manloloko ang kanyang mga tagapayo. Kahit sino ay puwedeng mag-imbento ng interpretasyon. Pero ang tanging may tunay na access sa kaalaman ng Diyos ang makapagsasabi sa kanya kung ano talaga ang napanaginipan niya.

Nataranta ang mga eksperto. Ang sagot nila sa talata 10–11 ay isa sa pinakatapat na pag-amin sa buong aklat: "Walang sinuman sa lupa ang makagagawa ng hinihiling ng hari... walang makapagsasabi nito sa kanya maliban sa mga diyos, na ang tahanan ay wala sa piling ng mga tao."

Nang hindi nila namamalayan, nasabi nila ang mismong punto ng kabanata. May hangganan ang karunungan ng tao. May mga problemang hindi kayang lutasin ng sinumang eksperto, ng anumang halaga ng pera, o ng anumang kapangyarihan sa lupa. Ang hindi nila alam, ang tunay na Diyos ay hindi nananatiling malayo. Siya ay Diyos na naghahayag at lumalapit sa Kanyang bayan.

Kumalat ang galit ng hari, at umabot ang hatol na kamatayan pati kina Daniel at sa kanyang mga kaibigan, na hindi naman ipinatawag. Minsan, naiipit tayo sa krisis na hindi naman tayo ang may gawa.

Kapag narating mo na ang dulo ng mga kasagutan ng tao, hindi pa iyon ang dulo ng pag-asa. Naroon ka sa lugar kung saan nagsisimulang ipakita ng Diyos ang Kanyang kaluwalhatian.$q$, $q$Itinuturo sa akin ng talatang ito na may mga problema sa buhay na walang sinuman sa lupa ang makalulutas. Inamin ito ng pinakamatatalinong tao sa Babilonia, at kailangan ko rin itong aminin. Ang ilan sa mga pasanin ko ay talagang masyadong malaki para sa aking lakas, ipon, o mga koneksyon.

Inaamin ko na madalas akong tumatakbo sa lahat ng tao at bagay bago ako tumakbo sa Diyos. Tumatawag ako sa mga kaibigan, naghahanap online, at gumagawa ng mga plano habang natataranta. Ang panalangin ay nagiging huling paraan ko sa halip na unang tugon. Dahil alam kong hindi malayo ang Diyos tulad ng mga diyos ng Babilonia, dapat kong dalhin muna sa Kanya ang mga imposibleng sitwasyon ko.

Pinaaalala rin sa akin na minsan naiipit ako sa mga krisis na hindi ko ginawa, gaya ni Daniel na nadamay sa utos ng hari. Kapag nangyari iyon, hindi ko kailangang maging mapait o matakot. Ang Diyos na kasama ni Daniel ay kasama ko rin.

Dahil dito, sisikapin kong pangalanan sa harap ng Panginoon ngayon ang mga "imposibleng" sitwasyon ko. Ibibigay ko ang mga ito sa Kanya nang tapat. Magmamasid din ako sa paligid ko para sa isang taong naubusan na ng kasagutan, at handa akong kumatok sa kanyang pinto at mag-alok na ipanalangin siya.$q$, $q$Panginoon, alam po Ninyo ang mga problema sa buhay ko na walang sinuman sa lupa ang makalulutas. Dinadala ko po ang mga ito sa Inyo ngayon. Patawarin po Ninyo ako sa pagtakbo ko muna sa lahat ng iba at sa huli na lang lumalapit sa Inyo. Salamat po na hindi Kayo malayong Diyos kundi Isang lumalapit at naghahayag ng Inyong sarili sa mga naghahanap sa Inyo. Kapag pakiramdam ko'y nakakulong ako sa mga kalagayang hindi ko pinili, tulungan po Ninyo akong magtiwala na Kayo pa rin ang may hawak ng lahat. Gamitin po Ninyo ako para magdala ng pag-asa sa isang taong naubusan na ng kasagutan. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-05', $q$Bago Ka Mataranta, Tawagan ang Iyong mga Kaibigan$q$, $q$Dumating ang abiso isang Miyerkoles ng hapon. Tatlong araw na lang ang maliit na furniture shop ni Leonardo para ayusin ang kanyang electrical wiring at mga fire exit, o ipasasara ito ng lungsod.

Dalawampung taon nang itinayo ni Leonardo ang shop. Gumagawa siya ng mga mesa, aparador, at kama para sa mga pamilya sa buong bayan. Imposible ang tatlong araw. Ang una niyang naisip ay sigawan ang inspector, isang binatang nagngangalang Arvin na mukhang halos humihingi pa ng paumanhin.

Sa halip, huminga nang malalim si Leonardo. "Sir, hindi po ako nakikipagtalo. Pero puwede n'yo po bang ipaliwanag sa akin kung ano talaga ang kailangang ayusin? At kung gagawin namin nang tama, puwede n'yo po ba akong bigyan hanggang Sabado?"

Napakurap si Arvin. Sinisigawan siya ng karamihan sa mga may-ari ng shop. Umupo siya at isa-isang ipinaliwanag kay Leonardo ang listahan. "Sabado," sabi niya sa wakas. "Ako mismo ang babalik."

Nang gabing iyon, tinawagan ni Leonardo ang tatlong lalaki: sina Joel, Alfredo, at Benjie. Nagsimula silang lahat bilang mga apprentice niya maraming taon na ang nakalipas. Ngayon, may kanya-kanya na silang shop.

"Kailangan ko ng tulong," simpleng sabi niya. "At hindi ko kayo kayang bayaran nang malaki."

Dumating pa rin sila. Nagsama si Joel ng kaibigan niyang electrician. Nagdala si Alfredo ng mga gamit. Nagdala naman si Benjie ng pansit na luto ng asawa niya at isang malaking kaldero ng kanin. Tatlong gabi silang nagtrabaho nang magkakatabi, nagtatawanan, pinagpapawisan, at nagkukuwentuhan tungkol sa mga lumang araw.

Noong Sabado ng umaga, nilibot ni Arvin ang shop dala ang kanyang clipboard. Tiningnan niya ang bawat saksakan at bawat exit. Pagkatapos, pinirmahan niya ang papel at kinamayan si Leonardo.

Nang umalis siya, hindi agad nagdiwang si Leonardo. Tinipon niya ang tatlong lalaki, tiningnan ang bawat isa, at sinabing, "Bago ang lahat, salamat. Hindi ko ito kakayanin nang mag-isa."

Nang gabing iyon, sumulat siya ng tatlong thank-you note at isa-isang iniabot sa kamay ng bawat isa.$q$, $q$Nang dumating ang mga berdugo para kay Daniel, hindi siya nataranta. Sinasabi ng talata 14 na siya ay "sumagot nang may karunungan at pag-iingat." Nagtanong siya nang mahinahon kay Arioc, ang kumander: "Bakit napakabigat ng utos ng hari?" Pagkatapos, pumunta siya sa hari at humingi ng panahon. Ang parehong haring kaaakusa lang sa kanyang mga tagapayo na nagpapatagal lang ng oras ay pumayag ngayon sa hiling ni Daniel. Kumikilos na ang Diyos.

Sumunod, umuwi si Daniel at tinawag ang kanyang mga kaibigan. Hindi hiningi kina Hananias, Misael, at Azarias na lutasin ang problema. Hiningi sa kanila na manalangin, na "humingi ng awa sa Diyos ng langit" (t. 18). Alam ni Daniel na ang bagay na ito ay Diyos lang ang makahaharap, at alam din niyang hindi niya ito dapat harapin nang mag-isa.

Sumagot ang Diyos nang gabing iyon. At tingnan ang unang tugon ni Daniel: bago tumakbo sa hari, bago iligtas ang sariling buhay, sumamba muna siya. Ang kanyang panalangin sa talata 20–23 ay isa sa pinakamaganda sa buong Kasulatan. Ang karunungan at kapangyarihan ay sa Diyos. Siya ang "nagbabago ng mga panahon at kapanahunan; nag-aalis Siya ng mga hari at naglalagay ng mga hari." Siya ang "naghahayag ng malalalim at natatagong bagay."

Sinabi ng mga pantas ng Babilonia na mga diyos lang ang makapaghahayag ng panaginip. Ipinapakita sa atin ni Daniel na iyan mismo ang ginagawa ng Diyos ng langit.

Nagbibigay ang talatang ito ng simpleng huwaran para sa panahon ng krisis. Manatiling mahinahon at magalang. Hingin ang kailangan mo. Tipunin ang mga kaibigang mananampalataya para manalangin. At kapag sumagot ang Diyos, huminto at magpasalamat muna sa Kanya bago magpatuloy. Magkasama ang panalangin at papuri.$q$, $q$Itinuturo sa akin ng talatang ito na ang paraan ng pagtugon ko sa krisis ay nagpapakita kung saan talaga nakalagay ang aking tiwala. Kamatayan ang nakaharap kay Daniel, pero nagsalita siya nang mahinahon at may karunungan. Inaamin ko na kapag dumarating ang problema, ang una kong reaksyon ay madalas na takot, galit, o masasakit na salita. Dapat kong hilingin sa Panginoon na bigyan ako ng matatag na espiritu ni Daniel, para tumugon ako nang may karunungan at pag-iingat sa halip na pagkataranta.

Hinahamon din ako ng mga pagkakaibigan ni Daniel. May mga taong matatawagan siya kahit hatinggabi para manalangin kasama niya. Mayroon ba akong ganoong mga kaibigan? Ganoon bang kaibigan ako sa iba? Sisikapin kong magtayo ng mas malalim at nananalanging pagkakaibigan sa aking simbahan at maliit na grupo, hindi lang para sa sarili ko kundi para makasama ko rin ang iba sa kanilang mahihirap na panahon.

Dahil alam kong pinuri muna ni Daniel ang Diyos bago siya gumawa ng anuman, gusto kong maging mas mabilis magpasalamat. Madalas, natatanggap ko ang mga sagot ng Diyos at nagmamadali na akong magpatuloy, nakakalimutang sumamba.

Ngayong linggo, papangalanan ko ang isang panalanging kamakailan lang sinagot ng Diyos, at pasasalamatan ko Siya rito nang malakas. Lalapit din ako sa isang kaibigan at itatanong, "Paano kita maipapanalangin?"$q$, $q$Diyos ng langit, sa Inyo po ang karunungan at kapangyarihan. Binabago po Ninyo ang mga panahon at kapanahunan, at alam N'yo ang nasa kadiliman. Kapag dumarating ang problema, bigyan po Ninyo ako ng mahinahon at marunong na puso sa halip na pagkataranta. Salamat po sa mga kaibigang ibinigay Ninyo sa akin na kasama kong nananalangin. Gawin po Ninyo akong tapat na prayer partner ng iba. At kapag sumasagot Kayo, tulungan po Ninyo akong hindi makalimot na huminto at purihin muna Kayo. Sa Inyo, O Diyos, ang aking pasasalamat at papuri, sapagkat nakikinig Kayo at sumasagot. Sa pangalan ni Jesus, amen.$q$, $q$Ngayong linggo, sinimulan natin ang aklat ng Daniel at nakilala ang apat na binatang malayo sa kanilang tahanan. Noong Martes, nakita nating bumagsak ang Jerusalem at binigyan ng mga bagong pangalan si Daniel at ang kanyang mga kaibigan, pero ang Panginoon pa rin ang may hawak ng lahat. Noong Miyerkoles, ipinasya ni Daniel na hindi niya dudungisan ang kanyang sarili, at nanindigan siya nang may tapang at paggalang. Noong Huwebes, natutunan natin na binigyan ng Diyos ng karunungan ang mga binatang ito at nanatiling tapat si Daniel matagal na matapos dumating at umalis ang mga hari. Noong Biyernes, inamin ng mga eksperto ng Babilonia na walang sinuman sa lupa ang makatutugon sa imposibleng hiling ng hari. At ngayong araw, hinarap ni Daniel ang krisis sa pamamagitan ng mahinahong salita, mga kaibigang nananalangin, at taos-pusong papuri sa Diyos na naghahayag ng mga hiwaga.

Sa susunod na linggo, haharap si Daniel sa hari at ihahayag ang dakilang panaginip tungkol sa isang rebulto at isang batong nagiging kaharian. Pagkatapos, makikilala natin ang isang gintong imahen, tatlong binatang tumangging yumukod, at isang naglalagablab na pugon na may ikaapat na Lalaking naglalakad sa gitna ng apoy. 🏁$q$),
  (DATE '2026-12-07', $q$Hindi Po Ako 'Yon$q$, $q$Walong buwan pa lang nagtatrabaho si Mylene sa maliit na botika malapit sa district hospital nang mangyari ito.

Iniabot sa kanya ng isang mukhang pagod na batang ama ang dalawang reseta mula sa dalawang magkaibang doktor. Ang isa ay para sa impeksyon sa tainga ng kanyang anak. Ang isa naman ay para sa seizure condition na ipinagamot ng bata maraming taon na ang nakalipas. Dalawang beses itong binasa ni Mylene. May bumabagabag sa kanya sa pagsasama ng dalawang gamot.

Naalala niya ang isang aral noong una niyang linggo. Pinakopya sa kanya ni Mrs. Domingo, ang pharmacist na may-ari ng botika, ang isang mahabang listahan ng mga mapanganib na kombinasyon ng gamot sa isang maliit na kuwaderno. "Hindi mo matatandaan ang lahat," sabi niya. "Kaya isulat mo, at tingnan mo tuwing may reseta."

Inilabas ni Mylene ang kuwaderno. Naroon nga. Ang dalawang gamot kapag pinagsama ay maaaring magdulot ng malubhang reaksyon sa isang bata.

Tinawag niya si Mrs. Domingo, na agad itong kinumpirma at tinawagan ang doktor. Sa loob ng isang oras, napalitan ang reseta. Paulit-ulit na kinamayan ng batang ama si Mylene. "Baka nailigtas mo ang buhay ng anak ko," sabi niya.

Makalipas ang isang linggo, tumawag ang isang lokal na programa sa radyo para kapanayamin ang "alertong pharmacy assistant." Kinabahan si Mylene pero pumayag.

"Paano mo nahuli ang pagkakamali?" tanong ng announcer. "Siguro napakatalino mo."

Natawa si Mylene. "Hindi po, sir. Hindi po ako 'yon. Tinuruan po ako ng amo ko na isulat ang lahat at tingnan tuwing may reseta. Binuksan ko lang po ang kuwaderno. Siya po ang nagsiguro na naroon na ang sagot."

Nakikinig si Mrs. Domingo sa maliit na radyo sa likod ng counter. Nagkunwari siyang abala sa pagbibilang ng mga tableta, pero nakita ni Mylene na pinunasan niya ang kanyang mga mata gamit ang likod ng kanyang kamay.

Mula noon, si Mylene na ang pinagsanay ni Mrs. Domingo sa bawat bagong assistant na pumapasok sa botika.$q$, $q$Pumasok ngayon si Daniel sa silid ng trono dala ang sagot na ibinigay sa kanya ng Diyos. Pansinin ang una niyang inalala: "Huwag ninyong patayin ang mga pantas ng Babilonia!" (t. 24). Mga paganong salamangkero ang mga ito, mga lalaking bumigo sa hari. Pero ipinakiusap ni Daniel ang kanilang buhay. Ang bayan ng Diyos ay dapat maging pagpapala kahit sa mga hindi kapareho nila ng pananampalataya.

Dali-daling ipinasok ni Arioc si Daniel at inangkin ang kaunting papuri para sa sarili: "Nakatagpo ako ng isang lalaki" (t. 25). Pero kabaligtaran ang ginawa ni Daniel. Nang tanungin siya ng hari kung kaya niyang ihayag ang panaginip, malinaw na sinabi ni Daniel na walang ekspertong tao ang makagagawa nito. "Ngunit may Diyos sa langit na naghahayag ng mga hiwaga" (t. 28). Pagkatapos ay idinagdag niya, "Ang hiwagang ito ay inihayag sa akin, hindi dahil mayroon akong higit na karunungan kaysa sa sinumang taong nabubuhay" (t. 30).

Napakagandang pagkakataon sana iyon para magmalaki! Kayang itayo ni Daniel ang kanyang pangalan sa isang iglap. Sa halip, itinuro niya ang lahat ng mata sa Diyos.

Pagkatapos ay inilarawan niya ang panaginip: isang napakalaki at nakasisilaw na rebulto na yari sa ginto, pilak, tanso, bakal, at putik. Kahanga-hanga man ito, nakatayo ito sa mahihinang paa. Isang batong "tinapyas, ngunit hindi ng kamay ng tao" ang tumama sa mga paang iyon, at gumuho ang buong rebulto at naging alikabok na tinangay ng hangin. Lumaki ang bato at naging bundok na pumuno sa buong lupa.

Bukas, makikita natin ang kahulugan nito. Sa ngayon, panghawakan ito: ang pinakamahalagang bagay tungkol sa bato ay hindi ito tinapyas ng kamay ng tao. Ginagawa ng Diyos ang Kanyang pinakadakilang gawain sa mga paraang walang sinuman ang makaaangkin ng papuri. Ang trabaho natin, tulad ni Daniel, ay siguraduhing sa Kanya mapupunta ang kaluwalhatian.$q$, $q$Itinuturo sa akin ng talatang ito na bawat mabuting bagay na maiaalok ko ay nagmumula sa Diyos. Nakatayo si Daniel sa harap ng pinakamakapangyarihang tao sa mundo dala ang sagot na gustong malaman ng lahat, at ang unang lumabas sa bibig niya ay tungkol sa Diyos, hindi sa sarili niya. Inaamin ko na madalas ay medyo labis kong ikinasisiya ang papuri ng tao. Gusto kong makilala bilang ang nakaaalam, ang nakaayos, o ang nagligtas sa sitwasyon.

Dahil sa halimbawa ni Daniel, sisikapin kong ibigay ang papuri sa tunay na may-ari nito. Kapag pinupuri ako, ituturo ko ito pabalik sa Diyos, at sa mga taong ginamit Niya para hubugin ako: mga magulang, guro, mentor, at kaibigan.

Hinahamon din ako ng malasakit ni Daniel sa mga pantas na nabigo. Hindi niya sila mga kaibigan o kapwa mananampalataya, pero ipinakiusap niya ang kanilang buhay. Dapat kong hilingin sa Panginoon na bigyan ako ng parehong kabaitan sa mga taong iba sa akin o bumigo sa akin.

Dahil alam kong ginagawa ng Diyos ang Kanyang pinakadakilang gawain "hindi ng kamay ng tao," titigil na ako sa pagsisikap na maging bida sa sarili kong kuwento. Ngayong linggo, maghahanap ako ng pagkakataong hayagang parangalan ang Diyos kapag may nagpapasalamat sa akin.$q$, $q$Diyos sa langit, Kayo po ang Tagapaghayag ng mga Hiwaga, at bawat kaunting karunungang mayroon ako ay galing sa Inyo. Patawarin po Ninyo ako sa mga pagkakataong tahimik kong inangkin ang kaluwalhatiang para sa Inyo. Turuan po Ninyo akong ituro ang mga tao sa Inyo tuwing pinupuri nila ako. Bigyan po Ninyo ako ng pusong may malasakit kahit sa mga hindi pa nakakakilala sa Inyo, at gawin po Ninyo akong pagpapala sa kanila. Nawa'y maging tulad ng kay Daniel ang aking buhay, na nagpapakita sa mundo na may Diyos sa langit na nagsasalita pa rin at nagliligtas pa rin. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-08', $q$Mga Kastilyong Buhangin at ang Bato$q$, $q$Buong hapon na binuo ni Nathaniel ang pinakamalaking kastilyong buhangin na nagawa niya kailanman. May apat itong tore, isang pader, isang kanal sa paligid, at isang tulay na gawa sa patag na piraso ng kahoy na inanod ng dagat. Pinalamutian niya ito ng mga kabibe at ng isang maliit na bandilang gawa sa balot ng kendi.

"Lolo Fidel! Tingnan n'yo po!" sigaw niya.

Kahahatak lang ng kanyang lolo sa maliit na bangkang pangisda papunta sa buhanginan. Pinunasan niya ang kanyang mga kamay at dahan-dahang lumapit. "Ang ganda," sabi niya. "Palasyong bagay sa isang hari 'yan."

Abot-tainga ang ngiti ni Nathaniel. "Nandito na po 'yan habambuhay."

Ngumiti si Lolo Fidel pero walang sinabi.

Makalipas ang isang oras, tumaas ang tubig. Pinuno ng unang alon ang kanal. Tinangay ng ikalawa ang tulay. Pagsapit ng paglubog ng araw, nakatayo na si Nathaniel sa tubig na hanggang bukung-bukong, nakatitig sa isang makinis at patag na dalampasigan. Halos maiyak na siya.

Ipinatong ng kanyang lolo ang kamay sa balikat niya at itinuro ang dulo ng baybayin, sa lumang pader na bato sa gilid ng nayon. "Alam mo ba kung sino ang gumawa niyan?"

Umiling si Nathaniel.

"Wala nang nakaaalala. Nandiyan na 'yan noong bata pa ang sarili kong lolo. Tinamaan na 'yan ng mga bagyo. Tinamaan na ng malalaking alon. Taon-taon, nagtatayo ang mga tao ng mga bahay, tindahan, at pati resort malapit diyan. Marami sa mga iyon ay wala na ngayon." Pinisil niya ang balikat ni Nathaniel. "Pero nandiyan pa rin ang pader."

Sabay silang naglakad papunta roon. Hinaplos ni Nathaniel ang magagaspang at kinain na ng dagat na mga bato.

"Lolo, bakit po hindi ito nasisira?"

"Dahil hindi ito nakapatong sa buhangin," sabi ng kanyang lolo. "Nakapatong ito sa batong nasa ilalim."

Kinabukasan, gumawa ulit si Nathaniel ng kastilyong buhangin. Pero sa pagkakataong ito, ginawa niya ito mismo sa tabi ng lumang pader na bato, at tumawa siya nang dumating ang mga alon.$q$, $q$Ipinaliwanag na ngayon ni Daniel ang panaginip. Ang gintong ulo ay si Nebuchadnezzar mismo, ang hari "na binigyan ng Diyos ng langit ng kapangyarihang maghari" (t. 37). Kahit ang pinakadakilang hari sa lupa ay naghahari lang dahil pinahihintulutan ito ng Diyos.

Pagkatapos ng Babilonia, darating ang ibang mga kaharian: pilak, tanso, at bakal. Nauunawaan ng maraming guro ng Bibliya na ang mga ito ay ang Medo-Persia, Gresya, at Roma. Bawat isa ay magiging makapangyarihan sa kanyang panahon. Dudurugin ng kahariang bakal ang lahat, pero ang mga paa nito ay mahinang halo ng bakal at putik, matibay at marupok nang sabay.

Pagkatapos ay ang puso ng panaginip: "Sa mga araw ng mga haring iyon, magtatatag ang Diyos ng langit ng isang kahariang hindi kailanman mawawasak... at ito'y mananatili magpakailanman" (t. 44). Ito ang batong tinapyas nang hindi ng kamay ng tao. Ito ang sariling kaharian ng Diyos, at hindi ito itinayo ng mga hukbo o ng pulitika. Nagsisimula itong maliit, tulad ng isang bato, pero lumalaki ito hanggang mapuno ang buong lupa.

Bilang mga Cristiano, nakikita natin itong natupad kay Jesus. Dumating Siya sa panahon ng Roma, ang kahariang bakal. Ipinahayag Niya, "Malapit na ang kaharian ng Diyos." Nagsimula ang Kanyang kaharian sa iilang alagad, at ngayon ay lumaganap na ito sa bawat bansa. Balang araw, sa Kanyang pagbabalik, lubusan nitong pupunuin ang lupa.

Nagpatirapa ang hari at ipinahayag na ang Diyos ni Daniel ay "Diyos ng mga diyos at Panginoon ng mga hari." Itinaas sa posisyon si Daniel, at hindi niya kinalimutan ang kanyang mga kaibigan.

Bawat kaharian, pamahalaan, kompanya, at kayamanan ng tao ay isang kastilyong buhangin. Ang kaharian lang ng Diyos ang mananatili magpakailanman. Doon mo itayo ang iyong buhay.$q$, $q$Itinuturo sa akin ng talatang ito na bawat makalupang kapangyarihan, gaano man kasilaw, ay pansamantala lamang. Ang ginto, pilak, tanso, at bakal ay nauuwi lahat sa alikabok na tinatangay ng hangin. Inaamin ko na madalas akong humahanga sa pinahahalagahan ng mundo. Hinahangaan ko ang yaman, katayuan, at impluwensya, at labis akong nag-aalala tungkol sa mga lider at sistema sa paligid ko, na para bang sila ang may huling salita.

Dahil alam kong nagtatag ang Diyos ng langit ng isang kahariang hindi kailanman mawawasak, doon ko dapat ilagay ang aking pag-asa. Si Jesus ang batong hindi tinapyas ng kamay ng tao. Lumalago ang Kanyang kaharian, at walang makapipigil dito.

Sisikapin kong suriin kung saan ko itinatayo ang aking buhay. Ibinubuhos ko ba ang aking oras, pera, at lakas sa mga kastilyong buhangin na tatangayin ng susunod na alon? O namumuhunan ba ako sa mga bagay na mananatili magpakailanman: ang pagkilala sa Diyos, ang pagmamahal sa kapwa, at ang pagbabahagi ng ebanghelyo?

Pinalalakas din ng katapatan ni Daniel ang loob ko. Nang itaas siya sa posisyon, inalala niya ang kanyang mga kaibigan. Dahil dito, maghahanap ako ng mga paraan para iangat ang iba kapag binibigyan ako ng Diyos ng pabor, sa halip na sarilinin ang lahat.

Ngayong araw, pipili ako ng isang bagay na may walang-hanggang halaga at ibibigay ko rito ang buong atensyon ko.$q$, $q$Hari ng mga hari, salamat po na ang Inyong kaharian ay hindi kailanman mawawasak. Bawat ibang kapangyarihan ay bumabangon at bumabagsak, pero Kayo ay naghahari magpakailanman. Patawarin po Ninyo ako sa pagiging madaling humanga sa mga bagay na hindi magtatagal. Tulungan po Ninyo akong itayo ang buhay ko sa matibay na batong si Jesus at sa Kanyang kaharian. Bigyan po Ninyo ako ng mga matang nakakakita sa walang hanggan at ng tapang na ipuhunan dito ang buhay ko. At kapag pinagpapala N'yo ako, tulungan po Ninyo akong alalahanin at iangat ang iba sa daan. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-09', $q$Kapag Lahat ay Yumuyukod$q$, $q$Dalawang taon nang kusinero si Joshua sa isang cargo ship nang magsimula ang bagong kaayusan.

Sa isang daungan sa ibang bansa, nagsimulang bumili ang ilan sa crew ng mga karton ng murang sigarilyo at itinatago ang mga ito sa mga bodega ng barko. Sa susunod na daungan, ibinebenta nila ang mga ito sa isang kontak sa pier nang hindi nagbabayad ng buwis. Malaki ang tubo. "Ginagawa 'yan ng lahat sa rutang ito," paliwanag ng chief steward na si Herminio. "Small thing lang. Hindi malalaman ng kompanya."

Ang bodega ni Joshua ang pinakamagandang taguan sa buong barko. Hiniling ni Herminio na ilipat niya ang ilang sako ng bigas para magkaroon ng puwang.

Naisip ni Joshua ang kanyang asawa at dalawang anak sa bahay. Naisip niya ang dagdag na pera. Naisip din niya kung anong klaseng lalaki ang gusto niyang makita ng mga anak niya pag-uwi niya.

"Sorry, Chief," tahimik niyang sabi. "Hindi ko kaya. Magluluto ako para sa lahat, maglilinis ako, kukuha ako ng dagdag na shift. Pero hindi ako makatutulong dito."

Noong una, walang nagsalita. Pagkatapos, nagsimula ang mga biro. Bigla na lang naging "masyadong maalat" ang luto niya. May nagtago ng tsinelas niya. Sa oras ng kainan, hindi na tumatabi sa mesa niya ang mga lalaki.

Makalipas ang dalawang linggo, ipinatawag ng kapitan si Joshua sa kanyang opisina. "Sinasabi ng ilang crew na hindi ka raw team player," sabi niya habang nakatingin sa isang papel. "Mahirap ka raw pakisamahan."

Kumakabog ang dibdib ni Joshua. Alam niya kung sino ang nagreklamo at kung bakit. Huminga siya nang malalim.

"Kapitan, ginawa ko po ang bawat gawaing ibinigay sa akin. Puwede n'yo pong tingnan ang logbook. Iisang bagay lang po ang tinanggihan ko." Huminto siya sandali. "Kung gusto n'yo pong malaman kung ano iyon, tingnan n'yo po ang bodega malapit sa galley."

Matagal siyang tinitigan ng kapitan. Pagkatapos, dinampot nito ang telepono. Hindi alam ni Joshua kung ano ang matutuklasan ng kapitan, o kung gagawing miserable ng crew ang natitirang biyahe. Naghugas siya ng kamay, isinuot ang kanyang apron, at inisip ang kanyang asawa at mga anak na naghihintay sa bahay. Anuman ang mangyari, hindi siya yumukod.$q$, $q$Nakita ni Nebuchadnezzar sa panaginip ang isang rebultong may gintong ulo. Ngayon, nagtayo siya ng rebultong ginto mula ulo hanggang paa, mga siyamnapung talampakan ang taas. Para bang sinasabi niya, "Hindi lilipas ang aking kaharian." Ipinatawag niya ang bawat opisyal sa imperyo sa kapatagan ng Dura para yumukod sa harap nito.

Pansinin ang mahahabang listahan sa kabanatang ito: mga opisyal, instrumentong pangmusika, mga bansa, at mga wika. Inuulit-ulit ang mga ito. Ipinipinta ng manunulat ang larawan ng napakabigat na panggigipit. Naroon ang lahat ng mahahalagang tao. Tumutugtog ang musika. Sabay-sabay na nagpapatirapa ang buong madla. At para sa sinumang tumanggi, may naglalagablab na pugon.

Higit pa ito sa pulitika. Ang pagyukod sa rebulto ay nangangahulugan ng pagpaparangal sa mga diyos ng hari at pagbibigay sa kanya ng pinakamataas na katapatan. Para sa bayan ng Diyos, idolatriya ito, tuwirang paglabag sa unang dalawang utos.

Pagkatapos, may ilang astrologong "may masamang hangaring nagsumbong laban sa mga Judio" (t. 8). Malamang ay mga lalaki ito na naiinggit at nagagalit sa tagumpay nina Shadrach, Meshach, at Abednego. Ginamit nila ang utos ng hari bilang sandata. Ang katapatan sa Diyos ay minsang nagpapagalit sa mga tao, hindi dahil may ginawa tayong mali, kundi dahil ang pagtanggi nating yumukod ay naglalantad sa ginagawa ng lahat.

Bihira nang may kinalaman sa mga gintong rebulto ang idolatriya ngayon. Pero pareho pa rin ang panggigipit. Kapag "tumugtog ang musika" sa trabaho, sa paaralan, o online, inaasahang yuyukod ang lahat sa pera, kasikatan, kaginhawahan, o sa "ginagawa naman ng lahat." Hindi kailanman madali ang tumayo habang yumuyukod ang lahat. Pero ganito ipinapakita ng bayan ng Diyos sa mundo kung sino ang tunay nilang Hari.$q$, $q$Itinuturo sa akin ng talatang ito na darating ang mga sandaling yuyukod ang lahat ng nasa paligid ko, at kailangan kong magpasya kung tatayo ako. Napaliligiran sina Shadrach, Meshach, at Abednego ng mga opisyal, musika, at banta ng pugon. Pero hindi nila ibinigay ang kanilang pagsamba kaninuman maliban sa Diyos.

Inaamin ko na minsan ay yumuyukod ako para lang hindi mapansin. Sumasabay ako sa tsismis, sa maliliit na pandaraya, o sa mga gawing alam kong hindi nakalulugod sa Diyos, dahil lang ginagawa ito ng lahat. Dapat kong hilingin sa Panginoon na ipakita sa akin ang mga "gintong rebulto" sa buhay ko: anumang bagay na pinararangalan ko nang higit sa Kanya o niyuyukuran ko dahil sa takot.

Pinaaalala rin sa akin na ang katapatan ay maaaring magdala ng paratang. Maaaring hindi ako maunawaan ng mga tao o magsalita pa sila laban sa akin. Dahil alam kong hinarap ng tatlong binata ang mga nagsumbong nang may masamang hangarin, hindi na ako magugulat kapag may kapalit ang paggawa ng tama.

Dahil sa kanilang halimbawa, sisikapin kong manindigan nang may kababaang-loob at paggalang. Hindi ko kailangang maging mayabang o maingay. Kailangan ko lang manatiling nakatayo kapag tumugtog ang musika.

Ngayong linggo, papangalanan ko ang isang bahagi ng buhay ko kung saan ako yumuyukod sa panggigipit, at hihingi ako sa Diyos ng tapang na tumayo.$q$, $q$Panginoon, Kayo lamang po ang karapat-dapat sa aking pagsamba. Patawarin po Ninyo ako sa mga pagkakataong yumukod ako sa panggigipit, sa takot, o sa karamihan sa halip na parangalan Kayo. Ipakita po Ninyo ang mga diyos-diyosan sa puso ko na hindi ko napapansin. Bigyan po Ninyo ako ng tapang na tumayo kapag yumuyukod ang lahat, at ng kababaang-loob na gawin ito nang walang kayabangan. Kapag hindi ako nauunawaan o pinararatangan dahil sa paggawa ng tama, tulungan po Ninyo akong magtiwala na ipagtatanggol N'yo ako. Nawa'y ipakita ng buhay ko sa mundo kung sino ang tunay kong Hari. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-10', $q$Kahit Hindi$q$, $q$Labing-isang taon nang nagmamaneho ng trak si Melchor para sa iisang trading company. Naghahakot siya ng mga sako ng feeds at pataba mula sa pier papunta sa mga bodega sa probinsya. Maingat siya, hindi kailanman nahuhuli, at hindi pa kailanman naaksidente.

Isang umaga, ipinatawag siya ng operations manager na si Mr. Salcedo sa opisina. "May malaking shipment tayo ngayon. Magkarga ka ng sampung toneladang higit sa karaniwan."

Napakunot ang noo ni Melchor. "Sir, sobra-sobra na po 'yan sa limit. Hindi kakayanin ng preno ang daan sa bundok."

Iniusog ni Mr. Salcedo ang isang papel sa mesa. Isa itong weighbridge ticket, napunan na ng mas mababang timbang. "Huwag kang mag-alala. May kontak ako sa timbangan. Magmaneho ka lang."

Matagal na tinitigan ni Melchor ang pekeng ticket. Naisip niya ang tatlo niyang anak na nag-aaral at ang motorsiklong hinuhulugan pa niya. Naisip din niya ang mga jeepney at tricycle na nadaraanan niya araw-araw sa daang iyon sa bundok, punô ng mga pamilya.

"Sir," sabi niya, "hindi ko po kaya."

Tumigas ang mukha ni Mr. Salcedo. "Alam mo namang may sampung drayber na naghihintay sa trabaho mo."

"Alam ko po, sir." Nanginginig ang boses ni Melchor, pero nagpatuloy siya. "Baka tanggalin n'yo ako. Baka bigyan ako ng Diyos ng ibang trabaho, baka hindi. Pero hindi ako magmamaneho ng overloaded na trak pababa ng bundok na iyon. Kahit mawalan ako ng trabahong ito, hindi ko gagawin."

Tinanggal siya makalipas ang dalawang linggo.

Nang gabing iyon, umupo siya kasama ang asawa niyang si Veronica sa kanilang maliit na mesa sa kusina. Inaasahan niyang magagalit ito. Sa halip, hinawakan nito ang kanyang kamay.

"Pinakasalan ko ang lalaking hindi isusugal ang buhay ng ibang tao para sa pera," sabi niya. "Siya pa rin ang asawa ko."

Apat na buwang nag-sideline si Melchor sa kung anu-anong trabaho. Hindi ito naging madali. Pero mahimbing ang tulog niya gabi-gabi, at hindi niya kailanman pinagsisihan ang umagang iyon.$q$, $q$Si Nebuchadnezzar, "punô ng matinding galit," ay nagbigay pa ng isang pagkakataon sa tatlong binata. Tutugtog ulit ang musika. Kung yuyukod sila, patatawarin ang lahat. Kung hindi, ang pugon. Pagkatapos ay nagdagdag siya ng hamon: "Sinong diyos ang makapagliligtas sa inyo mula sa aking mga kamay?" (t. 15).

Ang sagot nila ay isa sa pinakamatapang na pahayag sa Bibliya. "Hindi na namin kailangang sagutin kayo sa bagay na ito" (t. 16). Hindi sila bastos. Hindi lang nila kailangan ng panahon para pag-isipan pa. Matagal nang naayos ang tanong na iyon.

Sa talata 17, ganito ang mababasa sa BSB: "Kung ang Diyos na aming pinaglilingkuran ay umiiral." Hindi ito pag-aalinlangan. Paraan ito ng pagsagot sa pangungutyang tanong ng hari. Para bang sinasabi nila, "Tinatanong mo kung sinong diyos ang makapagliligtas sa amin? Kung umabot man sa pugon, totoo ang aming Diyos, at kaya Niya."

Pagkatapos ay ang mga salitang nagpalakas sa mga mananampalataya sa loob ng maraming siglo: "Ngunit kahit hindi Niya gawin... hindi kami maglilingkod sa inyong mga diyos" (t. 18).

Ito ang hinog na pananampalataya. Tiyak sila sa kapangyarihan ng Diyos, pero hindi nila inakalang alam nila ang plano ng Diyos. Nagtiwala sila na kaya Niya silang iligtas, at susundin nila Siya kahit piliin Niyang hindi gawin iyon.

Akala ng ilan, ang pananampalataya ay laging pag-asa sa resultang gusto natin. Pero ang tunay na pananampalataya ay nakasandig sa kung sino ang Diyos, hindi sa kung ano ang gagawin Niya para sa atin. Ang ating pagsunod ay hindi kasunduan sa Diyos. Sumusunod tayo dahil karapat-dapat Siya, dumating man ang apoy o hindi.

Kaya mo bang sabihin sa Diyos ngayon ang "kahit hindi"?$q$, $q$Itinuturo sa akin ng talatang ito ang pagkakaiba ng pananampalataya sa Diyos at pananampalataya sa resultang gusto ko. Naniwala sina Shadrach, Meshach, at Abednego na kaya silang iligtas ng Diyos, pero handa silang sumunod sa Kanya kahit hindi Niya iyon gawin. Inaamin ko na madalas ay may kondisyon ang pananampalataya ko. Nagtitiwala ako sa Diyos hangga't nasusunod ang gusto ko, at nahihirapan ako kapag hindi.

Dapat kong hilingin sa Panginoon na bigyan ako ng pananampalatayang "kahit hindi." Kahit hindi agad dumating ang paggaling, magtitiwala ako sa Kanya. Kahit mawala sa akin ang trabaho, ang pagkakataon, o ang pagsang-ayon ng mga tao, mananatili akong tapat. Kahit hindi masagot ang mga panalangin ko sa paraang inaasahan ko, hindi ako tatalikod.

Hinahamon din ako ng katatagan nila. Hindi na nila kinailangang makipagtalo sa hari. Dahil alam kong ang pag-aatubili ay madalas humahantong sa pakikipagkompromiso, sisikapin kong ayusin nang maaga ang aking mga paninindigan, para kapag dumating ang panggigipit, malinaw na ang sagot ko.

Dahil karapat-dapat ang Diyos sa aking pagsunod anuman ang mangyari, pipiliin kong parangalan Siya ngayon sa isang desisyong maaaring may kapalit ang pagsunod sa Kanya.$q$, $q$Makapangyarihang Diyos, naniniwala po ako na kaya N'yong gawin nang higit pa sa hinihingi o iniisip ko. Pero kahit hindi N'yo gawin ang gusto ko, pinipili ko pong magtiwala at sumunod sa Inyo. Patawarin po Ninyo ako sa mga pagkakataong naging tawaran ang pananampalataya ko sa halip na pagsuko. Bigyan po Ninyo ako ng matatag na pusong hindi natitinag kapag dumarating ang panggigipit. Tulungan po Ninyo akong parangalan Kayo, iligtas man ako mula sa apoy o kailangan kong lumakad sa gitna nito. Karapat-dapat po Kayo sa aking pagsamba sa bawat panahon. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-11', $q$May Iba Pang Kasama sa Apoy$q$, $q$Nang mamatay ang asawa niyang si Eduardo, tumigil na si Lourdes sa pagsagot sa kanyang telepono.

Tatlumpung taon siyang nanahi ng mga uniporme sa paaralan at mga gown sa harapang silid ng kanilang maliit na bahay, habang nag-aayos naman ng relo si Eduardo sa mesang katabi niya. Ngayon, bakante na ang mesa nito, maayos pa ring nakasalansan ang mga gamit niya sa isang lumang lata. Ilang oras na nakaupo si Lourdes sa kanyang makinang panahi nang hindi man lang ito binubuksan.

Malayo ang tirahan ng kanyang mga anak at hanggang tawag lang ang kaya nila. Nagpapadala ng mensahe ang mga kaibigan: "Sabihan mo lang ako kung may kailangan ka." Hindi kailanman nagsabi si Lourdes kaninuman.

Maliban na lang kay Carmela, na hindi nagtanong. Dumating na lang si Carmela.

Tatlong bahay lang ang layo ni Carmela. Biyuda rin siya, isang retiradong labandera na masakit ang tuhod at malakas tumawa. Sa unang umaga, kumatok siya, pumasok nang hindi na naghihintay, at naglapag ng dalawang tasa ng mainit na salabat. Hindi siya gaanong nagsalita. Umupo lang siya.

Kinabukasan, dumating ulit siya. At sa sumunod na araw. May mga araw na nagwawalis siya ng sahig. May mga araw na nagdadala siya ng kanin at pritong isda. May mga gabing hindi mapigilan ni Lourdes ang pag-iyak, at hinahawakan lang ni Carmela ang kanyang kamay hanggang makatulog siya sa sofa, saka ito tahimik na lalabas.

Lumipas ang mga buwan. Isang hapon, binuksan ulit ni Lourdes ang kanyang makinang panahi. Narinig ni Carmela ang pamilyar na ugong mula sa kalye at paika-ikang lumapit nang nakangiti.

Gumagawa si Lourdes ng isang damit. Asul ito, ang paboritong kulay ni Carmela.

"Bakit mo ginagawa 'yan?" tanong ni Carmela habang hinahaplos ang tela.

Huminto si Lourdes at tiningnan ang kaibigan. "Dahil dapat sana'y tinupok na ako ng pinakamasamang taon ng buhay ko," mahina niyang sabi. "Pero hindi ako nag-iisa roon. Nandoon ka sa buong panahong iyon."

Malakas na tumawa si Carmela at pinunasan ang kanyang mga mata. "Siyempre naman. Saan pa ba ako pupunta?"$q$, $q$Umapaw ang galit ng hari. Iniutos niyang painitin ang pugon nang pitong beses na higit sa karaniwan, sobrang init na namatay sa apoy ang mga sundalong naghagis sa tatlong binata. Bumagsak sa apoy sina Shadrach, Meshach, at Abednego, nakagapos at may buong kasuotan.

Pagkatapos ay napatayo ang hari sa pagkagulat. "Hindi ba't tatlong lalaki ang inihagis natin sa apoy, mahigpit na nakagapos?... Tingnan ninyo! Apat na lalaki ang nakikita ko, walang gapos at walang pinsala, naglalakad sa gitna ng apoy, at ang ikaapat ay mukhang anak ng mga diyos!" (t. 24–25).

Pansinin ang tatlong bagay. Una, hindi sila inilayo ng Diyos sa apoy. Sinalubong Niya sila sa loob nito. Ikalawa, ang tanging tinupok ng apoy ay ang mga lubid na nakagapos sa kanila. Ikatlo, hindi sila nag-iisa. May ikaapat na anyong naglalakad kasama nila. Tinawag siya kalaunan ni Nebuchadnezzar na isang anghel. Maraming Cristiano ang nakakita sa kanya ng larawan ng Anak ng Diyos, na nangangakong makakasama ng Kanyang bayan sa bawat pagsubok.

Nang lumabas sila, "kahit isang buhok sa kanilang ulo ay hindi nasunog... at wala silang amoy ng apoy" (t. 27). Buo ang pagliligtas ng Diyos.

Ang haring nagtanong noon, "Sinong diyos ang makapagliligtas sa inyo?" ay sumagot na ngayon sa sarili niyang tanong: "Walang ibang diyos na makapagliligtas nang ganito" (t. 29). Ang kanilang katapatan ay naging patotoo sa buong imperyo.

Hindi ipinangako ng Diyos na ilalayo Niya tayo sa bawat apoy. Pero ipinangako Niya, "Kapag lumakad ka sa apoy, hindi ka masusunog" (Isaias 43:2). Sa pinakamabigat mong pagsubok, hindi ka kailanman nag-iisa. May iba pang kasama mo sa apoy.$q$, $q$Itinuturo sa akin ng talatang ito na mas dakila ang presensya ng Diyos kaysa sa anumang apoy na haharapin ko. Hindi Niya pinigilan na maihagis ang tatlong binata sa pugon, pero lumakad Siya kasama nila sa loob nito. Inaamin ko na madalas ay pagtakas lang sa mga pagsubok ang ipinapanalangin ko. Gusto kong ilayo ng Diyos ang apoy. Pero ipinapakita sa akin ng Daniel 3 na minsan, ang mas dakila Niyang regalo ay ang Kanyang presensya sa gitna ng apoy.

Naaaliw ako na ang tanging tinupok ng apoy ay ang mga lubid. Dahil alam kong kayang gamitin ng Diyos ang pinakamahihirap kong panahon para palayain ako sa mga bagay na gumagapos sa akin, tulad ng takot, kayabangan, o pagkakapit sa mga bagay ng mundo, dapat ko nang itigil ang pagturing sa bawat pagsubok bilang kawalan.

Sisikapin kong alalahanin, kapag nasa gitna ako ng masakit na panahon, na hindi ako nag-iisa. Kasama ko si Jesus, at itatawid Niya ako.

Hinahamon din akong maging tulad ng ikaapat na lalaki sa apoy ng ibang tao. May mga tao sa paligid ko na dumaraan sa pagdadalamhati, sakit, o kawalan. Dahil kasama ko ang Diyos, pipiliin kong samahan ang isang taong nasasaktan ngayong linggo, hindi para magbigay ng payo, kundi para lang naroon ako.$q$, $q$Panginoong Jesus, salamat po sa paglakad Ninyo kasama ko sa gitna ng apoy. Kapag humaharap ako sa mga pagsubok na hindi ko matakasan, ipaalala po Ninyo na nasa tabi ko lang Kayo. Gamitin po Ninyo ang init ng mahihirap na panahon para tupukin ang anumang gumagapos sa akin at pumipigil sa malaya kong pagsunod sa Inyo. Itawid po Ninyo ako, Panginoon, para maging patotoo ang buhay ko na walang ibang Diyos na makapagliligtas na tulad Ninyo. Gawin po Ninyo akong tapat na kasama ng iba na dumaraan sa sarili nilang apoy. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-12', $q$Ang Patotoo ng Taong Mapagmataas$q$, $q$Kilala ng lahat sa bayan si Gregorio. Siya ang may-ari ng pinakamalaking palaisdaan sa lugar, ng tatlong delivery truck, at ng nag-iisang dalawang-palapag na bahay na konkreto sa kanilang kalye. Ipinagmamalaki niya ang lahat ng ito, at sinisiguro niyang alam ito ng mga tao.

Huli kung magpasahod siya sa kanyang mga trabahador at tinatawanan pa niya sila kapag nagrereklamo. "Kung ayaw n'yo, maraming iba ang may gusto sa trabaho n'yo." Hindi siya pumupunta sa lamay, kaarawan, o kasal ng kahit sino maliban kung may mapapala siya. "Ginawa ko ang lahat ng ito sa sarili kong kamay," mahilig niyang sabihin. "Wala akong utang na loob kaninuman."

Pagkatapos, isang gabi, habang nagbibilang ng pera sa kanyang mesa, biglang hindi na gumana ang kaliwang kamay ni Gregorio. Namanhid ang kanyang mukha. Sinubukan niyang sumigaw pero hindi niya mabuo ang mga salita.

Si Tomas, ang pinakamatagal niyang katiwala, ang nakakita sa kanya at nagmadaling dalhin siya sa ospital sa likod ng isang trak ng isda.

Mild stroke daw sabi ng mga doktor. Nabawi niya ang karamihan ng kanyang lakas sa mga sumunod na buwan. Pero may kumalas sa loob niya. Habang nakahiga sa kama sa ospital, hindi siya makapagbilang ng pera o makapag-utos. Ang tanging kaya niya ay humiga roon at matakot.

Dinadalaw siya ni Tomas linggo-linggo. Ipinapanalangin siya ng pamilya ni Tomas. Minsang dumating ang pastor ni Tomas at umupo lang sa tabi niya at nagkuwento tungkol kay Jesus, ang Isang dumating hindi para sa mga mapagmataas kundi para sa mga nakaaalam na kailangan nila Siya.

Makalipas ang isang taon, tinipon ni Gregorio ang lahat ng kanyang trabahador sa palaisdaan. Naghanda siya ng malaking tanghalian. Nang makakain na ang lahat, tumayo siya, medyo pasuray-suray.

"Kailangan kong ikuwento sa inyo ang nangyari sa akin," sabi niya. Pumiyok ang kanyang boses. "Akala ko ako ang gumawa ng lahat. Mali ako. Pinakumbaba ako ng Diyos, at pagkatapos ay iniligtas ako ng Diyos."

Pagkatapos, itinaas niya ang sahod ng lahat.$q$, $q$Kakaiba ang kabanata 4. Isinulat ito bilang liham mula mismo kay Nebuchadnezzar, ipinadala "sa mga tao ng bawat bansa at wika" (t. 1). Ang mapagmataas na haring dating humihingi ng pagsamba sa kanyang gintong rebulto ay nagsasabi na ngayon sa buong mundo tungkol sa kadakilaan ng Diyos ni Daniel.

Nagsisimula siya sa papuri: "Kay dakila ng Kanyang mga tanda, kay kapangyarihan ng Kanyang mga kababalaghan! Ang Kanyang kaharian ay walang hanggang kaharian" (t. 3). Ito ang parehong haring dating nag-akalang mananatili magpakailanman ang sarili niyang kaharian. Malinaw na may nagbago.

Pagkatapos ay ikinuwento niya ang nangyari. "Ako, si Nebuchadnezzar, ay panatag sa aking bahay at umuunlad sa aking palasyo" (t. 4). Maginhawa ang buhay. Natalo na ang kanyang mga kaaway, at punô ang kanyang kabang-yaman. Mapanganib ang ganoong uri ng ginhawa. Kapag maayos ang lahat, madaling makalimot sa Diyos.

Pagkatapos ay dumating ang isa pang nakababagabag na panaginip. Muli, nabigo ang kanyang mga pantas. Muli, "sa wakas" ay dumating si Daniel. Kawili-wili na si Daniel ang huling ipinatawag, kahit nakatulong na siya noon. Sa mga dati pa rin niyang eksperto unang lumapit ang hari.

Pansinin na tinatawag pa rin ng hari si Daniel sa kanyang pangalang Babilonyo, Belteshazzar, "ayon sa pangalan ng aking diyos." Sinasabi rin niyang nasa kanya "ang espiritu ng mga banal na diyos." May natutunan na si Nebuchadnezzar, pero kulang pa rin ang pagkaunawa niya sa Diyos. Hindi pa tapos ang Diyos sa kanya.

Sa susunod na linggo, makikita natin ang panaginip at kung paano pinakumbaba ng Diyos ang mapagmataas na haring ito. Pero alam na natin kung paano ito nagtatapos: sa isang patotoo. Ang layunin ng Diyos sa pagpapakumbaba sa atin ay hindi kailanman para wasakin tayo. Ito ay para dalhin tayo sa Kanya.$q$, $q$Itinuturo sa akin ng talatang ito na kayang baguhin ng Diyos kahit ang pinakamapagmataas na puso. Mula sa paghingi ng pagsamba, nagpahayag si Nebuchadnezzar ng kadakilaan ng Diyos sa buong mundo. Nagbibigay ito sa akin ng pag-asa para sa mga taong sinukuan ko na, at nagbibigay din ito ng pag-asa para sa sarili ko.

Binabalaan din ako ng mga salitang "panatag" at "umuunlad." Inaamin ko na pinakanalalayo ako sa Diyos kapag maginhawa ang buhay. Kapag bayad ang mga bayarin at malusog ang lahat, umiikli ang mga panalangin ko at humihina ang pag-asa ko sa Diyos. Dapat kong hilingin sa Panginoon na panatilihin akong mapagpakumbaba at malapit sa Kanya, lalo na sa magagandang panahon.

Napansin ko rin na sa mga dati niyang eksperto unang tumawag ang hari, bago kay Daniel. Dahil alam kong madalas akong tumatakbo muna sa mga dati kong pinagkukunan ng ginhawa bago bumaling sa Diyos, sisikapin kong gawin Siyang una kong tatawagan, hindi huling paraan.

Dahil ginagawang patotoo ng Diyos ang mga taong pinakumbaba Niya, hindi ko itatago ang mga aral na itinuro Niya sa akin sa mahihirap na panahon. Ngayong linggo, ibabahagi ko sa isang tao ang isang paraan kung paano ako pinakumbaba ng Diyos at inilapit sa Kanya.$q$, $q$Kataas-taasang Diyos, walang hanggan po ang Inyong kaharian at nananatili magpakailanman ang Inyong kapangyarihan. Salamat po na kaya N'yong baguhin kahit ang pinakamapagmataas na puso, kasama na ang akin. Panatilihin po Ninyo akong mapagpakumbaba kapag madali ang buhay, at huwag N'yong hayaang ilayo ako ng ginhawa sa Inyo. Tulungan po Ninyo akong lumapit muna sa Inyo, hindi sa huli. Bigyan po Ninyo ako ng tapang na ikuwento sa iba ang ginawa N'yo sa buhay ko. At kumilos po Kayo sa puso ng mga mapagmataas na taong mahal ko, para makilala nila Kayo. Sa pangalan ni Jesus, amen.$q$, $q$Ngayong linggo, pinanood natin ang Diyos ng langit na ipinapakita ang Kanyang kapangyarihan sa Babilonia. Noong Lunes, humarap si Daniel sa hari dala ang sagot, pero ibinigay niya ang lahat ng papuri sa "Diyos sa langit na naghahayag ng mga hiwaga." Noong Martes, natutunan natin na bawat makalupang kaharian ay tulad ng rebultong mauuwi sa alikabok, pero ang kaharian ng Diyos, ang batong hindi tinapyas ng kamay ng tao, ay mananatili magpakailanman. Noong Miyerkoles, yumukod ang buong imperyo sa harap ng isang gintong rebulto, maliban sa tatlong binata. Noong Huwebes, sinabi nila sa hari, "Kahit hindi Niya kami iligtas, hindi kami yuyukod." Noong Biyernes, sinalubong sila ng Diyos sa apoy, at may ikaapat na Lalaking lumakad kasama nila. Ngayong araw, sinimulan nating basahin ang sariling patotoo ng mapagmataas na hari kung paano siya binago ng Diyos.

Sa susunod na linggo, maririnig natin ang kabuuan ng kuwento ni Nebuchadnezzar: isang malaking punong pinutol, isang haring pinakumbaba, at isang pusong naibalik. Pagkatapos, makikilala natin ang kanyang kahalili, si Belshazzar, sa isang magulong handaan kung saan may mahiwagang kamay na sumulat sa pader. 🏁$q$),
  (DATE '2026-12-14', $q$May Ugat Pa ang Tuod$q$, $q$Mas matanda pa sa sinuman sa kalye ang lumang puno ng mangga sa bakuran ni Lola Remedios. Umaabot ang mga sanga nito sa tatlong bahay. Tuwing tag-init, napakarami nitong bunga kaya pinupuno ni Lola Remedios ang mga palanggana at ipinamimigay sa bawat kapitbahay. Naglalaro ang mga bata sa lilim nito. Pumaparada sa ilalim nito ang mga tricycle driver para magpahinga tuwing tanghali. Buong taon, may mga ibong namumugad dito.

"Pinakakain ng punong 'yan ang kalahati ng kalye," madalas sabihin ng mga tao.

Pagkatapos ay dumating ang isang malakas na bagyo. Sa kalagitnaan ng gabi, nabali ang isang sangang kasinlaki ng jeepney at bumagsak sa bubong ng kapitbahay. Kinaumagahan, dumating ang mga tauhan ng munisipyo dala ang mga chainsaw. Bulok na raw ang loob ng puno. Kailangan na itong putulin.

Pinanood ng apo ni Lola Remedios na si Kenneth mula sa bintana ang sunud-sunod na pagbagsak ng mga sanga. Pagsapit ng hapon, isang malapad at pangit na tuod na lang ang natira. Mukhang hubad ang kalye. Wala na ang mga ibon.

"Lola, bakit po hindi rin nila binunot ang tuod?" tanong ni Kenneth.

"Pinakiusapan ko sila na huwag na," sabi niya. "Maayos pa ang mga ugat. Ang loob lang ng puno ang bulok."

Hindi ito naintindihan ni Kenneth. Ilang buwang nakatayo lang doon ang tuod. Ginagawa itong upuan ng mga tao.

Pagkatapos, isang umaga matapos ang mga pag-ulan, tumakbo si Kenneth papasok sa bahay na sumisigaw. "Lola! Lola! Halika po, tingnan n'yo!"

Sa gilid ng lumang tuod, may tatlong matingkad na berdeng usbong na tumagos sa balat ng kahoy. Maliliit lang ang mga ito, pero buhay.

Dahan-dahang lumuhod si Lola Remedios at hinawakan ng daliri ang isa. "Nakita mo?" nakangiti niyang sabi. "Pinutol nila ang bulok. Pero hangga't nasa lupa pa ang mga ugat, may pag-asa."

Tinalian ni Kenneth ng pulang laso ang tuod para walang umupo sa mga bagong usbong.$q$, $q$Inilalarawan ngayon ni Nebuchadnezzar ang kanyang ikalawang dakilang panaginip. Nakakita siya ng isang napakalaking punong nasa gitna ng lupa. Umaabot ito sa langit at kitang-kita kahit saan. Maganda ito at mabunga. Nagpapahinga sa lilim nito ang mga hayop, namumugad sa mga sanga nito ang mga ibon, at "mula rito ay napakain ang bawat nilalang" (t. 12).

Larawan ng kapangyarihan ng hari ang puno. At pansinin na hindi ito puro masama. Ang kanyang kaharian ay nagbigay ng pagkain, kaayusan, at proteksyon sa maraming tao. Binibigyan ng Diyos ng kapangyarihan ang mga lider para pagpalain nila ang mga nasa ilalim nila.

Pero pagkatapos ay bumaba mula sa langit ang isang "bantay, isang banal" na may utos: "Putulin ang puno." Hahubaran ito ng mga sanga, dahon, at bunga. Mas nakakatakot pa, ang taong kinakatawan ng puno ay mawawala sa sarili niyang isip at mamumuhay na parang hayop "hanggang lumipas sa kanya ang pitong panahon."

Bakit? Ibinibigay ng talata 17 ang layunin: "upang malaman ng mga nabubuhay na ang Kataas-taasan ang naghahari sa kaharian ng sangkatauhan at ibinibigay ito sa sinumang Kanyang naisin, at inilalagay rito ang pinakaabang tao." Ito ang pangunahing tema ng Daniel. Akala ng mga hari, sila ang naghahari, pero ang Diyos ang naghahari sa kanila.

Pero may sinag ng pag-asa sa madilim na panaginip na ito. "Iwan ang tuod at ang mga ugat nito sa lupa" (t. 15). Totoo ang hatol, pero hindi ito ang katapusan. Plano ng Diyos na ibagsak ang hari, hindi para wasakin siya, kundi para magising siya sa katotohanan.

Ganyan din ang pakikitungo ng Diyos sa Kanyang bayan. Maaaring malalim ang sugat ng Kanyang pagdidisiplina, pero iniiwan Niya ang mga ugat. Ang layunin Niya ay hindi kailanman pagwasak, kundi pagpapanumbalik.$q$, $q$Itinuturo sa akin ng talatang ito na anumang impluwensyang ibinibigay sa akin ng Diyos ay para pagpalain ang iba. Tulad ng malaking puno, ang aking tahanan, trabaho, at posisyon ay dapat maging lugar kung saan nakakatagpo ang mga tao ng kanlungan at pagkalinga. Dapat kong itanong sa Panginoon kung ang mga taong nasa pangangalaga ko ay napapakain at naiingatan, o ginagamit ko lang para sa sarili kong kapakinabangan.

Pinaaalala rin sa akin na ang Kataas-taasan ang naghahari. Gaano man ako lumakas o magtagumpay, hindi ako ang may hawak. Dahil alam kong kayang ibagsak ng Diyos kahit ang pinakamakapangyarihang puno, sisikapin kong hawakan nang bukas-palad ang aking mga naabot.

Pero ang pinakanakaaaliw sa akin ay ang tuod na iniwan sa lupa. Inaamin ko na may mga panahong pinutol ng Diyos ang ilang bagay sa buhay ko, at masakit iyon. Hindi ko iyon naintindihan noon. Ngayon, nakikita ko na inaalis Niya ang bulok para may bagong tumubo.

Dahil laging iniiwan ng pagdidisiplina ng Diyos ang mga ugat, hindi ako mawawalan ng pag-asa kapag pinupungusan Niya ako. Kung nasa panahon ako ng kawalan ngayon, magtitiwala ako na maaari pa ring dumating ang bagong buhay. At maghahanap ako ng isang taong makakanlungan at mapalalakas ko ang loob ngayong linggo.$q$, $q$Kataas-taasang Diyos, Kayo po ang naghahari sa bawat kaharian, bawat lider, at bawat buhay. Salamat po sa mga kaloob at impluwensyang ibinigay N'yo sa akin. Tulungan po Ninyo akong gamitin ang mga ito para pagpalain ang iba at hindi lang ang sarili ko. Kapag pinuputol N'yo ang mga bagay sa buhay ko na bulok, bigyan po Ninyo ako ng biyayang magtiwala sa Inyo. Salamat po na laging iniiwan ng Inyong pagdidisiplina ang mga ugat at hindi N'yo kailanman sinusukuan ang Inyong mga anak. Magpatubo po Kayo ng bagong buhay mula sa mga tuod ng buhay ko, para sa Inyong kaluwalhatian. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-15', $q$Isang Gupit at Isang Mabigat na Katotohanan$q$, $q$Halos sampung taon nang ginugupitan ni Wilfredo si Mr. Arcilla tuwing ikalawang linggo. Si Mr. Arcilla ang may-ari ng pinakamalaking hardware store sa bayan, at lagi siyang dumarating nang eksaktong alas-kuwatro, umuupo sa parehong upuan, at nagsasalita sa buong oras.

Marami nang alam si Wilfredo tungkol sa kanya. Alam niyang sinisigawan ni Mr. Arcilla ang kanyang mga trabahador at kinakaltasan ang sahod nila sa maliliit na pagkakamali. Alam niyang tinanggal ang isa sa mga dati niyang delivery boy dahil nahuli ito sa araw na isinugod sa ospital ang nanay nito. Takot ang nararamdaman ng mga tao sa bayan kapag pinag-uusapan si Mr. Arcilla, hindi kailanman pagmamahal.

Isang hapon, mas tahimik si Mr. Arcilla kaysa karaniwan. "Ayaw ng anak ko na siya ang magpatakbo ng tindahan," sabi niya sa wakas. "Ayaw raw niyang maging katulad ko. Makapaniwala ka ba roon?"

Patuloy sa paggupit si Wilfredo. Matatag ang kanyang mga kamay, pero kumakabog ang kanyang dibdib. Puwede siyang tumango at sumang-ayon na lang, gaya ng lagi niyang ginagawa. O puwede niyang sabihin ang totoo.

"Sir," maingat niyang sabi, "puwede po ba akong magsabi ng isang bagay? Puwede po kayong maghanap ng ibang barbero pagkatapos kung magagalit kayo."

Tiningnan siya ni Mr. Arcilla sa salamin. "Sige."

"Mabait po kayo sa akin. Lagi kayong nagbabayad sa oras at malaki magbigay ng tip. Pero takot po sa inyo ang mga trabahador ninyo, sir. At sa tingin ko po, nakikita iyon ng anak ninyo." Ibinaba niya ang gunting. "Sinasabi ko po ito dahil umaasa akong hindi pa huli ang lahat. Kung magsisimula kayong maging mabait sa kanila, baka ibang tatay na ang makita niya."

Tumahimik ang buong barberya. Sigurado si Wilfredo na kawawala lang ng kanyang pinakamagandang suki.

Tumayo si Mr. Arcilla, nagbayad, at lumabas nang walang imik.

Makalipas ang dalawang linggo, eksaktong alas-kuwatro, bumalik siya. Umupo siya at tahimik na nagsabi, "Tinaasan ko ang sahod ng mga delivery boy. Napansin ng anak ko."$q$, $q$Nang marinig ni Daniel ang panaginip, siya ay "nalito, at binagabag siya ng kanyang mga isip" (t. 19). Naintindihan niya mismo ang ibig sabihin nito, at ayaw niya itong sabihin. Napansin pa ito ng hari at sinabihan siyang huwag matakot.

Nakagugulat ang unang mga salita ni Daniel: "Panginoon ko, nawa'y sa mga napopoot sa inyo mangyari ang panaginip." Tunay na may malasakit si Daniel sa haring ito. Ito ang lalaking wumasak sa Jerusalem at nagdala kay Daniel sa pagkatapon. Pero hindi ikinatuwa ni Daniel ang pagpapahayag ng kanyang hatol. Sana raw ay sa iba na lang ito.

Gayunman, sinabi niya nang malinaw ang katotohanan: "Kayo, O hari, ang punong iyon!" (t. 22). Itataboy ang hari mula sa mga tao at mamumuhay na parang hayop "hanggang kilalanin ninyo na ang Kataas-taasan ang naghahari" (t. 25). Pero ang tuod ay nangangahulugang may pag-asa. Babalik ang kanyang kaharian "sa sandaling kilalanin ninyo na ang Langit ang naghahari" (t. 26).

Pagkatapos ay gumawa si Daniel ng mas matapang pang bagay. Binigyan niya ang hari ng personal na payo: "Talikuran ninyo ang inyong mga kasalanan sa pamamagitan ng paggawa ng tama, at ang inyong mga kasamaan sa pamamagitan ng pagkaawa sa mga inaapi" (t. 27). Hindi siya nagsalita nang pangkalahatan. Pinangalanan niya ang mga tiyak na kasalanan ng hari: kayabangan at kalupitan sa mahihina. At nag-alok siya ng daan palabas: ang pagsisisi ay maaaring magdulot ng "pagpapatuloy ng inyong kasaganaan."

Ganito ang anyo ng pagsasalita ng katotohanan nang may pag-ibig. Magalang si Daniel, mahabagin, at tapat. Hindi niya binola ang hari, at hindi rin niya ito inatake. Sinabi niya ang katotohanan dahil gusto niyang maligtas ito.

Tinatawag pa rin ng Diyos ang Kanyang bayan na magsalita ng mabibigat na katotohanan nang may pag-ibig, hindi para manalo sa pagtatalo, kundi para maibalik ang mga tao sa Kanya.$q$, $q$Itinuturo sa akin ng talatang ito na minsan, ang tunay na pag-ibig ay nangangailangan ng mabibigat na salita. Puwedeng pinalambot ni Daniel ang mensahe o nanahimik na lang para protektahan ang sarili. Sa halip, sinabi niya sa hari ang katotohanan dahil may malasakit siya rito. Inaamin ko na madalas akong nananahimik kapag ang isang taong kilala ko ay papunta sa maling direksyon. Sinasabi ko sa sarili ko na hindi ko iyon problema, pero kadalasan, natatakot lang ako sa magiging reaksyon niya.

Hinahamon din ako ng puso ni Daniel. Hindi niya ikinatuwa ang paghahatid ng hatol. Binagabag siya nito at sana raw ay sa iba na lang ito bumagsak. Dapat kong hilingin sa Panginoon na bigyan ako ng parehong habag, para kapag kailangan kong itama ang isang tao, gagawin ko ito nang may luha at hindi nang may kayabangan.

Dahil sa halimbawa ni Daniel, sisikapin kong maging tapat at tiyak, pero laging magalang at mabait. Ituturo ko rin ang mga tao sa pag-asa ng pagsisisi, hindi lang sa problema.

Dahil alam kong maaaring gusto akong gamitin ng Diyos para balaan ang isang taong mahal ko, ipapanalangin ko ngayong linggo ang isang taong kailangang makarinig ng mapagmahal na katotohanan. Kung bubuksan ng Diyos ang pinto, magsasalita ako nang mahinahon at ipagkakatiwala ko sa Kanya ang resulta.$q$, $q$Panginoon, bigyan po Ninyo ako ng tapang at habag ni Daniel. Patawarin po Ninyo ako sa mga pagkakataong nanahimik ako dahil natakot ako sa iisipin ng mga tao. Kapag ang isang taong mahal ko ay papunta sa kapahamakan, tulungan po Ninyo akong sabihin ang katotohanan nang may kahinahunan at paggalang. Ilayo po Ninyo ako sa kayabangan kapag itinatama ko ang iba, at ipaalala po Ninyo ang sarili kong pangangailangan sa Inyong awa. Gamitin po Ninyo ang aking mga salita para ibalik ang mga tao sa Inyo, kung saan laging may pag-asa para sa mga tumatalikod sa kanilang mga kasalanan. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-16', $q$Sino ang Gumawa Nito?$q$, $q$Sa edad na dalawampu't anim, si Jayson ang pinakapinag-uusapang online seller sa kanilang bayan. Nagbebenta siya ng mga gadget at accessories sa pamamagitan ng live stream, at sa magandang gabi ay mas malaki ang kinikita niya kaysa sa kinikita ng kanyang tatay sa isang buwan bilang tricycle driver.

Bumili siya ng bagong kotse, malaking TV para sa kanyang mga magulang, at mamahaling sapatos para sa sarili. Sa kanyang mga live stream, mahilig niyang sabihin, "Self-made 'to, mga kaibigan! Walang tumulong sa akin. Hard work lang!"

Ang hindi niya sinasabi ay madalas siyang nagbebenta ng mga pekeng item bilang orihinal. Ilang buwan niyang inaantala ang pagbabayad sa kanyang mga supplier. Nang humingi ng dagdag-sahod ang nakababata niyang pinsan na nag-iimpake ng mga order para sa kanya, tumawa si Jayson at sinabing, "Magpasalamat ka na lang at may trabaho ka."

Pagkatapos ay gumuho ang lahat sa loob lang ng isang buwan. Nag-post ang isang customer ng video na naglalantad sa kanyang mga pekeng produkto. Nag-viral ito. Na-ban ang kanyang online store. Dumating ang mga supplier para maningil, at binawi ang kotse. Sa loob ng kalahating taon, nagsasalansan na si Jayson ng mga kahon bilang warehouse helper sa minimum na sahod.

Matagal siyang galit. Pagkatapos, isang gabi, habang nakaupong mag-isa sa loading dock ng bodega matapos ang dobleng shift, tumingala siya sa mga bituin at humagulgol. "Wala akong itinayo," bulong niya. "Kumuha lang ako."

Nang sumunod na Linggo, sumama siya sa kanyang pinsan sa isang maliit na simbahang nagtitipon sa isang inuupahang puwesto sa itaas ng isang panaderya. Umupo siya sa likod. Nagsalita ang pastor tungkol sa Diyos na nagpapakumbaba sa mga mapagmataas pero nagbibigay ng biyaya sa mga mapagpakumbaba.

Makalipas ang dalawang taon, nagsimula ulit magbenta si Jayson, ngayon ay dahan-dahan, tapat, at may resibo. Sa una niyang live stream, tumingin siya sa camera at sinabing, "Bago ang lahat, gusto kong ikuwento sa inyo ang ginawa ng Diyos sa buhay ko."$q$, $q$Binigyan ng Diyos si Nebuchadnezzar ng isang buong taon para magbago. Binalaan siya ni Daniel at binigyan ng daan palabas. Pero walang nagbago.

Pagkatapos, isang gabi, naglalakad ang hari sa bubungan ng kanyang palasyo, tinatanaw ang dakilang lungsod. Isa ang Babilonia sa mga kamangha-manghang lugar ng sinaunang mundo, may naglalakihang pader, magagandang hardin, at engrandeng mga gusali. Punô ng kayabangan, sinabi niya, "Hindi ba ito ang dakilang Babilonia, na ako mismo ang nagtayo sa lakas ng aking kapangyarihan... at para sa kaluwalhatian ng aking karangalan?" (t. 30).

Tingnan ang dami ng "ako" at "aking" sa pangungusap na iyon. Walang puwang para sa Diyos.

"Habang nasa bibig pa ng hari ang mga salita," kumilos ang Diyos. Nawala sa sarili niyang isip ang pinakamakapangyarihang tao sa mundo at namuhay na parang mabangis na hayop. Kumain siya ng damo. Humaba ang kanyang buhok at naging parang kuko ng ibon ang kanyang mga kuko. Pinaniwala siya ng kayabangan na isa siyang diyos, at ipinakita ng Diyos sa kanya na kung wala ang Kanyang awa, mas mababa pa siya sa tao.

Pero nanatili ang tuod. "Sa pagtatapos ng mga araw na iyon, ako, si Nebuchadnezzar, ay tumingala sa langit, at naibalik ang aking katinuan" (t. 34). Sa sandaling tumingala siya, bumalik ang kanyang isip. Ang una niyang ginawa ay hindi ang agawin ang kanyang trono, kundi ang purihin ang Diyos.

Ang huli niyang mga salita ay ilan sa pinakakahanga-hanga sa buong Bibliya: "Ngayon, ako, si Nebuchadnezzar, ay pumupuri at nagtataas at lumuluwalhati sa Hari ng langit... At kaya Niyang pakumbabain ang mga lumalakad nang may kayabangan" (t. 37).

Pinapapanood tayo ng kayabangan nang pababa sa iba. Nagsisimula ang kababaang-loob kapag tumitingala tayo sa langit. Doon matatagpuan ang katinuan, pagpapanumbalik, at tunay na kadakilaan.$q$, $q$Itinuturo sa akin ng talatang ito kung gaano kapanganib ang kayabangan, lalo na kapag tahimik at kumportable ito. Hindi naman sumisigaw sa galit si Nebuchadnezzar. Hinahangaan lang niya ang sarili niyang tagumpay. Inaamin ko na minsan, tinitingnan ko ang mga naabot ko at tahimik kong inaangkin ang lahat ng papuri. Nakakalimutan ko ang Diyos na nagbigay sa akin ng hininga, kalusugan, mga pagkakataon, at mga taong tumulong sa akin sa daan.

Nabigla rin ako sa pagtitiis ng Diyos. Binigyan Niya ang hari ng isang buong taon para magsisi. Dahil alam kong ang pagtitiis ng Diyos ay hindi pahintulot para patuloy na magkasala, hindi ko dapat ipagpaliban ang pagtalikod sa kayabangang ipinakita na Niya sa akin.

Pero pinakapinalalakas ng loob ko ang talata 34. Sa sandaling tumingala ang hari, nagbago ang lahat. Sisikapin kong tumingala nang mas madalas: simulan ang aking mga araw sa pasasalamat, tingnan ang aking mga pagpapala bilang mga regalo, at alalahanin na ang Diyos ang tunay na nagtatayo ng anumang mabuti sa buhay ko.

Dahil kaya ng Diyos na pakumbabain ang mga mapagmataas, gusto kong ako na mismo ang magpakumbaba. Ngayong araw, pasasalamatan ko nang malakas ang Diyos sa tatlong bagay na kadalasang inaangkin ko ang papuri, at pasasalamatan ko ang isang taong tumulong sa akin para marating ko ang kinalalagyan ko.$q$, $q$Hari ng langit, totoo po ang lahat ng Inyong mga gawa at makatarungan ang lahat ng Inyong mga daan. Patawarin po Ninyo ako sa mga pagkakataong tiningnan ko ang buhay ko at sinabing, "Ako ang gumawa nito." Lahat ng mayroon ako ay galing sa Inyo. Pakumbabain po Ninyo ang puso ko bago pa N'yo kailanganing pakumbabain ang mga kalagayan ko. Turuan po Ninyo akong tumingala sa Inyo araw-araw nang may pasasalamat at papuri. Salamat po sa pagpapanumbalik Ninyo sa mga bumabaling sa Inyo. Gawin po Ninyo akong buhay na patotoo na itinataas N'yo ang mga mapagpakumbaba at binibiyayaan ang lahat ng naghahanap sa Inyo. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-17', $q$Ang Handaan Bago ang Bagyo$q$, $q$Nakataas na ang babala ng bagyo mula pa umaga. Nagpadala ng mga text blast ang barangay. Dumaan sa mga kalye sa tabi ng ilog ang isang trak na may loudspeaker: "Mag-evacuate na po tayo! Tumataas na ang ilog!"

Pinagtawanan lang ito ni Kevin at ng kanyang mga kaibigan. "Taon-taon nilang sinasabi 'yan," sabi ni Kevin. "Wala namang nangyayari." Kakatanggap lang nila ng sahod sa construction site, at ilang linggo na nilang pinaplano ang inuman sa bahay ni Kevin sa tabi ng ilog. Hindi nila ito ika-cancel dahil lang sa kaunting ulan.

Kaya habang binubuhat ng mga pamilya ang kanilang mga bag at mga anak papunta sa covered court, nilakasan ng grupo ang videoke at binuksan ang unang kahon ng beer. Nang kumatok si Arnel, isang barangay volunteer, para balaan ulit sila, kinutya nila ito.

"Kuya Arnel, sali ka na! Relax ka lang!"

Umiling si Arnel. "Pakiusap. Isang metro ang itinaas ng tubig sa loob ng dalawang oras. Kahit lumipat man lang kayo sa main road."

Pinagsarhan nila siya ng pinto.

Pagsapit ng hatinggabi, nawalan ng kuryente. Pagsapit ng ala-una ng madaling-araw, bumubuhos na ang tubig sa ilalim ng pinto. Sa loob ng ilang minuto, umabot ito sa kanilang mga tuhod, pagkatapos ay sa kanilang baywang. Malakas ang agos sa labas. Nagsisigawan ang mga kaibigan ni Kevin. Nanginginig nang husto ang mga tuhod ni Kevin kaya halos hindi siya makatayo sa mesang inakyatan niya.

Pagkatapos ay narinig nila ito: ang tunog ng isang motor at isang flashlight na sumusuyod sa tubig. Si Arnel iyon, sakay ng isang rubber boat kasama ang dalawa pang volunteer.

"Kumapit kayo sa lubid!" sigaw ni Arnel.

Basa, nilalamig, at nanginginig, umakyat si Kevin sa bangka. Hindi niya matingnan si Arnel. Ang lalaking pinagtawanan niya ang tanging dumating.

Sa evacuation center, matagal na nakaupo si Kevin nang tahimik. Pagkatapos ay lumapit siya at tahimik na tinulungan si Arnel na isalansan ang mga relief goods.$q$, $q$Lumundag ang kabanata 5 nang mahigit dalawampung taon pasulong. Wala na si Nebuchadnezzar, at si Belshazzar na ang naghahari sa Babilonia. Sinasabi sa atin ng kasaysayan na sa mismong gabing ito, nakakampo ang mga hukbo ng mga Medo at Persiano sa labas ng mga pader ng lungsod. Nasa panganib ang Babilonia. At ano ang ginawa ng hari? Nagdaos siya ng handaan para sa isang libong maharlika.

Pagkatapos, "habang lasing sa alak," gumawa siya ng isang kakila-kilabot na desisyon. Iniutos niyang dalhin ang mga banal na kopang ginto at pilak na kinuha mula sa templo ng Diyos sa Jerusalem. Uminom sila ng kanyang mga panauhin mula sa mga ito habang pinupuri ang "mga diyos na ginto at pilak, tanso at bakal, kahoy at bato" (t. 4). Sinadya nitong kutyain ang buhay na Diyos.

Sa mismong sandaling iyon, lumitaw ang mga daliri ng isang kamay ng tao at sumulat sa pader. Ang hari, na napakayabang ilang sandali lang ang nakalipas, ay namutla. "Nanlambot ang kanyang mga balakang at nag-umpugan ang kanyang mga tuhod" (t. 6). Walang makabasa sa sulat.

Pagkatapos ay pumasok ang reyna, malamang ang inang reyna. Naalala niya ang isang lalaki mula sa panahon ni Nebuchadnezzar, isang taong may "pambihirang espiritu" na kayang "lutasin ang mahihirap na problema." Nakalimutan na si Daniel ng bagong hari, pero hindi ng Diyos.

Nagbababala sa atin ang talatang ito tungkol sa dalawang panganib. Ang una ay ang pabayang pamumuhay sa harap ng panganib: nagpapakasaya habang nasa pintuan na ang paghatol. Ang ikalawa ay ang pagbabalewala sa mga banal na bagay. Ang pangalan ng Diyos, ang Kanyang Salita, ang Kanyang iglesya, at ang Kanyang bayan ay hindi mga bagay na dapat gawing biro o abusuhin.

Pinagtawanan ni Belshazzar ang Diyos hanggang sa sandaling sumulat ang Diyos sa kanyang pader. Mas mabuting seryosohin ang Diyos ngayon, habang may panahon pa.$q$, $q$Itinuturo sa akin ng talatang ito na hindi hahayaan ng Diyos na kutyain Siya magpakailanman. Ginamit ni Belshazzar ang mga banal na bagay para sa sarili niyang kasiyahan at pinuri ang mga walang-buhay na diyos-diyosan, at pinatigil ng Diyos ang kanyang handaan sa pamamagitan ng mensaheng hindi niya maaaring balewalain. Inaamin ko na minsan ay masyadong magaan ang pagturing ko sa mga banal na bagay. Ginagawa kong biro ang kasalanan, minamadali ko ang pagsamba, o ginagamit ko nang pabaya ang pangalan ng Diyos.

Dapat kong hilingin sa Panginoon na bigyan ako ng malusog na takot sa Kanya. Hindi takot na naglalayo sa akin, kundi paggalang na nagseseryoso sa Kanya.

Binabalaan din ako ng kapabayaan ng hari. Nasa pintuan na ang kaaway, at nagdaraos siya ng handaan. Dahil alam kong maikli ang buhay at totoo ang mga babala ng Diyos, sisikapin kong hindi mamuhay na para bang walang bukas at walang paghatol. Titigil na ako sa pagbabalewala sa mga babalang ipinapadala ng Diyos sa pamamagitan ng Kanyang Salita, ng aking konsensya, at ng mga taong nagmamahal sa akin.

Pinalalakas din ni Daniel ang loob ko. Nakalimutan siya ng bagong hari, pero hindi ng Diyos. Kapag pakiramdam ko'y hindi ako napapansin, makapagtitiwala ako na alam ng Diyos kung nasaan mismo ako.

Ngayong linggo, ituturing ko nang may paggalang ang oras ko kasama ang Diyos at ibibigay ko sa Kanya ang buong atensyon ko.$q$, $q$Banal na Diyos, patawarin po Ninyo ako sa mga pagkakataong binalewala ko Kayo. Bigyan po Ninyo ako ng mapitagang pusong nagseseryoso sa Inyong pangalan, Inyong Salita, at Inyong mga babala. Ilayo po Ninyo ako sa pabayang pamumuhay at sa pagbabalewala sa mga tandang ipinapadala N'yo sa akin. Salamat po na mapagtiis Kayo at nagpapadala Kayo ng mga taong nagbababala at nagliligtas sa mga nasa panganib. Kapag pakiramdam ko'y nakalimutan ako, ipaalala po Ninyo na lagi N'yong alam kung nasaan ako. Tulungan po Ninyo akong mamuhay araw-araw nang bukas ang mga mata sa tunay na mahalaga. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-18', $q$Alam Mo na ang Lahat ng Ito$q$, $q$Lumaki si Marvin na pinapanood ang sugal na dahan-dahang sumisira sa kanyang tatay. Naaalala niya ang mga gabing umiiyak ang kanyang nanay dahil sa mga hindi nababayarang bayarin. Naaalala niya ang pagbebenta ng kanilang maliit na TV para makabayad ng utang. Naaalala niya ang mga hungkag na pangako ng kanyang tatay: "Last na 'to, promise."

Noong binatilyo pa siya, isinumpa ni Marvin na hindi siya kailanman magiging katulad nito. Ibinigay niya ang kanyang buhay sa Panginoon sa isang youth camp, at sa loob ng maraming taon ay tinupad niya ang pangakong iyon.

Ngayon, tatlumpu't dalawang taong gulang na siya, forklift operator sa isang bodega, may asawa at isang batang babae. Nagsimula ito nang inosente: ilang online games sa kanyang cellphone tuwing break. Pagkatapos ay maliliit na pustahan kasama ang mga kaibigan. Pagkatapos ay mas malalaki. Sinasabi niya sa sarili na libangan lang ito. Hindi nagtagal, itinatago na niya ang cellphone niya sa asawa niyang si Joanna, at lumiliban na sa simbahan para raw "makabawi ng tulog."

Isang araw ng sahod, malaki ang napanalunan niya. Sa sobrang tuwa, dumiretso siya sa bahay ng ate niyang si Cecilia na may dalang regalo: isang bagong-bagong rice cooker at isang sobre ng pera para sa tuition ng mga anak nito.

Tiningnan ni Cecilia ang sobre. Pagkatapos ay tiningnan niya si Marvin.

"Saan galing 'to, Marvin?"

Sinubukan niyang tawanan na lang. Hindi tumawa si Cecilia.

"Sa 'yo na lang," mahina niyang sabi, at itinulak pabalik ang sobre. "Ayoko nito." Napuno ng luha ang kanyang mga mata. "Marvin, nakita mo ang ginawa nito kay Papa. Nakita mo ang ginawa nito kay Mama. Alam mo na ang lahat ng ito. Paano mo nagagawa ang parehong bagay?"

Gusto sanang magalit ni Marvin. Sa halip, umupo siya sa plastik nitong upuan at tinakpan ng mga kamay ang kanyang mukha.

Nang gabing iyon, ipinagtapat niya ang lahat kay Joanna. Nang sumunod na Linggo, nasa simbahan na ulit siya. Binura niya ang mga app, ibinigay ang password ng kanyang cellphone sa asawa, at sumali sa isang accountability group ng mga kalalakihan.

Pagkalipas ng isang taon, si Cecilia ang unang tinawagan niya para sa isang magandang balita.$q$, $q$Inalok ni Belshazzar si Daniel ng kulay-ubeng balabal, gintong kuwintas, at ikatlong pinakamataas na posisyon sa kaharian. Prangka ang sagot ni Daniel: "Inyo na lang ang inyong mga regalo at ibigay ang inyong mga gantimpala sa iba" (t. 17). Matanda na ngayon si Daniel, malamang ay lampas walumpung taong gulang. Wala siyang mapapala sa pagsang-ayon ng hari, at hindi niya hahayaang maimpluwensyahan ng mga gantimpala ang kanyang mensahe.

Pagkatapos ay binigyan ni Daniel ang hari ng aral sa kasaysayan. Binigyan ng Diyos si Nebuchadnezzar ng dakilang kapangyarihan, pero nang magmataas ang puso nito, pinakumbaba siya ng Diyos hanggang sa "kilalanin niya na ang Kataas-taasang Diyos ang naghahari" (t. 21).

Pagkatapos ay dumating ang pinakamatatalim na salita sa kabanata: "Ngunit ikaw na kanyang anak, O Belshazzar, ay hindi nagpakumbaba ng iyong puso, kahit alam mo na ang lahat ng ito" (t. 22).

Iyan ang tunay na kasalanan ni Belshazzar. Hindi siya mangmang. Alam niya ang kuwento ng pagbagsak at pagpapanumbalik ng kanyang lolo. Mayroon siyang bawat dahilan para matakot sa Diyos. Sa halip, siya ay "nagmataas laban sa Panginoon ng langit," uminom mula sa mga sisidlan ng templo, at pumuri sa mga diyos-diyosang "hindi nakakakita, hindi nakaririnig, at hindi nakauunawa."

Ang huling paratang ni Daniel ay tumatama mismo sa puso: "Hindi mo niluwalhati ang Diyos na may hawak sa Kanyang kamay ng iyong mismong hininga at ng lahat ng iyong mga daan" (t. 23).

Isa itong babala para sa ating lumaking alam ang katotohanan. Hindi tayo maililigtas ng kaalaman lang. Maaari nating alam ang mga tamang sagot pero ayaw pa rin nating magpakumbaba. Bawat hiningang hinihinga natin ay regalo ng Diyos. Ang tanong ay hindi kung gaano karami ang alam natin, kundi kung pinararangalan ba natin Siya sa mga alam natin.$q$, $q$Itinuturo sa akin ng talatang ito na ang pagkaalam ng katotohanan ay hindi katulad ng pagsunod dito. Alam ni Belshazzar ang nangyari kay Nebuchadnezzar, pero dumiretso pa rin siya sa parehong kayabangan. Inaamin ko na may mga aral na natutunan ko, minsan nang masakit, na hindi ko pa rin isinasabuhay. Nakita ko na kung saan humahantong ang ilang kasalanan, pero patuloy ko pa rin silang pinaglalaruan.

Dapat kong hilingin sa Panginoon na siyasatin ang puso ko para sa anumang bahagi kung saan maaari Niyang sabihin sa akin, "Alam mo na ang lahat ng ito." Ayokong maging taong nakarinig na ng maraming sermon pero hindi pa rin nagbabago.

Hinahamon din ako ng integridad ni Daniel. Tinanggihan niya ang mga regalo ng hari para maging malinaw ang kanyang mensahe. Dahil alam kong tahimik na napatatahimik ng pera at mga pabor ang katotohanan, sisikapin kong maging taong hindi nabibili ang mga salita.

Pinapakumbaba ako ng talata 23. Hawak ng Diyos ang mismong hininga ko. Dahil regalo Niya ang bawat hininga, gagawin kong layunin na luwalhatiin Siya sa lahat ng aking mga daan.

Ngayong linggo, papangalanan ko ang isang aral na alam ko na pero hindi ko pa sinusunod, at gagawa ako ng isang tiyak na hakbang para magbago, kasama ang paghingi sa isang tao na tulungan akong manatiling tapat sa hakbang na iyon.$q$, $q$Diyos na may hawak ng mismong hininga ko, patawarin po Ninyo ako sa mga pagkakataong alam ko ang katotohanan pero ayaw kong magpakumbaba. Siyasatin po Ninyo ako at ipakita kung saan ko inulit ang mga pagkakamaling alam na alam ko. Bigyan po Ninyo ako ng tapang na tuluyang talikuran ang mga ito. Salamat po sa mga taong nagmamahal sa akin nang sapat para sabihin sa akin ang totoo. Panatilihin po Ninyong tapat ang aking mga salita at malaya ang puso ko sa impluwensya ng mga regalo at pabor. Sa bawat hiningang ibinibigay N'yo sa akin, nawa'y luwalhatiin ko Kayo. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-19', $q$Tinimbang at Natagpuang Kulang$q$, $q$Nasa dulo ng isang maalikabok na daan malapit sa ilog ang junk shop ni Bernardo. Tuwing umaga, itinutulak ng mga nangangalakal ng basura ang kanilang mga kariton papunta sa kanyang timbangan, dala ang mga sako ng plastik na bote, karton, scrap na bakal, at lumang kawad na tanso. Para sa marami sa kanila, ang ibinabayad ni Bernardo ang tanging makakain nila sa araw na iyon.

Ipinagmamalaki ni Bernardo ang pagiging patas niya. "Honest timbang," sabi niya. "Kaya bumabalik ang mga tao."

Nang magsimulang tumulong sa shop ang pamangkin niyang si Rex, natuwa si Bernardo. Mabilis si Rex sa numero at magaling makitungo sa mga customer. Lumakas ang negosyo. Nagsimulang mamalagi si Bernardo sa bahay at ipinaubaya na kay Rex ang pagtitimbang.

Pagkatapos, isang hapon, dumating sa bahay ni Bernardo ang isang matandang nangangalakal na nagngangalang Ignacio. Hinubad niya ang kanyang sombrero at kinakabahang hinawakan ito.

"Sir, pasensya na po sa abala. Ilang buwan na po akong nagdadala ng parehong punong sako ng bote linggo-linggo. Dati, walong kilo ang timbang nito. Ngayon, laging anim na lang." Nag-atubili siya. "Baka po tumatanda lang ako."

Pumunta si Bernardo sa shop nang gabing iyon. Kinuha niya ang isang limang-kilong sako ng bigas na kabibili lang niya at inilagay sa timbangan. Apat na kilo ang lumabas. Natagpuan niya ang maliit na piraso ng bakal na itinago ni Rex sa ilalim.

Matagal na nakaupo si Bernardo sa madilim na shop.

Kinaumagahan, ipinatawag niya si Rex. Walang sigawan, isang tahimik at seryosong usapan lang na nagtapos sa pag-iyak ni Rex. Pagkatapos ay inilabas ni Bernardo ang isang lumang kuwaderno at isa-isang inalala ang bawat pangalang kaya niyang maalala.

Sa sumunod na buwan, hinanap niya ang pinakamaraming nangangalakal na kaya niyang hanapin at ibinalik ang halagang nadaya sa kanila. Naubos dito ang malaking bahagi ng kanyang ipon.

Nang matanggap ni Ignacio ang kanyang sobre, napaiyak siya. "Sir, hindi n'yo naman po kailangang gawin 'to."

"Kailangan," sabi ni Bernardo. "Dapat nagsasabi ng totoo ang timbangan."$q$, $q$Sa wakas, binasa ni Daniel ang nakasulat: "MENE, MENE, TEKEL, PARSIN." Mga salitang Aramaiko ito para sa mga timbang at sukat, parang pagsasabing "binilang, binilang, tinimbang, hinati." Kung sila lang, walang saysay ang mga ito. Pero ibinigay ng Diyos kay Daniel ang kahulugan.

MENE: "Binilang ng Diyos ang mga araw ng iyong paghahari at winakasan na ito" (t. 26). Akala ni Belshazzar, tuloy-tuloy lang ang kanyang paghahari. Pero nabilang na ng Diyos ang bawat araw, at dumating na ang huli.

TEKEL: "Tinimbang ka sa timbangan at natagpuang kulang" (t. 27). Isa ito sa pinakamabigat na linya sa Bibliya. Inilagay ng Diyos ang buhay ng hari sa Kanyang perpektong timbangan. Ang lahat ng kanyang yaman, kapangyarihan, handaan, at kayabangan ay walang timbang.

PERES: "Hinati ang iyong kaharian at ibinigay sa mga Medo at Persiano" (t. 28).

Nakapagtataka, pinarangalan pa rin ni Belshazzar si Daniel gaya ng ipinangako niya. Pero huli na ang lahat. "Nang gabi ring iyon, pinatay si Belshazzar na hari ng mga Caldeo" (t. 30). Bumagsak ang dakilang lungsod ng Babilonia sa loob ng isang gabi, gaya ng sinabi ng Diyos.

Bawat isa sa atin ay titimbangin balang araw sa timbangan ng Diyos. At ang tapat na katotohanan ay lahat tayo, kung sa sarili lang natin, ay "matatagpuang kulang." Wala ni isa sa atin ang umaabot sa kabanalan ng Diyos.

Kaya napakagandang balita ng ebanghelyo. Tumapak si Jesus sa timbangan para sa atin. Ipinamuhay Niya ang perpektong buhay na hindi natin kayang ipamuhay at tinanggap Niya ang hatol na nararapat sa atin. Kapag nagtiwala tayo sa Kanya, nakikita tayo ng Diyos na nadaramitan ng Kanyang katuwiran. Kay Cristo, hindi na tayo natatagpuang kulang.$q$, $q$Itinuturo sa akin ng talatang ito na sinusukat ng Diyos ang buhay ko nang may perpektong katumpakan. Akala ni Belshazzar, marami pa siyang panahon, pero bilang na pala ang kanyang mga araw. Inaamin ko na madalas akong namumuhay na para bang lagi akong may bukas para ayusin ang kaugnayan ko sa Diyos, para patawarin ang isang tao, o para baguhin ang alam kong mali. Dahil alam kong binibilang ng Diyos ang mga araw ko, dapat ko nang itigil ang pagpapaliban sa pinakamahahalagang bagay.

Pinapakumbaba ako ng salitang TEKEL. Kung ilalagay ang buhay ko sa timbangan ng Diyos ngayon, nang hiwalay kay Cristo, matatagpuan itong kulang. Hindi kailanman mapapantayan ng aking mabubuting gawa, ng aking pagsisimba, at ng aking reputasyon ang timbang na iyon.

Pero dahil kay Jesus, hindi ko kailangang matakot sa timbangan. Ibinigay Niya sa akin ang Kanyang katuwiran. Dahil sa biyayang ito, sisikapin kong mamuhay nang may pasasalamat, hindi nang may takot.

Pinaaalala rin sa akin na maging tapat sa sarili kong "pagtitimbang." Patas ba ang pagsukat ko sa iba? Tapat ba ako sa aking trabaho, negosyo, at mga salita?

Ngayong linggo, aayusin ko ang isang bagay na matagal ko nang ipinagpapaliban, paghingi man ng tawad, pagbabayad ng utang, o isang hakbang ng pagsunod, dahil hindi ko alam kung ilang araw na ang binilang ng Diyos para sa akin.$q$, $q$Matuwid na Diyos, binibilang po Ninyo ang mga araw ko at tinitimbang N'yo ang bawat puso. Inaamin ko po na sa sarili ko ay kulang ako sa Inyong kaluwalhatian. Salamat po sa pagpapadala Ninyo kay Jesus para tumayo sa aking lugar at damitan ako ng Kanyang katuwiran. Dahil sa Kanya, hindi ako natatagpuang kulang. Tulungan po Ninyo akong mamuhay nang may pasasalamat at pagmamadali, hindi sinasayang ang mga araw na ibinigay N'yo sa akin. Gawin po Ninyo akong tapat sa lahat ng aking pakikitungo, at tulungan po Ninyo akong gawin ngayon ang hindi ko dapat ipagpaliban hanggang bukas. Sa pangalan ni Jesus, amen.$q$, $q$Ngayong linggo, pinanood natin kung paano hinarap ng Diyos ang dalawang mapagmataas na hari. Noong Lunes, nanaginip si Nebuchadnezzar ng isang malaking punong pinutol, at ang tuod lang ang naiwan sa lupa. Noong Martes, buong pagmamahal pero buong tapang na sinabi ni Daniel sa hari ang katotohanan at hinikayat itong magsisi. Noong Miyerkoles, nagyabang ang hari, "Ako ang gumawa nito," at pinakumbaba siya ng Diyos hanggang tumingala siya sa langit at pinuri ang Kataas-taasan. Noong Huwebes, kinutya ng kahalili niyang si Belshazzar ang Diyos sa isang lasing na handaan, at may kamay na sumulat sa pader. Noong Biyernes, sinabi sa kanya ni Daniel, "Alam mo na ang lahat ng ito," pero hindi mo pinakumbaba ang iyong puso. At ngayong araw, binasa natin ang hatol: tinimbang sa timbangan at natagpuang kulang. Bumagsak ang Babilonia nang gabi ring iyon.

Dadalhin tayo ng susunod na linggo sa Pasko. Makikita natin si Daniel, matanda na ngayon, na patuloy na nananalangin gaya ng dati, kahit nangangahulugan ito ng yungib ng mga leon. Pagkatapos, sa mismong araw ng Pasko, babasahin natin ang pangitain ni Daniel tungkol sa "Isang tulad ng Anak ng Tao" na dumarating sa mga ulap para tanggapin ang walang-hanggang kaharian. 🏁$q$),
  (DATE '2026-12-21', $q$Walang Matagpuan$q$, $q$Anim na taon nang ingat-yaman ng kooperatiba ng mga magsasaka si Rosalie. Asawa siya ng isang magsasaka ng palay na dalawang taon lang ang natapos sa kolehiyo, pero inaalagaan niya ang mga libro na parang bangko. Nakasulat ang bawat pisong pumapasok. May resibo ang bawat pisong lumalabas. Tuwing ikatlong buwan, nagpapaskil siya ng isang simpleng ulat sa bulletin board ng opisina ng kooperatiba para makita ng lahat ng miyembro.

Nang magsimulang pag-usapan ng board ng kooperatiba na gawin siyang general manager, hindi natuwa ang ilan. May sarili nang kandidato ang dalawang board member na sina Celso at Ramir, isang kamag-anak ni Celso. Nagsimula silang magbulungan.

"Bakit ang tahimik ng treasurer?" tanong nila sa mga pulong. "Baka may itinatago siya. Dapat magpa-audit tayo sa labas."

Hindi nakipagtalo si Rosalie. "Sige po," sabi niya. "Ituloy n'yo po."

Kumuha ang kooperatiba ng isang auditor mula sa lungsod. Sa loob ng dalawang linggo, sinuri niya ang anim na taon ng mga rekord: mga ledger, bank statement, resibo, at mga papeles ng pautang. Bawat ilang araw, kinukumusta siya nina Celso at Ramir. "May nakita na ba?"

Sa general assembly, tumayo ang auditor para iulat ang kanyang natuklasan. Punô ang bulwagan. Nakaupo sina Celso at Ramir sa unang hanay.

"Marami na akong na-audit na kooperatiba," sabi ng auditor. "Kadalasan, may nakikita ako: nawawalang resibo, hindi maipaliwanag na pag-withdraw, pabayang pagkukuwenta. Dito, wala akong nakita." Itinaas niya ang isang makapal na folder. "Naitala ang bawat sentimo. Sa totoo lang, hindi pa ako nakakakita ng ganito kalinis na libro."

Nagpalakpakan ang bulwagan. Napayuko si Rosalie sa kanyang mga kamay, nahihiya.

Maagang umalis sina Celso at Ramir.

Nang gabing iyon, dumaan sa bahay niya ang isang matandang magsasakang nagngangalang Mauricio, may dalang isang supot ng sariwang itlog. "Ma'am Rosalie," sabi niya, "naghanap sila ng dumi. Ang tanging nakita nila ay ang katotohanan."$q$, $q$Bumagsak na ang Babilonia, at bagong imperyo na ang namamahala. Inayos ni Haring Dario ang kanyang kaharian sa ilalim ng 120 opisyal at tatlong pinakamataas na administrador. Isa sa kanila si Daniel, na nasa edad otsenta na. Kahit sa edad na ito, si Daniel ay "nangibabaw" nang husto kaya plano ng hari na ilagay siya sa ibabaw ng buong kaharian.

Dahil dito, nainggit ang ibang mga opisyal. Kaya naghanap sila ng kahit ano, anumang bagay na magagamit laban sa kanya. Sinuri nila ang kanyang trabaho, pananalapi, at mga desisyon. Ibinibigay ng talata 4 ang resulta: "wala silang natagpuang paratang o katiwalian, dahil siya'y mapagkakatiwalaan, at walang kapabayaan o katiwaliang natagpuan sa kanya."

Napakagandang patotoo! Walang suhol. Walang shortcut. Walang katamaran. Naglingkod si Daniel sa ilalim ng maraming hari at imperyo, at malinis ang kanyang rekord.

Kaya binago ng kanyang mga kaaway ang kanilang taktika. "Hindi tayo kailanman makatatagpo ng paratang laban kay Daniel, maliban kung may matagpuan tayo laban sa kanya tungkol sa kautusan ng kanyang Diyos" (t. 5). Alam nila na ang tanging paraan para mabitag si Daniel ay sa pamamagitan ng kanyang katapatan sa Diyos.

Binola nila ang hari para pumirma sa isang batas: sa loob ng tatlumpung araw, walang sinumang maaaring manalangin kaninuman maliban sa hari. Ihahagis sa mga leon ang sinumang sumuway. At dahil batas ito ng mga Medo at Persiano, hindi na ito mababago kailanman.

Ito ang layunin para sa bawat mananampalataya: mamuhay sa paraang ang tanging "paratang" na maibibintang sa atin ay ang ating debosyon sa Diyos. Ang integridad sa ating trabaho at pananalapi ay hindi lang nagpoprotekta sa atin. Itinuturo nito ang mga tao sa Diyos na ating pinaglilingkuran.

Kung may susuri sa buhay mo ngayon, ano ang matatagpuan nila?$q$, $q$Itinuturo sa akin ng talatang ito na ang integridad ay isa sa pinakamatibay na patotoong maibibigay ko. Sinuri ng mga kaaway ni Daniel ang kanyang trabaho, pera, at mga gawi at wala silang natagpuan. Ang tanging magagamit nila laban sa kanya ay ang kanyang katapatan sa Diyos. Inaamin ko na hindi laging makalulusot ang buhay ko sa ganoong uri ng pagsusuri. May maliliit na shortcut akong ginagawa, maliliit na pagmamalabis na sinasabi ko, at maliliit na bahagi ng katamaran na pinalulusot ko.

Dapat kong hilingin sa Panginoon na siyasatin ako at ipakita ang anumang bagay sa aking trabaho, pananalapi, o mga salita na magdadala ng kahihiyan sa Kanyang pangalan. Dahil alam kong pinapanood ng mga tao kung paano namumuhay ang mga Cristiano, sisikapin kong maging mapagkakatiwalaan sa maliliit at malalaking bagay.

Pinaaalala rin sa akin na ang katapatan ay maaaring magdulot ng inggit sa iba. Walang ginawang masama si Daniel, pero may mga nagbalak laban sa kanya. Dahil dito, hindi ako magugulat kung may magalit sa aking integridad, at hindi ako tutugon nang may kapaitan.

Ngayong linggo, pipili ako ng isang bahagi kung saan ako naging pabaya, pagtupad man sa aking salita, paghawak ng pera, o mahusay na paggawa ng aking trabaho, at aayusin ko ito. Gusto kong ang buhay ko ay maging bukas na aklat na tumuturo sa Diyos.$q$, $q$Tapat na Diyos, nais ko pong mamuhay nang may integridad sa harap Ninyo at sa harap ng mga tao. Siyasatin po Ninyo ang puso ko at ipakita ang anumang bahagi ng kawalang-katapatan, kapabayaan, o pakikipagkompromiso. Tulungan po Ninyo akong maging mapagkakatiwalaan sa pinakamaliliit na bagay. Kapag naghahanap ang iba ng mali sa akin, nawa'y pusong nakatalaga sa Inyo lamang ang kanilang matagpuan. Ingatan po Ninyo ako mula sa kapaitan kapag hindi ako nauunawaan o kinakalaban. Nawa'y maging malinaw at tapat na saksi ang buhay ko sa Diyos na aking pinaglilingkuran. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-22', $q$Gaya ng Dati$q$, $q$Gabi-gabi, eksaktong alas-otso, binabasahan ni Lolo Simeon ang apo niyang si Ethan. Umuupo siya sa lumang upuang yantok sa tabi ng bintana, isinusuot ang makapal niyang salamin, at binubuksan ang anumang librong pinili ni Ethan. Pagkatapos, bago matulog si Ethan, lagi niyang itinatanong ang parehong tanong: "Ano ang pinakamagandang bahagi ng araw mo?"

Ganoon na ito mula noong apat na taong gulang si Ethan.

Nang siyam na taong gulang na si Ethan, nagkagulo ang lahat sa bahay. Gabi-gabing nag-aaway ang kanyang mga magulang, at pagkatapos ay umalis ang kanyang tatay. Nagsimulang mag-double shift sa pabrika ang kanyang nanay. Tensyonado at tahimik ang bahay. Tumigil na sa pagsasalita si Ethan sa paaralan. May mga gabing hindi siya kumakain.

Sinabi ng mga kamag-anak kay Lolo Simeon, "Hayaan mo na muna ang bata. Masyado siyang nalulungkot para sa mga kuwento ngayon."

Pero pagsapit ng alas-otso noong unang kakila-kilabot na gabing iyon, umupo si Lolo Simeon sa upuang yantok, isinuot ang kanyang salamin, at binuksan ang isang libro. Nanatili si Ethan sa kanyang kuwarto. Nagbasa pa rin nang malakas si Lolo Simeon, sapat ang lakas para marinig ni Ethan sa likod ng pinto.

Kinabukasan ng gabi, ginawa niya ulit ito. At sa sumunod pa.

Sa ikalimang gabi, lumangitngit ang pinto. Lumabas si Ethan, umupo sa sahig sa tabi ng upuan, at isinandal ang ulo sa tuhod ng kanyang lolo. Nagpatuloy sa pagbabasa si Lolo Simeon na para bang walang nangyari.

Sa pagtatapos ng kabanata, mahina niyang itinanong, "Ano ang pinakamagandang bahagi ng araw mo?"

Matagal na natahimik si Ethan. Pagkatapos ay sinabi niya, "Ito po."

Makalipas ang maraming taon, sa kanyang pagtatapos sa kolehiyo, ikinuwento ito ni Ethan sa harap ng kanyang mga kaklase at guro. "Nang magbago ang lahat," sabi niya, "hindi nagbago ang lolo ko. Patuloy lang niyang ginawa ang lagi niyang ginagawa. Iyon ang nagligtas sa akin."$q$, $q$"Nang malaman ni Daniel na napirmahan na ang kasulatan..." (t. 10). Alam ni Daniel ang batas. Alam niya ang parusa. At ano ang ginawa niya? Umuwi siya, binuksan ang kanyang mga bintana na nakaharap sa Jerusalem, lumuhod, "nanalangin, at nagpasalamat sa kanyang Diyos, gaya ng ginagawa niya noon."

Pansinin ang tatlong bagay tungkol sa buhay-panalangin ni Daniel. Una, regular ito: tatlong beses sa isang araw. Hindi pang-emergency na button ang panalangin para kay Daniel. Ito ang ritmo ng kanyang buhay. Ikalawa, kasama rito ang pasasalamat, kahit sa araw na nalaman niyang maaari siyang mamatay. Ikatlo, ginawa niya ito "gaya ng ginagawa niya noon." Hindi siya nagtago, at hindi rin siya nagpakitang-gilas ng paglaban. Tumanggi lang siyang baguhin ang kanyang tapat na gawi.

Kaya hindi siya natinag ng krisis. Ang lakas na kailangan niya sa yungib ng mga leon ay nabuo sa libu-libong karaniwang araw ng panalangin.

Naghihintay ang kanyang mga kaaway. Nahuli nila siyang nananalangin at nagmadaling pumunta sa hari. Si Dario ay "labis na nabagabag" (t. 14) at buong araw na naghanap ng paraan para makalusot, pero nakulong siya sa sarili niyang batas. Sa wakas, ibinigay niya ang utos. Inihagis si Daniel sa yungib, at tinakpan ng bato at tinatakan ang pasukan.

Pero pakinggan ang sinabi ng hari: "Iligtas ka nawa ng iyong Diyos, na patuloy mong pinaglilingkuran!" (t. 16). Kahit ang paganong haring ito ay napansin na hindi nagbabago ang pananampalataya ni Daniel.

Ang mga gawing binubuo mo ngayon ang magdadala sa iyo sa krisis ng bukas. Huwag nang hintayin ang yungib ng mga leon bago matutong manalangin.$q$, $q$Itinuturo sa akin ng talatang ito na ang lakas na kailangan ko para sa krisis ng bukas ay nabubuo sa karaniwang katapatan ngayon. Hindi biglang naging taong mapanalanginin si Daniel nang mapirmahan ang batas. Ilang taon na siyang nananalangin nang tatlong beses sa isang araw. Inaamin ko na madalas ay pabagu-bago ang buhay-panalangin ko. Mas nananalangin ako kapag may problema at mas kaunti kapag maayos ang lahat.

Dapat kong hilingin sa Panginoon na tulungan akong bumuo ng matatag na gawi ng panalangin, pagbabasa ng Bibliya, at pasasalamat, hindi bilang relihiyosong tungkulin, kundi bilang regular na ritmo ng aking kaugnayan sa Kanya.

Lubos akong naantig na nagpasalamat si Daniel sa mismong araw na nalaman niyang maaari siyang mamatay. Dahil alam kong ang pasasalamat ay makapangyarihang sandata laban sa takot, sisikapin kong magpasalamat sa Diyos kahit madilim ang mga kalagayan.

Hinahamon din ako ng mga salitang "gaya ng ginagawa niya noon." Kapag dumarating ang panggigipit, natutukso akong itago ang aking pananampalataya o kaya'y ipagmalaki ito. Wala sa dalawa ang ginawa ni Daniel. Nanatili lang siyang tapat.

Ngayong linggo, magtatakda ako ng regular na oras at lugar para makipagkita sa Diyos araw-araw, at iingatan ko ito. Gusto kong maging ganoon katatag ang aking pananampalataya na kahit ang mga tao sa paligid ko ay makapagsasabing patuloy kong pinaglilingkuran ang Diyos.$q$, $q$Panginoon, turuan po Ninyo akong manalangin tulad ni Daniel, nang tapat, regular, at may pusong mapagpasalamat. Patawarin po Ninyo ako sa pagturing ko sa panalangin na parang pang-emergency na button sa halip na araw-araw na pakikipag-usap sa Inyo. Tulungan po Ninyo akong bumuo ng mga gawi ng debosyon na magpapanatili sa aking matatag kapag dumarating ang mga pagsubok. Kapag tumitindi ang panggigipit, bigyan po Ninyo ako ng tapang na huwag itago ang aking pananampalataya at ng kababaang-loob na huwag itong ipagmalaki. Nawa'y makita ng mga tao na patuloy ko Kayong pinaglilingkuran, sa mabubuti at mahihirap na panahon. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-23', $q$Mga Bibig na Isinara$q$, $q$Labinlimang taon nang nagmamaneho ng tricycle si Ramil sa kanilang bayan. Alam ng lahat sa terminal na siya ang nagsasauli ng mga naiwang cellphone at wallet. "Honest Ramil," biro sa kanya ng ibang drayber.

Kaya hindi siya makapaniwala nang dumating sa terminal ang isang babae isang umaga, sumisigaw at tinuturo siya.

"Siya 'yon! Ninakaw niya ang bag ko! Nandoon ang sahod ko!"

Sumakay ang babae sa tricycle niya noong nakaraang gabi. Pag-uwi niya, sabi niya, wala na ang kanyang bag. Nagkumpulan ang mga tao. Umiling ang ilan. Nagsimula namang mag-post sa social media ang iba: "Mag-ingat sa tricycle driver na ito!" Daan-daang beses na na-share ang isang post, kasama ang litrato ni Ramil.

Pinapunta si Ramil ng pulis para tanungin. Nang gabing iyon, hindi siya makatulog. Nakaupo sa tabi niya sa bangko sa labas ng kanilang bahay ang asawa niyang si Divina, hawak ang kanyang kamay. Tumawag at nag-message ang mga suki niyang pasahero para sabihing naniniwala sila sa kanya. Ang presidente ng kanilang terminal, isang mas matandang drayber na nagngangalang Fernando, ay pumunta sa barangay hall kinaumagahan at humingi ng CCTV footage mula sa kalye kung saan bumaba ang babae.

Pagsapit ng tanghali, tumatakbong dumating si Fernando sa terminal, iwinawagayway ang kanyang cellphone.

Malinaw ang video. Bumaba ang babae sa tricycle ni Ramil na nakasabit sa balikat ang bag. Dalawampung minuto siyang nakipagkuwentuhan sa isang kaibigan sa kanto, inilapag ang bag sa isang bangko, at umalis nang hindi ito dala. Makalipas ang ilang minuto, dinampot ito ng isang estranghero.

Bumalik ang babae sa terminal kinabukasan nang nakayuko. Humingi siya ng tawad kay Ramil sa harap ng lahat at binura ang kanyang post. Natahimik ang mga taong nag-share nito.

Tumango lang si Ramil. "Okay lang po, ma'am. Sana po mahanap n'yo ang bag n'yo."

Pagkatapos ay bumalik na siya sa trabaho.$q$, $q$Kakila-kilabot ang gabing pinagdaanan ng hari. Tumanggi siyang kumain, tumanggi sa libangan, at hindi makatulog. Sa unang liwanag ng bukang-liwayway, tumakbo siya sa yungib at sumigaw, "O Daniel, lingkod ng buhay na Diyos, nailigtas ka ba ng iyong Diyos...?" (t. 20).

Mula sa kadiliman, narinig ang mahinahong tinig ni Daniel: "Ipinadala ng aking Diyos ang Kanyang anghel at isinara ang bibig ng mga leon. Hindi nila ako sinaktan" (t. 22). Buong gabing kasama ng matanda ang mga gutom na leon at lumabas siya nang walang kahit isang galos. Sinasabi sa atin ng talata 23 kung bakit: "dahil nagtiwala siya sa kanyang Diyos."

Kawili-wili na malamang ay mas payapa pa si Daniel nang gabing iyon kaysa sa hari. Hindi laging inaalis ng pananampalataya ang mga leon, pero nagbibigay ito ng kapayapaan sa loob ng yungib.

Pagkatapos ay dumating ang isang mabigat na bahagi ng kuwento. Inihagis ng hari sa yungib ang mga nagparatang kay Daniel, kasama ang kanilang mga asawa at anak, at agad silang pinatay ng mga leon. Malupit na desisyon ito ng hari, ayon sa malulupit na kaugalian noong panahong iyon. Tapat itong itinatala ng Bibliya, pero hindi nito ito pinupuri. Sinasabi mismo ng kautusan ng Diyos na hindi dapat parusahan ang mga anak dahil sa mga kasalanan ng kanilang mga magulang. Ang ipinapakita ng talata ay nagbalak ng kamatayan ang mga nagparatang para sa isang taong walang sala, at bumalik sa kanila ang bitag na inilatag nila.

Pagkatapos ay nagpadala si Dario ng utos sa buong imperyo: ang Diyos ni Daniel "ang buhay na Diyos, at Siya'y nananatili magpakailanman... Siya'y nagliligtas at sumasagip" (t. 26–27).

Matagal pagkatapos ni Daniel, may isa pang walang-salang Lalaki na hinatulan sa pamamagitan ng isang sabwatan. Inilagay Siya sa isang libingan, at tinakpan ng bato at tinatakan ito. Pero sa ikatlong araw, iginulong ang bato. Lumabas si Jesus nang buhay, at hindi Siya napigilan kahit ng kamatayan mismo.$q$, $q$Itinuturo sa akin ng talatang ito na kaya ng Diyos na isara ang bibig ng mga leon, mga totoong leon man o ang mga "leon" ng takot, maling paratang, at panganib sa sarili kong buhay. Buong gabing nasa yungib si Daniel, pero hindi siya nag-iisa at hindi siya napinsala. Inaamin ko na kapag nakaharap ako sa nakakatakot na sitwasyon, madalas ay nawawala na ang aking kapayapaan bago pa man dumating ang panganib.

Namangha ako na nakatulog si Daniel sa gitna ng mga leon habang hindi makatulog ang hari sa kanyang palasyo. Dahil alam kong nagmumula ang kapayapaan sa pagtitiwala, hindi sa kumportableng kalagayan, dapat kong hilingin sa Panginoon na bigyan ako ng parehong mahinahong pagtitiwala sa Kanya.

Pinaaalala rin sa akin na nakikita ng Diyos kapag ako'y pinararatangan nang mali. Hindi ko kailangang labanan ang bawat laban o ipagtanggol ang sarili nang may galit. Dahil ang Diyos ang aking tagapagtanggol, sisikapin kong sagutin ang mga paratang nang may pagtitiis at ipaubaya sa Kanyang mga kamay ang aking reputasyon.

Sa huli, nakikita ko si Jesus sa kuwentong ito: ang Isang walang sala, ang batong tinatakan, at ang pagliligtas sa madaling-araw. Ang Kanyang muling pagkabuhay ang nagbibigay sa akin ng pag-asa na walang yungib, walang libingan, at walang kasinungalingan ang may huling salita.

Ngayong linggo, dadalhin ko sa Diyos sa panalangin ang pinakamalaki kong takot, at pipiliin kong ipagkatiwala ito sa Kanya.$q$, $q$Buhay na Diyos, Kayo po ang nagliligtas at sumasagip, at walang anumang napakahirap para sa Inyo. Salamat po sa pagsasara Ninyo ng bibig ng mga leon sa buhay ko, kahit ang mga hindi ko alam na naroon pala. Kapag natatakot ako, bigyan po Ninyo ako ng kapayapaan ni Daniel. Kapag pinararatangan ako nang mali, tulungan po Ninyo akong magtiwala na ipagtatanggol N'yo ako. Salamat po kay Jesus, ang Isang walang sala na lumabas mula sa tinatakang libingan. Dahil buhay Siya, kaya kong harapin ang bawat yungib nang may pag-asa. Nawa'y akayin ng buhay ko ang iba na manginig sa harap Ninyo at magtiwala rin sa Inyo. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-24', $q$Kapag Nagngangalit ang Dagat$q$, $q$Bisperas ng Pasko noon, at nakahanda na ang mesa ng Noche Buena: hamon, queso de bola, spaghetti, at isang malaking plato ng lumpia. Pero bakante ang upuan sa kabisera ng mesa, at may isang cellphone na nakasandal sa pitsel ng juice.

Nasa screen ang kanilang nanay na si Analyn. Caregiver siya sa isang lungsod na libu-libong kilometro ang layo. Madilim ang bintana sa likod niya. Nakangiti siya, pero halata ng kanyang mga anak na pagod siya.

"Merry Christmas, mga anak!" sabi niya.

Labinlimang taong gulang ang panganay niyang si Patricia. Buong linggo itong nagbabasa ng balita. May kaguluhan sa bansang pinagtatrabahuhan ng kanyang nanay: mga protesta, curfew, at usap-usapan ng mas marahas na mangyayari. Gabi-gabi bago matulog, tinitingnan ni Patricia ang cellphone niya para siguraduhing nag-message ang nanay niya.

"Ma," tanong ni Patricia sa wakas, "safe po ba kayo? Nakakatakot po ang balita."

Saglit na naglaho ang ngiti ni Analyn. "Maingay talaga rito," pag-amin niya. "May mga sirena tuwing gabi. Galit ang mga tao. Hindi ako magsisinungaling, anak. Minsan, natatakot ako."

Natahimik ang mesa. Tumigil sa pagkain ng spaghetti ang bunsong si Gabriel.

Pagkatapos ay inilapit ni Analyn ang mukha sa camera. "Pero makinig kayo. Bago ako umalis ng bahay, may sinabi sa akin ang Lola n'yo. Sabi niya, 'Laging magiging maingay at mapanganib ang mundo. Pero kahit kailan, hindi ito nawala sa kamay ng Diyos.' Kaya gabi-gabi, kapag naririnig ko ang mga sirena, iyon ang inaalala ko."

Itinaas niya ang isang maliit at gamit na gamit nang kuwaderno. "Araw-araw, isinusulat ko rito ang isang bagay na ipinagpapasalamat ko. Gusto n'yo bang marinig ang para sa araw na ito?"

Tumango si Patricia habang pinupunasan ang kanyang mga mata.

"Ngayong araw," sabi ni Analyn, nakangiti ulit, "nakikita ko kayong lahat sa bisperas ng Pasko."

Iniabot ni Patricia ang kamay at hinawakan ang screen. Sa labas, nagsimulang pumutok ang mga paputok ng mga kapitbahay.$q$, $q$Ngayong araw, nagbabago ng direksyon ang aklat ng Daniel. Ang unang anim na kabanata ay mga kuwento tungkol sa buhay ni Daniel. Ang huling anim ay nagtatala ng mga pangitaing ibinigay sa kanya ng Diyos tungkol sa hinaharap. Dumating ang pangitaing ito ilang taon bago pa, noong panahon ng paghahari ni Belshazzar.

Nakita ni Daniel "ang apat na hangin ng langit na nagpapagalaw sa malawak na dagat" (t. 2). Sa Bibliya, ang maunos na dagat ay madalas na larawan ng magulo at hindi mapakaling mundo ng mga bansa. Mula rito ay lumabas ang apat na nakakatakot na hayop: isang leong may pakpak ng agila, isang osong may mga tadyang sa bibig, isang leopardong may apat na pakpak at apat na ulo, at isang ikaapat na hayop na "kakila-kilabot at napakalakas," may mga ngiping bakal at sampung sungay.

Pagkatapos ay lumitaw ang isang maliit na sungay, binunot ang tatlong iba pa, may mga matang tulad ng sa tao "at isang bibig na nagsasalita ng mga salitang mapagmataas" (t. 8).

Ano ang ibig sabihin nito? Bukas at sa Sabado, magpapaliwanag pa ang sugo ng Diyos. Sa ngayon, pansinin na kahawig ng pangitaing ito ang panaginip ni Nebuchadnezzar tungkol sa rebulto sa kabanata 2. Maraming guro ng Bibliya ang nakakakita ng parehong apat na kaharian: Babilonia, Medo-Persia, Gresya, at Roma. Pero nagbago ang larawan. Sa kabanata 2, ang mga kaharian ay mukhang isang nakasisilaw na rebultong yari sa mamahaling metal. Ganyan ang tingin ng mga imperyo ng tao sa kanilang sarili. Sa kabanata 7, mukha silang mababangis at nanlalamong hayop. Ganyan sila nakikita ng Diyos kapag naghahari sila nang wala Siya.

Ngayong bisperas ng Pasko, alalahanin na isinilang si Jesus sa panahon ng ikaapat na kahariang iyon, ang Roma. Dumating Siya sa isang mundong punô ng mga halimaw: marahas na mga pinuno, mabibigat na buwis, at takot. Pero dumating pa rin Siya. Habang lalong umiingay ang mundo, lalo nating kailangang alalahanin na nagngangalit lang ang dagat dahil pinahintulutan ito ng Diyos, at may Hari Siyang handang maghari.$q$, $q$Itinuturo sa akin ng talatang ito na madalas ay mararamdaman kong ang mundo ay parang nagngangalit na dagat na punô ng nakakatakot na mga halimaw. Nakita ni Daniel ang makapangyarihang mga imperyong bumabangon, dumudurog sa iba, at nagsasalita ng mga salitang mapagmataas. Inaamin ko na minsan ay pinupuno ako ng takot ng balita. Ang mga digmaan, katiwalian, karahasan, at kawalang-katiyakan ay nagpapaisip sa akin kung may may hawak pa ba.

Pero naaaliw ako dahil alam kong ipinakita ng Diyos kay Daniel ang mga bagay na ito nang maaga. Walang anuman sa kasaysayan ang nakagugulat sa Diyos. Bumabangon lang ang mga halimaw sa loob ng hangganang pinahihintulutan Niya, at maikli ang kanilang panahon.

Ngayong bisperas ng Pasko, pinaaalala sa akin na isinilang si Jesus sa isang mundong halos katulad nito, sa ilalim ng isang malupit at makapangyarihang imperyo. Hindi Niya hinintay na maging payapa muna ang mundo bago Siya dumating. Dumating Siya sa gitna ng kaguluhan para magdala ng kapayapaang hindi kayang ibigay ng mundo.

Dahil dito, sisikapin kong huwag hayaang nakawin ng ingay ng mundo ang aking kapayapaan o kagalakan ngayong panahon ng Pasko. Kapag nababalisa ako dahil sa balita, gagawin kong panalangin ang aking pag-aalala.

Ngayong gabi, bago ako matulog, papangalanan ko ang isang bagay na ipinagpapasalamat ko, at pasasalamatan ko ang Diyos na dumating na ang Prinsipe ng Kapayapaan.$q$, $q$Panginoon, madalas pong maingay, mapanganib, at punô ng takot ang mundo. Pero hindi N'yo ito kailanman nabitawan. Salamat po na nakikita N'yo ang simula hanggang sa wakas at walang kapangyarihang bumabangon nang walang pahintulot N'yo. Ngayong bisperas ng Pasko, salamat po sa pagpapadala Ninyo kay Jesus sa aming sira at maingay na mundo. Kapag natatakot ako, ipaalala po Ninyo na dumating na ang Prinsipe ng Kapayapaan at Siya ay naghahari. Punuin po Ninyo ng Inyong kapayapaan ang aking puso at tahanan ngayong gabi. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-25', $q$Ang Haring Bumaba$q$, $q$Noong bisperas ng Pasko, punô ang huling bus papuntang probinsya. Nagsiksikan sa bawat upuan ang mga pamilyang may dalang balikbayan box, mga estudyanteng uuwi para sa bakasyon, at mga manggagawang may dalang mga supot ng regalo. Ang bagong konduktor, isang lalaking may puting buhok na nakasuot ng kupas na damit ng kompanya, ay isa-isang dinaanan ang pasilyo habang nagbubutas ng mga tiket.

Tinulungan niya ang isang matandang babae na iakyat ang mabigat nitong kahon sa lalagyan. Ibinigay niya ang sarili niyang bote ng tubig sa nanay ng isang umiiyak na batang paslit. Nang mapagtanto ng isang batang estudyante na kulang siya ng limampung piso, tahimik niya itong binayaran mismo. Pasado hatinggabi, nang huminto ang bus sa isang kainan sa tabi ng daan, ibinili niya ng mainit na kape ang drayber at tumayo sa labas sa lamig habang kumakain ang lahat.

Dalawampung taon nang nagtatrabaho sa bus company ang drayber na si Elmer. Gusto niya ang bagong konduktor pero medyo nagtataka siya rito. "Bago ka lang, Tay?" tanong niya. "Saan ka naka-assign dati?"

Ngumiti lang ang matanda. "Ah, kung saan-saan."

Makalipas ang dalawang araw, nagdaos ang kompanya ng year-end gathering para sa lahat ng empleyado nito. Nakaupo sa mahahabang mesa ang mga drayber, konduktor, at mekaniko. Pagkatapos ay ipinakilala ang may-ari ng kompanya: si Mr. Lorenzo Dizon, isang lalaking hindi pa nakikita nang personal ng karamihan sa kanila.

Humakbang papunta sa mikropono ang konduktor na may puting buhok.

Muntik nang mabitawan ni Elmer ang kanyang plato.

"Gusto kong maintindihan ang trabaho ninyo," sabi ni Mr. Dizon. "Kaya hindi ako nanatili sa opisina ko. Bumaba ako para sumakay kasama ninyo. Binuhat ko ang mga kahon. Tumayo ako sa lamig. At ngayon, naiintindihan ko na ang ginagawa ninyo araw-araw."

Pagkatapos ay inanunsyo niya ang mga bagong benepisyo para sa bawat drayber at konduktor ng kompanya.

Napailing si Elmer habang tumatawa. "Buong gabi," sabi niya sa mekanikong katabi niya, "kausap ko pala ang amo at hindi ko alam."$q$, $q$Maligayang Pasko! Sa araw na ito, itinataas ni Daniel ang ating mga mata mula sa mga halimaw sa lupa patungo sa silid ng trono sa langit.

"Inilagay ang mga trono, at umupo ang Matanda sa mga Araw" (t. 9). Ito ang Diyos mismo, walang hanggan at dalisay, may kasuotang kasimputi ng niyebe, tronong naglalagablab sa apoy, at di-mabilang na mga anghel na naglilingkod sa Kanya. "Nagtipon ang hukuman, at binuksan ang mga aklat" (t. 10). Maingay ang mapagmataas na mga halimaw, pero ngayon ay nakaupo na ang hukuman ng langit para humatol, at inaalis ang kanilang kapangyarihan.

Pagkatapos ay nakita ni Daniel ang pinakakahanga-hangang tanawin sa lahat: "Isang tulad ng Anak ng Tao na dumarating kasama ng mga ulap ng langit" (t. 13). Mukha Siyang tao, tulad ng isang anak ng tao, pero dumarating Siya sa mga ulap, na sa Kasulatan ay paraan ng pagdating ng Diyos mismo. Lumapit Siya sa Matanda sa mga Araw at tinanggap ang "kapangyarihan, kaluwalhatian, at paghahari" at isang kaharian "na hindi kailanman mawawasak" (t. 14).

Umahon ang mga halimaw mula sa nagngangalit na dagat. Ang Haring ito ay nagmula sa langit. Nilamon ng mga halimaw ang mga tao. Ang Haring ito ay paglilingkuran ng bawat bansa.

Sino Siya? Si Jesus mismo ang sumagot sa tanong na iyan. "Anak ng Tao" ang paborito Niyang tawag sa Kanyang sarili. Sa Kanyang paglilitis, sinabi Niya sa pinakapunong pari, "Makikita ninyo ang Anak ng Tao na nakaupo sa kanan ng Kapangyarihan at dumarating kasama ng mga ulap ng langit" (Marcos 14:62).

Iyan ang himala ng Pasko. Ang Isang darating balang araw sa kaluwalhatian sa mga ulap ay unang bumaba nang may kababaang-loob, isinilang sa isang sabsaban. Naging tunay Siyang tao, isang Anak ng Tao, para mailigtas Niya tayo at maibahagi sa atin ang Kanyang walang-hanggang kaharian.$q$, $q$Itinuturo sa akin ng talatang ito na ang sanggol na isinilang sa Betlehem ay ang Hari ng isang walang-hanggang kaharian. Sa araw ng Pasko, madaling isipin lang ang sabsaban at isang matamis na sanggol. Pero ipinapakita sa akin ni Daniel kung sino talaga ang batang iyon: ang Anak ng Tao na tumatanggap ng lahat ng kapangyarihan, kaluwalhatian, at paghahari mula sa Matanda sa mga Araw.

Namamangha ako na piniling bumaba nang napakapakumbaba ng maluwalhating Haring ito. Hindi Siya nanatiling malayo sa langit. Dumating Siya sa ating mundo, nagkatawang-tao, at lumakad kasama ng mga karaniwang tao. Dahil dito, alam kong nauunawaan Niya ang aking kahinaan, mga pakikibaka, at sakit.

Dahil alam kong babalik Siya sa mga ulap ng langit, hindi ako dapat mamuhay na para bang tungkol lang sa mga regalo at pagkain ang Pasko. Sisikapin kong ipagdiwang ang araw na ito nang ang pagsamba ang nasa gitna, ibinibigay sa aking Hari ang karangalang nararapat sa Kanya.

Gusto ko ring ibahagi ang mabuting balitang ito. Sa paligid ko ngayong araw ay may isang taong nag-iisa, nagdadalamhati, o malayo sa Diyos. Maghahanap ako ng isang taong mapagpapala, sa pamamagitan ng pagbisita, pagtawag, regalo, o isang simpleng salita tungkol sa Haring bumaba para sa atin.

Ngayong araw, yumuyukod ako sa harap ni Jesus, ang Anak ng Tao at Hari ng mga hari.$q$, $q$Matanda sa mga Araw, naghahari po Kayo sa kaluwalhatian at kabanalan magpakailanman. Salamat po sa pagpapadala Ninyo sa Inyong Anak, ang Anak ng Tao, para isilang para sa amin nang may kababaang-loob. Panginoong Jesus, bumaba po Kayo mula sa langit para kami ay maging bahagi ng Inyong walang-hanggang kaharian. Sinasamba ko po Kayo ngayong araw bilang aking Tagapagligtas at Hari. Punuin po Ninyo ng kagalakan at pasasalamat ang aming pagdiriwang, at panatilihin po Ninyong nakatuon sa Inyo ang aking puso. Gamitin po Ninyo ako ngayong araw para ibahagi ang Inyong pag-ibig sa isang taong nangangailangan nito. Dumating po Kayo agad, Panginoon, sa mga ulap ng langit. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-26', $q$Hindi Sila ang May Huling Salita$q$, $q$Nasa isang kanto malapit sa pampublikong paaralan ang maliit na panaderya ni Edna. Tuwing umaga bago magbukang-liwayway, nagluluto siya ng pandesal, ensaymada, at ng sikat niyang ube roll. Pumipila ang mga estudyante bago ang klase. Dumaraan ang mga magulang papunta sa trabaho.

Pagkatapos ay nagbukas ang isang malaking bakery chain ng sangay mismo sa tapat ng kalye.

Noong una, hindi nag-alala si Edna. May puwang naman para sa dalawa. Pero hindi patas lumaban ang bagong sangay. Ilang buwan nilang ibinaba ang presyo nang mas mababa pa sa kanya, nalulugi na lang para mapaalis siya. May nag-post ng mga pekeng review online, sinasabing nagkasakit daw ang mga estudyante dahil sa tinapay niya. Tatlong beses dumating ang isang health inspector sa loob ng isang buwan dahil sa mga reklamong walang pangalan.

Pumasa ang panaderya niya sa bawat inspeksyon. Pero nagawa na ang pinsala. Bumaba sa kalahati ang benta. Kinailangang pakawalan ni Edna ang isa sa dalawa niyang katulong. May mga gabing nakaupo siya sa walang-laman niyang tindahan pagkatapos magsara at umiiyak.

Sinasamahan siya ng asawa niyang si Ruben, isang mekaniko ng jeepney. "Ituloy mo lang ang pagluluto, Edna," sabi niya. "Ituloy mo lang ang pagluluto ng tapat na tinapay."

Kaya iyon ang ginawa niya. Hindi niya sinagot nang may galit ang mga pekeng review. Pinanatili niyang patas ang kanyang mga presyo, malinis ang kanyang tindahan, at sariwa ang kanyang tinapay. Patuloy na dumarating ang mga tapat niyang suki, kahit kumaunti sila.

Makalipas ang isang taon, lumabas na ang branch manager sa tapat ng kalye pala ang nasa likod ng mga pekeng review at reklamo. Tinanggal siya ng kompanya, humingi ito ng tawad sa publiko, at hindi nagtagal ay tuluyang isinara ang sangay.

Sa unang umaga matapos itong magsara, umabot hanggang kanto ang pila sa labas ng panaderya ni Edna. Ngumiti sa kanya ang isang guro na nasa unahan ng pila. "Hindi kami tumigil sa paniniwala sa inyo, Ma'am Edna."

Iniabot ni Edna sa kanya ang isang mainit na ube roll. "Mahabang taon iyon," sabi niya. "Pero hindi sila ang nagkaroon ng huling salita."$q$, $q$Labis na binagabag si Daniel ng kanyang pangitain. Kaya nagtanong siya sa isa sa mga nilalang sa langit na nakatayo sa malapit para ipaliwanag ito. Maikli ang sagot: "Ang apat na malalaking halimaw na ito ay apat na haring babangon mula sa lupa. Ngunit tatanggapin ng mga banal ng Kataas-taasan ang kaharian at aangkinin ito magpakailanman" (t. 17–18).

Gusto pang malaman ni Daniel ang higit pa tungkol sa ikaapat na halimaw at lalo na sa maliit na sungay na nagsasalita ng mapagmataas na mga salita. Nalaman niyang ang sungay na ito ay "magsasalita laban sa Kataas-taasan at aapihin ang mga banal," at susubukang baguhin ang mga itinakdang panahon at kautusan ng Diyos (t. 25). Nakikita ito ng maraming guro ng Bibliya bilang larawan ng huling kaaway ng bayan ng Diyos bago bumalik si Cristo. Nakikita naman dito ng iba ang bawat pinunong nagtataas ng sarili laban sa Diyos. Alinman dito, malinaw ang punto.

Haharapin ng bayan ng Diyos ang tunay na pagsalungat. Sinasabi ng talata 21 na nakipagdigma ang sungay laban sa mga banal "at nanaig laban sa kanila." Tapat iyan. Minsan, mukhang nananalo ang kasamaan.

Pero pansinin ang hangganan ng panahon: "isang panahon, mga panahon, at kalahating panahon" (t. 25). Sinukat at nilimitahan ang panahon ng kasamaan. Hindi ito tumatagal magpakailanman.

Pagkatapos: "Magtitipon ang hukuman, at aalisin ang kanyang kapangyarihan at lubusang wawasakin magpakailanman" (t. 26). At ibibigay ang kaharian "sa bayan, sa mga banal ng Kataas-taasan" (t. 27).

Kahapon, nakita natin na sa Anak ng Tao ang kaharian. Ngayon, natutunan natin na ibinabahagi Niya ito sa Kanyang bayan. Ang mga inapi ay maghahari kasama Niya.

Nababagabag pa rin si Daniel nang matapos ang pangitain. Okay lang iyon. Hindi natin kailangang maunawaan ang bawat detalye. Kailangan lang nating alalahanin kung sino ang may huling salita.$q$, $q$Itinuturo sa akin ng talatang ito na totoo ang pagsalungat laban sa bayan ng Diyos, pero pansamantala lamang ito. Malinaw na sinabi kay Daniel na mananaig ang mapagmataas na sungay laban sa mga banal sa loob ng isang panahon. Inaamin ko na kapag nakikita kong nagtatagumpay ang kasamaan, minsan ay naiisip ko kung nakalimutan na ba ng Diyos ang Kanyang bayan.

Pero dahil alam kong nilagyan ng Diyos ng hangganan ang panahon ng kasamaan, makapagtitiis ako nang may pag-asa. Magtitipon ang hukuman ng langit. Hahatulan ang bawat kawalang-katarungan. At ibibigay ang kaharian sa mga banal ng Kataas-taasan.

Namamangha ako na ibinabahagi ni Jesus, ang Anak ng Tao, ang Kanyang walang-hanggang kaharian sa mga karaniwang mananampalatayang tulad ko. Dahil dito, sisikapin kong huwag sumuko kapag mabigat ang kapalit ng pagsunod kay Cristo. Patuloy kong gagawin ang tama, kahit mukhang walang nakapapansin.

Naaaliw din ako na nabagabag si Daniel at hindi niya naunawaan ang lahat. Hindi ko kailangang malaman ang lahat ng sagot tungkol sa hinaharap. Kailangan ko lang magtiwala sa Isang may hawak nito.

Habang nagtatapos ang taong ito, papangalanan ko ang isang bahagi ng buhay ko kung saan pinanghinaan ako ng loob dahil sa pagsalungat, at ilalagay ko ito sa mga kamay ng Diyos, nagtitiwalang Siya ang magkakaroon ng huling salita.$q$, $q$Kataas-taasang Diyos, salamat po na hindi magtatagal magpakailanman ang kasamaan. Kapag nakikita ko ang kawalang-katarungan at pagsalungat laban sa Inyong bayan, tulungan po Ninyo akong alalahanin na Kayo ang naglagay ng hangganan nito. Bigyan po Ninyo ako ng pagtitiis para patuloy na gawin ang tama kahit mahirap. Salamat po sa kamangha-manghang pangako na makababahagi ang Inyong mga banal sa walang-hanggang kaharian ng Inyong Anak. Kapag hindi ko naiintindihan ang lahat tungkol sa hinaharap, tulungan po Ninyo akong magtiwala sa Inyo. Kayo po ang may huling salita sa buhay ko at sa buong lupa. Sa pangalan ni Jesus, amen.$q$, $q$Napakagandang linggo! Noong Lunes, sinuri ng mga kaaway ni Daniel ang kanyang buhay at wala silang natagpuang mali, kaya binitag nila siya sa pamamagitan ng kanyang pananampalataya. Noong Martes, nanalangin at nagpasalamat si Daniel "gaya ng ginagawa niya noon," kahit nangangahulugan ito ng yungib ng mga leon. Noong Miyerkoles, isinara ng Diyos ang bibig ng mga leon, at ipinahayag ng hari sa buong imperyo na ang Diyos ni Daniel ang buhay na Diyos. Noong bisperas ng Pasko, nakita ni Daniel ang apat na halimaw na umaahon mula sa nagngangalit na dagat. Noong araw ng Pasko, nagalak tayo habang dumating ang Anak ng Tao sa harap ng Matanda sa mga Araw at tinanggap ang isang walang-hanggang kaharian. At ngayong araw, natutunan natin na magngangalit ang kasamaan sa loob lang ng limitadong panahon, pero aangkinin ng mga banal ng Kataas-taasan ang kaharian magpakailanman.

Sa susunod na linggo, isasara natin ang taon sa loob ng apat na araw. Makakakita si Daniel ng isa pang pangitain, tungkol sa isang lalaking tupa at isang kambing, at tutulungan siya ng anghel na si Gabriel na maunawaan ito. Pagkatapos, sa huling dalawang araw ng taon, luluhod tayo kasama ni Daniel habang nananalangin siya ng isang taos-pusong panalangin ng pagtatapat, humihingi ng awa sa Diyos hindi dahil sa ating katuwiran, kundi dahil sa Kanyang dakilang habag. 🏁$q$),
  (DATE '2026-12-28', $q$Hanggang Kailan, Panginoon?$q$, $q$Labinsiyam na taong gulang ang anak ni Perla na si Jerome nang umalis siya ng bahay. Nagkaroon sila ng kakila-kilabot na pagtatalo ng kanyang tatay tungkol sa mga kaibigang sinasamahan niya at sa perang nawawala sa drawer. Ibinalibag ni Jerome ang pinto at hindi na bumalik.

Noong una, may mga naririnig na balita si Perla. May nakakita raw sa kanya sa lungsod. May nagsabing nagtatrabaho siya sa isang car wash. May nagsabing may problema siya. Pagkatapos, sa mahabang panahon, wala nang balita.

Gabi-gabi, iniiwang bukas ni Perla ang ilaw sa beranda. Sinasabi ng asawa niyang si Eliseo na sayang lang ito sa kuryente. Iniiwan pa rin niya itong bukas.

Tuwing Pasko, niluluto niya ang paborito ni Jerome, pork menudo na maraming patatas, at nagtatabi siya ng isang plato. Tuwing kaarawan nito, bumibili siya ng maliit na cake at isinusulat dito ang pangalan nito. Mahinahong sinasabi sa kanya ng mga kaibigan niya na mag-move on na. May mga gabing habang mag-isa siyang naghuhugas ng pinggan, ibinubulong niya, "Hanggang kailan? Hanggang kailan bago siya umuwi?"

Lumipas ang isang taon. Pagkatapos ay tatlo. Pagkatapos ay lima.

Sa ikaanim na taon, isang linggo bago ang Pasko, may kumatok sa pinto nang hatinggabi. Binuksan ito ni Eliseo.

Isang payat na binata ang nakatayo sa ilalim ng ilaw ng beranda, may hawak na plastik na supot. Mukha siyang mas matanda at pagod. Namumula ang kanyang mga mata.

"Pa," sabi ni Jerome. Pumiyok ang kanyang boses. "Isang taon na po akong malinis. May trabaho na po ako. Nakita ko lang po... nakita ko pong bukas pa rin ang ilaw."

Natigilan si Eliseo. Pagkatapos ay niyakap niya ang kanyang anak.

Tumatakbong dumating si Perla mula sa kusina, hawak pa ang sandok. Hindi niya sinabing "Saan ka nanggaling?" Hindi niya sinabing "Bakit hindi ka tumawag?"

Ang sinabi lang niya, "Anak, umupo ka. Mainit pa ang menudo."$q$, $q$Dumating ang pangitain ngayong araw ilang taon matapos ang nasa kabanata 7. Sa pagkakataong ito, nakakita si Daniel ng isang makapangyarihang lalaking tupa na may dalawang sungay na sumusugod sa bawat direksyon. "Walang hayop na makatatayo laban sa kanya" (t. 4). Pagkatapos ay dumating mula sa kanluran ang isang kambing na may isang malaking sungay, napakabilis na para bang hindi sumasayad sa lupa. Dinurog nito ang lalaking tupa at naging napakadakila. Pero "sa kasagsagan ng kanyang kapangyarihan, nabali ang kanyang malaking sungay," at apat na sungay ang tumubo sa lugar nito (t. 8).

Bukas, sasabihin sa atin ng anghel na si Gabriel na ang lalaking tupa ay ang Media at Persia at ang kambing ay ang Gresya. Ipinapakita ng kasaysayan kung gaano ito katumpak na natupad. Mabilis na sumugod pasilangan si Alexander the Great at sinakop ang Imperyong Persiano sa loob lang ng ilang taon. Pagkatapos ay bigla siyang namatay sa edad na mga tatlumpu't dalawa, at hinati ang kanyang kaharian sa apat sa kanyang mga heneral.

Mula sa isa sa mga bahaging iyon ay lumabas ang isang "maliit na sungay" na sumalakay sa bayan ng Diyos, nagpatigil sa araw-araw na paghahandog, at "ibinagsak sa lupa ang katotohanan" (t. 12). Kinikilala siya ng maraming guro ng Bibliya bilang si Antiochus IV, isang pinunong Griyego na lumapastangan sa templo sa Jerusalem mga 170 taon bago si Cristo. Larawan din ang kanyang mga ginawa ng huling kaaway ng bayan ng Diyos.

Pagkatapos ay narinig ni Daniel ang isang anghel na nagtanong ng tanong na itinatanong ng mga mananampalataya sa loob ng maraming siglo: "Hanggang kailan?" (t. 13). Hanggang kailan pahihintulutan ang kasamaan na yurakan ang banal?

Tiyak ang sagot: "2,300 gabi at umaga; pagkatapos ay maibabalik sa wastong kalagayan ang santuwaryo" (t. 14). May hangganang itinakda ng Diyos ang paghihirap. At gaya ng ipinangako, nilinis at naibalik ang templo kalaunan.

Hindi laging sinasabi sa atin ng Diyos kung hanggang kailan. Pero lagi Niyang alam, at laging dumarating ang Kanyang pagpapanumbalik.$q$, $q$Itinuturo sa akin ng talatang ito na nakikita ng Diyos ang pagbangon at pagbagsak ng bawat kapangyarihan at Siya ang naglalagay ng hangganan sa bawat panahon ng paghihirap. Mukhang hindi mapipigilan ang lalaking tupa hanggang dumating ang kambing. Mukhang hindi mapipigilan ang kambing hanggang nabali ang malaki nitong sungay. Inaamin ko na madalas ay labis akong humahanga sa anumang mukhang malakas ngayon, at labis akong natatakot sa anumang mukhang nananalo.

Naaaliw din ako na ang langit mismo ay nagtanong, "Hanggang kailan?" Sinasabi nito sa akin na hindi kakulangan ng pananampalataya ang itanong iyon sa Diyos. Mayroon din akong sariling mga panalanging "hanggang kailan": para sa mga mahal sa buhay na malayo sa Diyos, para sa paggaling, para sa mga sagot, at para sa pagbabago.

Dahil alam kong nagbigay ang Diyos ng tiyak na hangganan sa paghihirap sa pangitain ni Daniel, dapat akong magtiwala na may hangganan din ang aking paghihintay, kahit hindi ko ito nakikita. Darating ang pagpapanumbalik.

Dahil dito, sisikapin kong panatilihing "bukas ang ilaw sa beranda" sa aking mga panalangin. Hindi ako susuko sa pananalangin para sa mga tao at sitwasyong matagal ko nang pinapasan.

Habang nagtatapos ang taong ito, isusulat ko ang mga pangalan ng mga taong hinihintay ko sa Diyos, at mangangako akong patuloy silang ipapanalangin sa bagong taon.$q$, $q$Panginoon ng kasaysayan, itinataas N'yo po ang mga hari at ibinababa sila, at walang anuman ang nasa labas ng Inyong kontrol. Salamat po na may hangganang itinakda N'yo sa bawat panahon ng paghihirap. Alam po Ninyo kung gaano na ako katagal naghihintay at nananalangin. Bigyan po Ninyo ako ng lakas na huwag sumuko. Panatilihin po Ninyong nag-aalab ang aking pananampalataya tulad ng ilaw na iniwang bukas para sa mga mahal ko. Nagtitiwala po ako na sa Inyong perpektong panahon, ibabalik N'yo ang nasira. Salamat po sa pagiging tapat Ninyo kahit mahaba ang paghihintay. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-29', $q$Pagkatapos ay Bumangon Ako$q$, $q$Dalawampu't dalawang taon nang komadrona si Aurora sa maliit na birthing clinic sa kanilang barangay. Mahigit dalawang libong sanggol na ang natulungan niyang isilang. Kilala niya sa pangalan ang karamihan sa mga bata sa bayan, dahil siya ang unang humawak sa kanila.

Pero isang gabi noong Disyembre, may isang nawala sa kanya.

Biglang nagkaproblema ang panganganak. Ginawa ni Aurora ang lahat ng itinuro sa kanya. Tumawag siya ng ambulansya, sumama sa batang ina papunta sa ospital, at hinawakan ang kamay nito sa buong biyahe. Nagsikap nang husto ang mga doktor. Pero hindi nakaligtas ang sanggol.

Umuwi si Aurora nang madaling-araw at umupo sa mesa sa kusina nang hindi man lang binubuksan ang ilaw. Ipinagtimpla siya ng kape ng asawa niyang si Nicanor, pero hindi niya ito ininom. Paulit-ulit na binabalikan ng isip niya ang bawat minuto. May nakaligtaan ba siya? Bakit ito nangyari? Bakit sa mabait na batang inang iyon, na nakapili na ng pangalan?

Wala siyang sagot. Masama ang pakiramdam niya. Dalawang araw siyang hindi lumabas ng bahay.

Sa ikatlong umaga, tumunog ang kanyang telepono. Ang klinika iyon. Nanganganak ang isang babae mula sa kabilang kalye, at wala sa bayan ang isa pang komadrona.

Ilang sandaling nakaupo si Aurora, nakatingin sa telepono. Pagkatapos ay dahan-dahan siyang tumayo, naghilamos, at isinuot ang kanyang uniporme.

Makalipas ang tatlong oras, may hawak na siyang isang malusog at umiiyak nang malakas na sanggol na lalaki. Sabay na tumawa at umiyak ang ina.

Pag-uwi ni Aurora nang gabing iyon, nakita niyang naghihintay sa kanyang gate ang batang inang nawalan ng sanggol. Kumabog ang dibdib ni Aurora. Pero niyakap lang siya ng babae.

"Salamat po at hindi n'yo ako iniwan noong gabing iyon," bulong niya. "At salamat po sa pagbalik n'yo."$q$, $q$Habang sinisikap ni Daniel na maunawaan ang pangitain, may isang "may anyong tulad ng tao" na tumayo sa harap niya, at may tinig na tumawag, "Gabriel, ipaliwanag mo sa lalaking ito ang pangitain" (t. 16). Si Gabriel ang parehong anghel na magbabalita balang araw ng kapanganakan ni Juan Bautista at ni Jesus.

Labis na natakot si Daniel kaya nagpatirapa siya. Hinawakan siya ni Gabriel, tinulungang tumayo, at nagpaliwanag. Ang lalaking tupa ay "ang mga hari ng Media at Persia." Ang kambing ay "ang hari ng Gresya," at ang malaking sungay nito ay ang unang hari. Ang apat na sungay ay apat na kahariang darating pagkatapos niya (t. 20–22).

Pagkatapos ay inilarawan ni Gabriel ang "isang mapangahas na hari, bihasa sa pakana" (t. 23). Magiging makapangyarihan at mapanlinlang siya. Wawasakin niya ang marami at "tatayo pa laban sa Prinsipe ng mga prinsipe," ang Diyos mismo. "Gayunman, siya'y babaliin, ngunit hindi ng kamay ng tao" (t. 25). Muli, ang Diyos mismo ang haharap sa mapagmataas na pinuno, gaya ng batong "hindi tinapyas ng kamay ng tao" na tumama sa rebulto sa kabanata 2.

Pansinin ang naging reaksyon ni Daniel sa dulo. "Ako, si Daniel, ay napagod at ilang araw na nagkasakit. Pagkatapos ay bumangon ako at itinuloy ang gawain ng hari. Naguluhan ako sa pangitain; hindi ito maunawaan" (t. 27).

Kahit si Daniel, ang dakilang tagapagpaliwanag ng mga panaginip, ay hindi naunawaan ang lahat. Nanlumo siya at nagkasakit. Pero pagkatapos ay bumangon siya at bumalik sa trabaho.

Napakagandang larawan iyan ng pananampalataya. Hindi natin kailangang maunawaan ang lahat ng ginagawa ng Diyos para patuloy na maglingkod sa Kanya. Minsan, ang pananampalataya ay simpleng pagbangon at paggawa ng susunod na tapat na hakbang.$q$, $q$Itinuturo sa akin ng talatang ito na okay lang na hindi ko maunawaan ang lahat ng ginagawa ng Diyos. Isa si Daniel sa pinakamarunong na taong nabuhay kailanman, at kahit siya ay nagsabing ang pangitain ay "hindi maunawaan." Inaamin ko na madalas ay gusto ko munang may paliwanag bago ako handang sumulong. Gusto kong malaman kung bakit nangyari ang isang bagay bago ko ito ipagkatiwala sa Diyos.

Naaaliw ako na hinawakan ni Gabriel si Daniel at tinulungan itong tumayo. Dahil alam kong sinasalubong ako ng Diyos sa aking kahinaan at marahan Niya akong itinatayo, hindi ako dapat mahiya kapag nanlulumo ako.

Lubos din akong hinahamon ng mga salitang "Pagkatapos ay bumangon ako at itinuloy ang gawain ng hari." May mga pagkakataon ngayong taon na napabagsak ako ng kabiguan, kalituhan, o pagdadalamhati. Ang ilan sa mga tanong na iyon ay wala pa ring sagot. Pero kaya ko pa ring bumangon at gawin ang susunod na tapat na hakbang.

Dahil dito, sisikapin kong patuloy na maglingkod sa Diyos kahit hindi ko maunawaan ang Kanyang mga daan. Magtitiwala ako sa Kanyang pagkatao kahit hindi ko masundan ang Kanyang plano.

Habang nagtatapos ang taon, tutukuyin ko ang isang bahagi kung saan tumigil ako sa paglilingkod dahil nasaktan o naguluhan ako, at hihingi ako sa Diyos ng lakas na bumangon muli.$q$, $q$Panginoon, may mga bagay po sa buhay ko na hindi ko maunawaan. Ang ilan sa mga tanong ngayong taon ay wala pa ring sagot. Salamat po na hindi ko kailangang maunawaan ang lahat para magtiwala sa Inyo. Kapag nanlulumo ako, hawakan po Ninyo ako at itayo, gaya ng pagtatayo N'yo kay Daniel. Bigyan po Ninyo ako ng lakas na bumangon at gawin ang susunod na tapat na hakbang na itinawag N'yo sa akin. Tulungan po Ninyo akong magtiwala sa Inyong puso kahit hindi ko makita ang Inyong plano. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-30', $q$Nagkamali Kami$q$, $q$Hangga't natatandaan ni Benedicto, hindi nag-uusap ang kanyang pamilya at ang mga pinsan nila sa kabilang ibayo ng ilog. Sa mga reunion, magkahiwalay ang kanilang mesa. Nang mamatay ang Tito Pablo niya, tumanggi ang kanyang tatay na pumunta sa libing. Ang tanging sinabi sa kanya kailanman ay, "Dinaya nila tayo sa lupa."

Ngayon, animnapu't walong taong gulang na si Benedicto, isang retiradong mangingisda, at wala na ang kanyang mga magulang. Habang nililinis ang lumang baul na kahoy ng kanyang tatay, nakakita siya ng isang bungkos ng mga sulat na nakatali ng pisi.

Umupo siya sa sahig at isa-isang binasa ang mga ito. Habang nagbabasa, nagsimulang manginig ang kanyang mga kamay.

Iba ang kuwentong isinasalaysay ng mga sulat. Limampung taon na ang nakalipas, nangutang ang kanyang lolo sa tatay ni Tito Pablo para makabili ng bangka. Nang lumubog ang bangka sa isang bagyo, hindi kailanman nabayaran ng pamilya ni Benedicto ang utang. Sa halip, inilipat nila nang ilang metro ang mga batong-hangganan ng kanilang pinaghahatiang lupa sa gabi. Nang magreklamo ang pamilya ni Tito Pablo, inakusahan sila ng tatay ni Benedicto na nagsisinungaling.

Hindi pala ang mga pinsan ang nandaya. Ang sarili niyang pamilya pala.

Hindi nakatulog si Benedicto nang gabing iyon. Kinaumagahan, isinuot niya ang pinakamaganda niyang polo shirt, dinala ang mga sulat, at tumawid sa ilog.

Binuksan ng pinsan niyang si Rodrigo ang pinto, gulat at naghihinala. Hindi na nagtalumpati si Benedicto. Iniabot niya ang mga sulat sa nanginginig niyang mga kamay.

"Rodrigo," sabi niya, "nagkamali kami. Nagkamali ang lolo ko. Nagkamali ang tatay ko. Hindi ko alam, pero dapat ay nagtanong ako. Patawarin mo ako sa ginawa ng pamilya ko sa pamilya mo."

Matagal na nagbasa si Rodrigo. Pagkatapos ay tumingala siya nang basa ang mga mata at tumabi sa pintuan.

"Pasok ka, Pinsan," sabi niya. "Siguro gutom ka na."$q$, $q$Nagsisimula ang kabanata 9 sa isang simpleng ginagawa ni Daniel: binabasa niya ang kanyang Bibliya. Pinag-aaralan niya ang aklat ni Jeremias at natagpuan ang pangako ng Diyos na tatagal nang pitumpung taon ang pagkatiwangwang ng Jerusalem (Jeremias 25:11–12). Sa panahong ito, halos pitumpung taon na ang lumipas mula nang dalhin si Daniel sa Babilonia. Malapit nang matapos ang panahon!

Paano tumugon si Daniel? Hindi lang siya umupo at naghintay. "Ibinaling ko ang aking pansin sa Panginoong Diyos upang hanapin Siya sa panalangin at pagsusumamo, na may pag-aayuno, sako, at abo" (t. 3). Hindi ginawang tamad ng pangako ng Diyos si Daniel. Inudyukan siya nitong manalangin.

Pansinin kung paano nagsimula ang kanyang panalangin. Una, pinuri niya ang Diyos bilang "dakila at kahanga-hanga," ang Diyos na tumutupad sa Kanyang tipan ng pag-ibig (t. 4). Pagkatapos ay nagtapat siya: "Nagkasala kami at gumawa ng mali. Gumawa kami ng kasamaan at naghimagsik" (t. 5).

"Kami" ang sinabi ni Daniel. Isa siya sa pinakatapat na tao sa Bibliya. Wala saanman sa Kasulatan na nakatala ang isang kasalanan sa kanyang buhay. Pero hindi siya nagturo sa iba. Tumayo siya kasama ng kanyang bayan at ipinagtapat ang kanilang kasalanan na para bang sa kanya. Inamin niya na hindi sila nakinig sa mga propetang isinugo ng Diyos.

Pagkatapos ay pinaghambing niya ang Diyos at ang Kanyang bayan: "Sa Inyo, O Panginoon, ang katuwiran, ngunit sa araw na ito ay nababalot kami ng kahihiyan" (t. 7). Pero sa gitna ng lahat ng kahihiyang iyon, kumapit siya sa pag-asa: "Sa Panginoon nating Diyos ang habag at kapatawaran" (t. 9).

Ganito ang anyo ng tunay na pagtatapat. Tapat ito tungkol sa kasalanan, sapat ang kababaang-loob para sabihing "kami," at punô ng pag-asa sa awa ng Diyos. At madalas, nagsisimula ito sa simpleng pagbubukas ng Salita ng Diyos.$q$, $q$Itinuturo sa akin ng talatang ito na ang pagbabasa ng Salita ng Diyos ay dapat umakay sa akin sa panalangin. Nagbasa si Daniel ng isang pangako at agad siyang bumaling sa Diyos nang buong puso. Inaamin ko na madalas kong binabasa ang Bibliya na parang ibang libro lang. Nag-iipon ako ng impormasyon pero hindi ko hinahayaang udyukan ako nitong manalangin, magtapat, o kumilos.

Hinahamon din ako ng paraan ng pagsasabi ni Daniel ng "kami." Madali para sa akin na ituro ang mga kasalanan ng aking pamilya, simbahan, o bansa, na para bang wala akong kinalaman sa mga iyon. Si Daniel, kahit tapat, ay mapagpakumbabang tumayo kasama ng kanyang bayan at ipinagtapat ang kanilang mga kasalanan na para bang sa kanya. Dapat kong hilingin sa Panginoon na bigyan ako ng parehong kababaang-loob.

Dahil alam kong sa Diyos ang katuwiran at kailangan ko ang Kanyang awa gaya ng sinuman, sisikapin kong tumigil sa paninisi at magsimulang magtapat. Kung saan nakagawa ng mali sa iba ang aking pamilya o komunidad, puwedeng ako ang magsabing, "Nagkamali kami," at magsikap na ayusin ang mga bagay.

Dahil sa Diyos ang habag at kapatawaran, hindi ko kailangang matakot sa pagtatapat. Habang nagtatapos ang taong ito, maglalaan ako ng oras ngayong araw para basahin nang dahan-dahan ang Salita ng Diyos at hayaan itong umakay sa akin sa tapat na panalangin tungkol sa sarili kong buhay.$q$, $q$Dakila at kahanga-hangang Diyos, tinutupad po Ninyo ang Inyong tipan ng pag-ibig sa mga nagmamahal sa Inyo. Inaamin ko po na ako'y nagkasala at gumawa ng mali. Hindi po ako laging nakinig sa Inyong Salita. Patawarin po Ninyo ako sa mga pagkakataong sinisi ko ang iba sa halip na mapagpakumbabang magtapat. Bigyan po Ninyo ako ng puso ni Daniel, para tumayo kasama ng aking pamilya, simbahan, at bansa sa tapat na panalangin. Salamat po na sa Inyo ang habag at kapatawaran. Nawa'y udyukan ako ng Inyong Salita na manalangin at magbago. Sa pangalan ni Jesus, amen.$q$, NULL),
  (DATE '2026-12-31', $q$Hindi Dahil Karapat-dapat Kami$q$, $q$Mahirap na taon ito para kay Dominic at sa asawa niyang si Leah. Helper ng karpintero si Dominic, at nang malugi ang construction company na pinagtatrabahuhan niya noong Marso, nawalan siya ng trabaho. Nagtitinda ng kakanin si Leah mula sa maliit nilang inuupahang kuwarto, pero hindi ito sapat. Pagsapit ng Disyembre, pitong buwan na silang hindi nakababayad ng upa.

Ang kanilang kasera, si Lola Concepcion, ay isang tahimik na biyudang nakatira sa ground floor. Hindi siya kailanman sumigaw o nagbanta. Buwan-buwan, kapag bumababa si Dominic para sabihing hindi sila makababayad, may isinusulat lang siya sa isang maliit na berdeng kuwaderno at sinasabing, "Naiintindihan ko."

Noong umaga ng Disyembre 31, bumaba si Dominic nang mabigat ang loob. Ilang beses na niyang kinuwenta. Kahit makahanap siya ng tuloy-tuloy na trabaho sa Enero, aabutin ng ilang taon bago niya ito mabayaran. Nagpasya na siyang sabihing aalis na sila.

"Lola," panimula niya, "pasensya na po talaga. Hindi pa po kami nakababayad mula Hunyo. Hindi po kami karapat-dapat na manatili. Aalis na po kami pagkatapos ng Bagong Taon."

Matagal siyang tinitigan ni Lola Concepcion. Pagkatapos ay inilabas niya ang berdeng kuwaderno at binuksan sa isang pahinang punô ng mga numero. Nakilala ni Dominic ang sarili niyang pangalan sa itaas.

Dahan-dahan niyang pinunit ang pahina. Pagkatapos ay hinati niya ito sa dalawa, at hinati ulit.

"Lola, hindi ko po maintindihan. Bakit po?"

"Hindi dahil karapat-dapat kayo," sabi niya nang may maliit na ngiti. "Noong buhay pa ang asawa ko, minsan na rin kaming nasa kalagayan ninyo. May nagpatawad sa amin. Hindi ko iyon kailanman nakalimutan."

Hindi makapagsalita si Dominic. Umakyat siya, kung saan nagluluto si Leah. Tiningnan nito ang kanyang mukha at nabitawan ang sandok.

Nang gabing iyon, habang pinaliliwanag ng mga paputok ang langit, magkahawak-kamay silang nakatayo sa maliit nilang balkonahe. Sa unang pagkakataon sa buong taon, hindi sila natatakot sa bukas.$q$, $q$Ipinagpatuloy ni Daniel ang kanyang panalangin nang may malalim na katapatan. Hindi aksidente ang pagkatapon ng Israel. "Ang buong Israel ay lumabag sa Inyong kautusan" (t. 11). Ang sakunang dumating sa Jerusalem ay eksaktong ibinabala ng Diyos sa Kautusan ni Moises. "Ang PANGINOON nating Diyos ay matuwid sa lahat ng Kanyang ginagawa; gayunma'y hindi namin sinunod ang Kanyang tinig" (t. 14).

Walang idinadahilan si Daniel. Hindi niya sinasabing hindi patas ang Diyos. Hindi niya sinisisi ang Babilonia. Inaamin niyang makatarungan ang hatol ng Diyos.

Pero pagkatapos ay nagbago ang takbo ng panalangin. Inalala ni Daniel kung sino ang Diyos: ang Diyos "na naglabas sa Inyong bayan mula sa lupain ng Egipto sa pamamagitan ng makapangyarihang kamay" (t. 15). Ang Diyos na nagligtas noon ay kayang magligtas muli.

Pagkatapos ay dumating ang puso ng panalangin: "Hindi namin iniharap sa Inyo ang aming mga pagsusumamo dahil sa aming matuwid na mga gawa, kundi dahil sa Inyong dakilang habag" (t. 18).

Iyan ang tanging batayan para makalapit ang sinuman sa Diyos. Hindi ang ating mabubuting gawa, ang ating pagsisimba, o ang ating relihiyosong rekord. Ang Kanyang awa lamang.

Pansinin din kung ano ang pinakamahalaga kay Daniel. Paulit-ulit niyang sinasabi, "alang-alang sa Inyo," "Inyong lungsod," "Inyong bayan," "Inyong pangalan." Ang pinakamalaking malasakit ni Daniel ay ang kaluwalhatian ng Diyos.

At pagkatapos ay nagtapos ang panalangin sa isang masidhing pagsamo: "O Panginoon, makinig Kayo! O Panginoon, magpatawad Kayo! O Panginoon, dinggin at kumilos Kayo!" (t. 19).

Sa huling araw ng taon, ito ang perpektong panalangin para sa atin. Lumilingon tayo at nakikita kung saan tayo nabigo. Pero hindi tayo lumalapit sa Diyos batay sa ating nagawa ngayong taon. Lumalapit tayo dahil sa Kanyang dakilang habag, na pinakamalinaw nating nakikita kay Jesus. At hinihiling natin sa Kanya na makinig, magpatawad, at kumilos sa darating na taon.$q$, $q$Itinuturo sa akin ng talatang ito na hindi ako kailanman makalalapit sa Diyos batay sa sarili kong kabutihan. Habang lumilingon ako sa taong ito, nakikita ko ang maraming paraan kung paano ako nabigo: mga salitang hindi ko dapat sinabi, mga pagkakataong sinayang ko, at mga panahong hindi ko sinunod ang tinig ng Diyos. Tulad ni Daniel, kailangan kong aminin na matuwid ang Panginoon sa lahat ng Kanyang ginagawa, at ako ang nagkulang.

Pero hindi ko kailangang tapusin ang taon sa kahihiyan. Dahil alam kong dinidinig ako ng Diyos "dahil sa Kanyang dakilang habag," dapat akong lumapit sa Kanya nang may pagtitiwala, hindi dahil karapat-dapat ako sa Kanyang tulong, kundi dahil Siya ay maawain. Binuksan na ni Jesus ang daan.

Hinahamon din ako ng malasakit ni Daniel sa pangalan ng Diyos. Inaamin ko na madalas ay tungkol lang sa mga pangangailangan ko ang aking mga panalangin. Dahil ang kaluwalhatian ng Diyos ang pinakamahalaga, sisikapin kong manalangin sa bagong taon nang "alang-alang sa Inyo," hinihiling sa Diyos na kumilos sa mga paraang nagbibigay-karangalan sa Kanyang pangalan.

Ngayong gabi, habang nagtatapos ang taong ito, maglalaan ako ng oras para pasalamatan ang Diyos sa Kanyang awa sa nakalipas na labindalawang buwan. Pagkatapos ay gagawin kong sarili kong panalangin ang panalangin ni Daniel para sa bagong taon: O Panginoon, makinig Kayo! O Panginoon, magpatawad Kayo! O Panginoon, dinggin at kumilos Kayo!$q$, $q$O Panginoon, matuwid po Kayo sa lahat ng Inyong ginagawa, at hindi ko po laging sinunod ang Inyong tinig. Habang nagtatapos ang taong ito, lumalapit po ako sa Inyo hindi dahil sa aking mabubuting gawa, kundi dahil sa Inyong dakilang habag. Salamat po kay Jesus, na sa pamamagitan Niya ay makalalapit ako sa Inyo nang may pagtitiwala. Patawarin po Ninyo ako sa aking mga pagkabigo ngayong taon. Salamat po sa bawat awang ipinakita N'yo sa akin. Sa darating na taon, kumilos po Kayo sa aking buhay, pamilya, simbahan, at bansa alang-alang sa Inyong pangalan. O Panginoon, makinig Kayo! O Panginoon, magpatawad Kayo! O Panginoon, dinggin at kumilos Kayo! Sa pangalan ni Jesus, amen.$q$, NULL)
  ) AS v(entry_date, title_tl, story_tl, explanation_tl, response_tl, prayer_tl, weekly_summary_tl)
 WHERE d.entry_date = v.entry_date
   AND d.church_id = (SELECT id FROM public.churches WHERE slug = 'rosehill')
   AND (d.tl_status IS NULL OR d.tl_status = 'draft');

-- (3) Ledger stamp
INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('130', '130_devo_2026_12_daniel_bilingual.sql',
        'S115 Dec 2026 Daniel guide for Rosehill: English (insert if missing) + Tagalog draft')
ON CONFLICT (version) DO UPDATE
  SET filename = EXCLUDED.filename, note = EXCLUDED.note, applied_at = now();

-- (4) Self-verify (every row should read PASS)
SELECT 'December days for Rosehill (expect 27)' AS checkpoint,
       CASE WHEN (SELECT count(*) FROM public.devotionals
                   WHERE church_id = (SELECT id FROM public.churches WHERE slug='rosehill')
                     AND entry_date BETWEEN DATE '2026-12-01' AND DATE '2026-12-31') = 27
            THEN 'PASS' ELSE 'FAIL' END AS status
UNION ALL
SELECT 'every December day has Tagalog (draft or reviewed)',
       CASE WHEN NOT EXISTS (SELECT 1 FROM public.devotionals
                   WHERE church_id = (SELECT id FROM public.churches WHERE slug='rosehill')
                     AND entry_date BETWEEN DATE '2026-12-01' AND DATE '2026-12-31'
                     AND (title_tl IS NULL OR story_tl IS NULL OR prayer_tl IS NULL))
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'no Sunday entries',
       CASE WHEN NOT EXISTS (SELECT 1 FROM public.devotionals
                   WHERE church_id = (SELECT id FROM public.churches WHERE slug='rosehill')
                     AND entry_date BETWEEN DATE '2026-12-01' AND DATE '2026-12-31'
                     AND extract(dow FROM entry_date) = 0)
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'ledger 130',
       CASE WHEN EXISTS (SELECT 1 FROM public.schema_migrations WHERE version = '130') THEN 'PASS' ELSE 'FAIL' END;
